import 'package:uz_xarid/core/usecases/usecase.dart';
import 'package:uz_xarid/features/cart/domain/entities/cart_item_entity.dart';
import 'package:uz_xarid/features/cart/domain/repositories/cart_repository.dart';

class GetCartItemsUseCase extends UseCase<CartEntity, GetCartParams> {
  final CartRepository repository;

  GetCartItemsUseCase(this.repository);

  @override
  Future<CartEntity> call(GetCartParams params) {
    return repository.getCart(page: params.page, pageSize: params.pageSize);
  }
}

class GetCartParams {
  final int? page;
  final int? pageSize;

  GetCartParams({this.page, this.pageSize});
}
