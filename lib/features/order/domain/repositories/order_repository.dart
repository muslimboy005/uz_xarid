import 'package:dartz/dartz.dart';
import 'package:uzxarid/core/error/failures.dart';
import 'package:uzxarid/features/order/data/models/order_create_dto.dart';
import 'package:uzxarid/features/order/data/models/order_response_dto.dart';

abstract class OrderRepository {
  Future<Either<Failure, OrderResponseDto>> createOrder(OrderCreateDto request);
  Future<Either<Failure, OrderListResponseDto>> getMyOrders({
    int page = 1,
    int pageSize = 10,
  });
}
