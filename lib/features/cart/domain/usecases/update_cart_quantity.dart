import 'package:uz_xarid/core/usecases/usecase.dart';
import 'package:uz_xarid/features/cart/domain/repositories/cart_repository.dart';

class UpdateCartQuantityUseCase extends UseCase<void, UpdateCartParams> {
  final CartRepository repository;

  UpdateCartQuantityUseCase(this.repository);

  @override
  Future<void> call(UpdateCartParams params) {
    return repository.updateCart(id: params.id, quantity: params.quantity);
  }
}

class UpdateCartParams {
  final int id;
  final int quantity;

  UpdateCartParams({required this.id, required this.quantity});
}
