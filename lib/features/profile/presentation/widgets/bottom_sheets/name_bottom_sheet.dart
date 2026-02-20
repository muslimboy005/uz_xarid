import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uz_xarid/core/constants/app_assets.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/constants/app_dimens.dart';
import 'package:uz_xarid/core/widgets/app_image.dart';
import 'package:uz_xarid/core/widgets/app_text.dart';
import 'package:uz_xarid/core/widgets/w__container.dart';
import 'package:uz_xarid/core/utils/error_handler.dart';
import 'package:uz_xarid/features/profile/domain/entity/full_name.dart';
import 'package:uz_xarid/features/profile/presentation/bloc/profile_bloc.dart';

class NameBottomSheet extends StatefulWidget {
  const NameBottomSheet({super.key});

  static void show(BuildContext parentContext) {
    showModalBottomSheet<void>(
      context: parentContext,
      isScrollControlled: true,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return BlocProvider.value(
          value: parentContext.read<ProfileBloc>(),
          child: const NameBottomSheet(),
        );
      },
    );
  }

  @override
  State<NameBottomSheet> createState() => _NameBottomSheetState();
}

class _NameBottomSheetState extends State<NameBottomSheet> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state.status == ProfileStatus.success) {
          if (context.mounted) {
            final profileBloc = context.read<ProfileBloc>();
            Navigator.of(context).pop();

            Future.delayed(const Duration(milliseconds: 300), () {
              profileBloc.add(const ProfileLoadEvent());
            });
          }
        } else if (state.status == ProfileStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(getFriendlyErrorMessage(state.errorMessage)),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state.status == ProfileStatus.loading;

        return Container(
          height:
              MediaQuery.of(context).size.height -
              (MediaQuery.of(context).padding.top + 250),
          child: Padding(
            padding: EdgeInsets.only(
              left: AppDimens.paddingMedium,
              right: AppDimens.paddingMedium,
              top: 10,
              bottom:
                  MediaQuery.of(context).viewInsets.bottom +
                  AppDimens.paddingMedium,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.paddingLarge),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 24), // Spacer for centering
                    AppText(
                      text: 'Почти готово',
                      fontSize: 16,
                      fontWeight: 700,
                      color: AppColors.black500,
                    ),
                    AppImage(
                      path: AppAssets.close,
                      size: 24,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 21),
                AppText(
                  text: 'Ваш профиль почти готов, представьтесь',
                  fontSize: 14,
                  fontWeight: 400,
                  color: AppColors.black300,
                ),
                const SizedBox(height: 20),
                AppText(
                  text: 'Имя',
                  fontSize: 14,
                  fontWeight: 700,
                  color: AppColors.black500,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _firstNameController,
                  enabled: !isLoading,
                  decoration: const InputDecoration(
                    hintText: 'Ваше имя',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppDimens.paddingLarge),
                AppText(
                  text: 'Фамилия',
                  fontSize: 14,
                  fontWeight: 700,
                  color: AppColors.black500,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _lastNameController,
                  enabled: !isLoading,
                  decoration: const InputDecoration(
                    hintText: 'Ваша фамилия',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppDimens.paddingLarge),
                ContainerW(
                  color: AppColors.blue500,
                  radius: 12,
                  onTap: isLoading
                      ? null
                      : () {
                          if (_firstNameController.text.trim().isEmpty ||
                              _lastNameController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Iltimos, ism va familiyani kiriting',
                                ),
                              ),
                            );
                            return;
                          }

                          context.read<ProfileBloc>().add(
                            ProfileSignSubmitEvent(
                              FullNameEntity(
                                firstName: _firstNameController.text.trim(),
                                lastName: _lastNameController.text.trim(),
                              ),
                            ),
                          );
                        },
                  child: isLoading
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Center(
                            child: const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Center(
                            child: AppText(
                              text: 'Продолжить',
                              fontSize: 16,
                              fontWeight: 500,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
