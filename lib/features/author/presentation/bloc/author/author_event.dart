import 'package:equatable/equatable.dart';

abstract class AuthorEvent extends Equatable {
  const AuthorEvent();

  @override
  List<Object?> get props => [];
}

class AuthorLoadStarted extends AuthorEvent {
  final int userId;
  final bool isRefresh;

  const AuthorLoadStarted({required this.userId, this.isRefresh = false});

  @override
  List<Object?> get props => [userId, isRefresh];
}

class AuthorLoadMore extends AuthorEvent {
  final int userId;

  const AuthorLoadMore({required this.userId});

  @override
  List<Object?> get props => [userId];
}
