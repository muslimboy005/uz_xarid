import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uz_xarid/core/constants/app_assets.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/widgets/app_image.dart';
import 'package:uz_xarid/core/widgets/app_text.dart';
import 'package:uz_xarid/core/widgets/profile_breadcrumb.dart';
import 'package:uz_xarid/core/widgets/uzxarid_app_bar.dart';
import 'package:uz_xarid/core/widgets/w__container.dart';
import 'package:uz_xarid/core/widgets/w_text_form.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uz_xarid/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:uz_xarid/features/profile/domain/entity/business_entity.dart';

class MyBusinessPage extends StatefulWidget {
  const MyBusinessPage({super.key});

  @override
  State<MyBusinessPage> createState() => _MyBusinessPageState();
}

class _MyBusinessPageState extends State<MyBusinessPage> {
  final _companyNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<TextEditingController> _phoneControllers = [
    TextEditingController(),
  ];
  final _cityController = TextEditingController();
  final _streetController = TextEditingController();
  final _houseController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _instagramController = TextEditingController();
  final _facebookController = TextEditingController();
  final _telegramController = TextEditingController();
  final _youtubeController = TextEditingController();

  File? _avatarFile;
  File? _bannerFile;
  final ImagePicker _picker = ImagePicker();

  String? _workingHours;
  String? _lunchBreak;

