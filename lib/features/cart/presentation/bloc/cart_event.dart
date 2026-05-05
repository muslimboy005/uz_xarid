import 'package:equatable/equatable.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class CartLoadRequested extends CartEvent {}

class CartItemAddRequested extends CartEvent {
  final String adSlug;
  final int? variantId;
  final int quantity;

  const CartItemAddRequested({
    required this.adSlug,
    this.variantId,
    required this.quantity,
  });

  @override
  List<Object?> get props => [adSlug, variantId, quantity];
}

class CartItemUpdateRequested extends CartEvent {
  final int id;
  final int quantity;

  const CartItemUpdateRequested({required this.id, required this.quantity});

  @override
  List<Object?> get props => [id, quantity];
}

class CartItemRemoveRequested extends CartEvent {
  final int id;

  const CartItemRemoveRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class CartClearRequested extends CartEvent {}

class CartCheckoutRequested extends CartEvent {
  final String? firstName;
  final String? lastName;
  final int? addressId;
  final String? notes;

  const CartCheckoutRequested({
    this.firstName,
    this.lastName,
    this.addressId,
    this.notes,
  });

  @override
  List<Object?> get props => [firstName, lastName, addressId, notes];
}
