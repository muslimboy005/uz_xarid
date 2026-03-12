import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:uz_xarid/core/error/exceptions.dart';
import 'package:uz_xarid/core/error/failures.dart';
import 'package:uz_xarid/features/order/data/datasources/order_api.dart';
import 'package:uz_xarid/features/order/data/models/order_create_dto.dart';
import 'package:uz_xarid/features/order/data/models/order_response_dto.dart';
import 'package:uz_xarid/features/order/domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderApi api;

  OrderRepositoryImpl({required this.api});

  @override
  Future<Either<Failure, OrderResponseDto>> createOrder(
    OrderCreateDto request,
  ) async {
    try {
      final response = await api.createOrder(request);
      return Right(response);
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(
          ServerFailure(
            message: e.response?.data?['message'] ?? 'Server error',
          ),
        );
      }
      return Left(ServerFailure(message: e.message ?? 'Unknown error'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderListResponseDto>> getMyOrders({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await api.getMyOrders(page: page, pageSize: pageSize);
      return Right(response);
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(
          ServerFailure(
            message: e.response?.data?['message'] ?? 'Server error',
          ),
        );
      }
      return Left(ServerFailure(message: e.message ?? 'Unknown error'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
