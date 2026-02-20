import 'package:equatable/equatable.dart';

/// Domain entity for a category with nested children (category → subcategory → children).
class CategoryEntity extends Equatable {
  const CategoryEntity({
    required this.id,
    required this.name,
    this.image,
    this.children = const [],
  });

  final int id;
  final String name;
  final String? image;
  final List<CategoryEntity> children;

  String get displayName => name.trim().isEmpty ? 'Turkum $id' : name;

  bool get hasChildren => children.isNotEmpty;

  @override
  List<Object?> get props => [id, name, image, children];
}
