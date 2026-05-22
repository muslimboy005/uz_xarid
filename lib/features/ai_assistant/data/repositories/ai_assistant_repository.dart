import 'package:uzxarid/core/constants/api_urls.dart';
import 'package:uzxarid/core/dio/dio_client.dart';
import 'package:uzxarid/features/ai_assistant/data/models/ai_assistant_response_model.dart';

class AiAssistantRepository {
  final DioClient _dio;

  AiAssistantRepository(this._dio);

  Future<AiAssistantResponseModel> ask(String message) async {
    final result = await _dio.post(
      ApiUrls.aiAssistant,
      data: {'message': message},
    );

    if (!result.ok || result.result is! Map<String, dynamic>) {
      throw Exception('ai-assistant request failed');
    }

    return AiAssistantResponseModel.fromJson(
      result.result as Map<String, dynamic>,
    );
  }
}
