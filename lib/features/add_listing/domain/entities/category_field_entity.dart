class CategoryFieldEntity {
  const CategoryFieldEntity({
    required this.name,
    required this.label,
    required this.type,
    required this.required,
    required this.placeholder,
    required this.suffix,
    required this.options,
    required this.condition,
    this.minValue,
    this.maxValue,
    this.valueSource = 'attributes',
  });

  final String name;
  final String label;
  final String type;
  final bool required;
  final String? placeholder;
  final String? suffix;
  final List<CategoryFieldOptionEntity> options;
  final CategoryFieldConditionEntity? condition;
  final double? minValue;
  final double? maxValue;

  /// Backend `value_source`: `"attributes"` yoki `"vehicle_detail"`.
  final String valueSource;

  factory CategoryFieldEntity.fromJson(Map<String, dynamic> json) {
    final optionsRaw = json['options'];
    final options = <CategoryFieldOptionEntity>[];
    if (optionsRaw is List) {
      for (final e in optionsRaw) {
        if (e is Map<String, dynamic>) {
          options.add(CategoryFieldOptionEntity.fromJson(e));
        } else if (e is Map) {
          options.add(
            CategoryFieldOptionEntity.fromJson(e.cast<String, dynamic>()),
          );
        }
      }
    }

    CategoryFieldConditionEntity? condition;
    final condRaw = json['condition'];
    if (condRaw is Map<String, dynamic>) {
      condition = CategoryFieldConditionEntity.fromJson(condRaw);
    } else if (condRaw is Map) {
      condition = CategoryFieldConditionEntity.fromJson(
        condRaw.cast<String, dynamic>(),
      );
    }

    return CategoryFieldEntity(
      name: (json['name'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      required: json['required'] == true,
      placeholder: json['placeholder']?.toString(),
      suffix: json['suffix']?.toString(),
      options: options,
      condition: condition,
      minValue: _parseNum(json['min_value']),
      maxValue: _parseNum(json['max_value']),
      valueSource: (json['value_source'] ?? 'attributes').toString().isEmpty
          ? 'attributes'
          : (json['value_source'] ?? 'attributes').toString(),
    );
  }

  static double? _parseNum(dynamic raw) {
    if (raw == null) return null;
    if (raw is num) return raw.toDouble();
    final s = raw.toString().trim();
    if (s.isEmpty) return null;
    return double.tryParse(s);
  }
}

class CategoryFieldOptionEntity {
  const CategoryFieldOptionEntity({required this.label, required this.value});

  final String label;
  final String value;

  factory CategoryFieldOptionEntity.fromJson(Map<String, dynamic> json) {
    return CategoryFieldOptionEntity(
      label: (json['label'] ?? '').toString(),
      value: (json['value'] ?? '').toString(),
    );
  }
}

class CategoryFieldConditionEntity {
  const CategoryFieldConditionEntity({
    required this.field,
    required this.equals,
  });

  final String field;
  final String equals;

  factory CategoryFieldConditionEntity.fromJson(Map<String, dynamic> json) {
    return CategoryFieldConditionEntity(
      field: (json['field'] ?? '').toString(),
      equals: (json['equals'] ?? '').toString(),
    );
  }
}
