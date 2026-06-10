import 'package:uzxarid/features/product_list/domain/entities/product_list_item_entity.dart';

/// Bitta sahifa e'lonlar + yana sahifa bor-yo'qligi (infinite scroll uchun).
class ProductListResult {
  const ProductListResult({required this.items, this.hasMore = false});

  final List<ProductListItemEntity> items;

  /// Keyingi sahifa mavjudligi — to'liq sahifa qaytsa, yana bo'lishi mumkin.
  final bool hasMore;
}
