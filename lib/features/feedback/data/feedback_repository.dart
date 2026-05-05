import 'package:dio/dio.dart';
import 'package:uz_xarid/core/constants/api_urls.dart';
import 'package:uz_xarid/core/either/either.dart';
import 'package:uz_xarid/core/error/failures.dart';
import 'package:uz_xarid/features/catalog/domain/entities/category_entity.dart';
import 'package:uz_xarid/features/catalog/domain/usecases/get_categories.dart';
import 'package:uz_xarid/features/feedback/data/models/feedback_reason.dart';

class FeedbackSubmitParams {
  const FeedbackSubmitParams({
    required this.reasonId,
    required this.description,
    this.categoryId,
    this.subject,
    this.contact,
    this.customReasonText,
    this.attachments = const [],
  });

  final int reasonId;
  final int? categoryId;
  final String? subject;
  final String description;
  final String? contact;
  final String? customReasonText;
  final List<String> attachments;
}

class FeedbackRepository {
  FeedbackRepository({required Dio dio, required GetCategories getCategories})
    : _dio = dio,
      _getCategories = getCategories;

  final Dio _dio;
  final GetCategories _getCategories;

  Future<Either<Failure, List<FeedbackReason>>> getReasons() async {
    try {
      final response = await _dio.get(ApiUrls.feedbackReasons);
      final results = _extractResults(response.data);
      final reasons = results
          .whereType<Map<String, dynamic>>()
          .map(FeedbackReason.fromJson)
          .where((item) => item.id > 0 && item.name.trim().isNotEmpty)
          .toList();
      return Right(reasons);
    } on DioException catch (e) {
      return Left(ServerFailure(message: _resolveErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, List<CategoryEntity>>> getCategories() {
    return _getCategories(const GetCategoriesParams(categoryType: 'Product'));
  }

  Future<Either<Failure, void>> submit(FeedbackSubmitParams params) async {
    try {
      final formData = FormData.fromMap({
        'reason_id': params.reasonId,
        if (params.categoryId != null) 'category_id': params.categoryId,
        if ((params.subject ?? '').trim().isNotEmpty)
          'subject': params.subject!.trim(),
        'description': params.description.trim(),
        if ((params.contact ?? '').trim().isNotEmpty)
          'contact': params.contact!.trim(),
        if ((params.customReasonText ?? '').trim().isNotEmpty)
          'custom_reason_text': params.customReasonText!.trim(),
      });

      for (final path in params.attachments) {
        formData.files.add(
          MapEntry(
            'attachments',
            await MultipartFile.fromFile(path, filename: path.split('/').last),
          ),
        );
      }

      await _dio.post(
        ApiUrls.feedback,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      return Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(message: _resolveErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  List<dynamic> _extractResults(dynamic data) {
    if (data is List) {
      return data;
    }
    if (data is Map<String, dynamic>) {
      final nested = data['data'];
      if (nested is Map<String, dynamic> && nested['results'] is List) {
        return nested['results'] as List<dynamic>;
      }
      if (data['results'] is List) {
        return data['results'] as List<dynamic>;
      }
      if (nested is List) {
        return nested;
      }
    }
    return const [];
  }

  String _resolveErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final detail = data['detail'] ?? data['message'] ?? data['error'];
      if (detail is String && detail.trim().isNotEmpty) {
        return detail;
      }
    }
    return e.message ?? 'Xatolik yuz berdi';
  }
}
