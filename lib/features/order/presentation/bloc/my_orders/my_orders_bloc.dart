import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uz_xarid/features/order/domain/repositories/order_repository.dart';
import 'my_orders_event.dart';
import 'my_orders_state.dart';

class MyOrdersBloc extends Bloc<MyOrdersEvent, MyOrdersState> {
  final OrderRepository repository;

  MyOrdersBloc({required this.repository}) : super(const MyOrdersState()) {
    on<LoadMyOrdersEvent>(_onLoadMyOrders);
  }

  Future<void> _onLoadMyOrders(
    LoadMyOrdersEvent event,
    Emitter<MyOrdersState> emit,
  ) async {
    if (event.refresh) {
      emit(
        state.copyWith(
          status: MyOrdersStatus.initial,
          currentPage: 1,
          hasReachedMax: false,
          orders: [],
        ),
      );
    }

    if (state.hasReachedMax) return;

    if (state.status == MyOrdersStatus.initial) {
      emit(state.copyWith(status: MyOrdersStatus.loading));
    }

    final page = state.currentPage;

    final result = await repository.getMyOrders(page: page, pageSize: 15);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: MyOrdersStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (data) {
        final newOrders = data.data.results;
        emit(
          state.copyWith(
            status: MyOrdersStatus.success,
            orders: List.of(state.orders)..addAll(newOrders),
            hasReachedMax:
                newOrders.isEmpty ||
                data.data.currentPage >= data.data.totalPages,
            currentPage: page + 1,
          ),
        );
      },
    );
  }
}
