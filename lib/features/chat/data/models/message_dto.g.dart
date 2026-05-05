// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageDto _$MessageDtoFromJson(Map<String, dynamic> json) => MessageDto(
  id: (json['id'] as num).toInt(),
  senderId: json['sender_id'],
  content: json['content'] as String,
  createdAt: json['created_at'] as String,
  isRead: json['is_read'] as bool?,
  fileUrl: json['file_url'] as String?,
);

Map<String, dynamic> _$MessageDtoToJson(MessageDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sender_id': instance.senderId,
      'content': instance.content,
      'created_at': instance.createdAt,
      'is_read': instance.isRead,
      'file_url': instance.fileUrl,
    };

MessagePaginationDto _$MessagePaginationDtoFromJson(
  Map<String, dynamic> json,
) => MessagePaginationDto(
  results: (json['results'] as List<dynamic>)
      .map((e) => MessageDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  count: (json['count'] as num?)?.toInt(),
  next: json['next'] as String?,
  previous: json['previous'] as String?,
);

Map<String, dynamic> _$MessagePaginationDtoToJson(
  MessagePaginationDto instance,
) => <String, dynamic>{
  'results': instance.results,
  'count': instance.count,
  'next': instance.next,
  'previous': instance.previous,
};
