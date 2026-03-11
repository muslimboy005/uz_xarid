import 'package:equatable/equatable.dart';
import 'package:uz_xarid/features/order/data/models/order_response_dto.dart';

enum MyOrdersStatus { initial, loading, success, failure }

class MyOrdersState extends Equatable {
  final MyOrdersStatus status;
  final List<OrderResponseDto> orders;
  final String? errorMessage;
  final int currentPage;
  final bool hasReachedMax;

  const MyOrdersState({
    this.status = MyOrdersStatus.initial,
    this.orders = const [],
    this.errorMessage,
    this.currentPage = 1,
    this.hasReachedMax = false,
  });

  MyOrdersState copyWith({
    MyOrdersStatus? status,
    List<OrderResponseDto>? orders,
    String? errorMessage,
    int? currentPage,
    bool? hasReachedMax,
  }) {
    return MyOrdersState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [
    status,
    orders,
    errorMessage,
    currentPage,
    hasReachedMax,
  ];
}
