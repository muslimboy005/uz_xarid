import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uzxarid/app/router/app_router.dart';
import 'package:uzxarid/core/dp/infection.dart';
import 'package:uzxarid/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:uzxarid/features/profile/presentation/widgets/bottom_sheets/phone_bottom_sheet.dart';
import 'package:uzxarid/features/profile/presentation/widgets/bottom_sheets/otp_bottom_sheet.dart';

class AuthActionService {
  bool _isShowingLogin = false;
  Completer<bool>? _authCompleter;

  Future<bool> ensureAuthenticated() async {
    if (_isShowingLogin) {
      return _authCompleter?.future ?? Future.value(false);
    }

    final context = AppRouter.navigatorKey.currentContext;
    if (context == null) return false;

    _isShowingLogin = true;
    _authCompleter = Completer<bool>();

    try {
      _showPhoneSheet(context);
    } catch (e) {
      _isShowingLogin = false;
      _authCompleter?.complete(false);
    }

    return _authCompleter!.future;
  }

  void _showPhoneSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return BlocProvider.value(
          value: getIt<ProfileBloc>(),
          child: PhoneBottomSheet(
            onCodeSent: (phone) {
              // PhoneBottomSheet will pop itself, we show OTP sheet
              _showOtpSheet(context, phone);
            },
          ),
        );
      },
    ).whenComplete(() {
      if (!_authCompleter!.isCompleted) {
        _isShowingLogin = false;
        _authCompleter?.complete(false);
      }
    });
  }

  void _showOtpSheet(BuildContext context, String phone) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return BlocProvider.value(
          value: getIt<ProfileBloc>(),
          child: OtpBottomSheet(
            phone: phone,
            onAskName: () {
              // Optional: handle name asking
            },
            onOtpSuccess: () {
              _isShowingLogin = false;
              if (!_authCompleter!.isCompleted) {
                _authCompleter?.complete(true);
              }
            },
          ),
        );
      },
    );
  }
}
