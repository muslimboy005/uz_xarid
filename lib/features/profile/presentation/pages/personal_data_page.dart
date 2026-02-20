import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uz_xarid/core/constants/app_assets.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/utils/input_formatters.dart';
import 'package:uz_xarid/core/widgets/app_image.dart';
import 'package:uz_xarid/core/widgets/app_text.dart';
import 'package:uz_xarid/core/widgets/profile_breadcrumb.dart';
import 'package:uz_xarid/core/widgets/uzxarid_app_bar.dart';
import 'package:uz_xarid/core/widgets/w__container.dart';
import 'package:uz_xarid/core/widgets/w_text_form.dart';
import 'package:uz_xarid/features/profile/data/model/profile_model.dart';
import 'package:uz_xarid/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:uz_xarid/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.nameRequiredError)),
      );
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
    final l10n = AppLocalizations.of(context)!;

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

        return Scaffold(
          appBar: UzXaridAppBar(onSearchChanged: (q) {}, onMenuTap: () {}),
          backgroundColor: AppColors.primary,
          body: SafeArea(
            child: Container(
              color: AppColors.background,
              child: Column(
                children: [
                  ProfileBreadcrumb(
                    labels: const ['Главная', 'Профиль', 'Личные данные'],
                    onTaps: [
                      () => context.go('/home'),
                      () => context.go('/profile'),
                      null,
                    ],
                  ),
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
                                    color: AppColors.white,
                                    radius: 8,
                                    borderColor: AppColors.black100,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: AppImage(
                                        path: AppAssets.backDropleft,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                AppText(
                                  text: 'Личные данные',
                                  fontSize: 20,
                                  fontWeight: 700,
                                  color: AppColors.black500,
                                ),
                              ],
            child: Column(
              children: [
                ProfileBreadcrumb(
                  labels: [l10n.navHome, l10n.profileTitle, l10n.personalDataTitle],
                  onTaps: [
                    () => context.go('/home'),
                    () => context.go('/profile'),
                    null,
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionHeader(l10n.personalDataTitle),
                        const SizedBox(height: 12),
                        _card(
                          children: [
                            _avatarRow(),
                            const SizedBox(height: 16),
                            _label(l10n.firstNameLabel),
                            const SizedBox(height: 6),
                            WTextField(
                              controller: _firstNameController,
                              hintText: l10n.firstNameHint,
                              keyboardType: TextInputType.name,
                              enabled: !isLoading,
                            ),
                            const SizedBox(height: 12),
                            _label(l10n.lastNameLabel),
                            const SizedBox(height: 6),
                            WTextField(
                              controller: _lastNameController,
                              hintText: l10n.lastNameHint,
                              keyboardType: TextInputType.name,
                              enabled: !isLoading,
                            ),
                            const SizedBox(height: 12),
                            _label(l10n.genderLabel),
                            const SizedBox(height: 6),
                            _genderDropdown(isLoading),
                            const SizedBox(height: 12),
                            _label(l10n.birthDateLabel),
                            const SizedBox(height: 6),
                            _dateField(isLoading),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _sectionHeader(l10n.contactDataTitle),
                        const SizedBox(height: 12),
                        _card(
                          children: [
                            _label(l10n.phoneLabel),
                            const SizedBox(height: 6),
                            WTextField(
                              controller: _phoneController,
                              hintText: l10n.phoneHint,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [UzbekPhoneInputFormatter()],
                              enabled: !isLoading,
                            ),
                            const SizedBox(height: 12),
                            _label(l10n.emailLabel),
                            const SizedBox(height: 6),
                            WTextField(
                              controller: _emailController,
                              hintText: l10n.emailHint,
                              keyboardType: TextInputType.emailAddress,
                              enabled: !isLoading,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _sectionHeader(l10n.addressTitle),
                        const SizedBox(height: 12),
                        _card(
                          children: [
                            _label(l10n.cityLabel),
                            const SizedBox(height: 6),
                            WTextField(
                              controller: _cityController,
                              hintText: l10n.cityHint,
                              enabled: !isLoading,
                            ),
                            const SizedBox(height: 12),
                            _label(l10n.streetLabel),
                            const SizedBox(height: 6),
                            WTextField(
                              controller: _streetController,
                              hintText: l10n.streetHint,
                              enabled: !isLoading,
                            ),
                            const SizedBox(height: 12),
                            _label(l10n.houseLabel),
                            const SizedBox(height: 6),
                            WTextField(
                              controller: _houseController,
                              hintText: l10n.houseHint,
                              enabled: !isLoading,
                            ),
                            const SizedBox(height: 12),
                            _label(l10n.districtLabel),
                            const SizedBox(height: 6),
                            WTextField(
                              controller: _districtController,
                              hintText: l10n.districtHint,
                              enabled: !isLoading,
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
                              ),
                              const SizedBox(height: 12),
                              _label('Фамилия'),
                              const SizedBox(height: 6),
                              WTextField(
                                controller: _lastNameController,
                                hintText: 'Введите фамилию',
                                keyboardType: TextInputType.name,
                                enabled: !isLoading,
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
                              ),
                              const SizedBox(height: 12),
                              _label('Электронная почта'),
                              const SizedBox(height: 6),
                              WTextField(
                                controller: _emailController,
                                hintText: 'Введите E-mail',
                                keyboardType: TextInputType.emailAddress,
                                enabled: !isLoading,
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
                              ),
                              const SizedBox(height: 12),
                              _label('Улица'),
                              const SizedBox(height: 6),
                              WTextField(
                                controller: _streetController,
                                hintText: 'Введите улицу',
                                enabled: !isLoading,
                              ),
                              const SizedBox(height: 12),
                              _label('Дом / Квартира'),
                              const SizedBox(height: 6),
                              WTextField(
                                controller: _houseController,
                                hintText: 'Дом / Квартира',
                                enabled: !isLoading,
                              ),
                              const SizedBox(height: 12),
                              _label('Район'),
                              const SizedBox(height: 6),
                              WTextField(
                                controller: _districtController,
                                hintText: 'Введите район',
                                enabled: !isLoading,
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
    final l10n = AppLocalizations.of(context)!;

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

        return Row(
          children: [
            GestureDetector(
              onTap: _pickImageFromGallery,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.blue50,
                    backgroundImage: imageProvider,
                    onBackgroundImageError: imageProvider != null
                        ? (exception, stackTrace) {
                            // Xatoliklarni jim qabul qilamiz, debugger qotib qolmasligi uchun
                          }
                        : null,
                    child: imageProvider == null
                        ? const Icon(
                            Icons.person,
                            color: AppColors.blue500,
                            size: 36,
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: AppColors.blue500,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 12,
                        color: AppColors.white,
                      ),
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
                    text: l10n.profilePhotoLabel,
                    fontSize: 14,
                    fontWeight: 600,
                    color: AppColors.black500,
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: _pickImageFromGallery,
                    child: AppText(
                      text: l10n.chooseFromGallery,
                      fontSize: 13,
                      fontWeight: 400,
                      color: AppColors.blue500,
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
    final l10n = AppLocalizations.of(context)!;
    return {'male': l10n.genderMale, 'female': l10n.genderFemale};
  }

  String _genderHint(BuildContext context) {
    return AppLocalizations.of(context)!.genderHint;
  }

  Widget _genderDropdown(bool disabled) {
    final genderLabels = _localizedGenderLabels(context);

    return ValueListenableBuilder<String?>(
      valueListenable: _selectedGender,
      builder: (context, gender, _) {
        return Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.black50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.black100),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: gender,
              hint: AppText(
                text: _genderHint(context),
                fontSize: 14,
                fontWeight: 400,
                color: AppColors.black300,
              ),
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.black300,
              ),
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
                              color: AppColors.black500,
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
    final l10n = AppLocalizations.of(context)!;

    return ValueListenableBuilder<DateTime?>(
      valueListenable: _selectedDate,
      builder: (context, date, _) {
        return GestureDetector(
          onTap: disabled ? null : _pickDate,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.black50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.black100),
            ),
            child: Row(
              children: [
                Expanded(
                  child: AppText(
                    text: date != null ? _formatDate(date) : l10n.birthDatePlaceholder,
                    fontSize: 14,
                    fontWeight: 400,
                    color: date != null
                        ? AppColors.black500
                        : AppColors.black300,
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: AppColors.black300,
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
      color: AppColors.white,
      width: double.infinity,
      radius: 16,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: AppText(
          text: title,
          fontSize: 18,
          fontWeight: 700,
          color: AppColors.black500,
        ),
      ),
    );
  }

  Widget _card({required List<Widget> children}) {
    return ContainerW(
      width: double.infinity,
      color: AppColors.white,
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
      color: AppColors.black400,
    );
  }

  Widget _bottomButtons(BuildContext context, bool isLoading) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isLoading ? null : () => context.pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.black500,
                side: const BorderSide(color: AppColors.black100),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(l10n.actionCancel),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: isLoading ? null : _onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue500,
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
                  : Text(l10n.actionSave),
            ),
          ),
        ],
      ),
    );
  }
}
