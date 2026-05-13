import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uzxarid/core/cubit/app_mode_cubit.dart';
import 'package:uzxarid/core/dio/dio_client.dart';
import 'package:uzxarid/core/dp/infection.dart';
import 'package:uzxarid/core/constants/app_colors.dart';
import 'package:uzxarid/core/theme/theme_colors.dart';
import 'package:uzxarid/core/widgets/app_text.dart';
import 'package:uzxarid/core/widgets/w__container.dart';

class DocumentDetailPage extends StatefulWidget {
  const DocumentDetailPage({super.key, required this.documentId});

  final int documentId;

  @override
  State<DocumentDetailPage> createState() => _DocumentDetailPageState();
}

class _DocumentDetailPageState extends State<DocumentDetailPage> {
  final Dio _dio = getIt<DioClient>().dio;

  bool _isLoading = true;
  String? _errorMessage;
  DocumentDetail? _detail;

  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _dio.get<dynamic>('document/${widget.documentId}/');
      final raw = response.data;

      if (raw is Map<String, dynamic>) {
        setState(() {
          _detail = DocumentDetail.fromJson(raw);
          _isLoading = false;
        });
        return;
      }

      if (raw is Map) {
        setState(() {
          _detail = DocumentDetail.fromJson(raw.cast<String, dynamic>());
          _isLoading = false;
        });
        return;
      }

      throw Exception('Document detail noto‘g‘ri formatda keldi.');
    } catch (e) {
      setState(() {
        _errorMessage = 'Tafsilot yuklanmadi: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Directory _contractsDir() {
    return Directory('${Directory.systemTemp.path}/uzxarid_contracts');
  }

  File _cachedPdfFile(int documentId) {
    final dir = _contractsDir();
    return File('${dir.path}/$documentId.pdf');
  }

  bool _isReadyForDownload(String? status) {
    return status == 'generated' ||
        status == 'sent' ||
        status == 'signed';
  }

  Future<Map<String, dynamic>> _fetchDocumentDetail(int documentId) async {
    final response = await _dio.get<dynamic>('document/$documentId/');
    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }
    if (response.data is Map) {
      return (response.data as Map).cast<String, dynamic>();
    }
    throw Exception('Document detail noto‘g‘ri formatda keldi.');
  }

  Future<void> _waitUntilReady(int documentId) async {
    const maxAttempts = 30;
    const interval = Duration(seconds: 2);

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      final detailJson = await _fetchDocumentDetail(documentId);
      final status = detailJson['status']?.toString();

      if (_isReadyForDownload(status)) return;
      if (status == 'cancelled') {
        throw Exception('Hujjat bekor qilingan.');
      }

      await Future.delayed(interval);
    }

    throw TimeoutException('Hujjat tayyor bo‘lish vaqti tugadi.');
  }

  Future<Uint8List> _downloadPdfBytes(int documentId) async {
    final response = await _dio.get<List<int>>(
      'document/$documentId/download/',
      options: Options(responseType: ResponseType.bytes),
    );

    final data = response.data;
    if (data == null) throw Exception('PDF yuklab olinmadi.');
    return Uint8List.fromList(data);
  }

  Future<void> _ensureDownloaded(int documentId) async {
    final cached = _cachedPdfFile(documentId);
    if (await cached.exists()) return;

    final detailJson = await _fetchDocumentDetail(documentId);
    final status = detailJson['status']?.toString();

    if (!_isReadyForDownload(status)) {
      await _dio.post('document/$documentId/generate/');
      await _waitUntilReady(documentId);
    }

    final bytes = await _downloadPdfBytes(documentId);

    final dir = _contractsDir();
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    await cached.writeAsBytes(bytes, flush: true);
  }

  Future<void> _onDownloadPressed() async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    try {
      await _ensureDownloaded(widget.documentId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yuklab olindi (offline uchun saqlandi).')),
      );

      // Status yangilansin
      await _loadDetail();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download xatolik: ${e.toString()}'),
          backgroundColor: AppColors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _onOpenPressed() async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    try {
      await _ensureDownloaded(widget.documentId);
      final file = _cachedPdfFile(widget.documentId);
      final uri = Uri.file(file.path);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ochish xatolik: ${e.toString()}'),
          backgroundColor: AppColors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _onSharePressed() async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    try {
      await _ensureDownloaded(widget.documentId);
      final file = _cachedPdfFile(widget.documentId);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Shartnoma #${widget.documentId}',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Share xatolik: ${e.toString()}'),
          backgroundColor: AppColors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!context.mounted) return const SizedBox.shrink();
    final primaryColor = context.watch<AppModeCubit>().state.primaryColor;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: context.cardSurface,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: const Icon(Icons.arrow_back_ios_new),
        ),
        title: AppText(
          text: 'Hujjat tafsiloti',
          fontWeight: 700,
          color: context.textPrimary,
        ),
      ),
      body: Container(
        color: context.bodyBackground,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.red),
                        ),
                      )
                    : _detail == null
                        ? const Center(child: Text('Hujjat topilmadi.'))
                        : _DocumentDetailBody(
                            detail: _detail!,
                            isBusy: _isBusy,
                            primaryColor: primaryColor,
                            onDownload: () {
                              _onDownloadPressed();
                            },
                            onShare: () {
                              _onSharePressed();
                            },
                            onOpen: () {
                              _onOpenPressed();
                            },
                          ),
          ),
        ),
      ),
    );
  }
}

