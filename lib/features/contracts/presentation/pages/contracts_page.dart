import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uzxarid/core/dio/dio_client.dart';
import 'package:uzxarid/core/cubit/app_mode_cubit.dart';
import 'package:uzxarid/core/dp/infection.dart';
import 'package:uzxarid/core/widgets/app_text.dart';
import 'package:uzxarid/core/widgets/uzxarid_app_bar.dart';
import 'package:uzxarid/core/constants/app_colors.dart';
import 'package:uzxarid/core/theme/theme_colors.dart';
import 'package:uzxarid/core/widgets/w__container.dart';

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
    return Directory('${Directory.systemTemp.path}/uzxarid_contracts');
  }

  File _cachedPdfFile(int documentId) {
    final dir = _contractsDir();
    final safeId = documentId.toString();
    return File('${dir.path}/$safeId.pdf');
  }

  /// PDF mavjudligini status emas, `file`/`file_url` borligi belgilaydi.
  /// Backend `status: "pending"` ("Imzoga tayyor") holatida ham fayl tayyor
  /// bo'lishi mumkin — shuning uchun statusga emas, file_url'ga qaraymiz.
  String? _extractFileUrl(Map<String, dynamic> detail) {
    final raw = detail['file_url'] ?? detail['file'] ?? detail['signed_file'];
    final url = raw?.toString();
    if (url == null || url.isEmpty) return null;
    return url;
  }

  Future<Map<String, dynamic>> _fetchDocumentDetail(int documentId) async {
    final response = await _dio.get<dynamic>('document/$documentId/');
    final raw = response.data;
    Map<String, dynamic>? envelope;
    if (raw is Map<String, dynamic>) {
      envelope = raw;
    } else if (raw is Map) {
      envelope = raw.cast<String, dynamic>();
    }
    if (envelope == null) {
      throw Exception('Document detail noto‘g‘ri formatda keldi.');
    }

    final data = envelope['data'];
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return data.cast<String, dynamic>();
    return envelope;
  }

  Future<void> _waitUntilFileReady(int documentId) async {
    const maxAttempts = 30;
    const interval = Duration(seconds: 2);

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      final detailJson = await _fetchDocumentDetail(documentId);
      final fileUrl = _extractFileUrl(detailJson);
      final status = detailJson['status']?.toString();

      if (fileUrl != null) return;
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

    // file_url bo'lmasa generate qilamiz va polling boshlaymiz.
    // Backend `status: "pending"` bilan ham file_url'ni qaytarishi mumkin,
    // shuning uchun statusga emas, file_url'ga qaraymiz.
    final detailJson = await _fetchDocumentDetail(documentId);
    if (_extractFileUrl(detailJson) == null) {
      await _dio.post('document/$documentId/generate/');
      await _waitUntilFileReady(documentId);
    }

    final bytes = await _downloadPdfBytes(documentId);

    final dir = _contractsDir();
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    await cached.writeAsBytes(bytes, flush: true);
  }

  Future<void> _onViewPressed(DocumentItem doc) async {
    var fileUrl = doc.fileUrl;

    // List javobida file_url ko'pincha bor, lekin pending yangi doc uchun
    // bo'lmasligi mumkin — bunda detail GET va generate qilamiz.
    if (fileUrl == null) {
      if (_downloadingIds.contains(doc.id)) return;
      setState(() => _downloadingIds.add(doc.id));
      try {
        final detailJson = await _fetchDocumentDetail(doc.id);
        fileUrl = _extractFileUrl(detailJson);
        if (fileUrl == null) {
          await _dio.post('document/${doc.id}/generate/');
          await _waitUntilFileReady(doc.id);
          fileUrl = _extractFileUrl(await _fetchDocumentDetail(doc.id));
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ko‘rish xatolik: ${e.toString()}'),
            backgroundColor: AppColors.red,
          ),
        );
        return;
      } finally {
        if (mounted) setState(() => _downloadingIds.remove(doc.id));
      }
    }

    if (fileUrl == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fayl tayyorlanmadi.')),
      );
      return;
    }

    try {
      final uri = Uri.parse(fileUrl);
      final opened = await launchUrl(uri, mode: LaunchMode.inAppWebView);
      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Faylni ochib bo‘lmadi.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ko‘rish xatolik: ${e.toString()}'),
          backgroundColor: AppColors.red,
        ),
      );
    }
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
                                  final isBusy =
                                      _downloadingIds.contains(doc.id);

                                  return _DocumentCard(
                                    doc: doc,
                                    isBusy: isBusy,
                                    primaryColor: primaryColor,
                                    onView: () => _onViewPressed(doc),
                                    onDownload: () => _onDownloadPressed(doc),
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

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({
    required this.doc,
    required this.isBusy,
    required this.primaryColor,
    required this.onView,
    required this.onDownload,
  });

  final DocumentItem doc;
  final bool isBusy;
  final Color primaryColor;
  final VoidCallback onView;
  final VoidCallback onDownload;

  static IconData _typeIcon(String type) {
    final t = type.toLowerCase();
    if (t.contains('invoice')) return Icons.receipt_long_outlined;
    if (t.contains('reconciliation')) return Icons.fact_check_outlined;
    if (t.contains('contract')) return Icons.description_outlined;
    return Icons.insert_drive_file_outlined;
  }

  /// Status uchun semantik rang. `status_display` matni o'zgarmaydi, faqat rang.
  static Color _statusColor(String? status, Color fallback) {
    switch (status) {
      case 'signed':
        return const Color(0xFF16A34A);
      case 'cancelled':
        return const Color(0xFFDC2626);
      case 'pending':
        return const Color(0xFFD97706);
      default:
        return fallback;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textPrimary = context.textPrimary;
    final textSecondary = context.textSecondary;
    final borderColor = context.borderColor;
    final cardSurface = context.cardSurface;

    final typeText = doc.typeLabel;
    final statusText = doc.statusDisplay ?? doc.status ?? '—';
    final statusColor = _statusColor(doc.status, primaryColor);
    final dateText = doc.dateLabel;
    final docNumber = doc.documentNumber;
    final title = (doc.name != null && doc.name!.isNotEmpty)
        ? doc.name!
        : '$typeText #${doc.id}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _typeIcon(doc.type),
                  color: primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  typeText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                  height: 1.3,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (docNumber != null && docNumber.isNotEmpty) ...[
                Icon(Icons.tag, size: 14, color: textSecondary),
                const SizedBox(width: 4),
                Text(
                  docNumber,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(width: 12),
              ],
              if (dateText != null) ...[
                Icon(
                  Icons.calendar_today_outlined,
                  size: 13,
                  color: textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  dateText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: textSecondary,
                      ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ContainerW(
                  radius: 10,
                  height: 42,
                  color: cardSurface,
                  borderColor: borderColor,
                  onTap: onView,
                  child: Center(
                    child: Text(
                      'Ko‘rish',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: textPrimary,
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
                  onTap: onDownload,
                  child: Center(
                    child: isBusy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : AppText(
                            text: 'Yuklab olish',
                            fontSize: 14,
                            fontWeight: 700,
                            color: context.textWhite,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DocumentItem {
  DocumentItem({
    required this.id,
    required this.type,
    required this.status,
    this.typeDisplay,
    this.statusDisplay,
    this.name,
    this.documentNumber,
    this.documentDate,
    this.createdAtRaw,
    this.fileUrl,
  });

  final int id;
  final String type;
  final String? typeDisplay;
  final String? status;
  final String? statusDisplay;
  final String? name;
  final String? documentNumber;
  final String? documentDate;
  final String? createdAtRaw;
  final String? fileUrl;

  factory DocumentItem.fromJson(Map<String, dynamic> json) {
    final id = _toInt(json['id'] ?? json['document_id'] ?? json['pk']);
    final type = (json['type'] ?? json['document_type'] ?? '').toString();
    final typeDisplay = json['document_type_display']?.toString();

    final status = (json['status'] ?? json['state'])?.toString();
    final statusDisplay = json['status_display']?.toString();

    final name = json['name']?.toString();
    final documentNumber = json['document_number']?.toString();
    final documentDate = json['document_date']?.toString();
    final createdAtRaw =
        (json['created_at'] ?? json['createdAt'] ?? json['date'])?.toString();

    final fileUrlRaw =
        (json['file_url'] ?? json['file'] ?? json['signed_file'])?.toString();
    final fileUrl =
        (fileUrlRaw == null || fileUrlRaw.isEmpty) ? null : fileUrlRaw;

    return DocumentItem(
      id: id,
      type: type,
      typeDisplay: typeDisplay,
      status: status,
      statusDisplay: statusDisplay,
      name: name,
      documentNumber: documentNumber,
      documentDate: documentDate,
      createdAtRaw: createdAtRaw,
      fileUrl: fileUrl,
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  /// `document_type_display` mavjud bo'lsa shuni, aks holda lokalizatsiya qilingan
  /// fallback yoki xom `type`'ni qaytaradi.
  String get typeLabel {
    final display = typeDisplay;
    if (display != null && display.isNotEmpty) return display;
    final t = type.toLowerCase();
    if (t.contains('reconciliation')) return 'Hisob-kitob akti';
    if (t.contains('invoice')) return 'Hisob-faktura';
    if (t.contains('contract')) return 'Shartnoma';
    if (t.isEmpty) return 'Hujjat';
    return type;
  }

  /// `document_date` (YYYY-MM-DD) -> "DD.MM.YYYY". Fallback — `created_at` sanasi.
  String? get dateLabel {
    final raw = (documentDate != null && documentDate!.isNotEmpty)
        ? documentDate
        : createdAtRaw?.split('T').first;
    if (raw == null || raw.isEmpty) return null;
    final parts = raw.split('-');
    if (parts.length != 3) return raw;
    return '${parts[2]}.${parts[1]}.${parts[0]}';
  }
}

