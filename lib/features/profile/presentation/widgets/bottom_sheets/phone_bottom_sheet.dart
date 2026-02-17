import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uz_xarid/core/constants/app_dimens.dart';
import 'package:uz_xarid/core/utils/input_formatters.dart';
import 'package:uz_xarid/features/profile/presentation/bloc/profile_bloc.dart';

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
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state.status == ProfileStatus.success) {
          Navigator.of(context).pop();
          widget.onCodeSent(_phoneController.text);
        } else if (state.status == ProfileStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Xatolik yuz berdi'),
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
                'Вход в аккаунт',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Мы отправим проверочный код на введённый номер по SMS.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppDimens.paddingLarge),
              Text(
                'Телефон',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
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
                decoration: const InputDecoration(
                  hintText: '+998 90 123-45-67',
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
                          final digits = _phoneController.text.replaceAll(
                            RegExp(r'\D'),
                            '',
                          );

                          if (digits.length != 12 ||
                              !digits.startsWith('998')) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Telefon raqamni to\'liq kiriting',
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
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text('Получить код'),
                ),
              ),
              const SizedBox(height: AppDimens.paddingMedium),
              DefaultTextStyle.merge(
                style: Theme.of(context).textTheme.bodySmall,
                child: const Text(
                  'Авторизациядан o\'tish орқали сиз шахсий маълумотларни '
                  'қайта ишлаш сиёсатга розилик биладирасиз',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
