import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/theme/theme_colors.dart';
import 'package:uz_xarid/features/catalog/domain/entities/category_entity.dart';
import 'package:uz_xarid/features/feedback/data/feedback_repository.dart';
import 'package:uz_xarid/features/feedback/data/models/feedback_reason.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key, required this.repository});

  final FeedbackRepository repository;

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  static const int _maxFileSizeBytes = 5 * 1024 * 1024;
  static const List<String> _allowedExtensions = ['jpg', 'jpeg', 'png', 'pdf'];

  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contactController = TextEditingController();
  final _customReasonController = TextEditingController();
  final _descriptionFocusNode = FocusNode();
  final _imagePicker = ImagePicker();

  List<FeedbackReason> _reasons = const [];
  List<CategoryEntity> _categories = const [];
  List<_FeedbackAttachment> _attachments = const [];

  FeedbackReason? _selectedReason;
  CategoryEntity? _selectedCategory;

  bool _isInitialLoading = true;
  bool _isSubmitting = false;
  bool _hasDescriptionError = false;
  bool _hasReasonError = false;
  String? _pageError;

  @override
  void initState() {
    super.initState();
    _descriptionController.addListener(_onDescriptionChanged);
    _logAnalytics('feedback_opened');
    _loadInitialData();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController
      ..removeListener(_onDescriptionChanged)
      ..dispose();
    _contactController.dispose();
    _customReasonController.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isInitialLoading = true;
      _pageError = null;
    });

    final reasonsResult = await widget.repository.getReasons();
    final categoriesResult = await widget.repository.getCategories();

    if (!mounted) return;

    String? error;
    List<FeedbackReason> reasons = const [];
    List<CategoryEntity> categories = const [];

    reasonsResult.either(
      (failure) => error = failure.message ?? 'Xatolik yuz berdi',
      (data) => reasons = data,
    );
    categoriesResult.either(
      (failure) => error ??= failure.message ?? 'Xatolik yuz berdi',
      (data) => categories = data,
    );

    setState(() {
      _reasons = reasons;
      _categories = categories;
      _pageError = error;
      _isInitialLoading = false;
    });
  }

  void _onDescriptionChanged() {
    final hasError = _descriptionController.text.trim().length < 10;
    if (_hasDescriptionError != hasError && mounted) {
      setState(() => _hasDescriptionError = hasError);
    }
  }

  bool get _requiresCustomReason => _selectedReason?.isOther == true;

  bool get _canSubmit {
    return !_isSubmitting &&
        _selectedReason != null &&
        _descriptionController.text.trim().length >= 10 &&
        (!_requiresCustomReason ||
            _customReasonController.text.trim().isNotEmpty);
  }

  String get _descriptionHint {
    if (_selectedReason?.isTechnical == true) {
      return 'Qanday xatolik yuz berdi?';
    }
    return 'Murojaatingiz tafsilotlarini yozing';
  }

  String? get _reasonHint {
    if (_selectedReason?.isFraud == true) {
      return 'Iltimos, e\'lon linkini yuboring';
    }
    return null;
  }

  Future<void> _showReasonSheet() async {
    final selected = await showModalBottomSheet<FeedbackReason>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ReasonPickerSheet(
        reasons: _reasons,
        selectedReason: _selectedReason,
      ),
    );

    if (selected == null || !mounted) return;

    setState(() {
      _selectedReason = selected;
      _hasReasonError = false;
      if (!selected.isOther) {
        _customReasonController.clear();
      }
    });
    _logAnalytics('reason_selected', parameters: {'reason_id': selected.id});
  }

  Future<void> _showCategorySheet() async {
    final selected = await showModalBottomSheet<CategoryEntity>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CategoryPickerSheet(
        categories: _categories,
        selectedCategory: _selectedCategory,
      ),
    );

    if (selected == null || !mounted) return;
    setState(() => _selectedCategory = selected);
  }

  Future<void> _showAttachmentSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final cardColor = context.cardSurface;
        final textColor = context.textPrimary;
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: Text('Kamera'),
                  textColor: textColor,
                  iconColor: textColor,
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickFromCamera();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: Text('Galereya'),
                  textColor: textColor,
                  iconColor: textColor,
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickFromGallery();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.attach_file_outlined),
                  title: Text('Fayl tanlash'),
                  textColor: textColor,
                  iconColor: textColor,
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickFile();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickFromCamera() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (image == null || !mounted) return;
    await _addAttachment(image.path);
  }

  Future<void> _pickFromGallery() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image == null || !mounted) return;
    await _addAttachment(image.path);
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: _allowedExtensions,
    );
    final path = result?.files.single.path;
    if (path == null || !mounted) return;
    await _addAttachment(path);
  }

  Future<void> _addAttachment(String path) async {
    final extension = path.split('.').last.toLowerCase();
    if (!_allowedExtensions.contains(extension)) {
      _showMessage('Faqat jpg, png yoki pdf fayl yuborish mumkin');
      return;
    }

    final file = File(path);
    if (!await file.exists()) {
      _showMessage('Fayl topilmadi');
      return;
    }

    final size = await file.length();
    if (size > _maxFileSizeBytes) {
      _showMessage('Fayl hajmi 5MB dan oshmasligi kerak');
      return;
    }

    if (_attachments.any((item) => item.path == path)) {
      _showMessage('Bu fayl allaqachon tanlangan');
      return;
    }

    setState(() {
      _attachments = [
        ..._attachments,
        _FeedbackAttachment(
          path: path,
          name: path.split('/').last,
          extension: extension,
        ),
      ];
    });
  }

  Future<void> _submit() async {
    setState(() {
      _hasReasonError = _selectedReason == null;
      _hasDescriptionError = _descriptionController.text.trim().length < 10;
    });

    if (!_canSubmit || _selectedReason == null) {
      if (_descriptionController.text.trim().length < 10) {
        _descriptionFocusNode.requestFocus();
      }
      return;
    }

    setState(() => _isSubmitting = true);

    final result = await widget.repository.submit(
      FeedbackSubmitParams(
        reasonId: _selectedReason!.id,
        categoryId: _selectedCategory?.id,
        subject: _subjectController.text,
        description: _descriptionController.text,
        contact: _contactController.text,
        customReasonText: _customReasonController.text,
        attachments: _attachments.map((item) => item.path).toList(),
      ),
    );

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    result.either(
      (failure) => _showMessage(failure.message ?? 'Xatolik yuz berdi'),
      (_) async {
        _logAnalytics(
          'feedback_submitted',
          parameters: {'reason_id': _selectedReason!.id},
        );
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Murojaatingiz yuborildi'),
            content: const Text(
              'So\'rovingiz qabul qilindi. Tez orada ko\'rib chiqamiz.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Yopish'),
              ),
            ],
          ),
        );

        if (!mounted) return;
        Navigator.of(context).pop();
        _showMessage('Murojaatingiz qabul qilindi');
      },
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _logAnalytics(String event, {Map<String, Object?>? parameters}) {
    log('feedback_event', name: event, error: parameters);
  }

  @override
  Widget build(BuildContext context) {
    final bodyBg = context.bodyBackground;
    final cardColor = context.cardSurface;
    final textColor = context.textPrimary;
    final hintColor = context.textSecondary;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: bodyBg,
      appBar: AppBar(
        title: const Text('Taklif va shikoyatlar'),
        backgroundColor: bodyBg,
        foregroundColor: textColor,
        elevation: 0,
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          height: 52,
          child: FilledButton(
            onPressed: _canSubmit ? _submit : null,
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Yuborish'),
          ),
        ),
      ),
      body: _isInitialLoading
          ? const Center(child: CircularProgressIndicator())
          : _pageError != null && _reasons.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _pageError!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: textColor),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _loadInitialData,
                      child: const Text('Qayta urinish'),
                    ),
                  ],
                ),
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  16 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_pageError != null) ...[
                      _InlineBanner(message: _pageError!),
                      const SizedBox(height: 16),
                    ],
                    _SectionCard(
                      color: cardColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel('Sabab *', color: textColor),
                          const SizedBox(height: 8),
                          _PickerField(
                            title: _selectedReason?.name ?? 'Sababni tanlang',
                            hasValue: _selectedReason != null,
                            hasError: _hasReasonError,
                            onTap: _showReasonSheet,
                          ),
                          if (_hasReasonError) ...[
                            const SizedBox(height: 6),
                            const Text(
                              'Sabab tanlanishi shart',
                              style: TextStyle(color: AppColors.red),
                            ),
                          ],
                          if (_requiresCustomReason) ...[
                            const SizedBox(height: 16),
                            _FieldLabel('Boshqa sabab', color: textColor),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _customReasonController,
                              decoration: _inputDecoration(
                                context,
                                hintText: 'Sababni yozing',
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ],
                          if (_reasonHint != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _reasonHint!,
                              style: TextStyle(color: hintColor, fontSize: 13),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      color: cardColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel('Kategoriya', color: textColor),
                          const SizedBox(height: 8),
                          _PickerField(
                            title:
                                _selectedCategory?.displayName ??
                                'Kategoriyani tanlang',
                            hasValue: _selectedCategory != null,
                            onTap: _showCategorySheet,
                            trailing: _selectedCategory != null
                                ? IconButton(
                                    onPressed: () => setState(
                                      () => _selectedCategory = null,
                                    ),
                                    icon: const Icon(Icons.close, size: 18),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 16),
                          _FieldLabel('Mavzu', color: textColor),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _subjectController,
                            maxLength: 120,
                            decoration: _inputDecoration(
                              context,
                              hintText: 'Qisqa mavzu kiriting',
                            ),
                          ),
                          const SizedBox(height: 8),
                          _FieldLabel('Tavsif *', color: textColor),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _descriptionController,
                            focusNode: _descriptionFocusNode,
                            maxLines: 5,
                            minLines: 4,
                            decoration: _inputDecoration(
                              context,
                              hintText: _descriptionHint,
                              errorText: _hasDescriptionError
                                  ? 'Kamida 10 ta belgi kiriting'
                                  : null,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 16),
                          _FieldLabel('Kontakt ma\'lumoti', color: textColor),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _contactController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _inputDecoration(
                              context,
                              hintText: 'Telefon yoki email',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      color: cardColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _FieldLabel('Ilova', color: textColor),
                              const Spacer(),
                              Text(
                                'jpg, png, pdf · 5MB',
                                style: TextStyle(
                                  color: hintColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: _showAttachmentSheet,
                            icon: const Icon(Icons.attach_file),
                            label: const Text('Fayl biriktirish'),
                          ),
                          if (_attachments.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            ..._attachments.map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _AttachmentTile(
                                  attachment: item,
                                  onDelete: () {
                                    setState(() {
                                      _attachments = _attachments
                                          .where(
                                            (entry) => entry.path != item.path,
                                          )
                                          .toList();
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Sabab tanlanmaguncha yuborish tugmasi faol bo\'lmaydi.',
                      style: TextStyle(color: hintColor, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String hintText,
    String? errorText,
  }) {
    final borderColor = context.borderColor;
    return InputDecoration(
      hintText: hintText,
      errorText: errorText,
      filled: true,
      fillColor: context.surfaceContainer,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 1.4,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      counterText: '',
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.title, {required this.color});

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w700),
    );
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.title,
    required this.hasValue,
    required this.onTap,
    this.hasError = false,
    this.trailing,
  });

  final String title;
  final bool hasValue;
  final bool hasError;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: context.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasError
                ? AppColors.red
                : hasValue
                ? Theme.of(context).colorScheme.primary
                : context.borderColor,
            width: hasValue || hasError ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: hasValue ? context.textPrimary : context.textSecondary,
                ),
              ),
            ),
            trailing ??
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: context.textSecondary,
                ),
          ],
        ),
      ),
    );
  }
}

