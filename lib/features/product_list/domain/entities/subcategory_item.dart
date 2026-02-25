/// Mahsulotlar sahifasida gorizontal scroll da ko'rsatiladigan ostki turkum.
class SubcategoryItem {
  const SubcategoryItem({
    required this.id,
    required this.name,
    this.image,
  });

  final int id;
  final String name;
  final String? image;
}
