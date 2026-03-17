// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMessagesResponseModel _$ChatMessagesResponseModelFromJson(
  Map<String, dynamic> json,
) => ChatMessagesResponseModel(
  status: json['status'] as bool,
  data: ChatMessagesData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ChatMessagesResponseModelToJson(
  ChatMessagesResponseModel instance,
) => <String, dynamic>{'status': instance.status, 'data': instance.data};

ChatMessagesData _$ChatMessagesDataFromJson(Map<String, dynamic> json) =>
    ChatMessagesData(
      count: (json['count'] as num).toInt(),
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: (json['results'] as List<dynamic>)
          .map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ChatMessagesDataToJson(ChatMessagesData instance) =>
    <String, dynamic>{
      'count': instance.count,
      'next': instance.next,
      'previous': instance.previous,
      'results': instance.results,
    };

ChatMessageModel _$ChatMessageModelFromJson(Map<String, dynamic> json) =>
    ChatMessageModel(
      id: (json['id'] as num).toInt(),
      chatRoom: (json['chat_room'] as num).toInt(),
      sender: (json['sender'] as num).toInt(),
      content: json['content'] as String?,
      fileUrl: json['file_url'] as String?,
      file: json['file'] as String?,
      files:
          (json['files'] as List<dynamic>?)
              ?.map((e) => ChatFileModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isRead: json['is_read'] as bool,
      readAt: json['read_at'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      senderInfo: ChatSenderInfoModel.fromJson(
        json['sender_info'] as Map<String, dynamic>,
      ),
      fileUrlDisplay: json['file_url_display'] as String?,
    );

Map<String, dynamic> _$ChatMessageModelToJson(ChatMessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'chat_room': instance.chatRoom,
      'sender': instance.sender,
      'content': instance.content,
      'file_url': instance.fileUrl,
      'file': instance.file,
      'files': instance.files,
      'is_read': instance.isRead,
      'read_at': instance.readAt,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'sender_info': instance.senderInfo,
      'file_url_display': instance.fileUrlDisplay,
    };

ChatFileModel _$ChatFileModelFromJson(Map<String, dynamic> json) =>
    ChatFileModel(
      id: (json['id'] as num).toInt(),
      file: json['file'] as String,
      fileType: json['file_type'] as String?,
      fileUrl: json['file_url'] as String?,
      fileUrlDisplay: json['file_url_display'] as String?,
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$ChatFileModelToJson(ChatFileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'file': instance.file,
      'file_type': instance.fileType,
      'file_url': instance.fileUrl,
      'file_url_display': instance.fileUrlDisplay,
      'created_at': instance.createdAt,
    };

ChatSenderInfoModel _$ChatSenderInfoModelFromJson(Map<String, dynamic> json) =>
    ChatSenderInfoModel(
      firstName: json['first_name'] as String?,
      avatar: json['avatar'] as String?,
      phone: json['phone'] as String?,
    );

Map<String, dynamic> _$ChatSenderInfoModelToJson(
  ChatSenderInfoModel instance,
) => <String, dynamic>{
  'first_name': instance.firstName,
  'avatar': instance.avatar,
  'phone': instance.phone,
};
