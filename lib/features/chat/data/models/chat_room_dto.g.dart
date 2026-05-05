// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_room_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatRoomDto _$ChatRoomDtoFromJson(Map<String, dynamic> json) => ChatRoomDto(
  id: (json['id'] as num).toInt(),
  chatType: json['chat_type'] as String,
  buyer: (json['buyer'] as num?)?.toInt(),
  seller: (json['seller'] as num?)?.toInt(),
  ad: (json['ad'] as num?)?.toInt(),
  buyerInfo: json['buyer_info'] == null
      ? null
      : ChatUserInfoDto.fromJson(json['buyer_info'] as Map<String, dynamic>),
  sellerInfo: json['seller_info'] == null
      ? null
      : ChatUserInfoDto.fromJson(json['seller_info'] as Map<String, dynamic>),
  adInfo: json['ad_info'] == null
      ? null
      : ChatAdInfoDto.fromJson(json['ad_info'] as Map<String, dynamic>),
  lastMessage: json['last_message'] == null
      ? null
      : MessageDto.fromJson(json['last_message'] as Map<String, dynamic>),
  unreadCount: (json['unread_count'] as num?)?.toInt(),
);

Map<String, dynamic> _$ChatRoomDtoToJson(ChatRoomDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'chat_type': instance.chatType,
      'buyer': instance.buyer,
      'seller': instance.seller,
      'ad': instance.ad,
      'buyer_info': instance.buyerInfo,
      'seller_info': instance.sellerInfo,
      'ad_info': instance.adInfo,
      'last_message': instance.lastMessage,
      'unread_count': instance.unreadCount,
    };

ChatUserInfoDto _$ChatUserInfoDtoFromJson(Map<String, dynamic> json) =>
    ChatUserInfoDto(
      firstName: json['first_name'] as String?,
      avatar: json['avatar'] == null
          ? null
          : ChatAvatarDto.fromJson(json['avatar'] as Map<String, dynamic>),
      phone: json['phone'] as String?,
    );

Map<String, dynamic> _$ChatUserInfoDtoToJson(ChatUserInfoDto instance) =>
    <String, dynamic>{
      'first_name': instance.firstName,
      'avatar': instance.avatar,
      'phone': instance.phone,
    };

ChatAvatarDto _$ChatAvatarDtoFromJson(Map<String, dynamic> json) =>
    ChatAvatarDto(
      original: json['original'] as String?,
      small: json['small'] as String?,
      medium: json['medium'] as String?,
      large: json['large'] as String?,
    );

Map<String, dynamic> _$ChatAvatarDtoToJson(ChatAvatarDto instance) =>
    <String, dynamic>{
      'original': instance.original,
      'small': instance.small,
      'medium': instance.medium,
      'large': instance.large,
    };

ChatAdInfoDto _$ChatAdInfoDtoFromJson(Map<String, dynamic> json) =>
    ChatAdInfoDto(
      slug: json['slug'] as String?,
      title: json['title'] as String?,
      price: json['price'],
      mainImage: json['main_image'] == null
          ? null
          : ChatMainImageDto.fromJson(
              json['main_image'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$ChatAdInfoDtoToJson(ChatAdInfoDto instance) =>
    <String, dynamic>{
      'slug': instance.slug,
      'title': instance.title,
      'price': instance.price,
      'main_image': instance.mainImage,
    };

ChatMainImageDto _$ChatMainImageDtoFromJson(Map<String, dynamic> json) =>
    ChatMainImageDto(original: json['original'] as String?);

Map<String, dynamic> _$ChatMainImageDtoToJson(ChatMainImageDto instance) =>
    <String, dynamic>{'original': instance.original};
