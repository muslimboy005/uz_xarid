import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uz_xarid/core/constants/app_dimens.dart';
import 'package:uz_xarid/core/dp/infection.dart';
import 'package:uz_xarid/core/service/local_service.dart';
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
      isDismissible: false,
      enableDrag: false,
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

  @override
  void dispose() {
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
            } else {

            }
          });
        } else if (state.status == ProfileStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Noto\'g\'ri kod'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state.status == ProfileStatus.loading;

        return Padding(
          padding: EdgeInsets.only(
            left: AppDimens.paddingMedium,
            right: AppDimens.paddingMedium,
            top: AppDimens.paddingMedium,
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
              Text(
                'Введите код',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Код был отправлен на ваш номер телефона (${widget.phone}).\n'
                'Пожалуйста, проверьте SMS.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppDimens.paddingLarge),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                enabled: !isLoading,
                autofocus: true,
                style: const TextStyle(
                  letterSpacing: 8,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: const InputDecoration(
                  hintText: '••••••',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppDimens.paddingLarge),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading
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
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text('Продолжить'),
                ),
              ),
              const SizedBox(height: AppDimens.paddingMedium),
              Center(
                child: TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          final phoneDigits = widget.phone.replaceAll(
                            RegExp(r'\D'),
                            '',
                          );
                          context.read<ProfileBloc>().add(
                            ProfileSendOtpEvent(otpModel: phoneDigits),
                          );
                        },
                  child: const Text('Отправить код повторно'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
