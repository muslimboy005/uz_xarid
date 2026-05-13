import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:uzxarid/core/error/failures.dart';
import 'package:uzxarid/features/chat/data/datasources/chat_api.dart';
import 'package:uzxarid/features/chat/data/models/chat_room_dto.dart';
import 'package:uzxarid/features/chat/data/models/message_dto.dart';
import 'package:uzxarid/features/chat/domain/entities/chat_room_entity.dart';
import 'package:uzxarid/features/chat/domain/entities/message_entity.dart';
import 'package:uzxarid/features/chat/domain/repositories/chat_repository.dart';
import 'package:uzxarid/core/service/chat_socket_service.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatApi _api;
  final ChatSocketService _socketService;

  ChatRepositoryImpl(this._api, this._socketService);

  @override
  Future<Either<Failure, List<ChatRoomEntity>>> getRooms({int? page}) async {
    try {
      final response = await _api.getRooms(page);
      final entities = response.data.results.map(_mapChatRoom).toList();
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChatRoomEntity>> createRoom(String adSlug) async {
    try {
      final response = await _api.createRoom({
        'chat_type': 'ad',
        'ad_slug': adSlug,
      });
      return Right(_mapChatRoom(response.data));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MessageEntity>>> getMessages(
    int roomId, {
    int? page,
  }) async {
    try {
      final response = await _api.getMessages(roomId.toString(), page);
      final entities = response.data.results.map(_mapMessage).toList();
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MessageEntity>> sendMessage(
    int roomId,
    String content,
  ) async {
    try {
      final response = await _api.sendMessage({
        'chat_room_id': roomId.toString(),
        'content': content,
      });
      return Right(_mapMessage(response.data));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<Map<String, dynamic>> get realtimeMessages => _socketService.messages;

  @override
  void connectToRoom(int roomId, String token) {
    final url = 'ws://api.uzxarid.uz/ws/chat/$roomId/?token=$token';
    _socketService.connect(url);
  }

  @override
  void markRead(int? messageId) {
    _socketService.send({
      'type': 'mark_read',
      'data': messageId != null ? {'message_id': messageId} : {},
    });
  }

  @override
  void dispose() {
    _socketService.close();
  }

  ChatRoomEntity _mapChatRoom(ChatRoomDto dto) {
    // Basic logic for now: other participant is whoever's info we have.
    // In a mature app, we'd compare against current user ID.
    final participant = dto.sellerInfo ?? dto.buyerInfo;
    final otherId = dto.seller ?? dto.buyer;

    return ChatRoomEntity(
      id: dto.id,
      chatType: dto.chatType,
      otherParticipantId: otherId,
      adInfo: dto.adInfo != null
          ? ChatAdInfoEntity(
              slug: dto.adInfo!.slug,
              title: dto.adInfo!.title,
              price: dto.adInfo!.price?.toString(),
              image: dto.adInfo!.mainImage?.original,
            )
          : null,
      otherParticipant: participant != null
          ? ChatParticipantEntity(
              firstName: participant.firstName,
              avatarUrl:
                  participant.avatar?.original ?? participant.avatar?.small,
              phone: participant.phone,
            )
          : null,
      lastMessage: dto.lastMessage != null
          ? _mapMessage(dto.lastMessage!)
          : null,
      unreadCount: dto.unreadCount ?? 0,
    );
  }

  MessageEntity _mapMessage(MessageDto dto) {
    return MessageEntity(
      id: dto.id,
      senderId: _parseId(dto.senderId),
      content: dto.content,
      createdAt: DateTime.tryParse(dto.createdAt) ?? DateTime.now(),
      isRead: dto.isRead,
      fileUrl: dto.fileUrl,
    );
  }

  int? _parseId(dynamic id) {
    if (id == null) return null;
    if (id is int) return id;
    if (id is String) return int.tryParse(id);
    return null;
  }
}
