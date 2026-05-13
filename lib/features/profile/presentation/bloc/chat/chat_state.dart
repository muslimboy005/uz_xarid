import 'package:equatable/equatable.dart';
import 'package:uzxarid/features/profile/data/model/chat/chat_model.dart';

enum ChatStatus { initial, loading, success, failure }

class ChatState extends Equatable {
  final ChatStatus status;
  final List<ChatMessageModel> messages;
  final bool hasReachedMax;
  final int currentPage;
  final String? errorMessage;
  final bool isSending;
  final List<String> pickedFilePaths;
  final int? currentUserId;
  final int? chatRoomId;

  const ChatState({
    this.status = ChatStatus.initial,
    this.messages = const [],
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.errorMessage,
    this.isSending = false,
    this.pickedFilePaths = const [],
    this.currentUserId,
    this.chatRoomId,
  });

  ChatState copyWith({
    ChatStatus? status,
    List<ChatMessageModel>? messages,
    bool? hasReachedMax,
    int? currentPage,
    String? errorMessage,
    bool? isSending,
    List<String>? pickedFilePaths,
    int? currentUserId,
    int? chatRoomId,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      errorMessage: errorMessage ?? this.errorMessage,
      isSending: isSending ?? this.isSending,
      pickedFilePaths: pickedFilePaths ?? this.pickedFilePaths,
      currentUserId: currentUserId ?? this.currentUserId,
      chatRoomId: chatRoomId ?? this.chatRoomId,
    );
  }

  @override
  List<Object?> get props => [
    status,
    messages,
    hasReachedMax,
    currentPage,
    errorMessage,
    isSending,
    pickedFilePaths,
    currentUserId,
    chatRoomId,
  ];
}
