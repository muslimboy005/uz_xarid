import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uz_xarid/features/author/domain/repositories/author_repository.dart';
import 'package:uz_xarid/features/author/presentation/bloc/author/author_event.dart';
import 'package:uz_xarid/features/author/presentation/bloc/author/author_state.dart';
import 'package:uz_xarid/features/author/domain/entities/author_entity.dart';

class AuthorBloc extends Bloc<AuthorEvent, AuthorState> {
  final AuthorRepository repository;

  AuthorBloc({required this.repository}) : super(AuthorInitial()) {
    on<AuthorLoadStarted>(_onLoadStarted);
    on<AuthorLoadMore>(_onLoadMore);
  }

  Future<void> _onLoadStarted(
    AuthorLoadStarted event,
    Emitter<AuthorState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(AuthorLoading());
    }
    try {
      final author = await repository.getAuthorAds(
        userId: event.userId,
        page: 1,
      );
      final hasReachedMax = author.currentPage >= author.totalPages;

      emit(AuthorLoaded(author: author, hasReachedMax: hasReachedMax));
    } catch (e) {
      emit(AuthorError(message: e.toString()));
    }
  }

  Future<void> _onLoadMore(
    AuthorLoadMore event,
    Emitter<AuthorState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AuthorLoaded ||
        currentState.hasReachedMax ||
        currentState.isFetchingMore) {
      return;
    }

    emit(currentState.copyWith(isFetchingMore: true));

    try {
      final nextPage = currentState.author.currentPage + 1;
      final newAuthorData = await repository.getAuthorAds(
        userId: event.userId,
        page: nextPage,
      );

      final updatedAds = List.of(currentState.author.ads)
        ..addAll(newAuthorData.ads);

      final updatedAuthor = AuthorEntity(
        id: newAuthorData.id,
        firstName: newAuthorData.firstName,
        lastName: newAuthorData.lastName,
        phone: newAuthorData.phone,
        avatar: newAuthorData.avatar,
        dateJoined: newAuthorData.dateJoined,
        totalAds: newAuthorData.totalAds,
        totalCommentsAuthor: newAuthorData.totalCommentsAuthor,
        averageRatingAuthor: newAuthorData.averageRatingAuthor,
        ads: updatedAds,
        currentPage: newAuthorData.currentPage,
        totalPages: newAuthorData.totalPages,
      );

      final hasReachedMax =
          newAuthorData.currentPage >= newAuthorData.totalPages;

      emit(
        currentState.copyWith(
          author: updatedAuthor,
          hasReachedMax: hasReachedMax,
          isFetchingMore: false,
        ),
      );
    } catch (e) {
      // Revert loading flag if failed
      emit(currentState.copyWith(isFetchingMore: false));
    }
  }
}
