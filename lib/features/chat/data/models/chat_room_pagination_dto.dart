import 'package:json_annotation/json_annotation.dart';
import 'chat_room_dto.dart';

part 'chat_room_pagination_dto.g.dart';

@JsonSerializable()
class ChatRoomPaginationDto {
  final List<ChatRoomDto> results;
  final int? count;
  final String? next;
  final String? previous;

  ChatRoomPaginationDto({required this.results, this.count, this.next, this.previous});

  factory ChatRoomPaginationDto.fromJson(Map<String, dynamic> json) => _$ChatRoomPaginationDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ChatRoomPaginationDtoToJson(this);
}

@JsonSerializable()
class ChatRoomPaginationResponseDto {
  final bool status;
  final ChatRoomPaginationDto data;

  ChatRoomPaginationResponseDto({required this.status, required this.data});

  factory ChatRoomPaginationResponseDto.fromJson(Map<String, dynamic> json) => _$ChatRoomPaginationResponseDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ChatRoomPaginationResponseDtoToJson(this);
}
