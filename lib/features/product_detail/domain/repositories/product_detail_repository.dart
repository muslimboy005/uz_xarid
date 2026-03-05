import 'package:uz_xarid/core/either/either.dart';
import 'package:uz_xarid/core/error/failures.dart';
import 'package:uz_xarid/features/product_detail/domain/entities/ad_detail_entity.dart';

abstract class ProductDetailRepository {
  Future<Either<Failure, AdDetailEntity>> getAdDetail(String slug);

  Future<Either<Failure, dynamic>> getFeedbacks(String slug);

  Future<Either<Failure, dynamic>> leaveFeedback(
    String slug,
    Map<String, dynamic> data,
  );
}
