import 'package:dartz/dartz.dart';
import 'package:uz_xarid/core/error/failures.dart';
import 'package:uz_xarid/features/chat/domain/entities/message_entity.dart';
import 'package:uz_xarid/features/chat/domain/entities/chat_room_entity.dart';

abstract class ChatRepository {
  Future<Either<Failure, List<ChatRoomEntity>>> getRooms({int? page});
  Future<Either<Failure, ChatRoomEntity>> createRoom(String adSlug);
  Future<Either<Failure, List<MessageEntity>>> getMessages(int roomId, {int? page});
  Future<Either<Failure, MessageEntity>> sendMessage(int roomId, String content);
  
  Stream<Map<String, dynamic>> get realtimeMessages;
  void connectToRoom(int roomId, String token);
  void markRead(int? messageId);
  void dispose();
}
