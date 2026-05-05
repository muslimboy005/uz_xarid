import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uz_xarid/core/constants/app_assets.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/constants/app_dimens.dart';
import 'package:uz_xarid/core/cubit/app_mode_cubit.dart';
import 'package:uz_xarid/core/theme/theme_colors.dart';
import 'package:pinput/pinput.dart';
import 'package:uz_xarid/core/dp/infection.dart';
import 'package:uz_xarid/core/service/local_service.dart';
import 'package:uz_xarid/core/utils/input_formatters.dart';
import 'package:uz_xarid/core/widgets/app_image.dart';
import 'package:uz_xarid/core/widgets/app_text.dart';
import 'package:uz_xarid/core/widgets/w__container.dart';
import 'package:uz_xarid/features/profile/data/model/otp_model.dart';
import 'package:uz_xarid/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:uz_xarid/l10n/app_localizations.dart';

class OtpBottomSheet extends StatefulWidget {
  final String phone;
  final VoidCallback onAskName;
  final VoidCallback? onOtpSuccess;

  const OtpBottomSheet({
    super.key,
    required this.phone,
    required this.onAskName,
    this.onOtpSuccess,
  });

  static void show(
    BuildContext parentContext,
    String phone, {
    required VoidCallback onAskName,
    VoidCallback? onOtpSuccess,
  }) {
    showModalBottomSheet<void>(
      context: parentContext,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      builder: (sheetContext) {
        return BlocProvider.value(
          value: parentContext.read<ProfileBloc>(),
          child: OtpBottomSheet(
            phone: phone,
            onAskName: onAskName,
            onOtpSuccess: onOtpSuccess,
          ),
        );
      },
    );
  }

  @override
  State<OtpBottomSheet> createState() => _OtpBottomSheetState();
}

class _OtpBottomSheetState extends State<OtpBottomSheet> {
  final TextEditingController _otpController = TextEditingController();

  Timer? _timer;
  int _retryCount = 0;
  bool _isSuccessHandled = false;

  final _timerSeconds = ValueNotifier<int>(120);
  final _isResendEnabled = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    if (_retryCount >= 3) {
      _isResendEnabled.value = false;
      return;
    }

    _timerSeconds.value = 120;
    _isResendEnabled.value = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds.value == 0) {
        _isResendEnabled.value = true;
        timer.cancel();
      } else {
        _timerSeconds.value--;
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _timerSeconds.dispose();
    _isResendEnabled.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) async {
        if (state.status == ProfileStatus.success && !_isSuccessHandled) {
          _isSuccessHandled = true;
          final profileData = state.profileModel?.data;

          if (profileData?.token != null) {
            await getIt<SecureStorageService>().saveTokens(
              profileData!.token!.access,
              profileData.token!.refresh,
            );
          }

          widget.onOtpSuccess?.call();

          if (context.mounted) {
            Navigator.of(context).pop(true); // Return true indicating success
          }

          Future.delayed(const Duration(milliseconds: 200), () {
            if (profileData?.askName == true) {
              widget.onAskName();
            }
          });
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
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: AppDimens.paddingMedium,
              right: AppDimens.paddingMedium,
              top: AppDimens.paddingSmall2,
              bottom:
                  MediaQuery.of(context).viewInsets.bottom +
                  AppDimens.paddingMedium,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 24),
                    AppText(
                      text: l10n.otpSheetTitle,
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: [
                        TextSpan(
                          text: l10n.otpSentToNumber(formatPhone(widget.phone)),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Pinput(
                  controller: _otpController,
                  length: 6,
                  autofocus: true,
                  defaultPinTheme: PinTheme(
                    width: 50,
                    height: 50,
                    textStyle: TextStyle(
                      fontSize: 20,
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: BoxDecoration(
                      color: surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                  ),
                  focusedPinTheme: PinTheme(
                    width: 50,
                    height: 50,
                    textStyle: TextStyle(
                      fontSize: 20,
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: context.watch<AppModeCubit>().state.primaryColor,
                        width: 2,
                      ),
                    ),
                  ),
                  submittedPinTheme: PinTheme(
                    width: 50,
                    height: 50,
                    textStyle: TextStyle(
                      fontSize: 20,
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: BoxDecoration(
                      color: surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                  ),
                  showCursor: true,
                  preFilledWidget: Text(
                    '-',
                    style: TextStyle(color: textSecondary, fontSize: 24),
                  ),
                  onCompleted: (_) {},
                ),
                const SizedBox(height: 20),
                ContainerW(
                  color: AppColors.blue500,
                  radius: 12,
                  onTap: isLoading
                      ? null
                      : () {
                          if (_otpController.text.length != 6) {
                            return;
                          }

                          final phoneDigits = widget.phone.replaceAll(
                            RegExp(r'\D'),
                            '',
                          );

                          context.read<ProfileBloc>().add(
                            ProfileConfirmOtpEvent(
                              otpModel: OtpModel(
                                phone: phoneDigits,
                                otp: _otpController.text,
                              ),
                            ),
                          );
                        },
                  child: Padding(
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
                const SizedBox(height: AppDimens.paddingMedium),
                const SizedBox(height: 20),
                ValueListenableBuilder<bool>(
                  valueListenable: _isResendEnabled,
                  builder: (context, resendEnabled, _) {
                    return ValueListenableBuilder<int>(
                      valueListenable: _timerSeconds,
                      builder: (context, seconds, _) {
                        return Center(
                          child: TextButton(
                            onPressed: (isLoading || !resendEnabled)
                                ? null
                                : () {
                                    if (_retryCount >= 3) return;

                                    final phoneDigits = widget.phone.replaceAll(
                                      RegExp(r'\D'),
                                      '',
                                    );
                                    context.read<ProfileBloc>().add(
                                      ProfileResendOtpEvent(phone: phoneDigits),
                                    );

                                    _retryCount++;
                                    _startTimer();
                                  },
                            child: Text(
                              resendEnabled
                                  ? l10n.otpResend
                                  : l10n.otpResendCountdown(seconds.toString()),
                              style: TextStyle(
                                color: (isLoading || !resendEnabled)
                                    ? textSecondary
                                    : context
                                          .watch<AppModeCubit>()
                                          .state
                                          .primaryColor,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
