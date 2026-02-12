import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'home_category_event.dart';
part 'home_category_state.dart';

class HomeCategoryBloc extends Bloc<HomeCategoryEvent, HomeCategoryState> {
  HomeCategoryBloc() : super(const HomeCategoryState(selectedIndex: 0)) {
    on<HomeCategorySelected>(_onSelected);
  }

  void _onSelected(
    HomeCategorySelected event,
    Emitter<HomeCategoryState> emit,
  ) {
    emit(state.copyWith(selectedIndex: event.index));
  }
}
