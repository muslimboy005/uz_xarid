import 'package:dio/dio.dart';
import 'package:uz_xarid/core/either/either.dart';
import 'package:uz_xarid/core/error/failure.dart';
import 'package:uz_xarid/features/profile/data/datasource/profile_datasource.dart';
import 'package:uz_xarid/features/profile/data/model/profile_model.dart';
import 'package:uz_xarid/features/profile/domain/entity/full_name.dart';
import 'package:uz_xarid/features/profile/domain/repositories/profile_repository.dart';

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
      final result = await _profileDataSource.sendOtp({'phone': phone});
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
      final result = await _profileDataSource.resendOtp({'phone': phone});
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(ValidationFailure(e.toString()));
    }
  }
}
