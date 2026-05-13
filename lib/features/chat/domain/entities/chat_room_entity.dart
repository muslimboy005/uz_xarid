import 'package:equatable/equatable.dart';
import 'package:uzxarid/features/chat/domain/entities/message_entity.dart';

class ChatRoomEntity extends Equatable {
  final int id;
  final String chatType;
  final int? otherParticipantId;
  final ChatParticipantEntity? otherParticipant;
  final ChatAdInfoEntity? adInfo;

  final MessageEntity? lastMessage;
  final int unreadCount;

  const ChatRoomEntity({
    required this.id,
    required this.chatType,
    this.otherParticipantId,
    this.otherParticipant,
    this.adInfo,
    this.lastMessage,
    this.unreadCount = 0,
  });

  @override
  List<Object?> get props => [id, chatType, otherParticipant, adInfo, lastMessage, unreadCount];
}

class ChatParticipantEntity extends Equatable {
  final String? firstName;
  final String? avatarUrl;
  final String? phone;

  const ChatParticipantEntity({this.firstName, this.avatarUrl, this.phone});

  @override
  List<Object?> get props => [firstName, avatarUrl, phone];
}

class ChatAdInfoEntity extends Equatable {
  final String? slug;
  final String? title;
  final String? price;
  final String? image;

  const ChatAdInfoEntity({this.slug, this.title, this.price, this.image});

  @override
  List<Object?> get props => [slug, title, price, image];
}
