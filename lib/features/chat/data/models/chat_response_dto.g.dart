// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatRoomResponseDto _$ChatRoomResponseDtoFromJson(Map<String, dynamic> json) =>
    ChatRoomResponseDto(
      status: json['status'] as bool,
      data: ChatRoomDto.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ChatRoomResponseDtoToJson(
  ChatRoomResponseDto instance,
) => <String, dynamic>{'status': instance.status, 'data': instance.data};

MessagePaginationResponseDto _$MessagePaginationResponseDtoFromJson(
  Map<String, dynamic> json,
) => MessagePaginationResponseDto(
  status: json['status'] as bool,
  data: MessagePaginationDto.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$MessagePaginationResponseDtoToJson(
  MessagePaginationResponseDto instance,
) => <String, dynamic>{'status': instance.status, 'data': instance.data};

MessageResponseDto _$MessageResponseDtoFromJson(Map<String, dynamic> json) =>
    MessageResponseDto(
      status: json['status'] as bool,
      data: MessageDto.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MessageResponseDtoToJson(MessageResponseDto instance) =>
    <String, dynamic>{'status': instance.status, 'data': instance.data};
