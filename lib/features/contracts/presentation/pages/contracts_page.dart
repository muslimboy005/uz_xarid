import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uz_xarid/core/dio/dio_client.dart';
import 'package:uz_xarid/core/cubit/app_mode_cubit.dart';
import 'package:uz_xarid/core/dp/infection.dart';
import 'package:uz_xarid/core/widgets/app_text.dart';
import 'package:uz_xarid/core/widgets/uzxarid_app_bar.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/theme/theme_colors.dart';
import 'package:uz_xarid/core/widgets/w__container.dart';

class ContractsPage extends StatefulWidget {
  const ContractsPage({super.key});

  @override
  State<ContractsPage> createState() => _ContractsPageState();
}

class _ContractsPageState extends State<ContractsPage> {
  final Dio _dio = getIt<DioClient>().dio;

  bool _isLoading = true;
  String? _errorMessage;
  final List<DocumentItem> _documents = [];

  /// Har bir id bo‘yicha hozir download/generate bo‘layaptimi.
  final Set<int> _downloadingIds = {};

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _dio.get<dynamic>('document/');
      final results = _extractResults(response.data);
      final docs = <DocumentItem>[];
      for (final item in results) {
        if (item is Map<String, dynamic>) {
          docs.add(DocumentItem.fromJson(item));
        } else if (item is Map) {
          docs.add(DocumentItem.fromJson(item.cast<String, dynamic>()));
        }
      }

      setState(() {
        _documents
          ..clear()
          ..addAll(docs);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Hujjatlar yuklanmadi. ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  List<dynamic> _extractResults(dynamic raw) {
    if (raw == null) return const [];

    if (raw is List) return raw;

    if (raw is Map) {
      final results = raw['results'];
      if (results is List) return results;

      final data = raw['data'];
      if (data is Map) {
        final dataResults = data['results'];
        if (dataResults is List) return dataResults;
        final dataList = data['documents'];
        if (dataList is List) return dataList;
      }

      final documents = raw['documents'];
      if (documents is List) return documents;
    }

    return const [];
  }

  Directory _contractsDir() {
    // Offline bo‘lishi uchun app ichidagi vaqtinchalik katalogga saqlaymiz.
    // (systemTemp ba'zan OS tomonidan tozalanishi mumkin, ammo real caching uchun ishlaydi.)
    return Directory('${Directory.systemTemp.path}/uz_xarid_contracts');
  }

  File _cachedPdfFile(int documentId) {
    final dir = _contractsDir();
    final safeId = documentId.toString();
    return File('${dir.path}/$safeId.pdf');
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
    final exists = await cached.exists();
    if (exists) return;

    // Statusni tekshirib, agar tayyor bo‘lmasa generate qilamiz.
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

  Future<void> _onDownloadPressed(DocumentItem doc) async {
    if (_downloadingIds.contains(doc.id)) return;

    setState(() => _downloadingIds.add(doc.id));
    try {
      await _ensureDownloaded(doc.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yuklab olindi (offline uchun saqlandi).'),
        ),
      );

      // Statusni listda yangilaymiz (mutatsiya qilmaymiz, itemni almashtiramiz).
      final updatedJson = await _fetchDocumentDetail(doc.id);
      final updatedItem = DocumentItem.fromJson(updatedJson);
      final idx = _documents.indexWhere((d) => d.id == doc.id);
      if (idx != -1 && mounted) {
        setState(() => _documents[idx] = updatedItem);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download xatolik: ${e.toString()}'),
          backgroundColor: AppColors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _downloadingIds.remove(doc.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!context.mounted) return const SizedBox.shrink();

    final bodyBg = context.bodyBackground;
    final cardColor = context.cardSurface;

    return Scaffold(
      appBar: UzXaridAppBar(
        onSearchChanged: (query) {},
        onMenuTap: () {},
      ),
      body: Container(
        color: bodyBg,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: ContainerW(
                        color: cardColor,
                        radius: 8,
                        onTap: () => context.pop(),
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(Icons.arrow_back_ios_new, size: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    AppText(
                      text: 'Shartnomalar',
                      fontSize: 22,
                      fontWeight: 700,
                      color: context.textPrimary,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _errorMessage != null && _documents.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _errorMessage!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(color: AppColors.red),
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: _loadDocuments,
                                      child: const Text('Qayta urinish'),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadDocuments,
                              child: ListView.separated(
                                padding: EdgeInsets.zero,
                                itemCount: _documents.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final doc = _documents[index];

                                  final primaryColor = context
                                      .watch<AppModeCubit>()
                                      .state
                                      .primaryColor;

                                  final isDownloading =
                                      _downloadingIds.contains(doc.id);

                                  return Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: bodyBg,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: context.borderColor,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '${doc.typeLabel} #${doc.id}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall
                                                    ?.copyWith(
                                                      fontWeight: FontWeight.w700,
                                                      color: context.textPrimary,
                                                    ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: primaryColor.withValues(
                                                    alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                doc.status ?? '—',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color: primaryColor,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '${doc.sellerName ?? '—'} → ${doc.buyerName ?? '—'}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: context.textSecondary,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          doc.dateLabel ?? '',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: context.textSecondary,
                                              ),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ContainerW(
                                                radius: 10,
                                                height: 42,
                                                color: cardColor,
                                                borderColor:
                                                    context.borderColor,
                                                onTap: () {
                                                  context.push(
                                                    '/profile/contracts/${doc.id}',
                                                  );
                                                },
                                                child: const Center(
                                                  child: Text(
                                                    'View',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: ContainerW(
                                                radius: 10,
                                                height: 42,
                                                color: primaryColor,
                                                onTap: () {
                                                  _onDownloadPressed(doc);
                                                },
                                                child: Center(
                                                  child: isDownloading
                                                      ? const SizedBox(
                                                          width: 22,
                                                          height: 22,
                                                          child:
                                                              CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            color: Colors.white,
                                                          ),
                                                        )
                                                      : AppText(
                                                          text: 'Download',
                                                          fontSize: 14,
                                                          fontWeight: 700,
                                                          color:
                                                              context.textWhite,
                                                        ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DocumentItem {
  DocumentItem({
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

  factory DocumentItem.fromJson(Map<String, dynamic> json) {
    final id = _toInt(json['id'] ?? json['document_id'] ?? json['pk']);
    final typeRaw = (json['type'] ?? json['document_type'] ?? '').toString();

    final createdAtRaw =
        (json['created_at'] ?? json['createdAt'] ?? json['date'])?.toString();

    final status = (json['status'] ?? json['state'])?.toString();

    final seller = json['seller'] ?? json['counterparty_seller'];
    final buyer = json['buyer'] ?? json['counterparty_buyer'];

    return DocumentItem(
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
    // fallback: type qay darajada kelgan bo‘lsa shuni ko‘rsatamiz
    return type;
  }

  String? get dateLabel {
    final raw = createdAtRaw;
    if (raw == null || raw.isEmpty) return null;
    return raw.split('T').first;
  }
}

