import 'package:dio/dio.dart';
import 'package:uzxarid/core/constants/api_urls.dart';
import 'package:uzxarid/core/either/either.dart';
import 'package:uzxarid/core/error/failure.dart';
import 'package:uzxarid/features/profile/data/datasource/profile_datasource.dart';
import 'package:uzxarid/features/profile/data/model/profile_model.dart';
import 'package:uzxarid/features/profile/data/model/address_model.dart';
import 'package:uzxarid/features/profile/domain/entity/full_name.dart';
import 'package:uzxarid/features/profile/domain/repositories/profile_repository.dart';
import 'package:uzxarid/features/profile/domain/entity/business_entity.dart';
import 'package:uzxarid/features/profile/data/model/plan_model.dart';
import 'package:uzxarid/features/profile/data/model/plan_history_model.dart';
import 'package:uzxarid/features/profile/data/model/chat/chat_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileApi _profileDataSource;
  final Dio _dio;

  ProfileRepositoryImpl({
    required ProfileApi profileDataSource,
    required Dio dio,
  }) : _profileDataSource = profileDataSource,
       _dio = dio;

  @override
  Future<Either<Failure, ProfileModel>> sendOtp(String phone) async {
    try {
      final body = await _buildOtpRequestBody(phone);
      final result = await _profileDataSource.sendOtp(body);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(ValidationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProfileModel>> confirmOtp(
    String phone,
    String otp,
  ) async {
    try {
      final result = await _profileDataSource.confirmOtp({
        'phone': phone,
        'code': otp,
      });
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(ValidationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProfileModel>> profileUpdate(
    ProfileUpdateEntity entity,
  ) async {
    try {
      late ProfileModel result;

      if (entity.avatarPath != null && entity.avatarPath!.isNotEmpty) {
        final formData = FormData.fromMap({
          ...entity.toMap(),
          'avatar': await MultipartFile.fromFile(
            entity.avatarPath!,
            filename: entity.avatarPath!.split('/').last,
          ),
        });

        final response = await _dio.patch(
          'auth/user-update/',
          data: formData,
          options: Options(contentType: 'multipart/form-data'),
        );
        result = ProfileModel.fromJson(response.data);
      } else {
        result = await _profileDataSource.profileUpdate(entity.toMap());
      }

      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(ValidationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProfileModel>> getProfile() async {
    try {
      final result = await _profileDataSource.getProfile();
      return Right(result);
    } catch (e) {
      return Left(ValidationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProfileModel>> resendOtp(String phone) async {
    try {
      final body = await _buildOtpRequestBody(phone);
      final result = await _profileDataSource.resendOtp(body);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(ValidationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProfileModel>> getBusinessMe() async {
    try {
      final result = await _profileDataSource.getBusinessMe();
      return Right(result);
    } catch (e) {
      return Left(ValidationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProfileModel>> createBusiness(
    BusinessEntity entity,
  ) async {
    try {
      final formData = FormData.fromMap(entity.toMap());

      if (entity.avatarPath != null && entity.avatarPath!.isNotEmpty) {
        formData.files.add(
          MapEntry(
            'avatar',
            await MultipartFile.fromFile(
              entity.avatarPath!,
              filename: entity.avatarPath!.split('/').last,
            ),
          ),
        );
      }

      if (entity.bannerPath != null && entity.bannerPath!.isNotEmpty) {
        formData.files.add(
          MapEntry(
            'banner',
            await MultipartFile.fromFile(
              entity.bannerPath!,
              filename: entity.bannerPath!.split('/').last,
            ),
          ),
        );
      }

      final result = await _profileDataSource.createBusiness(formData);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(ValidationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProfileModel>> updateBusiness(
    String id,
    BusinessEntity entity,
  ) async {
    try {
      final formData = FormData.fromMap(entity.toMap());

      if (entity.avatarPath != null && entity.avatarPath!.isNotEmpty) {
        formData.files.add(
          MapEntry('avatar', await MultipartFile.fromFile(entity.avatarPath!)),
        );
      }

      if (entity.bannerPath != null && entity.bannerPath!.isNotEmpty) {
        formData.files.add(
          MapEntry(
            'banner',
            await MultipartFile.fromFile(
              entity.bannerPath!,
              filename: entity.bannerPath!.split('/').last,
            ),
          ),
        );
      }

      final result = await _profileDataSource.updateBusiness(id, formData);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(ValidationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProfileModel>> deleteBusiness(String id) async {
    try {
      final result = await _profileDataSource.deleteBusiness(id);
      return Right(result);
    } catch (e) {
      return Left(ValidationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProfileModel>> updateBusinessImage(String id) async {
    try {
      final result = await _profileDataSource.updateBusinessImage(
        id,
        FormData.fromMap({}),
      );
      return Right(result);
    } catch (e) {
      return Left(ValidationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProfileModel>> getBusinessById(String id) async {
    try {
      final result = await _profileDataSource.getBusinessById(id);
      return Right(result);
    } catch (e) {
      return Left(ValidationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AddressResponseModel>> getAddresses(
    int page,
    int pageSize,
  ) async {
    try {
      final result = await _profileDataSource.getAddresses(page, pageSize);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(ValidationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AddressModel>> createAddress(
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await _profileDataSource.createAddress(data);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(ValidationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AddressModel>> updateAddress(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await _profileDataSource.updateAddress(id, data);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(ValidationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAddress(int id) async {
    try {
      await _profileDataSource.deleteAddress(id);
      return Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(ValidationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, dynamic>> getViewedAds(int page, int pageSize) async {
    try {
      final result = await _profileDataSource.getViewedAds(page, pageSize);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(ValidationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearViewedAds() async {
    try {
      await _profileDataSource.clearViewedAds();
      return Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(ValidationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PlanResponseModel>> getPlans() async {
    try {
      final result = await _profileDataSource.getPlans();
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(ValidationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PlanHistoryResponseModel>> getPlanHistory(
    int page,
    int pageSize,
  ) async {
    try {
      final result = await _profileDataSource.getPlanHistory(page, pageSize);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(ValidationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChatMessagesResponseModel>> getChatMessages(
    int chatRoomId,
    int page,
    int pageSize,
  ) async {
    try {
      final result = await _profileDataSource.getChatMessages(
        chatRoomId,
        page,
        pageSize,
      );
      return Right(result);
    } on DioException catch (e) {
      String message = 'Ma\'lumot yuklashda xatolik';
      if (e.response?.statusCode == 400) {
        final data = e.response?.data;
        message =
            'Ruxsat berilmadi yoki xato so\'rov (400) [ID: $chatRoomId] - ${data.toString()}';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        message = 'Internet aloqasi sekin';
      }
      return Left(ServerFailure(message));
    } catch (e) {
      return Left(
        ValidationFailure('Kutilmagan xato: ${e.toString().split('\n').first}'),
      );
    }
  }

  @override
  Future<Either<Failure, ChatMessagesResponseModel>> sendChatMessage(
    dynamic data,
  ) async {
    try {
      final result = await _profileDataSource.sendChatMessage(data);
      return Right(result);
    } on DioException catch (e) {
      String message = 'Xabar yuborishda xatolik';
      if (e.response?.statusCode == 400) {
        final responseData = e.response?.data;
        final errors = responseData?['data'];
        // Detect "Chat room not found" specifically
        if (errors is Map && errors['chat_room_id'] != null) {
          final roomErrors = errors['chat_room_id'];
          if (roomErrors is List &&
              roomErrors.any((e) => e.toString().contains('not found'))) {
            message = 'CHAT_ROOM_NOT_FOUND';
          } else if (roomErrors is List &&
              roomErrors.any((e) => e.toString().contains('Обязательное'))) {
            message = 'CHAT_ROOM_NOT_FOUND';
          } else {
            message = 'Xato (400) [Send] - ${responseData.toString()}';
          }
        } else {
          message = 'Xato (400) [Send] - ${responseData.toString()}';
        }
      }
      return Left(ServerFailure(message));
    } catch (e) {
      return Left(
        ValidationFailure(
          'Xabar yuborishda kutilmagan xato: ${e.toString().split('\n').first}',
        ),
      );
    }
  }

  Future<Map<String, dynamic>> _buildOtpRequestBody(String phone) async {
    final body = <String, dynamic>{'phone': phone};
    final offerId = await _getActiveOfferId();
    if (offerId != null) {
      body['offer_id'] = offerId;
      body['offer_accepted'] = true;
    }
    return body;
  }

  Future<int?> _getActiveOfferId() async {
    final response = await _dio.get(ApiUrls.activeOffer);
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final directId = data['id'];
      if (directId is int) return directId;
      if (directId is String) return int.tryParse(directId);

      final nestedData = data['data'];
      if (nestedData is Map<String, dynamic>) {
        final nestedId = nestedData['id'];
        if (nestedId is int) return nestedId;
        if (nestedId is String) return int.tryParse(nestedId);
      }
    }
    return null;
  }
}
