import 'package:dio/dio.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';
import 'package:uz_xarid/core/constants/api_urls.dart';
import 'package:uz_xarid/features/profile/data/model/profile_model.dart';
import 'package:uz_xarid/features/profile/domain/entity/full_name.dart';
part 'profile_datasource.g.dart';


@RestApi(baseUrl: ApiUrls.baseUrl)
abstract class ProfileApi {
  factory ProfileApi(Dio dio, {String baseUrl}) = _ProfileApi;

  @POST(ApiUrls.sendOtp)
  Future<ProfileModel> sendOtp(String phone);
  @POST(ApiUrls.confirmOtp)
  Future<ProfileModel> confirmOtp(String phone, String otp);
  @PATCH(ApiUrls.profileUpdate)
  Future<ProfileModel> profileUpdate(FullNameEntity fullName);
  
}

//   @override
//   Future<ProfileModel> sentOtp(String phone) async {
//     try {
//       final mainModel = await _dioClient.post(ApiUrls.sendOtp);
//       if( mainModel.ok && mainModel.result != null) {
//         return ProfileModel.fromMap(mainModel.result);
//       }
//       throw ApiException(
//         "API xatoligi: ok=${mainModel.ok}, result=${mainModel.result}",
//       );
//     } catch (e) {
//       print("Profile malumotlarini olib kelishda xatolik: $e");
//       throw Exception("Profile malumotlarini olib kelishda xatolik: $e");
//     }
//   }

//   @override
//   Future<ProfileModel> confirmOtp(String phone, String otp) async {
//     try {
//       final mainModel = await _dioClient.post(ApiUrls.confirmOtp);
//       if (mainModel.ok && mainModel.result != null ) {
//         return ProfileModel.fromJson(mainModel.result);
//       }
//       throw ApiException(
//         "API xatoligi: ok=${mainModel.ok}, result=${mainModel.result}",
//       );
//     } catch (e) {
//         print("Otp jo'natishda xatolik yuz berid: $e");
//       throw Exception("Otp jo'natishda xatolik yuz berid: $e");
//     }
//   }
  

//  }