import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:uz_xarid/core/constants/api_urls.dart';
import 'package:uz_xarid/features/cart/data/models/cart_item_model.dart';

part 'cart_api.g.dart';

@RestApi(baseUrl: ApiUrls.baseUrl)
abstract class CartApi {
  factory CartApi(Dio dio, {String baseUrl}) = _CartApi;

  @GET(ApiUrls.cart)
  Future<CartResponseModel> getCart({
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  @POST(ApiUrls.cart)
  Future<HttpResponse> addToCart(@Body() Map<String, dynamic> body);

  @GET(ApiUrls.cartId)
  Future<HttpResponse> getCartItem(@Path('id') String id);

  @PATCH(ApiUrls.cartId)
  Future<HttpResponse> updateCartItem(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  @DELETE(ApiUrls.cartId)
  Future<HttpResponse> deleteCartItem(@Path('id') String id);

  @POST(ApiUrls.cartCheckout)
  Future<HttpResponse> checkout(@Body() Map<String, dynamic> body);

  @DELETE(ApiUrls.cartClear)
  Future<HttpResponse> clearCart();
}
