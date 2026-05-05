import 'package:uz_xarid/core/usecases/usecase.dart';
import 'package:uz_xarid/features/cart/domain/repositories/cart_repository.dart';

class AddToCartUseCase extends UseCase<void, AddToCartParams> {
  final CartRepository repository;

  AddToCartUseCase(this.repository);

  @override
  Future<void> call(AddToCartParams params) {
    return repository.addToCart(
      adSlug: params.adSlug,
      variantId: params.variantId,
      quantity: params.quantity,
    );
  }
}

class AddToCartParams {
  final String adSlug;
  final int? variantId;
  final int quantity;

  AddToCartParams({
    required this.adSlug,
    this.variantId,
    required this.quantity,
  });
}
