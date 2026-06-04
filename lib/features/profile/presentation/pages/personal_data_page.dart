import 'dart:io';

import 'package:flutter/material.dart';
import 'package:uzxarid/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uzxarid/core/constants/app_assets.dart';
import 'package:uzxarid/core/constants/app_colors.dart';
import 'package:uzxarid/core/cubit/app_mode_cubit.dart';
import 'package:uzxarid/core/theme/theme_colors.dart';
import 'package:uzxarid/core/utils/image_parser.dart';
import 'package:uzxarid/core/utils/input_formatters.dart';
import 'package:uzxarid/core/widgets/app_image.dart';
import 'package:uzxarid/core/widgets/app_text.dart';
import 'package:uzxarid/core/widgets/uzxarid_app_bar.dart';
import 'package:uzxarid/core/widgets/w__container.dart';
import 'package:uzxarid/core/widgets/w_text_form.dart';
import 'package:uzxarid/features/profile/data/model/profile_model.dart';
import 'package:uzxarid/features/profile/presentation/bloc/profile_bloc.dart';

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
  final _propiska = ValueNotifier<String>('');
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
    _phoneController.text = formatUzbekPhone(profile.phone);
    _emailController.text = profile.email;
    final g = profile.gender;
    if (g == 'male' || g == 'female') {
      _selectedGender.value = g;
    }
    if (profile.avatar.isNotEmpty) {
      _serverAvatarUrl.value = profile.avatar;
    }
    final dob = DateTime.tryParse(profile.dateOfBirth);
    if (dob != null) {
      _selectedDate.value = dob;
    }
    _propiska.value = profile.address;
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
    _propiska.dispose();
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
        phone: _phoneController.text.replaceAll(RegExp(r'\D'), ''),
        email: _emailController.text.trim(),
        city: _cityController.text.trim(),
        street: _streetController.text.trim(),
        house: _houseController.text.trim(),
        district: _districtController.text.trim(),
        gender: _selectedGender.value,
        avatarPath: _avatarFile.value?.path,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!context.mounted) return const SizedBox.shrink();
    final borderColor = context.borderColor;
    final l10n = AppLocalizations.of(context)!;
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

        return UzXaridScaffold(
          backgroundColor: bodyBg,
          body: Column(
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
                                  text: l10n.profilePersonalDataLabel,
                                  fontSize: 20,
                                  fontWeight: 700,
                                  color: textColor,
                                ),
                              ],
                            ),
                          ),
                          // _sectionHeader(l10n.profilePersonalDataLabel),
                          const SizedBox(height: 8),
                          _card(
                            children: [
                              _avatarRow(),
                              const SizedBox(height: 12),
                              _label(l10n.profileFirstNameLabel),
                              const SizedBox(height: 4),
                              _readOnlyController(
                                _firstNameController,
                                l10n.profileFirstNameHint,
                              ),
                              const SizedBox(height: 8),
                              _label(l10n.profileLastNameLabel),
                              const SizedBox(height: 4),
                              _readOnlyController(
                                _lastNameController,
                                l10n.profileLastNameHint,
                              ),
                              const SizedBox(height: 8),
                              _label(l10n.profileGenderLabel),
                              const SizedBox(height: 4),
                              _genderDropdown(isLoading),
                              const SizedBox(height: 8),
                              _label(l10n.profileBirthDateLabel),
                              const SizedBox(height: 4),
                              _dateField(),
                              const SizedBox(height: 8),
                              _label(l10n.profileResidenceLabel),
                              const SizedBox(height: 4),
                              _propiskaField(),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _sectionHeader(l10n.profileContactDataLabel),
                          const SizedBox(height: 8),
                          _card(
                            children: [
                              _label(l10n.profilePhoneLabel),
                              const SizedBox(height: 4),
                              WTextField(
                                controller: _phoneController,
                                hintText: l10n.profilePhoneHint,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [UzbekPhoneInputFormatter()],
                                enabled: !isLoading,
                                height: 44,
                                fillColor: surfaceContainer,
                                borderNoFocusColor: borderColor,
                              ),
                              const SizedBox(height: 8),
                              _label(l10n.profileEmailLabel),
                              const SizedBox(height: 4),
                              WTextField(
                                controller: _emailController,
                                hintText: l10n.profileEmailHint,
                                keyboardType: TextInputType.emailAddress,
                                enabled: !isLoading,
                                height: 44,
                                fillColor: surfaceContainer,
                                borderNoFocusColor: borderColor,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _sectionHeader(l10n.profileAddressSectionLabel),
                          const SizedBox(height: 8),
                          _card(
                            children: [
                              _label(l10n.profileCityLabel),
                              const SizedBox(height: 4),
                              WTextField(
                                controller: _cityController,
                                hintText: l10n.profileCityHint,
                                enabled: !isLoading,
                                height: 44,
                                fillColor: surfaceContainer,
                                borderNoFocusColor: borderColor,
                              ),
                              const SizedBox(height: 8),
                              _label(l10n.profileStreetLabel),
                              const SizedBox(height: 4),
                              WTextField(
                                controller: _streetController,
                                hintText: l10n.profileStreetHint,
                                enabled: !isLoading,
                                height: 44,
                                fillColor: surfaceContainer,
                                borderNoFocusColor: borderColor,
                              ),
                              const SizedBox(height: 8),
                              _label(l10n.profileHouseOrAptLabel),
                              const SizedBox(height: 4),
                              WTextField(
                                controller: _houseController,
                                hintText: l10n.profileHouseOrAptLabel,
                                enabled: !isLoading,
                                height: 44,
                                fillColor: surfaceContainer,
                                borderNoFocusColor: borderColor,
                              ),
                              const SizedBox(height: 8),
                              _label(l10n.profileDistrictLabel),
                              const SizedBox(height: 4),
                              WTextField(
                                controller: _districtController,
                                hintText: l10n.profileDistrictHint,
                                enabled: !isLoading,
                                height: 44,
                                fillColor: surfaceContainer,
                                borderNoFocusColor: borderColor,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  _bottomButtons(context, isLoading, l10n),
                ],
              ),
        );
      },
    );
  }

  Widget _avatarRow() {
    return ListenableBuilder(
      listenable: Listenable.merge([_avatarFile, _serverAvatarUrl]),
      builder: (context, _) {
        final avatar = _avatarFile.value;
        final l10n = AppLocalizations.of(context)!;
        ImageProvider? imageProvider;
        if (avatar != null) {
          imageProvider = FileImage(avatar);
        } else if (_serverAvatarUrl.value != null &&
            _serverAvatarUrl.value!.isNotEmpty) {
          String url = _serverAvatarUrl.value!.replaceFirst('file://', '');
          if (url.startsWith('/')) {
            url = 'https://api.uzxarid.uz$url';
          }
          imageProvider = NetworkImage(url.cdnUrl);
        }

        final primaryColor = context.watch<AppModeCubit>().state.primaryColor;
        final textColor = context.textPrimary;
        final avatarBg = context.isDark
            ? primaryColor.withValues(alpha: 0.25)
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
                        ? Icon(Icons.person, color: primaryColor, size: 36)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: primaryColor,
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
                    text: l10n.profilePhotoLabel,
                    fontSize: 14,
                    fontWeight: 600,
                    color: textColor,
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: _pickImageFromGallery,
                    child: AppText(
                      text: l10n.profileChooseFromGallery,
                      fontSize: 13,
                      fontWeight: 400,
                      color: primaryColor,
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
    return {'male': l10n.profileGenderMale, 'female': l10n.profileGenderFemale};
  }

  String _genderHint(BuildContext context) {
    return AppLocalizations.of(context)!.profileGenderHint;
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
          height: 44,
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

  // Tug'ilgan sana - faqat ko'rsatish uchun (o'zgartirib bo'lmaydi)
  Widget _dateField() {
    return ValueListenableBuilder<DateTime?>(
      valueListenable: _selectedDate,
      builder: (context, date, _) {
        return _readOnlyField(
          value: date != null ? _formatDate(date) : '',
          placeholder: AppLocalizations.of(context)!.profileBirthDateHint,
        );
      },
    );
  }

  // Propiska (yashash manzili) - faqat ko'rsatish uchun
  Widget _propiskaField() {
    return ValueListenableBuilder<String>(
      valueListenable: _propiska,
      builder: (context, address, _) {
        return _readOnlyField(
          value: address,
          placeholder: '—',
        );
      },
    );
  }

  // Controller qiymatini ko'rsatadigan read-only maydon (ism, familiya)
  Widget _readOnlyController(
    TextEditingController controller,
    String placeholder,
  ) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        return _readOnlyField(value: value.text, placeholder: placeholder);
      },
    );
  }

  // O'zgarmaydigan (read-only) maydon
  Widget _readOnlyField({
    required String value,
    required String placeholder,
  }) {
    final textColor = context.textPrimary;
    final textSecondary = context.textSecondary;
    final surfaceContainer = context.surfaceContainer;
    final borderColor = context.borderColor;
    final hasValue = value.trim().isNotEmpty;

    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: AppText(
              text: hasValue ? value : placeholder,
              fontSize: 14,
              fontWeight: 400,
              color: hasValue ? textColor : textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.lock_outline, size: 16, color: textSecondary),
        ],
      ),
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

  Widget _bottomButtons(
    BuildContext context,
    bool isLoading,
    AppLocalizations l10n,
  ) {
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
              child: Text(l10n.actionCancel),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: isLoading ? null : _onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.isDark
                    ? AppColors.darkBackground
                    : context.watch<AppModeCubit>().state.primaryColor,
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
                  : Text(l10n.addressSave),
            ),
          ),
        ],
      ),
    );
  }
}
