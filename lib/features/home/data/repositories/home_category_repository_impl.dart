import 'package:dio/dio.dart';
import 'package:uz_xarid/core/either/either.dart';
import 'package:uz_xarid/core/error/failures.dart';
import 'package:uz_xarid/features/home/data/datasources/home_category_api.dart';
import 'package:uz_xarid/features/home/domain/entities/category_entity.dart';
import 'package:uz_xarid/features/home/domain/repositories/home_category_repository.dart';

class HomeCategoryRepositoryImpl implements HomeCategoryRepository {
  HomeCategoryRepositoryImpl(this.api);

  final HomeCategoryApi api;

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories({
    String categoryType = 'Product',
  }) async {
    try {
      final response = await api.getCategories(categoryType);
      final dtoList = response.data.results;
      final entities = dtoList.map((e) => e.toEntity()).toList();
      return Right(entities);
    } on DioException catch (e) {
      final message = e.response?.statusMessage ?? e.message ?? 'Network error';
      return Left(ServerFailure(message: message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
