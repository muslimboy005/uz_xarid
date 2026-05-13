import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uzxarid/core/usecases/usecase.dart';
import 'package:uzxarid/features/cart/domain/entities/cart_item_entity.dart';
import 'package:uzxarid/features/cart/domain/usecases/add_to_cart.dart';
import 'package:uzxarid/features/cart/domain/usecases/cart_operations.dart';
import 'package:uzxarid/features/cart/domain/usecases/get_cart.dart';
import 'package:uzxarid/features/cart/domain/usecases/update_cart_quantity.dart';
import 'package:uzxarid/features/cart/presentation/bloc/cart_event.dart';
import 'package:uzxarid/features/cart/presentation/bloc/cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final GetCartItemsUseCase _getCartItemsUseCase;
  final AddToCartUseCase _addToCartUseCase;
  final UpdateCartQuantityUseCase _updateCartQuantityUseCase;
  final RemoveFromCartItemUseCase _removeFromCartItemUseCase;
  final ClearCartUseCase _clearCartUseCase;
  final CheckoutUseCase _checkoutUseCase;

  CartBloc({
    required GetCartItemsUseCase getCartItemsUseCase,
    required AddToCartUseCase addToCartUseCase,
    required UpdateCartQuantityUseCase updateCartQuantityUseCase,
    required RemoveFromCartItemUseCase removeFromCartItemUseCase,
    required ClearCartUseCase clearCartUseCase,
    required CheckoutUseCase checkoutUseCase,
  })  : _getCartItemsUseCase = getCartItemsUseCase,
        _addToCartUseCase = addToCartUseCase,
        _updateCartQuantityUseCase = updateCartQuantityUseCase,
        _removeFromCartItemUseCase = removeFromCartItemUseCase,
        _clearCartUseCase = clearCartUseCase,
        _checkoutUseCase = checkoutUseCase,
        super(const CartState()) {
    on<CartLoadRequested>(_onLoadRequested);
    on<CartItemAddRequested>(_onItemAddRequested);
    on<CartItemUpdateRequested>(_onItemUpdateRequested);
    on<CartItemRemoveRequested>(_onItemRemoveRequested);
    on<CartClearRequested>(_onClearRequested);
    on<CartCheckoutRequested>(_onCheckoutRequested);
  }

  Future<void> _onLoadRequested(CartLoadRequested event, Emitter<CartState> emit) async {
    emit(state.copyWith(status: CartStatus.loading));
    try {
      final cart = await _getCartItemsUseCase(GetCartParams(page: 1, pageSize: 200));
      emit(state.copyWith(
        status: CartStatus.success,
        items: cart.items,
        totalItems: cart.totalItems,
        loadingSlugs: {}, // Clear loading states
        loadingIds: {}, // Clear loading states
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CartStatus.failure,
        errorMessage: e.toString(),
        loadingSlugs: {}, // Clear loading states on error too
        loadingIds: {}, // Clear loading states on error too
      ));
    }
  }

  Future<void> _onItemAddRequested(CartItemAddRequested event, Emitter<CartState> emit) async {
    final loadingSlugs = Set<String>.from(state.loadingSlugs)..add(event.adSlug);
    emit(state.copyWith(loadingSlugs: loadingSlugs));

    try {
      await _addToCartUseCase(AddToCartParams(
        adSlug: event.adSlug,
        variantId: event.variantId,
        quantity: event.quantity,
      ));
      // Re-load to get the actual ID and subtotal from server
      add(CartLoadRequested());
      // We don't remove slug here yet, LoadRequested will refresh everything with new items
    } catch (e) {
      final newLoadingSlugs = Set<String>.from(state.loadingSlugs)..remove(event.adSlug);
      emit(state.copyWith(loadingSlugs: newLoadingSlugs, errorMessage: e.toString()));
    }
  }

  Future<void> _onItemUpdateRequested(CartItemUpdateRequested event, Emitter<CartState> emit) async {
    // Optimistic Update
    final originalItems = List<CartItemEntity>.from(state.items);
    final updatedItems = originalItems.map((item) {
      if (item.id == event.id) {
        return item.copyWith(quantity: event.quantity);
      }
      return item;
    }).toList();

    final loadingIds = Set<int>.from(state.loadingIds)..add(event.id);
    emit(state.copyWith(items: updatedItems, loadingIds: loadingIds));

    try {
      await _updateCartQuantityUseCase(UpdateCartParams(id: event.id, quantity: event.quantity));
      final newLoadingIds = Set<int>.from(state.loadingIds)..remove(event.id);
      emit(state.copyWith(loadingIds: newLoadingIds));
    } catch (e) {
      // Rollback
      final newLoadingIds = Set<int>.from(state.loadingIds)..remove(event.id);
      emit(state.copyWith(items: originalItems, loadingIds: newLoadingIds, errorMessage: e.toString()));
    }
  }

  Future<void> _onItemRemoveRequested(CartItemRemoveRequested event, Emitter<CartState> emit) async {
    final originalItems = List<CartItemEntity>.from(state.items);
    final updatedItems = originalItems.where((e) => e.id != event.id).toList();

    final loadingIds = Set<int>.from(state.loadingIds)..add(event.id);
    emit(state.copyWith(items: updatedItems, loadingIds: loadingIds, totalItems: state.totalItems - 1));

    try {
      await _removeFromCartItemUseCase(event.id);
      final newLoadingIds = Set<int>.from(state.loadingIds)..remove(event.id);
      emit(state.copyWith(loadingIds: newLoadingIds));
    } catch (e) {
      // Rollback
      final newLoadingIds = Set<int>.from(state.loadingIds)..remove(event.id);
      emit(state.copyWith(items: originalItems, loadingIds: newLoadingIds, totalItems: originalItems.length, errorMessage: e.toString()));
    }
  }

  Future<void> _onClearRequested(CartClearRequested event, Emitter<CartState> emit) async {
    emit(state.copyWith(status: CartStatus.loading));
    try {
      await _clearCartUseCase(const NoParams());
      emit(state.copyWith(status: CartStatus.success, items: [], totalItems: 0));
    } catch (e) {
      emit(state.copyWith(status: CartStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onCheckoutRequested(CartCheckoutRequested event, Emitter<CartState> emit) async {
    emit(state.copyWith(status: CartStatus.loading));
    try {
      await _checkoutUseCase(CheckoutParams(
        firstName: event.firstName ?? 'Foydalanuvchi',
        lastName: event.lastName ?? 'Xaridor',
        addressId: event.addressId ?? 0,
        notes: event.notes,
      ));
      emit(state.copyWith(status: CartStatus.success, items: [], totalItems: 0));
    } catch (e) {
      emit(state.copyWith(status: CartStatus.failure, errorMessage: e.toString()));
    }
  }
}
