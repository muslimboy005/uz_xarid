import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:uzxarid/core/constants/api_urls.dart';
import 'package:uzxarid/features/chat/data/models/chat_response_dto.dart';
import 'package:uzxarid/features/chat/data/models/chat_room_pagination_dto.dart';

part 'chat_api.g.dart';

@RestApi()
abstract class ChatApi {
  factory ChatApi(Dio dio, {String baseUrl}) = _ChatApi;

  @GET(ApiUrls.chatRooms)
  Future<ChatRoomPaginationResponseDto> getRooms(@Query('page') int? page);

  @POST(ApiUrls.chatRooms)
  Future<ChatRoomResponseDto> createRoom(@Body() Map<String, dynamic> body);

  @GET(ApiUrls.chatRoomMessages)
  Future<MessagePaginationResponseDto> getMessages(
    @Path('id') String roomId,
    @Query('page') int? page,
  );

  @POST(ApiUrls.chatMessages)
  Future<MessageResponseDto> sendMessage(@Body() Map<String, dynamic> body);
}
