import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uz_xarid/core/constants/app_assets.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/theme/theme_colors.dart';
import 'package:uz_xarid/core/utils/input_formatters.dart';
import 'package:uz_xarid/core/widgets/app_image.dart';
import 'package:uz_xarid/core/widgets/app_text.dart';
import 'package:uz_xarid/core/widgets/uzxarid_app_bar.dart';
import 'package:uz_xarid/core/widgets/w__container.dart';
import 'package:uz_xarid/core/widgets/w_text_form.dart';
import 'package:uz_xarid/features/profile/data/model/profile_model.dart';
import 'package:uz_xarid/features/profile/presentation/bloc/profile_bloc.dart';

class PersonalDataPage extends StatefulWidget {
  const PersonalDataPage({super.key});

  @override
  State<PersonalDataPage> createState() => _PersonalDataPageState();
}

class _PersonalDataPageState extends State<PersonalDataPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _cityController = TextEditingController();
  final _streetController = TextEditingController();
  final _houseController = TextEditingController();
  final _districtController = TextEditingController();

  final _avatarFile = ValueNotifier<File?>(null);
  final _selectedGender = ValueNotifier<String?>(null);
  final _selectedDate = ValueNotifier<DateTime?>(null);
  final _serverAvatarUrl = ValueNotifier<String?>(null);

  bool _filledFromServer = false;

  @override
  void initState() {
    super.initState();
    _tryFillFromServer(
      context.read<ProfileBloc>().state.profileModel?.data.user,
    );
  }

  void _tryFillFromServer(User? profile) {
    if (_filledFromServer || profile == null) return;
    _filledFromServer = true;
    _firstNameController.text = profile.firstName;
    _lastNameController.text = profile.lastName;
    _phoneController.text = profile.phone;
    _emailController.text = profile.email;
    final g = profile.gender;
    if (g == 'male' || g == 'female') {
      _selectedGender.value = g;
    }
    if (profile.avatar.isNotEmpty) {
      _serverAvatarUrl.value = profile.avatar;
    }
    if (profile.dateJoined != null) {
      _selectedDate.value = profile.dateJoined;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _streetController.dispose();
    _houseController.dispose();
    _districtController.dispose();
    _avatarFile.dispose();
    _selectedGender.dispose();
    _selectedDate.dispose();
    _serverAvatarUrl.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (picked != null && mounted) {
        _avatarFile.value = File(picked.path);
      }
    } catch (e) {
      debugPrint('Image picker error: $e');
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.value ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      _selectedDate.value = picked;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  void _onSave() {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty) {
      return;
    }

    context.read<ProfileBloc>().add(
      ProfileUpdateEvent(
        firstName: firstName,
        lastName: lastName,
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        city: _cityController.text.trim(),
        street: _streetController.text.trim(),
        house: _houseController.text.trim(),
        district: _districtController.text.trim(),
        gender: _selectedGender.value,
        birthDate: _formatDate(_selectedDate.value),
        avatarPath: _avatarFile.value?.path,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!context.mounted) return const SizedBox.shrink();
    final borderColor = context.borderColor;
    final surfaceContainer = context.surfaceContainer;
    return BlocConsumer<ProfileBloc, ProfileState>(
      listenWhen: (prev, curr) =>
          curr.status == ProfileStatus.updateSuccess ||
          (curr.status == ProfileStatus.failure &&
              prev.status == ProfileStatus.loading),
      listener: (context, state) {
        if (state.status == ProfileStatus.updateSuccess) {
          context.pop();
        }
      },
      buildWhen: (prev, curr) {
        if (!_filledFromServer && curr.profileModel?.data.user != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _tryFillFromServer(curr.profileModel?.data.user);
            }
          });
        }
        return prev.status != curr.status;
      },
      builder: (context, state) {
        final isLoading = state.status == ProfileStatus.loading;
        // final isDark = context.isDark;
        final bodyBg = context.bodyBackground;
        final cardColor = context.cardSurface;
        final textColor = context.textPrimary;

        return Scaffold(
          appBar: UzXaridAppBar(onSearchChanged: (q) {}, onMenuTap: () {}),
          backgroundColor: AppColors.primary,
          body: SafeArea(
            child: Container(
              color: bodyBg,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () => context.pop(),
                                  child: ContainerW(
                                    color: cardColor,
                                    radius: 8,
                                    // borderColor: context.borderColor,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: AppImage(
                                        path: AppAssets.backDropleft,
                                        color: textColor,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                AppText(
                                  text: 'Личные данные',
                                  fontSize: 20,
                                  fontWeight: 700,
                                  color: textColor,
                                ),
                              ],
                            ),
                          ),
                          // _sectionHeader('Личные данные'),
                          const SizedBox(height: 12),
                          _card(
                            children: [
                              _avatarRow(),
                              const SizedBox(height: 16),
                              _label('Имя'),
                              const SizedBox(height: 6),
                              WTextField(
                                controller: _firstNameController,
                                hintText: 'Введите имя',
                                keyboardType: TextInputType.name,
                                enabled: !isLoading,
                                fillColor: surfaceContainer,
                                borderNoFocusColor: borderColor,
                              ),
                              const SizedBox(height: 12),
                              _label('Фамилия'),
                              const SizedBox(height: 6),
                              WTextField(
                                controller: _lastNameController,
                                hintText: 'Введите фамилию',
                                keyboardType: TextInputType.name,
                                enabled: !isLoading,
                                fillColor: surfaceContainer,
                                borderNoFocusColor: borderColor,
                              ),
                              const SizedBox(height: 12),
                              _label('Пол'),
                              const SizedBox(height: 6),
                              _genderDropdown(isLoading),
                              const SizedBox(height: 12),
                              _label('Дата рождения'),
                              const SizedBox(height: 6),
                              _dateField(isLoading),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _sectionHeader('Контактные данные'),
                          const SizedBox(height: 12),
                          _card(
                            children: [
                              _label('Телефон'),
                              const SizedBox(height: 6),
                              WTextField(
                                controller: _phoneController,
                                hintText: '+998 XX XXX-XX-XX',
                                keyboardType: TextInputType.phone,
                                inputFormatters: [UzbekPhoneInputFormatter()],
                                enabled: !isLoading,
                                fillColor: surfaceContainer,
                                borderNoFocusColor: borderColor,
                              ),
                              const SizedBox(height: 12),
                              _label('Электронная почта'),
                              const SizedBox(height: 6),
                              WTextField(
                                controller: _emailController,
                                hintText: 'Введите E-mail',
                                keyboardType: TextInputType.emailAddress,
                                enabled: !isLoading,
                                fillColor: surfaceContainer,
                                borderNoFocusColor: borderColor,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _sectionHeader('Адрес'),
                          const SizedBox(height: 12),
                          _card(
                            children: [
                              _label('Город'),
                              const SizedBox(height: 6),
                              WTextField(
                                controller: _cityController,
                                hintText: 'Введите город',
                                enabled: !isLoading,
                                fillColor: surfaceContainer,
                                borderNoFocusColor: borderColor,
                              ),
                              const SizedBox(height: 12),
                              _label('Улица'),
                              const SizedBox(height: 6),
                              WTextField(
                                controller: _streetController,
                                hintText: 'Введите улицу',
                                enabled: !isLoading,
                                fillColor: surfaceContainer,
                                borderNoFocusColor: borderColor,
                              ),
                              const SizedBox(height: 12),
                              _label('Дом / Квартира'),
                              const SizedBox(height: 6),
                              WTextField(
                                controller: _houseController,
                                hintText: 'Дом / Квартира',
                                enabled: !isLoading,
                                fillColor: surfaceContainer,
                                borderNoFocusColor: borderColor,
                              ),
                              const SizedBox(height: 12),
                              _label('Район'),
                              const SizedBox(height: 6),
                              WTextField(
                                controller: _districtController,
                                hintText: 'Введите район',
                                enabled: !isLoading,
                                fillColor: surfaceContainer,
                                borderNoFocusColor: borderColor,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  _bottomButtons(context, isLoading),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _avatarRow() {
    return ValueListenableBuilder<File?>(
      valueListenable: _avatarFile,
      builder: (context, avatar, _) {
        ImageProvider? imageProvider;
        if (avatar != null) {
          imageProvider = FileImage(avatar);
        } else if (_serverAvatarUrl.value != null &&
            _serverAvatarUrl.value!.isNotEmpty) {
          String url = _serverAvatarUrl.value!.replaceFirst('file://', '');
          if (url.startsWith('/')) {
            url = 'https://uzxarid.felixits.uz$url';
          }
          imageProvider = NetworkImage(url);
        }

        final textColor = context.textPrimary;
        final avatarBg = context.isDark
            ? AppColors.primary.withValues(alpha: 0.25)
            : AppColors.blue50;
        return Row(
          children: [
            GestureDetector(
              onTap: _pickImageFromGallery,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: avatarBg,
                    backgroundImage: imageProvider,
                    onBackgroundImageError: imageProvider != null
                        ? (exception, stackTrace) {}
                        : null,
                    child: imageProvider == null
                        ? Icon(Icons.person, color: AppColors.primary, size: 36)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: context.cardSurface,
                          width: 2,
                        ),
                      ),
                      child: Icon(Icons.edit, size: 12, color: AppColors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: 'Фото профиля',
                    fontSize: 14,
                    fontWeight: 600,
                    color: textColor,
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: _pickImageFromGallery,
                    child: AppText(
                      text: 'Выбрать из галереи',
                      fontSize: 13,
                      fontWeight: 400,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Map<String, String> _localizedGenderLabels(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    switch (lang) {
      case 'uz':
        return {'male': 'Erkak', 'female': 'Ayol'};
      case 'ru':
        return {'male': 'Мужчина', 'female': 'Женщина'};
      default:
        return {'male': 'Male', 'female': 'Female'};
    }
  }

  String _genderHint(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    switch (lang) {
      case 'uz':
        return 'Jinsni tanlang';
      case 'ru':
        return 'Выберите пол';
      default:
        return 'Select gender';
    }
  }

  Widget _genderDropdown(bool disabled) {
    final genderLabels = _localizedGenderLabels(context);
    final surfaceContainer = context.surfaceContainer;
    final borderColor = context.borderColor;
    final textColor = context.textPrimary;
    final textSecondary = context.textSecondary;

    return ValueListenableBuilder<String?>(
      valueListenable: _selectedGender,
      builder: (context, gender, _) {
        return Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: surfaceContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: gender,
              hint: AppText(
                text: _genderHint(context),
                fontSize: 14,
                fontWeight: 400,
                color: textSecondary,
              ),
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down, color: textSecondary),
              items: disabled
                  ? null
                  : genderLabels.entries
                        .map(
                          (e) => DropdownMenuItem<String>(
                            value: e.key,
                            child: AppText(
                              text: e.value,
                              fontSize: 14,
                              fontWeight: 400,
                              color: textColor,
                            ),
                          ),
                        )
                        .toList(),
              onChanged: disabled ? null : (v) => _selectedGender.value = v,
            ),
          ),
        );
      },
    );
  }

  Widget _dateField(bool disabled) {
    final textColor = context.textPrimary;
    final textSecondary = context.textSecondary;
    final surfaceContainer = context.surfaceContainer;
    final borderColor = context.borderColor;

    return ValueListenableBuilder<DateTime?>(
      valueListenable: _selectedDate,
      builder: (context, date, _) {
        return GestureDetector(
          onTap: disabled ? null : _pickDate,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: surfaceContainer,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Expanded(
                  child: AppText(
                    text: date != null ? _formatDate(date) : 'ДД.ММ.ГГГГ',
                    fontSize: 14,
                    fontWeight: 400,
                    color: date != null ? textColor : textSecondary,
                  ),
                ),
                Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: textSecondary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionHeader(String title) {
    return ContainerW(
      color: context.cardSurface,
      width: double.infinity,
      radius: 16,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: AppText(
          text: title,
          fontSize: 18,
          fontWeight: 700,
          color: context.textPrimary,
        ),
      ),
    );
  }

  Widget _card({required List<Widget> children}) {
    return ContainerW(
      width: double.infinity,
      color: context.cardSurface,
      radius: 16,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _label(String text) {
    return AppText(
      text: text,
      fontSize: 13,
      fontWeight: 500,
      color: context.textSecondary,
    );
  }

  Widget _bottomButtons(BuildContext context, bool isLoading) {
    final textColor = context.textPrimary;
    final borderColor = context.borderColor;
    return Container(
      color: context.cardSurface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isLoading ? null : () => context.pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: textColor,
                side: BorderSide(color: borderColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Отмена'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: isLoading ? null : _onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.isDark
                    ? AppColors.darkBackground
                    : AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : const Text('Сохранить'),
            ),
          ),
        ],
      ),
    );
  }
}
