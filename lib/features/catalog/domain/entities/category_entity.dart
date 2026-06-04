import 'package:equatable/equatable.dart';

/// Domain entity for a category with nested children (category → subcategory → children).
class CategoryEntity extends Equatable {
  const CategoryEntity({
    required this.id,
    required this.name,
    this.image,
    this.children = const [],
    bool? hasChildren,
  }) : _hasChildren = hasChildren;

  final int id;
  final String name;
  final String? image;
  final List<CategoryEntity> children;

  /// API'dan kelgan `has_children` belgisi. Bolalar oldindan yuklanmagan
  /// bo'lsa ham (faqat tugun ochilganda GET qilinadi) bu orqali bilinadi.
  final bool? _hasChildren;

  String get displayName => name.trim().isEmpty ? 'Turkum $id' : name;

  bool get hasChildren => _hasChildren ?? children.isNotEmpty;

  @override
  List<Object?> get props => [id, name, image, children, _hasChildren];
}
