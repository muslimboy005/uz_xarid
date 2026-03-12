import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:uz_xarid/core/constants/api_urls.dart';
import 'package:uz_xarid/features/order/data/models/order_create_dto.dart';
import 'package:uz_xarid/features/order/data/models/order_response_dto.dart';

part 'order_api.g.dart';

@RestApi()
abstract class OrderApi {
  factory OrderApi(Dio dio, {String baseUrl}) = _OrderApi;

  @POST(ApiUrls.order)
  Future<OrderResponseDto> createOrder(@Body() OrderCreateDto request);

  @GET(ApiUrls.myOrders)
  Future<OrderListResponseDto> getMyOrders({
    @Query('page') int page = 1,
    @Query('page_size') int pageSize = 10,
  });
}
