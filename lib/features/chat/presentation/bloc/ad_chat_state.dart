part of 'ad_chat_bloc.dart';

enum ChatStatus { initial, loading, success, failure }

class ChatState extends Equatable {
  const ChatState({
    this.status = ChatStatus.initial,
    this.room,
    this.messages = const [],
    this.error,
    this.hasReachedMax = false,
  });

  final ChatStatus status;
  final ChatRoomEntity? room;
  final List<MessageEntity> messages;
  final String? error;
  final bool hasReachedMax;

  ChatState copyWith({
    ChatStatus? status,
    ChatRoomEntity? room,
    List<MessageEntity>? messages,
    String? error,
    bool? hasReachedMax,
  }) {
    return ChatState(
      status: status ?? this.status,
      room: room ?? this.room,
      messages: messages ?? this.messages,
      error: error ?? this.error,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [status, room, messages, error, hasReachedMax];
}
