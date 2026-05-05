import 'package:json_annotation/json_annotation.dart';

part 'chat_model.g.dart';

@JsonSerializable()
class ChatMessagesResponseModel {
  @JsonKey(name: 'status')
  final bool status;
  @JsonKey(name: 'data')
  final ChatMessagesData data;

  ChatMessagesResponseModel({required this.status, required this.data});

  factory ChatMessagesResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ChatMessagesResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMessagesResponseModelToJson(this);
}

@JsonSerializable()
class ChatMessagesData {
  @JsonKey(name: 'count')
  final int count;
  @JsonKey(name: 'next')
  final String? next;
  @JsonKey(name: 'previous')
  final String? previous;
  @JsonKey(name: 'results')
  final List<ChatMessageModel> results;

  ChatMessagesData({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory ChatMessagesData.fromJson(Map<String, dynamic> json) =>
      _$ChatMessagesDataFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMessagesDataToJson(this);
}

@JsonSerializable()
class ChatMessageModel {
  @JsonKey(name: 'id')
  final int id;
  @JsonKey(name: 'chat_room')
  final int chatRoom;
  @JsonKey(name: 'sender')
  final int sender;
  @JsonKey(name: 'content')
  final String? content;
  @JsonKey(name: 'file_url')
  final String? fileUrl;
  @JsonKey(name: 'file')
  final String? file;
  @JsonKey(name: 'files')
  final List<ChatFileModel> files;
  @JsonKey(name: 'is_read')
  final bool isRead;
  @JsonKey(name: 'read_at')
  final String? readAt;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;
  @JsonKey(name: 'sender_info')
  final ChatSenderInfoModel senderInfo;
  @JsonKey(name: 'file_url_display')
  final String? fileUrlDisplay;

  ChatMessageModel({
    required this.id,
    required this.chatRoom,
    required this.sender,
    this.content,
    this.fileUrl,
    this.file,
    this.files = const [],
    required this.isRead,
    this.readAt,
    required this.createdAt,
    required this.updatedAt,
    required this.senderInfo,
    this.fileUrlDisplay,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMessageModelToJson(this);
}

@JsonSerializable()
class ChatFileModel {
  @JsonKey(name: 'id')
  final int id;
  @JsonKey(name: 'file')
  final String file;
  @JsonKey(name: 'file_type')
  final String? fileType;
  @JsonKey(name: 'file_url')
  final String? fileUrl;
  @JsonKey(name: 'file_url_display')
  final String? fileUrlDisplay;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  ChatFileModel({
    required this.id,
    required this.file,
    this.fileType,
    this.fileUrl,
    this.fileUrlDisplay,
    this.createdAt,
  });

  factory ChatFileModel.fromJson(Map<String, dynamic> json) =>
      _$ChatFileModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatFileModelToJson(this);
}

@JsonSerializable()
class ChatSenderInfoModel {
  @JsonKey(name: 'first_name')
  final String? firstName;
  @JsonKey(name: 'avatar')
  final String? avatar;
  @JsonKey(name: 'phone')
  final String? phone;

  ChatSenderInfoModel({this.firstName, this.avatar, this.phone});

  factory ChatSenderInfoModel.fromJson(Map<String, dynamic> json) =>
      _$ChatSenderInfoModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatSenderInfoModelToJson(this);
}
