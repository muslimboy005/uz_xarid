import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uzxarid/features/order/data/models/order_create_dto.dart';
import 'package:uzxarid/features/order/domain/repositories/order_repository.dart';

import 'order_create_state.dart';

class OrderCreateCubit extends Cubit<OrderCreateState> {
  final OrderRepository repository;

  OrderCreateCubit({required this.repository}) : super(OrderCreateInitial());

  Future<void> createOrder(OrderCreateDto request) async {
    emit(OrderCreateLoading());
    final result = await repository.createOrder(request);

    result.fold(
      (failure) {
        emit(OrderCreateFailure(failure.message ?? 'Noma\'lum xato'));
      },
      (_) {
        emit(OrderCreateSuccess());
      },
    );
  }
}
