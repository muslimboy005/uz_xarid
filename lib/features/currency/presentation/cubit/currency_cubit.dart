import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uz_xarid/core/constants/app_keys.dart';
import 'package:uz_xarid/core/dp/infection.dart';
import 'package:uz_xarid/core/localization/currency_holder.dart';

import 'package:uz_xarid/features/currency/domain/currency.dart';

class CurrencyState extends Equatable {
  const CurrencyState({
    this.loading = false,
    this.error,
    this.currencies = const [],
    this.selectedCcy = 'UZS',
  });

  final bool loading;
  final String? error;
  final List<Currency> currencies;
  final String selectedCcy;

  Currency? get selected {
    if (currencies.isEmpty) return null;
    final match = currencies.where((c) => c.ccy == selectedCcy).toList();
    if (match.isNotEmpty) return match.first;
    return currencies.first;
  }

  CurrencyState copyWith({
    bool? loading,
    String? error,
    List<Currency>? currencies,
    String? selectedCcy,
    bool clearError = false,
  }) {
    return CurrencyState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      currencies: currencies ?? this.currencies,
      selectedCcy: selectedCcy ?? this.selectedCcy,
    );
  }

  @override
  List<Object?> get props => [loading, error, currencies, selectedCcy];
}

class CurrencyCubit extends Cubit<CurrencyState> {
  CurrencyCubit({Dio? dio})
    : _dio = dio ?? Dio(),
      super(
        CurrencyState(
          selectedCcy: getIt<CurrencyHolder>().ccy,
        ),
      );

  final Dio _dio;
  static const _endpoint = 'https://cbu.uz/uz/arkhiv-kursov-valyut/json/';

  Future<void> load() async {
    if (state.loading) return;
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final saved = getIt<SharedPreferences>().getString(
        AppKeys.selectedCurrencyKey,
      );
      final res = await _dio.get<dynamic>(_endpoint);
      final data = res.data;
      if (data is! List) {
        emit(state.copyWith(loading: false, error: 'Invalid response'));
        return;
      }
      final list = data
          .whereType<Map>()
          .map((e) => Currency.fromJson(Map<String, dynamic>.from(e)))
          .where((c) => c.ccy.toUpperCase() != 'UZS')
          .toList();
      // O'zbek so'mi cbu.uz javobida bo'lmaydi (u baza valyuta);
      // uni ro'yxatning eng tepasiga qo'lda qo'shamiz.
      list.insert(
        0,
        const Currency(
          id: 0,
          code: '000',
          ccy: 'UZS',
          nameUz: "O'zbek so'mi",
          nameRu: 'Узбекский сум',
          nameEn: 'Uzbek som',
          nominal: 1,
          rate: 1,
          diff: 0,
          date: '',
        ),
      );
      final selected = saved ?? state.selectedCcy;
      getIt<CurrencyHolder>().setCcy(selected);
      emit(
        state.copyWith(
          loading: false,
          currencies: list,
          selectedCcy: selected,
        ),
      );
    } on DioException catch (e) {
      emit(state.copyWith(loading: false, error: e.message ?? 'Network error'));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> select(String ccy) async {
    if (state.selectedCcy == ccy) return;
    emit(state.copyWith(selectedCcy: ccy));
    getIt<CurrencyHolder>().setCcy(ccy);
    await getIt<SharedPreferences>().setString(
      AppKeys.selectedCurrencyKey,
      ccy,
    );
  }
}
