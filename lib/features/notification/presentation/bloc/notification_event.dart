import 'package:equatable/equatable.dart';
import 'package:uzxarid/features/notification/domain/entities/notification_entity.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the unread badge count via `GET /user-notification/?is_read=false&page_size=1`.
/// Triggered on home screen open and after read/mark-all-read actions.
class NotificationBadgeLoadRequested extends NotificationEvent {
  const NotificationBadgeLoadRequested();
}

/// Loads a notifications tab (Order or System) via
/// `GET /user-notification/?notification_type=Order|System`.
class NotificationTabLoadRequested extends NotificationEvent {
  final NotificationKind kind;
  final bool refresh;

  const NotificationTabLoadRequested({
    required this.kind,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [kind, refresh];
}

class NotificationTabLoadMoreRequested extends NotificationEvent {
  final NotificationKind kind;

  const NotificationTabLoadMoreRequested({required this.kind});

  @override
  List<Object?> get props => [kind];
}

class NotificationMarkAllReadRequested extends NotificationEvent {
  const NotificationMarkAllReadRequested();
}

class NotificationOpened extends NotificationEvent {
  final int id;

  const NotificationOpened(this.id);

  @override
  List<Object?> get props => [id];
}
