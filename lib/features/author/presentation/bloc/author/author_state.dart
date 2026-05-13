import 'package:equatable/equatable.dart';
import 'package:uzxarid/features/author/domain/entities/author_entity.dart';

abstract class AuthorState extends Equatable {
  const AuthorState();

  @override
  List<Object?> get props => [];
}

class AuthorInitial extends AuthorState {}

class AuthorLoading extends AuthorState {}

class AuthorLoaded extends AuthorState {
  final AuthorEntity author;
  final bool hasReachedMax;
  final bool isFetchingMore;

  const AuthorLoaded({
    required this.author,
    required this.hasReachedMax,
    this.isFetchingMore = false,
  });

  AuthorLoaded copyWith({
    AuthorEntity? author,
    bool? hasReachedMax,
    bool? isFetchingMore,
  }) {
    return AuthorLoaded(
      author: author ?? this.author,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
    );
  }

  @override
  List<Object?> get props => [author, hasReachedMax, isFetchingMore];
}

class AuthorError extends AuthorState {
  final String message;

  const AuthorError({required this.message});

  @override
  List<Object?> get props => [message];
}
