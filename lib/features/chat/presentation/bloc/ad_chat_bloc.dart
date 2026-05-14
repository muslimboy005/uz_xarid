import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uzxarid/features/chat/domain/entities/message_entity.dart';
import 'package:uzxarid/features/chat/domain/entities/chat_room_entity.dart';
import 'package:uzxarid/features/chat/domain/repositories/chat_repository.dart';
import 'package:uzxarid/core/service/local_service.dart';

part 'ad_chat_event.dart';
part 'ad_chat_state.dart';

class AdChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _repository;
  final SecureStorageService _storage;
  StreamSubscription? _socketSubscription;

  AdChatBloc({
    required ChatRepository repository,
    required SecureStorageService storage,
  }) : _repository = repository,
       _storage = storage,
       super(const ChatState()) {
    on<ChatRoomOpened>(_onRoomOpened);
    on<ChatMessageSent>(_onMessageSent);
    on<ChatRealtimeMessageReceived>(_onRealtimeMessageReceived);
    on<ChatLoadMoreMessages>(_onLoadMore);
  }

  @override
  Future<void> close() {
    _socketSubscription?.cancel();
    _repository.dispose();
    return super.close();
  }

  Future<void> _onRoomOpened(ChatRoomOpened event, Emitter<ChatState> emit) async {
    emit(state.copyWith(status: ChatStatus.loading));
    
    final roomResult = await _repository.createRoom(event.adSlug);
    await roomResult.fold(
      (failure) async => emit(state.copyWith(status: ChatStatus.failure, error: failure.message)),
      (room) async {
        emit(state.copyWith(room: room));
        
        final messagesResult = await _repository.getMessages(room.id);
        await messagesResult.fold(
          (failure) async => emit(state.copyWith(status: ChatStatus.failure, error: failure.message)),
          (messages) async {
            emit(state.copyWith(status: ChatStatus.success, messages: messages));
            
            final token = await _storage.getToken();
            if (token != null) {
              _repository.connectToRoom(room.id, token);
              await _socketSubscription?.cancel();
              _socketSubscription = _repository.realtimeMessages.listen((data) {
                if (data['type'] == 'message') {
                  add(ChatRealtimeMessageReceived(data['data']));
                }
              });
            }
          },
        );
      },
    );
  }

  Future<void> _onMessageSent(ChatMessageSent event, Emitter<ChatState> emit) async {
    if (state.room == null || event.content.trim().isEmpty) return;
    
    final result = await _repository.sendMessage(state.room!.id, event.content);
    result.fold(
      (failure) => null,
      (message) {
        if (!state.messages.any((m) => m.id == message.id)) {
          final List<MessageEntity> updatedMessages = List.from(state.messages)..insert(0, message);
          emit(state.copyWith(messages: updatedMessages));
        }
      },
    );
  }

  void _onRealtimeMessageReceived(ChatRealtimeMessageReceived event, Emitter<ChatState> emit) {
    final data = event.data;
    final message = MessageEntity(
      id: data['id'] ?? 0,
      senderId: _parseId(data['sender_id']),
      content: data['content'] ?? '',
      createdAt: (DateTime.tryParse(data['created_at'] ?? '')?.toLocal()) ?? DateTime.now(),
      isRead: false,
    );
    
    if (!state.messages.any((m) => m.id == message.id)) {
      final List<MessageEntity> updatedMessages = List.from(state.messages)..insert(0, message);
      emit(state.copyWith(messages: updatedMessages));
    }
  }

  int? _parseId(dynamic id) {
    if (id == null) return null;
    if (id is int) return id;
    if (id is String) return int.tryParse(id);
    return null;
  }

  Future<void> _onLoadMore(ChatLoadMoreMessages event, Emitter<ChatState> emit) async {
    // Implement standard pagination
  }
}
