import 'package:uzxarid/core/usecases/usecase.dart';
import 'package:uzxarid/features/cart/domain/repositories/cart_repository.dart';

class RemoveFromCartItemUseCase extends UseCase<void, int> {
  final CartRepository repository;

  RemoveFromCartItemUseCase(this.repository);

  @override
  Future<void> call(int id) {
    return repository.deleteCartItem(id);
  }
}

class ClearCartUseCase extends UseCase<void, NoParams> {
  final CartRepository repository;

  ClearCartUseCase(this.repository);

  @override
  Future<void> call(NoParams params) {
    return repository.clearCart();
  }
}

class CheckoutUseCase extends UseCase<void, CheckoutParams> {
  final CartRepository repository;

  CheckoutUseCase(this.repository);

  @override
  Future<void> call(CheckoutParams params) {
    return repository.checkout(
      firstName: params.firstName,
      lastName: params.lastName,
      addressId: params.addressId,
      notes: params.notes,
    );
  }
}

class CheckoutParams {
  final String firstName;
  final String lastName;
  final int addressId;
  final String? notes;

  CheckoutParams({
    required this.firstName,
    required this.lastName,
    required this.addressId,
    this.notes,
  });
}
