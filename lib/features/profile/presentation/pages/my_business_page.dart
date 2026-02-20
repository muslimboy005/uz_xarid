import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uz_xarid/core/constants/app_assets.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/widgets/app_image.dart';
import 'package:uz_xarid/core/widgets/app_text.dart';
import 'package:uz_xarid/core/widgets/profile_breadcrumb.dart';
import 'package:uz_xarid/core/widgets/uzxarid_app_bar.dart';
import 'package:uz_xarid/core/widgets/w__container.dart';
import 'package:uz_xarid/l10n/app_localizations.dart';

class MyBusinessPage extends StatefulWidget {
  const MyBusinessPage({super.key});

  @override
  State<MyBusinessPage> createState() => _MyBusinessPageState();
}

class _MyBusinessPageState extends State<MyBusinessPage> {
  final _companyNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phone1Controller = TextEditingController();
  final _phone2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _streetController = TextEditingController();
  final _houseController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _instagramController = TextEditingController();
  final _facebookController = TextEditingController();
  final _telegramController = TextEditingController();
  final _youtubeController = TextEditingController();

  String? _workingHours;
  String? _lunchBreak;
  bool _showContactFields = false;

  @override
  void dispose() {
    _companyNameController.dispose();
    _descriptionController.dispose();
    _phone1Controller.dispose();
    _phone2Controller.dispose();
    _cityController.dispose();
    _streetController.dispose();
    _houseController.dispose();
    _landmarkController.dispose();
    _instagramController.dispose();
    _facebookController.dispose();
    _telegramController.dispose();
    _youtubeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: UzXaridAppBar(onSearchChanged: (query) {}, onMenuTap: () {}),
      backgroundColor: AppColors.primary,
      body: Container(
        decoration: BoxDecoration(color: AppColors.black50),
        child: SafeArea(
          child: Column(
            children: [
              ProfileBreadcrumb(
                labels: [l10n.navHome, l10n.profileTitle, l10n.myBusinessTitle],
                onTaps: [
                  () => context.go('/home'),
                  () => context.go('/profile'),
                  null,
                ],
              ),
              // Back + Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: ContainerW(
                        color: AppColors.white,
                        radius: 8,
                        borderColor: AppColors.black100,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: AppImage(path: AppAssets.backDropleft),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    AppText(
                      text: l10n.myBusinessTitle,
                      fontSize: 20,
                      fontWeight: 700,
                      color: AppColors.black500,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(title: l10n.companyInfoSection),
                      const SizedBox(height: 8),
                      ContainerW(
                        color: AppColors.white,
                        radius: 12,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  ContainerW(
                                    color: AppColors.blue500.withOpacity(0.1),
                                    radius: 32,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: AppImage(
                                        path: AppAssets.workBlue,
                                        size: 32,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  GestureDetector(
                                    onTap: () {},
                                    child: ContainerW(
                                      color: AppColors.white,
                                      radius: 8,
                                      borderColor: AppColors.black100,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            AppImage(
                                              path: AppAssets.edit,
                                            color: AppColors.black500,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 6),
                                          AppText(
                                            text: l10n.changeAvatar,
                                            fontSize: 14,
                                            fontWeight: 500,
                                            color: AppColors.black500,
                                          ),
                                        ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Company name
                              _FieldLabel(label: l10n.companyNameLabel),
                              const SizedBox(height: 8),
                              _TextField(
                                controller: _companyNameController,
                                hint: l10n.companyNameHint,
                              ),
                              const SizedBox(height: 12),
                              // Description
                              _FieldLabel(label: l10n.companyAboutLabel),
                              const SizedBox(height: 8),
                              _TextField(
                                controller: _descriptionController,
                                hint: l10n.companyAboutHint,
                                maxLines: 4,
                              ),
                              const SizedBox(height: 12),
                              // Upload cover
                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                  width: double.infinity,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.black300,
                                      style: BorderStyle.solid,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.add,
                                        color: AppColors.black300,
                                        size: 22,
                                      ),
                                      const SizedBox(height: 4),
                                      AppText(
                                        text: l10n.uploadCover,
                                        fontSize: 13,
                                        fontWeight: 400,
                                        color: AppColors.black300,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── Контактные данные ────────────────────────────
                      GestureDetector(
                        onTap: () => setState(
                          () => _showContactFields = !_showContactFields,
                        ),
                        child: ContainerW(
                          color: AppColors.white,
                          radius: 12,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                                child: Row(
                              children: [
                                Expanded(
                                  child: AppText(
                                    text: l10n.contactDataToggle,
                                    fontSize: 15,
                                    fontWeight: 600,
                                    color: AppColors.black500,
                                  ),
                                ),
                                Icon(
                                  _showContactFields ? Icons.remove : Icons.add,
                                  color: AppColors.black500,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (_showContactFields) ...[
                        const SizedBox(height: 8),
                        ContainerW(
                          color: AppColors.white,
                          radius: 12,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _FieldLabel(label: l10n.phone1Label),
                                const SizedBox(height: 6),
                                _TextField(
                                  controller: _phone1Controller,
                                  hint: l10n.phoneHint,
                                  keyboardType: TextInputType.phone,
                                ),
                                const SizedBox(height: 12),
                                _FieldLabel(label: l10n.phone2Label),
                                const SizedBox(height: 6),
                                _TextField(
                                  controller: _phone2Controller,
                                  hint: l10n.phoneHint,
                                  keyboardType: TextInputType.phone,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),

                      // ── Рабочее время ────────────────────────────────
                      _SectionHeader(title: l10n.workingTimeSection),
                      const SizedBox(height: 12),
                      ContainerW(
                        color: AppColors.white,
                        radius: 12,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel(label: l10n.workingDaysLabel),
                              const SizedBox(height: 6),
                              _DropdownField(
                                value: _workingHours,
                                hint: l10n.workingDaysHint,
                                items: [
                                  l10n.workingDaysOptionWeekdays,
                                  l10n.workingDaysOptionSat,
                                  l10n.workingDaysOptionDaily,
                                ],
                                onChanged: (v) =>
                                    setState(() => _workingHours = v),
                              ),
                              const SizedBox(height: 12),
                              _FieldLabel(label: l10n.lunchBreakLabel),
                              const SizedBox(height: 6),
                              _DropdownField(
                                value: _lunchBreak,
                                hint: l10n.lunchBreakHint,
                                items: const [
                                  '13:00–14:00',
                                  '12:00–13:00',
                                  '14:00–15:00',
                                ],
                                onChanged: (v) =>
                                    setState(() => _lunchBreak = v),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── Адрес ────────────────────────────────────────
                      _SectionHeader(title: l10n.addressTitle),
                      const SizedBox(height: 12),
                      ContainerW(
                        color: AppColors.white,
                        radius: 12,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel(label: l10n.cityLabel),
                              const SizedBox(height: 6),
                              _TextField(
                                controller: _cityController,
                                hint: l10n.cityHint,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _FieldLabel(label: l10n.streetLabel),
                                        const SizedBox(height: 6),
                                        _TextField(
                                          controller: _streetController,
                                          hint: l10n.streetHint,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _FieldLabel(label: l10n.houseLabel),
                                        const SizedBox(height: 6),
                                        _TextField(
                                          controller: _houseController,
                                          hint: l10n.houseHint,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _FieldLabel(label: l10n.landmarkLabel),
                              const SizedBox(height: 6),
                              _TextField(
                                controller: _landmarkController,
                                hint: l10n.landmarkHint,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── Социальные сети ──────────────────────────────
                      _SectionHeader(title: l10n.socialNetworksSection),
                      const SizedBox(height: 12),
                      ContainerW(
                        color: AppColors.white,
                        radius: 12,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SocialField(
                                label: 'Instagram',
                                icon: Icons.camera_alt_outlined,
                                controller: _instagramController,
                                hint: l10n.instagramHint,
                              ),
                              const SizedBox(height: 12),
                              _SocialField(
                                label: 'Facebook',
                                icon: Icons.facebook_rounded,
                                controller: _facebookController,
                                hint: l10n.facebookHint,
                              ),
                              const SizedBox(height: 12),
                              _SocialField(
                                label: 'Telegram',
                                icon: Icons.send_rounded,
                                controller: _telegramController,
                                hint: l10n.telegramHint,
                              ),
                              const SizedBox(height: 12),
                              _SocialField(
                                label: 'YouTube',
                                icon: Icons.play_circle_outline_rounded,
                                controller: _youtubeController,
                                hint: l10n.youtubeHint,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Action buttons ───────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => context.pop(),
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.black100),
                            ),
                            child: Center(
                              child: AppText(
                                text: l10n.actionCancel,
                                fontSize: 15,
                                fontWeight: 600,
                                color: AppColors.black500,
                              ),
                            ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {},
                              child: Container(
                                height: 50,
                              decoration: BoxDecoration(
                                color: AppColors.blue500,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: AppText(
                                  text: l10n.actionSave,
                                  fontSize: 15,
                                  fontWeight: 600,
                                  color: AppColors.white,
                                ),
                              ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helper Widgets ──────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return ContainerW(
      color: AppColors.white,
      width: double.infinity,
      radius: 12,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 19),
        child: AppText(
          text: title,
          fontSize: 16,
          fontWeight: 700,
          color: AppColors.black500,
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return AppText(
      text: label,
      fontSize: 14,
      fontWeight: 700,
      color: AppColors.black500,
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF171D23),
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontSize: 14,
          color: AppColors.black300,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: AppColors.black50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.blue500, width: 1.5),
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  final String? value;
  final String hint;
  final List<String> items;
  final void Function(String?) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.black50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(
            hint,
            style: const TextStyle(fontSize: 14, color: AppColors.black300),
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.black300,
          ),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _SocialField extends StatelessWidget {
  const _SocialField({
    required this.label,
    required this.icon,
    required this.controller,
    required this.hint,
  });

  final String label;
  final IconData icon;
  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: label,
          fontSize: 13,
          fontWeight: 600,
          color: AppColors.black500,
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: const TextStyle(fontSize: 14, color: Color(0xFF171D23)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 14, color: AppColors.black300),
            prefixIcon: Icon(icon, color: AppColors.black300, size: 18),
            filled: true,
            fillColor: AppColors.black50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.blue500,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
