class AiAssistantResponseModel {
  final bool success;
  final String message;
  final String? route;

  const AiAssistantResponseModel({
    required this.success,
    required this.message,
    this.route,
  });

  factory AiAssistantResponseModel.fromJson(Map<String, dynamic> json) {
    return AiAssistantResponseModel(
      success: json['success'] == true,
      message: (json['message'] ?? '').toString(),
      route: (json['route'] is String && (json['route'] as String).isNotEmpty)
          ? json['route'] as String
          : null,
    );
  }
}
