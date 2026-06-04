import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:uzxarid/core/cubit/app_mode_cubit.dart';
import 'package:uzxarid/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:uzxarid/features/cart/presentation/bloc/cart_event.dart';
import 'package:uzxarid/features/cart/presentation/bloc/cart_state.dart';
import 'package:uzxarid/l10n/app_localizations.dart';

class CartCounter extends StatelessWidget {
  final String adSlug;
  final int? variantId;
  final double? width;
  final double height;

  const CartCounter({
    super.key,
    required this.adSlug,
    this.variantId,
    this.width,
    this.height = 40,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        final item = state.items.where((e) => e.adSlug == adSlug && e.variantId == variantId).firstOrNull;
        final quantity = item?.quantity ?? 0;
        final isLoading = state.isLoading(adSlug, itemId: item?.id);

        if (quantity == 0) {
          return _buildAddButton(context, isLoading);
        }

        return _buildCounter(context, item!.id, quantity, isLoading);
      },
    );
  }

  Widget _buildAddButton(BuildContext context, bool isLoading) {
    final primaryColor = context.watch<AppModeCubit>().state.primaryColor;
    return GestureDetector(
      onTap: () {}, // Prevent propagation
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: width ?? double.infinity,
        height: height,
        child: ElevatedButton(
          onPressed: isLoading
              ? null
              : () {
                  context.read<CartBloc>().add(CartItemAddRequested(
                        adSlug: adSlug,
                        variantId: variantId,
                        quantity: 1,
                      ));
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    AppLocalizations.of(context)!.addToCart,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.visible,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildCounter(BuildContext context, int itemId, int quantity, bool isLoading) {
    final primaryColor = context.watch<AppModeCubit>().state.primaryColor;
    return GestureDetector(
      onTap: () {}, // Prevent propagation
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primaryColor, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ActionButton(
              icon: Icons.remove,
              color: primaryColor,
              onPressed: isLoading
                  ? null
                  : () {
                      if (quantity > 1) {
                        context.read<CartBloc>().add(CartItemUpdateRequested(
                              id: itemId,
                              quantity: quantity - 1,
                            ));
                      } else {
                        context.read<CartBloc>().add(CartItemRemoveRequested(itemId));
                      }
                    },
            ),
            Expanded(
              child: Center(
                child: isLoading
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                        ),
                      )
                    : Text(
                        '$quantity',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
              ),
            ),
            _ActionButton(
              icon: Icons.add,
              color: primaryColor,
              onPressed: isLoading
                  ? null
                  : () {
                      context.read<CartBloc>().add(CartItemUpdateRequested(
                            id: itemId,
                            quantity: quantity + 1,
                          ));
                    },
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  const _ActionButton({required this.icon, required this.color, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 20, color: color),
      style: IconButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minimumSize: const Size(32, 32),
        padding: const EdgeInsets.symmetric(horizontal: 6),
      ),
    );
  }
}

