import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class GetChatMessagesEvent extends ChatEvent {
  final int chatRoomId;
  final int page;
  final int pageSize;

  const GetChatMessagesEvent({
    required this.chatRoomId,
    this.page = 1,
    this.pageSize = 10,
  });

  @override
  List<Object?> get props => [chatRoomId, page, pageSize];
}

class SendChatMessageEvent extends ChatEvent {
  final int chatRoomId;
  final String content;
  final List<String> filePaths;

  const SendChatMessageEvent({
    required this.chatRoomId,
    required this.content,
    this.filePaths = const [],
  });

  @override
  List<Object?> get props => [chatRoomId, content, filePaths];
}

class PickFilesEvent extends ChatEvent {
  final List<String> filePaths;
  const PickFilesEvent(this.filePaths);

  @override
  List<Object?> get props => [filePaths];
}

class RemoveFileEvent extends ChatEvent {
  final String filePath;
  const RemoveFileEvent(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class StartChatPollingEvent extends ChatEvent {
  final int chatRoomId;
  const StartChatPollingEvent(this.chatRoomId);

  @override
  List<Object?> get props => [chatRoomId];
}

class StopChatPollingEvent extends ChatEvent {}

class SetChatUserIdEvent extends ChatEvent {
  final int userId;
  const SetChatUserIdEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class InitializeChatEvent extends ChatEvent {
  final int chatRoomId;
  const InitializeChatEvent(this.chatRoomId);

  @override
  List<Object?> get props => [chatRoomId];
}
