import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uz_xarid/features/profile/domain/repositories/profile_repository.dart';
import 'view_history_event.dart';
import 'view_history_state.dart';

class ViewHistoryBloc extends Bloc<ViewHistoryEvent, ViewHistoryState> {
  final ProfileRepository _repository;

  ViewHistoryBloc({required ProfileRepository repository})
    : _repository = repository,
      super(const ViewHistoryState()) {
    on<GetViewHistoryEvent>(_onGetViewHistory);
    on<ClearHistoryEvent>(_onClearHistory);
  }

  Future<void> _onGetViewHistory(
    GetViewHistoryEvent event,
    Emitter<ViewHistoryState> emit,
  ) async {
    emit(state.copyWith(status: ViewHistoryStatus.loading));

    final result = await _repository.getViewedAds(event.page, event.pageSize);

    if (result.isRight) {
      emit(
        state.copyWith(
          status: ViewHistoryStatus.success,
          history: result.right,
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: ViewHistoryStatus.failure,
          errorMessage: result.left.message,
        ),
      );
    }
  }

  Future<void> _onClearHistory(
    ClearHistoryEvent event,
    Emitter<ViewHistoryState> emit,
  ) async {
    emit(state.copyWith(status: ViewHistoryStatus.loading));

    final result = await _repository.clearViewedAds();

    if (result.isRight) {
      emit(state.copyWith(status: ViewHistoryStatus.success, history: null));
    } else {
      emit(
        state.copyWith(
          status: ViewHistoryStatus.failure,
          errorMessage: result.left.message,
        ),
      );
    }
  }
}