class _InlineBanner extends StatelessWidget {
  const _InlineBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(message, style: const TextStyle(color: AppColors.red)),
    );
  }
}

class _ReasonPickerSheet extends StatefulWidget {
  const _ReasonPickerSheet({
    required this.reasons,
    required this.selectedReason,
  });

  final List<FeedbackReason> reasons;
  final FeedbackReason? selectedReason;

  @override
  State<_ReasonPickerSheet> createState() => _ReasonPickerSheetState();
}

class _ReasonPickerSheetState extends State<_ReasonPickerSheet> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final items = widget.reasons.where((reason) {
      if (query.isEmpty) return true;
      return reason.name.toLowerCase().contains(query);
    }).toList();

    return _PickerBottomSheet(
      title: 'Sababni tanlang',
      searchController: _searchController,
      searchHint: 'Qidirish',
      onSearchChanged: (_) => setState(() {}),
      child: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, _) =>
            Divider(color: context.borderColor, height: 1),
        itemBuilder: (_, index) {
          final reason = items[index];
          final isSelected = widget.selectedReason?.id == reason.id;
          return ListTile(
            title: Text(reason.name),
            trailing: isSelected
                ? Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : null,
            onTap: () => Navigator.of(context).pop(reason),
          );
        },
      ),
    );
  }
}

