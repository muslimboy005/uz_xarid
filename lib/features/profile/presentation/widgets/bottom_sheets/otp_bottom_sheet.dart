import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uz_xarid/core/constants/app_assets.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/constants/app_dimens.dart';
import 'package:pinput/pinput.dart';
import 'package:uz_xarid/core/dp/infection.dart';
import 'package:uz_xarid/core/service/local_service.dart';
import 'package:uz_xarid/core/utils/error_handler.dart';
import 'package:uz_xarid/core/utils/input_formatters.dart';
import 'package:uz_xarid/core/widgets/app_image.dart';
import 'package:uz_xarid/core/widgets/app_text.dart';
import 'package:uz_xarid/core/widgets/w__container.dart';
import 'package:uz_xarid/features/profile/data/model/otp_model.dart';
import 'package:uz_xarid/features/profile/presentation/bloc/profile_bloc.dart';

class OtpBottomSheet extends StatefulWidget {
  final String phone;
  final VoidCallback onAskName;

  const OtpBottomSheet({
    super.key,
    required this.phone,
    required this.onAskName,
  });

  static void show(
    BuildContext parentContext,
    String phone, {
    required VoidCallback onAskName,
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
          child: OtpBottomSheet(phone: phone, onAskName: onAskName),
        );
      },
    );
  }

  @override
  State<OtpBottomSheet> createState() => _OtpBottomSheetState();
}

class _OtpBottomSheetState extends State<OtpBottomSheet> {
  final TextEditingController _otpController = TextEditingController();

  // Timer related
  Timer? _timer;
  int _start = 120; // 2 minutes
  bool _isResendEnabled = false;
  int _retryCount = 0;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    if (_retryCount >= 3) {
      setState(() {
        _isResendEnabled = false;
      });
      return;
    }

    _start = 120;
    _isResendEnabled = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          _isResendEnabled = true;
          timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) async {
        if (state.status == ProfileStatus.success) {
          final profileData = state.profileModel?.data;

          if (profileData?.token != null) {
            await getIt<SecureStorageService>().saveTokens(
              profileData!.token!.access,
              profileData.token!.refresh,
            );
          }

          if (context.mounted) {
            Navigator.of(context).pop();
          }

          Future.delayed(const Duration(milliseconds: 200), () {
            if (profileData?.askName == true) {
              widget.onAskName();
            } else {}
          });
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
                      color: AppColors.black500,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 24), // Spacer for centering
                    AppText(
                      text: 'Введите код',
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: [
                        const TextSpan(
                          text: 'Код был отправлен на ваш номер телефона  ',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.black300,
                          ),
                        ),
                        TextSpan(
                          text: "${formatPhone(widget.phone)}.",
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const TextSpan(
                          text: 'Пожалуйста, проверьте SMS.',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.black300,
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
                    textStyle: const TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                  ),
                  focusedPinTheme: PinTheme(
                    width: 50,
                    height: 50,
                    textStyle: const TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue, width: 2),
                    ),
                  ),
                  submittedPinTheme: PinTheme(
                    width: 50,
                    height: 50,
                    textStyle: const TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                  ),
                  showCursor: true,
                  // Placeholder for empty fields as requested (dash)
                  preFilledWidget: const Text(
                    '-',
                    style: TextStyle(color: Colors.grey, fontSize: 24),
                  ),
                  onCompleted: (pin) {
                    // Optional: Auto submit when filled
                  },
                ),
                const SizedBox(height: 20),
                ContainerW(
                  color: AppColors.blue500,
                  radius: 12,
                  onTap: isLoading
                      ? null
                      : () {
                          if (_otpController.text.length != 6) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('6 xonali SMS kodini kiriting'),
                              ),
                            );
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
                        text: 'Продолжить',
                        fontSize: 16,
                        fontWeight: 500,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.paddingMedium),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: (isLoading || !_isResendEnabled)
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

                            setState(() {
                              _retryCount++;
                              startTimer();
                            });
                          },
                    child: Text(
                      _isResendEnabled
                          ? 'Отправить код повторно'
                          : 'Отправить код повторно ($_start)',
                      style: TextStyle(
                        color: (isLoading || !_isResendEnabled)
                            ? Colors.grey
                            : Colors.blue,
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
