import 'package:equatable/equatable.dart';
import 'package:uz_xarid/features/chat/domain/entities/chat_room_entity.dart';

enum ChatListStatus { initial, loading, success, failure }

class ChatListState extends Equatable {
  final ChatListStatus status;
  final List<ChatRoomEntity> rooms;
  final String? error;
  final bool hasReachedMax;
  final int currentPage;

  const ChatListState({
    this.status = ChatListStatus.initial,
    this.rooms = const [],
    this.error,
    this.hasReachedMax = false,
    this.currentPage = 1,
  });

  ChatListState copyWith({
    ChatListStatus? status,
    List<ChatRoomEntity>? rooms,
    String? error,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return ChatListState(
      status: status ?? this.status,
      rooms: rooms ?? this.rooms,
      error: error ?? this.error,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [status, rooms, error, hasReachedMax, currentPage];
}
