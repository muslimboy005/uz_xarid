import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uz_xarid/features/chat/domain/repositories/chat_repository.dart';
import 'chat_list_event.dart';
import 'chat_list_state.dart';

class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  final ChatRepository _repository;

  ChatListBloc(this._repository) : super(const ChatListState()) {
    on<LoadChatRooms>(_onLoadChatRooms);
  }

  Future<void> _onLoadChatRooms(LoadChatRooms event, Emitter<ChatListState> emit) async {
    if (event.refresh) {
      emit(state.copyWith(status: ChatListStatus.loading, rooms: [], currentPage: 1, hasReachedMax: false));
    } else {
      if (state.hasReachedMax) return;
      if (state.status == ChatListStatus.loading) return;
      emit(state.copyWith(status: ChatListStatus.loading));
    }

    final result = await _repository.getRooms(page: state.currentPage);

    result.fold(
      (failure) => emit(state.copyWith(status: ChatListStatus.failure, error: failure.message)),
      (rooms) {
        if (rooms.isEmpty) {
          emit(state.copyWith(status: ChatListStatus.success, hasReachedMax: true));
        } else {
          emit(state.copyWith(
            status: ChatListStatus.success,
            rooms: event.refresh ? rooms : [...state.rooms, ...rooms],
            currentPage: state.currentPage + 1,
            hasReachedMax: rooms.length < 10,
          ));
        }
      },
    );
  }
}