class _CategoryPickerSheet extends StatefulWidget {
  const _CategoryPickerSheet({
    required this.categories,
    required this.selectedCategory,
  });

  final List<CategoryEntity> categories;
  final CategoryEntity? selectedCategory;

  @override
  State<_CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends State<_CategoryPickerSheet> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final items = widget.categories.where((category) {
      if (query.isEmpty) return true;
      return category.displayName.toLowerCase().contains(query);
    }).toList();

    return _PickerBottomSheet(
      title: 'Kategoriyani tanlang',
      searchController: _searchController,
      searchHint: 'Qidirish',
      onSearchChanged: (_) => setState(() {}),
      child: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, _) =>
            Divider(color: context.borderColor, height: 1),
        itemBuilder: (_, index) {
          final category = items[index];
          final isSelected = widget.selectedCategory?.id == category.id;
          return ListTile(
            title: Text(category.displayName),
            trailing: isSelected
                ? Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : null,
            onTap: () => Navigator.of(context).pop(category),
          );
        },
      ),
    );
  }
}

class _PickerBottomSheet extends StatelessWidget {
  const _PickerBottomSheet({
    required this.title,
    required this.searchController,
    required this.searchHint,
    required this.onSearchChanged,
    required this.child,
  });

  final String title;
  final TextEditingController searchController;
  final String searchHint;
  final ValueChanged<String> onSearchChanged;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DraggableScrollableSheet(
        initialChildSize: 0.72,
        minChildSize: 0.45,
        maxChildSize: 0.92,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: context.cardSurface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.borderColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: context.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: searchController,
                    onChanged: onSearchChanged,
                    decoration: InputDecoration(
                      hintText: searchHint,
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: context.surfaceContainer,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: context.borderColor),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: PrimaryScrollController(
                    controller: scrollController,
                    child: child,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AttachmentTile extends StatelessWidget {
  const _AttachmentTile({required this.attachment, required this.onDelete});

  final _FeedbackAttachment attachment;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isImage = attachment.isImage;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: isImage
                ? Image.file(
                    File(attachment.path),
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _fileIcon(),
                  )
                : _fileIcon(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  attachment.extension.toUpperCase(),
                  style: TextStyle(color: context.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }

  Widget _fileIcon() {
    return Container(
      width: 52,
      height: 52,
      color: AppColors.blue500.withValues(alpha: 0.12),
      alignment: Alignment.center,
      child: const Icon(
        Icons.picture_as_pdf_outlined,
        color: AppColors.blue500,
      ),
    );
  }
}

class _FeedbackAttachment {
  const _FeedbackAttachment({
    required this.path,
    required this.name,
    required this.extension,
  });

  final String path;
  final String name;
  final String extension;

  bool get isImage =>
      extension == 'jpg' || extension == 'jpeg' || extension == 'png';
}
