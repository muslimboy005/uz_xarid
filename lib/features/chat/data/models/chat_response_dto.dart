import 'package:json_annotation/json_annotation.dart';
import 'chat_room_dto.dart';
import 'message_dto.dart';

part 'chat_response_dto.g.dart';

@JsonSerializable()
class ChatRoomResponseDto {
  final bool status;
  final ChatRoomDto data;

  ChatRoomResponseDto({required this.status, required this.data});

  factory ChatRoomResponseDto.fromJson(Map<String, dynamic> json) => _$ChatRoomResponseDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ChatRoomResponseDtoToJson(this);
}

@JsonSerializable()
class MessagePaginationResponseDto {
  final bool status;
  final MessagePaginationDto data;

  MessagePaginationResponseDto({required this.status, required this.data});

  factory MessagePaginationResponseDto.fromJson(Map<String, dynamic> json) => _$MessagePaginationResponseDtoFromJson(json);
  Map<String, dynamic> toJson() => _$MessagePaginationResponseDtoToJson(this);
}

@JsonSerializable()
class MessageResponseDto {
  final bool status;
  final MessageDto data;

  MessageResponseDto({required this.status, required this.data});

  factory MessageResponseDto.fromJson(Map<String, dynamic> json) => _$MessageResponseDtoFromJson(json);
  Map<String, dynamic> toJson() => _$MessageResponseDtoToJson(this);
}
