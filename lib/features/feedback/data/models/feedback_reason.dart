class FeedbackReason {
  const FeedbackReason({required this.id, required this.name, this.slug});

  final int id;
  final String name;
  final String? slug;

  bool get isOther {
    final normalized = name.trim().toLowerCase();
    return normalized == 'boshqa' || normalized == 'other' || slug == 'other';
  }

  bool get isTechnical {
    final normalized = name.trim().toLowerCase();
    return normalized.contains('texnik') || slug == 'technical-issue';
  }

  bool get isFraud {
    final normalized = name.trim().toLowerCase();
    return normalized.contains('firib') || slug == 'fraud';
  }

  factory FeedbackReason.fromJson(Map<String, dynamic> json) {
    return FeedbackReason(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? json['title'] ?? json['reason'] ?? '').toString(),
      slug: json['slug']?.toString(),
    );
  }
}
