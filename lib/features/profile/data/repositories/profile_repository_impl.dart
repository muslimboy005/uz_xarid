import 'package:uz_xarid/core/either/either.dart';
import 'package:uz_xarid/core/error/failure.dart';
import 'package:uz_xarid/features/profile/data/datasource/profile_datasource.dart';
import 'package:uz_xarid/features/profile/data/model/profile_model.dart';
import 'package:uz_xarid/features/profile/domain/entity/full_name.dart';
import 'package:uz_xarid/features/profile/domain/repositories/profile_repository.dart';
import 'package:dio/dio.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileApi _profileDataSource;

  ProfileRepositoryImpl({required ProfileApi profileDataSource})
    : _profileDataSource = profileDataSource;

  @override
  Future<Either<Failure, ProfileModel>> sendOtp(String phone) async {
    try {
      print('📡 Repository: sendOtp called with $phone');
      final result = await _profileDataSource.sendOtp({'phone': phone});
      print('✅ Repository: sendOtp success');
      return Right(result);
    } on DioException catch (e) {
      print('❌ Repository: sendOtp DioError: ${e.message}');
      return Left(ServerFailure(e.message ?? 'Network error'));
    } catch (e) {
      print('❌ Repository: sendOtp error: $e');
      return Left(ValidationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProfileModel>> confirmOtp(
    String phone,
    String otp,
  ) async {
    try {
      print('📡 Repository: confirmOtp called');
      final result = await _profileDataSource.confirmOtp({
        'phone': phone,
        'code': otp,
      });
      print('✅ Repository: confirmOtp success');
      return Right(result);
    } on DioException catch (e) {
      print('❌ Repository: confirmOtp DioError: ${e.message}');
      return Left(ServerFailure(e.message ?? 'Network error'));
    } catch (e) {
      print('❌ Repository: confirmOtp error: $e');
      return Left(ValidationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProfileModel>> profileUpdate(
    FullNameEntity fullName,
  ) async {
    try {
      print('📡 Repository: profileUpdate called');
      final result = await _profileDataSource.profileUpdate({
        'first_name': fullName.firstName,
        'last_name': fullName.lastName,
      });
      print('✅ Repository: profileUpdate success');
      return Right(result);
    } on DioException catch (e) {
      print('❌ Repository: profileUpdate DioError: ${e.message}');
      return Left(ServerFailure(e.message ?? 'Network error'));
    } catch (e) {
      print('❌ Repository: profileUpdate error: $e');
      return Left(ValidationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProfileModel>> getProfile() async {
    try {
      print('📡 Repository: getProfile called');
      final result = await _profileDataSource.getProfile();
      print('✅ Repository: getProfile success');
      return Right(result);
    } catch (e) {
      print('❌ Repository: getProfile error: $e');
      return Left(ValidationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProfileModel>> resendOtp(String phone) async {
    try {
      print('📡 Repository: resendOtp called');
      final result = await _profileDataSource.resendOtp({'phone': phone});
      print('✅ Repository: resendOtp success');
      return Right(result);
    } on DioException catch (e) {
      print('❌ Repository: resendOtp DioError: ${e.message}');
      return Left(ServerFailure(e.message ?? 'Network error'));
    } catch (e) {
      print('❌ Repository: resendOtp error: $e');
      return Left(ValidationFailure(e.toString()));
    }
  }
}
