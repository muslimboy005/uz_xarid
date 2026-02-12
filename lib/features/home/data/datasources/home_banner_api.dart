import 'package:dio/dio.dart';
import 'package:uz_xarid/core/constants/api_urls.dart';
import 'package:uz_xarid/features/home/data/models/banner_dto.dart';

class HomeBannerApi {
  HomeBannerApi(this._dio);

  final Dio _dio;

  Future<BannerResponseDto> getBanners() async {
    final response = await _dio.get(ApiUrls.banner);
    final data = response.data as Map<String, dynamic>;
    return BannerResponseDto.fromJson(data);
  }
}
