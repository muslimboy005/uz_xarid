import 'dart:async';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uz_xarid/features/profile/data/model/chat/chat_model.dart';
import 'package:uz_xarid/features/profile/domain/repositories/profile_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ProfileRepository _repository;
  Timer? _pollingTimer;

  ChatBloc({required ProfileRepository repository})
      : _repository = repository,
        super(const ChatState()) {
    on<ChatEvent>((event, emit) async {
      try {
        if (event is GetChatMessagesEvent) {
          await _onGetChatMessages(event, emit);
        } else if (event is SendChatMessageEvent) {
          await _onSendChatMessage(event, emit);
        } else if (event is PickFilesEvent) {
          emit(state.copyWith(
              pickedFilePaths: List.unmodifiable(
                  [...state.pickedFilePaths, ...event.filePaths])));
        } else if (event is RemoveFileEvent) {
          emit(state.copyWith(
              pickedFilePaths: List.unmodifiable(
                  [...state.pickedFilePaths]..remove(event.filePath))));
        } else if (event is StartChatPollingEvent) {
          if (event.chatRoomId > 0) {
            _startPolling(event.chatRoomId);
          }
        } else if (event is StopChatPollingEvent) {
          _stopPolling();
        } else if (event is InitializeChatEvent) {
          emit(state.copyWith(chatRoomId: event.chatRoomId));
        } else if (event is SetChatUserIdEvent) {
          emit(state.copyWith(currentUserId: event.userId));
        }
      } catch (e) {
        if (!emit.isDone) {
          emit(state.copyWith(
            status: ChatStatus.failure,
            errorMessage: e.toString(),
            isSending: false,
          ));
        }
      }
    }, transformer: sequential());
  }

  void _startPolling(int chatRoomId) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 20), (timer) {
      if (!isClosed) {
        add(GetChatMessagesEvent(chatRoomId: chatRoomId, page: 1));
      }
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }

  Future<void> _onGetChatMessages(
    GetChatMessagesEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      // We don't return early anymore, we want to see what server says for 0

      final isFirstLoad = state.messages.isEmpty && event.page == 1;
      final isPolling = !isFirstLoad && event.page == 1;
      
      if (isFirstLoad) {
        emit(state.copyWith(status: ChatStatus.loading, messages: [], currentPage: 1, hasReachedMax: false));
      } else if (event.page > 1) {
        if (state.status == ChatStatus.loading) return;
        if (state.hasReachedMax) return;
        emit(state.copyWith(status: ChatStatus.loading));
      }

      final result = await _repository.getChatMessages(event.chatRoomId, event.page, event.pageSize);

      if (!emit.isDone) {
        if (result.isRight) {
          final messagesResponse = result.right;
          final newMessages = messagesResponse.data.results;

          // Smart Merging & Persistence Fix
          if (event.page == 1) {
            final serverMessages = newMessages;
            final currentMessages = state.messages;
            
            // Capture chatRoomId from the first message if not already set
            final newChatRoomId = serverMessages.isNotEmpty ? serverMessages.first.chatRoom : state.chatRoomId;

            // 1. Detect highest server ID
            final highestServerId = serverMessages.fold<int>(0, (max, m) => m.id > max ? m.id : max);
            
            // 2. Identify local messages that are newer or optimistic
            final localPreserved = currentMessages.where((m) => m.id < 0 || m.id > highestServerId).toList();
            
            // 3. Merge server results with local preserved
            final mergedResults = <ChatMessageModel>[...serverMessages];
            
            for (final local in localPreserved) {
               // SMART DEDUPLICATION: Compare content and file count
               final alreadyRepresented = mergedResults.any((m) {
                 if (m.id == local.id) return true;
                 if (local.id < 0) {
                    final sameContent = m.content == local.content;
                    final sameFileCount = m.files.length == local.files.length;
                    return sameContent && sameFileCount;
                 }
                 return false;
               });
               
               if (!alreadyRepresented) {
                 mergedResults.insert(0, local);
               }
            }

            // Sort descending
            mergedResults.sort((a, b) {
              if (a.id < 0 && b.id < 0) return b.id.compareTo(a.id);
              if (a.id < 0) return -1;
              if (b.id < 0) return 1;
              return b.id.compareTo(a.id);
            });

            // Polling Optimization: Deep check
            if (isPolling && currentMessages.isNotEmpty) {
               final idsChanged = currentMessages.length != mergedResults.length || 
                                  currentMessages.first.id != mergedResults.first.id;
               if (!idsChanged) return;
            }

            emit(state.copyWith(
              status: ChatStatus.success,
              messages: List.unmodifiable(mergedResults),
              hasReachedMax: newMessages.length < event.pageSize,
              currentPage: 1,
              chatRoomId: newChatRoomId,
            ));

            // If we just got a valid chatRoomId, start polling if not already
            if (newChatRoomId != null && newChatRoomId > 0 && _pollingTimer == null) {
               _startPolling(newChatRoomId);
            }
          } else {
            // Pagination deduplication
            final currentIds = state.messages.map((m) => m.id).toSet();
            final uniqueNewMessages = newMessages.where((m) => !currentIds.contains(m.id)).toList();
            
            emit(state.copyWith(
              status: ChatStatus.success,
              messages: List.unmodifiable([...state.messages, ...uniqueNewMessages]),
              hasReachedMax: newMessages.length < event.pageSize,
              currentPage: event.page,
            ));
          }
        } else {
          // AUTO-RECOVERY: If a specific room ID fails with 400, 
          // fallback to room ID 0 (new chat) to at least show a working UI.
          if (result.left.message.contains('400') && event.chatRoomId > 0) {
            add(const GetChatMessagesEvent(chatRoomId: 0));
            return;
          }

          // Failure handling
          if (isFirstLoad || event.page > 1) {
            emit(state.copyWith(
              status: ChatStatus.failure,
              errorMessage: result.left.message,
            ));
          }
        }
      }
    } catch (e) {
      if (!emit.isDone) {
        emit(state.copyWith(
          status: ChatStatus.failure,
          errorMessage: e.toString(),
        ));
      }
    }
  }

  Future<void> _onSendChatMessage(
    SendChatMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    // Multi-send allowed! Removing isSending check for faster UX
    
    final tempId = DateTime.now().millisecondsSinceEpoch * -1;
    final optimisticMessage = ChatMessageModel(
      id: tempId,
      chatRoom: event.chatRoomId > 0 ? event.chatRoomId : (state.chatRoomId ?? 0),
      sender: state.currentUserId ?? 0, // Use cached ID if available
      content: event.content,
      isRead: false,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
      senderInfo: ChatSenderInfoModel(firstName: 'Вы', avatar: null),
      files: event.filePaths.map((path) => ChatFileModel(
        id: -1, 
        file: path, 
        fileUrlDisplay: path,
      )).toList(),
      fileUrl: event.filePaths.isNotEmpty ? event.filePaths.first : null,
    );

    final currentMessages = List<ChatMessageModel>.from(state.messages);
    currentMessages.insert(0, optimisticMessage);
    
    emit(state.copyWith(
      isSending: true,
      messages: List.unmodifiable(currentMessages),
      pickedFilePaths: [],
    ));

    try {
      dynamic data;
      final effectiveRoomId = event.chatRoomId > 0 ? event.chatRoomId : (state.chatRoomId ?? 0);

      if (event.filePaths.isEmpty) {
        data = {
          if (effectiveRoomId > 0) "chat_room_id": effectiveRoomId,
          "content": event.content,
          "files": [],
          "file_urls": [],
          "file_types": [],
        };
      } else {
        final formDataMap = {
          if (effectiveRoomId > 0) "chat_room_id": effectiveRoomId,
          "content": event.content,
        };
        final formData = FormData.fromMap(formDataMap);
        for (var path in event.filePaths) {
          formData.files.add(MapEntry(
            "files",
            await MultipartFile.fromFile(path, filename: path.split('/').last),
          ));
        }
        data = formData;
      }

      final result = await _repository.sendChatMessage(data);

      if (!emit.isDone) {
        if (result.isRight) {
          final confirmedMessage = result.right.data.results.first;
          final updatedMessages = List<ChatMessageModel>.from(state.messages);
          
          // Update room ID in state if it was 0
          final newChatRoomId = confirmedMessage.chatRoom;

          // Precise replacement
          final index = updatedMessages.indexWhere((m) => m.id == tempId);
          if (index != -1) {
            updatedMessages[index] = confirmedMessage;
          } else {
             // Fallback deduplication
             updatedMessages.removeWhere((m) => m.id == confirmedMessage.id);
             updatedMessages.insert(0, confirmedMessage);
          }

          emit(state.copyWith(
            isSending: false,
            status: ChatStatus.success,
            messages: List.unmodifiable(updatedMessages),
            chatRoomId: newChatRoomId,
            errorMessage: null, // Clear error on success
          ));

          // Start polling if we just got a room ID
          if (newChatRoomId > 0 && _pollingTimer == null) {
            _startPolling(newChatRoomId);
          }
        } else {
          // Error handling for send failures
          final errorMessage = result.left.message;
          final rolledBackMessages = List<ChatMessageModel>.from(state.messages);
          rolledBackMessages.removeWhere((m) => m.id == tempId);
          
          if (errorMessage == 'CHAT_ROOM_NOT_FOUND') {
            // Chat room doesn't exist on backend — show a clean failure state
            emit(state.copyWith(
              status: ChatStatus.failure,
              isSending: false,
              messages: const [],
              chatRoomId: 0,
              errorMessage: 'CHAT_ROOM_NOT_FOUND',
            ));
          } else {
            emit(state.copyWith(
              status: ChatStatus.failure,
              isSending: false,
              messages: List.unmodifiable(rolledBackMessages),
              errorMessage: errorMessage,
            ));
          }
        }
      }
    } catch (e) {
      if (!emit.isDone) {
        final rolledBackMessages = List<ChatMessageModel>.from(state.messages);
        rolledBackMessages.removeWhere((m) => m.id == tempId);
        emit(state.copyWith(
          status: ChatStatus.failure, // SET STATUS TO FAILURE
          isSending: false,
          messages: List.unmodifiable(rolledBackMessages),
          errorMessage: e.toString().split('\n').first,
        ));
      }
    }
  }
}
