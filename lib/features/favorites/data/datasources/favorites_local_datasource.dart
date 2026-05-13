import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uzxarid/features/favorites/domain/entities/favorite_item_entity.dart';

const String _keyLikedList = 'favorites_local_list';

/// Lokal saqlash (login qilmagan foydalanuvchi uchun).
abstract class FavoritesLocalDatasource {
  Future<List<FavoriteItemEntity>> getLikedList();
  Future<void> addLiked(FavoriteItemEntity item);
  Future<void> removeLiked(String slug);
  Future<bool> isLiked(String slug);
}

class FavoritesLocalDatasourceImpl implements FavoritesLocalDatasource {
  FavoritesLocalDatasourceImpl({required SharedPreferences prefs})
    : _prefs = prefs;

  final SharedPreferences _prefs;

  @override
  Future<List<FavoriteItemEntity>> getLikedList() async {
    final json = _prefs.getString(_keyLikedList);
    if (json == null || json.isEmpty) return [];
    try {
      final list = jsonDecode(json) as List<dynamic>?;
      if (list == null) return [];
      return list.map((e) => _mapFromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> addLiked(FavoriteItemEntity item) async {
    final list = await getLikedList();
    if (list.any((e) => e.slug == item.slug)) return;
    list.add(item);
    await _saveList(list);
  }

  @override
  Future<void> removeLiked(String slug) async {
    final list = await getLikedList();
    list.removeWhere((e) => e.slug == slug);
    await _saveList(list);
  }

  @override
  Future<bool> isLiked(String slug) async {
    final list = await getLikedList();
    return list.any((e) => e.slug == slug);
  }

  Future<void> _saveList(List<FavoriteItemEntity> list) async {
    final encoded = jsonEncode(list.map(_mapToJson).toList());
    await _prefs.setString(_keyLikedList, encoded);
  }

  static FavoriteItemEntity _mapFromJson(Map<String, dynamic> json) {
    return FavoriteItemEntity(
      slug: json['slug'] as String? ?? '',
      title: json['title'] as String? ?? '',
      mainImage: json['main_image'] as String?,
      price: json['price'] as String?,
      finalPrice: json['final_price'] as String?,
      currency: json['currency'] as String? ?? 'uzs',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
      isLiked: true,
    );
  }

  static Map<String, dynamic> _mapToJson(FavoriteItemEntity e) {
    return {
      'slug': e.slug,
      'title': e.title,
      'main_image': e.mainImage,
      'price': e.price,
      'final_price': e.finalPrice,
      'currency': e.currency,
      'rating': e.rating,
      'review_count': e.reviewCount,
    };
  }
}
