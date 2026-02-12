import 'package:uz_xarid/core/constants/api_urls.dart';
import 'package:uz_xarid/core/dio/dio_client.dart';
import 'package:uz_xarid/core/error/failure.dart';
import 'package:uz_xarid/features/profile/data/model/profile_model.dart';

abstract class ProfileDatasource {
  Future<ProfileModel> sentOtp(String phone);
  Future<ProfileModel> confirmOtp(String phone, String otp);

    factory ProfileDatasource(DioClient dioClient) =>
      ProfileDataSourceImpl(dioClient: dioClient);

}
 class ProfileDataSourceImpl implements ProfileDatasource{

    final DioClient _dioClient;
  ProfileDataSourceImpl({required DioClient dioClient}) : _dioClient = dioClient;

  @override
  Future<ProfileModel> sentOtp(String phone) async {
    try {
      final mainModel = await _dioClient.post(ApiUrls.sendOtp);
      if( mainModel.ok && mainModel.result != null) {
        return ProfileModel.fromMap(mainModel.result);
      }
      throw ApiException(
        "API xatoligi: ok=${mainModel.ok}, result=${mainModel.result}",
      );
    } catch (e) {
      print("Profile malumotlarini olib kelishda xatolik: $e");
      throw Exception("Profile malumotlarini olib kelishda xatolik: $e");
    }
  }

  @override
  Future<ProfileModel> confirmOtp(String phone, String otp) async {
    try {
      final mainModel = await _dioClient.post(ApiUrls.confirmOtp);
      if (mainModel.ok && mainModel.result != null ) {
        return ProfileModel.fromJson(mainModel.result);
      }
      throw ApiException(
        "API xatoligi: ok=${mainModel.ok}, result=${mainModel.result}",
      );
    } catch (e) {
        print("Otp jo'natishda xatolik yuz berid: $e");
      throw Exception("Otp jo'natishda xatolik yuz berid: $e");
    }
  }
  

 }