import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uz_xarid/core/constants/app_assets.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/constants/app_dimens.dart';
import 'package:uz_xarid/core/utils/error_handler.dart';
import 'package:uz_xarid/core/utils/input_formatters.dart';
import 'package:uz_xarid/core/widgets/app_image.dart';
import 'package:uz_xarid/core/widgets/app_text.dart';
import 'package:uz_xarid/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:uz_xarid/l10n/app_localizations.dart';

class PhoneBottomSheet extends StatefulWidget {
  final ValueChanged<String> onCodeSent;

  const PhoneBottomSheet({super.key, required this.onCodeSent});

  static void show(
    BuildContext parentContext, {
    required ValueChanged<String> onCodeSent,
  }) {
    showModalBottomSheet<void>(
      context: parentContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return BlocProvider.value(
          value: parentContext.read<ProfileBloc>(),
          child: PhoneBottomSheet(onCodeSent: onCodeSent),
        );
      },
    );
  }

  @override
  State<PhoneBottomSheet> createState() => _PhoneBottomSheetState();
}

class _PhoneBottomSheetState extends State<PhoneBottomSheet> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state.status == ProfileStatus.success) {
          Navigator.of(context).pop();
          widget.onCodeSent(_phoneController.text);
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

        // Calculate height: Screen Height - Top Padding - AppBar Height (112)
        // UzXaridAppBar height is 112.
        return Container(
          height:
              MediaQuery.of(context).size.height -
              (MediaQuery.of(context).padding.top + 250),
          padding: EdgeInsets.only(
            left: AppDimens.paddingMedium,
            right: AppDimens.paddingMedium,
            top: AppDimens.paddingSmall2,
            bottom:
                MediaQuery.of(context).viewInsets.bottom +
                AppDimens.paddingMedium,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.black400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 24), // Spacer for centering
                  AppText(
                    text: l10n.loginSheetTitle,
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
              SizedBox(height: 21),
              AppText(
                text: l10n.loginSheetDescription,
                textAlign: TextAlign.center,
                fontSize: 14,
                fontWeight: 400,
                color: AppColors.black300,
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: AppText(
                  text: l10n.loginPhoneLabel,
                  fontSize: 14,
                  fontWeight: 700,
                  color: AppColors.black500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.number,
                enabled: !isLoading,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  UzbekPhoneInputFormatter(),
                ],
                decoration: InputDecoration(
                  hintText: l10n.loginPhoneHint,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: isLoading
                      ? null
                      : () {
                          final digits = _phoneController.text.replaceAll(
                            RegExp(r'\D'),
                            '',
                          );

                          if (digits.length != 12 ||
                              !digits.startsWith('998')) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  l10n.loginPhoneError,
                                ),
                              ),
                            );
                            return;
                          }

                          context.read<ProfileBloc>().add(
                            ProfileSendOtpEvent(otpModel: digits),
                          );
                        },
                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                    )
                    : Text(
                        l10n.loginGetCode,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Text.rich(
                  TextSpan(
                    text: l10n.loginPolicyPrefix,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    children: [
                      TextSpan(
                        text: l10n.loginPolicyLink,
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                        // recognizer: TapGestureRecognizer()..onTap = () {},
                      ),
                      TextSpan(
                        text: l10n.loginPolicySuffix,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
