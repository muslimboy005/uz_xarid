import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Manages current locale; extend later with persistence/API if needed.
class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(const Locale('uz'));

  void change(Locale locale) {
    if (state == locale) return;
    emit(locale);
  }
}
