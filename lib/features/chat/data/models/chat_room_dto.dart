import 'package:json_annotation/json_annotation.dart';
import 'message_dto.dart';

part 'chat_room_dto.g.dart';

@JsonSerializable()
class ChatRoomDto {
  final int id;
  @JsonKey(name: 'chat_type')
  final String chatType;
  final int? buyer;
  final int? seller;
  final int? ad;
  @JsonKey(name: 'buyer_info')
  final ChatUserInfoDto? buyerInfo;
  @JsonKey(name: 'seller_info')
  final ChatUserInfoDto? sellerInfo;
  @JsonKey(name: 'ad_info')
  final ChatAdInfoDto? adInfo;
  @JsonKey(name: 'last_message')
  final MessageDto? lastMessage;
  @JsonKey(name: 'unread_count')
  final int? unreadCount;

  ChatRoomDto({
    required this.id,
    required this.chatType,
    this.buyer,
    this.seller,
    this.ad,
    this.buyerInfo,
    this.sellerInfo,
    this.adInfo,
    this.lastMessage,
    this.unreadCount,
  });

  factory ChatRoomDto.fromJson(Map<String, dynamic> json) => _$ChatRoomDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ChatRoomDtoToJson(this);
}

@JsonSerializable()
class ChatUserInfoDto {
  @JsonKey(name: 'first_name')
  final String? firstName;
  final ChatAvatarDto? avatar;
  final String? phone;

  ChatUserInfoDto({this.firstName, this.avatar, this.phone});

  factory ChatUserInfoDto.fromJson(Map<String, dynamic> json) => _$ChatUserInfoDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ChatUserInfoDtoToJson(this);
}

@JsonSerializable()
class ChatAvatarDto {
  final String? original;
  final String? small;
  final String? medium;
  final String? large;

  ChatAvatarDto({this.original, this.small, this.medium, this.large});

  factory ChatAvatarDto.fromJson(Map<String, dynamic> json) => _$ChatAvatarDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ChatAvatarDtoToJson(this);
}

@JsonSerializable()
class ChatAdInfoDto {
  final String? slug;
  final String? title;
  final dynamic price;

  @JsonKey(name: 'main_image')
  final ChatMainImageDto? mainImage;

  ChatAdInfoDto({this.slug, this.title, this.price, this.mainImage});

  factory ChatAdInfoDto.fromJson(Map<String, dynamic> json) => _$ChatAdInfoDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ChatAdInfoDtoToJson(this);
}
@JsonSerializable()
class ChatMainImageDto {
  final String? original;

  ChatMainImageDto({this.original});

  factory ChatMainImageDto.fromJson(Map<String, dynamic> json) => _$ChatMainImageDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ChatMainImageDtoToJson(this);
}
