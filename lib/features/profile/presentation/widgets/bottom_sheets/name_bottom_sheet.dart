import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uz_xarid/core/constants/app_assets.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/constants/app_dimens.dart';
import 'package:uz_xarid/core/theme/theme_colors.dart';
import 'package:uz_xarid/core/widgets/app_image.dart';
import 'package:uz_xarid/core/widgets/app_text.dart';
import 'package:uz_xarid/core/widgets/w__container.dart';
import 'package:uz_xarid/core/utils/error_handler.dart';
import 'package:uz_xarid/features/profile/domain/entity/full_name.dart';
import 'package:uz_xarid/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:uz_xarid/l10n/app_localizations.dart';

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
  bool _isSuccessHandled = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state.status == ProfileStatus.success && !_isSuccessHandled) {
          _isSuccessHandled = true;
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
        final cardColor = context.cardSurface;
        final textColor = context.textPrimary;
        final textSecondary = context.textSecondary;
        final surfaceContainer = context.surfaceContainer;
        final borderColor = context.borderColor;

        return Container(
          height:
              MediaQuery.of(context).size.height -
              (MediaQuery.of(context).padding.top + 250),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
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
                      color: textSecondary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.paddingLarge),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 24),
                    AppText(
                      text: l10n.nameSheetTitle,
                      fontSize: 16,
                      fontWeight: 700,
                      color: textColor,
                    ),
                    AppImage(
                      path: AppAssets.close,
                      size: 24,
                      color: textColor,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 21),
                AppText(
                  text: l10n.nameSheetSubtitle,
                  fontSize: 14,
                  fontWeight: 400,
                  color: textSecondary,
                ),
                const SizedBox(height: 20),
                AppText(
                  text: l10n.firstNameLabel,
                  fontSize: 14,
                  fontWeight: 700,
                  color: textColor,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _firstNameController,
                  enabled: !isLoading,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: l10n.firstNameHint,
                    hintStyle: TextStyle(color: textSecondary),
                    fillColor: surfaceContainer,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
                      borderSide: BorderSide(color: borderColor),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.paddingLarge),
                AppText(
                  text: l10n.lastNameLabel,
                  fontSize: 14,
                  fontWeight: 700,
                  color: textColor,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _lastNameController,
                  enabled: !isLoading,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: l10n.lastNameHint,
                    hintStyle: TextStyle(color: textSecondary),
                    fillColor: surfaceContainer,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
                      borderSide: BorderSide(color: borderColor),
                    ),
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
                              SnackBar(
                                content: Text(
                                  l10n.nameRequiredError,
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
                              text: l10n.actionContinue,
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
