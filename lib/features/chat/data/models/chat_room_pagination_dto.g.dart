// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_room_pagination_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatRoomPaginationDto _$ChatRoomPaginationDtoFromJson(
  Map<String, dynamic> json,
) => ChatRoomPaginationDto(
  results: (json['results'] as List<dynamic>)
      .map((e) => ChatRoomDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  count: (json['count'] as num?)?.toInt(),
  next: json['next'] as String?,
  previous: json['previous'] as String?,
);

Map<String, dynamic> _$ChatRoomPaginationDtoToJson(
  ChatRoomPaginationDto instance,
) => <String, dynamic>{
  'results': instance.results,
  'count': instance.count,
  'next': instance.next,
  'previous': instance.previous,
};

ChatRoomPaginationResponseDto _$ChatRoomPaginationResponseDtoFromJson(
  Map<String, dynamic> json,
) => ChatRoomPaginationResponseDto(
  status: json['status'] as bool,
  data: ChatRoomPaginationDto.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ChatRoomPaginationResponseDtoToJson(
  ChatRoomPaginationResponseDto instance,
) => <String, dynamic>{'status': instance.status, 'data': instance.data};
