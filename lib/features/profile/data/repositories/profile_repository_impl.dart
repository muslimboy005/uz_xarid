import 'package:dio/dio.dart';
import 'package:uz_xarid/core/either/either.dart';
import 'package:uz_xarid/core/error/failure.dart';
import 'package:uz_xarid/features/profile/data/datasource/profile_datasource.dart';
import 'package:uz_xarid/features/profile/data/model/profile_model.dart';
import 'package:uz_xarid/features/profile/data/model/address_model.dart';
import 'package:uz_xarid/features/profile/domain/entity/full_name.dart';
import 'package:uz_xarid/features/profile/domain/repositories/profile_repository.dart';
import 'package:uz_xarid/features/profile/domain/entity/business_entity.dart';

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
}
