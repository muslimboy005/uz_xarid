import 'package:uzxarid/core/either/either.dart';
import 'package:uzxarid/core/error/failures.dart';
import 'package:uzxarid/features/product_detail/domain/entities/ad_detail_entity.dart';

abstract class ProductDetailRepository {
  Future<Either<Failure, AdDetailEntity>> getAdDetail(String slug);

  Future<Either<Failure, dynamic>> getFeedbacks(String slug);

  Future<Either<Failure, dynamic>> leaveFeedback(
    String slug,
    Map<String, dynamic> data,
  );
}