class _DocumentDetailBody extends StatelessWidget {
  const _DocumentDetailBody({
    required this.detail,
    required this.isBusy,
    required this.primaryColor,
    required this.onDownload,
    required this.onShare,
    required this.onOpen,
  });

  final DocumentDetail detail;
  final bool isBusy;
  final Color primaryColor;
  final VoidCallback onDownload;
  final VoidCallback onShare;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.cardSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${detail.typeLabel} #${detail.id}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: context.textPrimary,
                          ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      detail.status ?? '—',
                      style:
                          Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (detail.dateLabel != null) ...[
                Text(
                  detail.dateLabel!,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: context.textSecondary),
                ),
                const SizedBox(height: 8),
              ],
              Text(
                '${detail.sellerName ?? '—'} → ${detail.buyerName ?? '—'}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 16),
              Divider(height: 1, color: context.borderColor),
              const SizedBox(height: 16),
              Text(
                'Actions',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: context.textPrimary,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ContainerW(
                      radius: 12,
                      height: 48,
                      color: primaryColor,
                      onTap: onDownload,
                      child: Center(
                        child: isBusy
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : AppText(
                                text: 'Download',
                                fontSize: 15,
                                fontWeight: 700,
                                color: context.textWhite,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ContainerW(
                      radius: 12,
                      height: 48,
                      color: context.cardSurface,
                      borderColor: context.borderColor,
                      onTap: onShare,
                      child: Center(
                        child: AppText(
                          text: 'Share',
                          fontSize: 15,
                          fontWeight: 700,
                          color: context.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ContainerW(
                      radius: 12,
                      height: 48,
                      color: context.cardSurface,
                      borderColor: context.borderColor,
                      onTap: onOpen,
                      child: Center(
                        child: AppText(
                          text: 'Open in...',
                          fontSize: 15,
                          fontWeight: 700,
                          color: context.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Agar hujjat tayyor bo‘lmasa, app statusni kutadi.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DocumentDetail {
  DocumentDetail({
    required this.id,
    required this.type,
    required this.status,
    this.createdAtRaw,
    this.sellerName,
    this.buyerName,
  });

  final int id;
  final String type;
  final String? status;
  final String? createdAtRaw;
  final String? sellerName;
  final String? buyerName;

  factory DocumentDetail.fromJson(Map<String, dynamic> json) {
    final id = _toInt(json['id'] ?? json['document_id'] ?? json['pk']);
    final typeRaw = (json['type'] ?? json['document_type'] ?? '').toString();
    final createdAtRaw =
        (json['created_at'] ?? json['createdAt'] ?? json['date'])?.toString();
    final status = (json['status'] ?? json['state'])?.toString();

    final seller = json['seller'] ?? json['counterparty_seller'];
    final buyer = json['buyer'] ?? json['counterparty_buyer'];

    return DocumentDetail(
      id: id,
      type: typeRaw,
      status: status,
      createdAtRaw: createdAtRaw,
      sellerName: _formatName(seller),
      buyerName: _formatName(buyer),
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  static String? _formatName(dynamic obj) {
    if (obj == null) return null;
    if (obj is String) return obj;
    if (obj is Map) {
      final first = obj['first_name'] ?? obj['firstName'] ?? obj['given_name'];
      final last = obj['last_name'] ?? obj['lastName'] ?? obj['family_name'];
      final username = obj['username'] ?? obj['name'] ?? obj['full_name'];

      final firstStr = first?.toString() ?? '';
      final lastStr = last?.toString() ?? '';
      final nameFromParts = ('$firstStr $lastStr').trim();
      if (nameFromParts.isNotEmpty) return nameFromParts;
      return username?.toString();
    }
    return obj.toString();
  }

  String get typeLabel {
    final t = type.toLowerCase();
    if (t.contains('reconciliation')) return 'Hisob-kitob akti';
    if (t.contains('invoice')) return 'Hisob-faktura';
    if (t.contains('contract')) return 'Shartnoma';
    if (t.isEmpty) return 'Hujjat';
    return type;
  }

  String? get dateLabel {
    final raw = createdAtRaw;
    if (raw == null || raw.isEmpty) return null;
    return raw.split('T').first;
  }
}