  Future<void> _pickImage(bool isAvatar) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (pickedFile != null) {
        setState(() {
          if (isAvatar) {
            _avatarFile = File(pickedFile.path);
          } else {
            _bannerFile = File(pickedFile.path);
          }
        });
      }
    } catch (_) {}
  }
  // String? _lunchBreak;

  @override
  void dispose() {
    _companyNameController.dispose();
    _descriptionController.dispose();
    for (var controller in _phoneControllers) {
      controller.dispose();
    }
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
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state.status == ProfileStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Xatolik')),
          );
        } else if (state.status == ProfileStatus.createBusinessSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Biznes muvaffaqiyatli saqlandi!')),
          );
          context.pop();
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: UzXaridAppBar(onSearchChanged: (query) {}, onMenuTap: () {}),
          backgroundColor: AppColors.primary,
          body: Container(
            decoration: BoxDecoration(color: AppColors.black50),
            child: SafeArea(
              child: Column(
                children: [
                  ProfileBreadcrumb(
                    labels: const ['Главная', 'Профиль', 'Мой бизнес'],
                    onTaps: [
                      () => context.go('/home'),
                      () => context.go('/profile'),
                      null,
                    ],
                  ),
                  SizedBox(height: 16),
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
                          text: 'Мой бизнес',
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
                          ContainerW(
                            color: AppColors.white,
                            radius: 12,
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 19,
                              ),
                              child: AppText(
                                text: 'Информация о компании',
                                fontSize: 16,
                                fontWeight: 600,
                                color: AppColors.black500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
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
                                        color: AppColors.blue500.withOpacity(
                                          0.1,
                                        ),
                                        radius: 32,
                                        child: _avatarFile != null
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(32),
                                                child: Image.file(
                                                  _avatarFile!,
                                                  width: 64,
                                                  height: 64,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : Padding(
                                                padding: const EdgeInsets.all(
                                                  16.0,
                                                ),
                                                child: AppImage(
                                                  path: AppAssets.workBlue,
                                                  size: 32,
                                                ),
                                              ),
                                      ),
                                      const SizedBox(width: 12),
                                      GestureDetector(
                                        onTap: () => _pickImage(true),
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
                                                  text: 'Изменить аватар',
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
                                  WTextField(
                                    title: 'Название компании',
                                    hintText: 'Введите название компании',
                                    controller: _companyNameController,
                                  ),
                                  const SizedBox(height: 16),
                                  WTextField(
                                    title: 'Отзыв',
                                    hintText: 'Описание',
                                    controller: _descriptionController,
                                    maxLines: 4,
                                    minLines: 4,
                                  ),
                                  const SizedBox(height: 16),
                                  GestureDetector(
                                    onTap: () => _pickImage(false),
                                    child: DottedBorder(
                                      options: RoundedRectDottedBorderOptions(
                                        color: AppColors.black200,
                                        strokeWidth: 1.5,
                                        dashPattern: const [8, 4],
                                        radius: const Radius.circular(12),
                                      ),
                                      child: Container(
                                        height: 120,
                                        width: double.infinity,
                                        alignment: Alignment.center,
                                        child: _bannerFile != null
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Image.file(
                                                  _bannerFile!,
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.add,
                                                    size: 48,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  AppText(
                                                    text: 'Загрузить обложку',
                                                    fontSize: 14,
                                                    fontWeight: 500,
                                                    color: AppColors.black300,
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          ContainerW(
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
                                      text: 'Контактные данные',
                                      fontSize: 15,
                                      fontWeight: 600,
                                      color: AppColors.black500,
                                    ),
                                  ),
                                  if (_phoneControllers.length < 4)
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _phoneControllers.add(
                                            TextEditingController(),
                                          );
                                        });
                                      },
                                      child: ContainerW(
                                        color: AppColors.black50,
                                        radius: 8,
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Icon(
                                            Icons.add,
                                            color: AppColors.black500,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ContainerW(
                            color: AppColors.white,
                            radius: 12,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: List.generate(
                                  _phoneControllers.length,
                                  (index) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        bottom:
                                            index ==
                                                _phoneControllers.length - 1
                                            ? 0
                                            : 12,
                                      ),
                                      child: WTextField(
                                        title: 'Телефон ${index + 1}',
                                        hintText: 'Введите номер',
                                        controller: _phoneControllers[index],
                                        keyboardType: TextInputType.phone,
                                        suffixIconWidget: index > 0
                                            ? GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _phoneControllers[index]
                                                        .dispose();
                                                    _phoneControllers.removeAt(
                                                      index,
                                                    );
                                                  });
                                                },
                                                child: const Icon(
                                                  Icons.delete_outline,
                                                  color: AppColors.red,
                                                  size: 24,
                                                ),
                                              )
                                            : null,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          ContainerW(
                            color: AppColors.white,
                            radius: 12,
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 19,
                              ),
                              child: AppText(
                                text: 'Рабочее время',
                                fontSize: 16,
                                fontWeight: 600,
                                color: AppColors.black500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ContainerW(
                            color: AppColors.white,
                            radius: 12,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(
                                    text: 'Рабочие дни и время',
                                    fontSize: 13,
                                    fontWeight: 500,
                                    color: AppColors.black500,
                                  ),
                                  const SizedBox(height: 6),
                                  _DropdownField(
                                    value: _workingHours,
                                    hint: 'Например: Пн.–Пя. с 9:00 до 18:00',
                                    items: const [
                                      'Пн.–Пя. с 9:00 до 18:00',
                                      'Пн.–Сб. с 9:00 до 18:00',
                                      'Ежедневно с 9:00 до 22:00',
                                    ],
                                    onChanged: (v) =>
                                        setState(() => _workingHours = v),
                                  ),
                                  const SizedBox(height: 12),
                                  AppText(
                                    text: 'Перерыв (обед)',
                                    fontSize: 13,
                                    fontWeight: 500,
                                    color: AppColors.black500,
                                  ),
                                  const SizedBox(height: 6),
                                  _DropdownField(
                                    value: _lunchBreak,
                                    hint: 'Например: 13:00–14:00',
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

                          ContainerW(
                            color: AppColors.white,
                            radius: 12,
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 19,
                              ),
                              child: AppText(
                                text: 'Адрес',
                                fontSize: 16,
                                fontWeight: 600,
                                color: AppColors.black500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ContainerW(
                            color: AppColors.white,
                            radius: 12,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  WTextField(
                                    title: 'Город',
                                    hintText: 'Введите город',
                                    controller: _cityController,
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: WTextField(
                                          title: 'Улица',
                                          hintText: 'Введите улицу',
                                          controller: _streetController,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: WTextField(
                                          title: 'Дом / Квартира',
                                          hintText: 'Дом / Квартира',
                                          controller: _houseController,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  WTextField(
                                    title: 'Ориентир',
                                    hintText: 'Укажите ближайший ориентир',
                                    controller: _landmarkController,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ContainerW(
                            color: AppColors.white,
                            radius: 12,
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 19,
                              ),
                              child: AppText(
                                text: 'Социальные сети',
                                fontSize: 16,
                                fontWeight: 600,
                                color: AppColors.black500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ContainerW(
                            color: AppColors.white,
                            radius: 12,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  WTextField(
                                    title: 'Instagram',
                                    hintText: 'Введите ссылку на Instagram',
                                    controller: _instagramController,
                                    prefixIcon: const Icon(
                                      Icons.camera_alt_outlined,
                                      size: 18,
                                      color: AppColors.black300,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  WTextField(
                                    title: 'Facebook',
                                    hintText: 'Введите ссылку на Facebook',
                                    controller: _facebookController,
                                    prefixIcon: const Icon(
                                      Icons.facebook_rounded,
                                      size: 18,
                                      color: AppColors.black300,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  WTextField(
                                    title: 'Telegram',
                                    hintText: 'Введите ссылку на Telegram',
                                    controller: _telegramController,
                                    prefixIcon: const Icon(
                                      Icons.send_rounded,
                                      size: 18,
                                      color: AppColors.black300,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  WTextField(
                                    title: 'YouTube',
                                    hintText: 'Введите ссылку на YouTube',
                                    controller: _youtubeController,
                                    prefixIcon: const Icon(
                                      Icons.play_circle_outline_rounded,
                                      size: 18,
                                      color: AppColors.black300,
                                    ),
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
                                      border: Border.all(
                                        color: AppColors.black100,
                                      ),
                                    ),
                                    child: Center(
                                      child: AppText(
                                        text: 'Отмена',
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
                                  onTap: () {
                                    final entity = BusinessEntity(
                                      name: _companyNameController.text.trim(),
                                      avatarPath: _avatarFile?.path,
                                      bannerPath: _bannerFile?.path,
                                      bio: _descriptionController.text.trim(),
                                      addressCity: _cityController.text.trim(),
                                      addressRoad: _streetController.text
                                          .trim(),
                                      addressHome: _houseController.text.trim(),
                                      addressOrientation: _landmarkController
                                          .text
                                          .trim(),
                                      addressLat: 41.2995,
                                      addressLong: 69.2401,
                                      instagram: _instagramController.text
                                          .trim(),
                                      facebook: _facebookController.text.trim(),
                                      telegram: _telegramController.text.trim(),
                                      youtube: _youtubeController.text.trim(),
                                      workDays: "1,2,3,4,5",
                                      workHours: _workingHours ?? "09:00-18:00",
                                      contacts: _phoneControllers
                                          .map((e) => e.text.trim())
                                          .where((e) => e.isNotEmpty)
                                          .toList(),
                                    );
                                    context.read<ProfileBloc>().add(
                                      ProfileCreateBusinessEvent(entity),
                                    );
                                  },
                                  child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: AppColors.blue500,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child:
                                          state.status == ProfileStatus.loading
                                          ? const CircularProgressIndicator(
                                              color: AppColors.white,
                                            )
                                          : AppText(
                                              text: 'Сохранить',
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
      },
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
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.black100),
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