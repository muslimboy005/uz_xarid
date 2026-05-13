import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uzxarid/core/constants/app_colors.dart';
import 'package:uzxarid/core/cubit/app_mode_cubit.dart';
import 'package:uzxarid/core/theme/theme_colors.dart';
import 'package:uzxarid/core/utils/image_parser.dart';
import 'package:uzxarid/core/utils/price_formatter.dart';
import 'package:uzxarid/core/widgets/cart_counter.dart';
import 'package:uzxarid/features/cart/domain/entities/cart_item_entity.dart';
import 'package:uzxarid/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:uzxarid/features/cart/presentation/bloc/cart_event.dart';
import 'package:uzxarid/features/cart/presentation/bloc/cart_state.dart';
import 'package:uzxarid/features/currency/domain/currency.dart';
import 'package:uzxarid/features/currency/presentation/cubit/currency_cubit.dart';
import 'package:uzxarid/l10n/app_localizations.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: context.bodyBackground,
      appBar: AppBar(
        title: Text(
          l10n.navCart,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        backgroundColor: context.cardSurface,
        surfaceTintColor: context.cardSurface,
        elevation: 0,
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              if (state.items.isEmpty) return const SizedBox.shrink();
              return TextButton(
                onPressed: () => _showClearConfirmation(context),
                child: Text(
                  l10n.actionClear,
                  style: const TextStyle(color: AppColors.red),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state.status == CartStatus.loading && state.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.items.isEmpty) {
            return _buildEmptyCart(context, l10n);
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _CartItemTile(item: state.items[index]);
                  },
                ),
              ),
              _CartSummary(cartItems: state.items),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: context.textSecondary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.cartEmpty,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.cartEmptySubtitle,
            style: TextStyle(color: context.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.watch<AppModeCubit>().state.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(l10n.cartStartShopping),
          ),
        ],
      ),
    );
  }

  void _showClearConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(dialogContext)!;
        return AlertDialog(
          title: Text(l10n.cartClearTitle),
          content: Text(l10n.cartClearConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.actionCancel),
            ),
            TextButton(
              onPressed: () {
                context.read<CartBloc>().add(CartClearRequested());
                Navigator.pop(dialogContext);
              },
              child: Text(
                l10n.actionClear,
                style: const TextStyle(color: AppColors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItemEntity item;

  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final selectedCcy = context.watch<CurrencyCubit>().state.selectedCcy;
    final itemCurrency = currencyDisplayLabel(selectedCcy);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: (item.adImage ?? '').cdnUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                width: 80,
                height: 80,
                color: context.surfaceContainer,
                child: const Icon(Icons.image_outlined),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.adTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (item.variantName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.variantName!,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${item.unitPrice} $itemCurrency',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: context.watch<AppModeCubit>().state.primaryColor,
                        fontSize: 14,
                      ),
                    ),
                    CartCounter(
                      adSlug: item.adSlug,
                      variantId: item.variantId,
                      width: 100,
                      height: 32,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  final List<CartItemEntity> cartItems;

  const _CartSummary({required this.cartItems});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final total = cartItems.fold<double>(0, (sum, item) => sum + (double.tryParse(item.subtotal) ?? 0));
    final selectedCcy = context.watch<CurrencyCubit>().state.selectedCcy;
    final currency = currencyDisplayLabel(selectedCcy);

    final primaryColor = context.watch<AppModeCubit>().state.primaryColor;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
            Text(
              l10n.cartTotal,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: context.textPrimary,
              ),
            ),
                Text(
                  '${formatPrice(total.toString())} $currency',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            BlocBuilder<CartBloc, CartState>(
              builder: (context, state) {
                return SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: state.status == CartStatus.loading
                        ? null
                        : () {
                            context.read<CartBloc>().add(CartCheckoutRequested());
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: state.status == CartStatus.loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            l10n.productDetailPlaceOrder,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

}
