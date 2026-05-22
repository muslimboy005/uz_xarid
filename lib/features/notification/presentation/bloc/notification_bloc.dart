import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uzxarid/features/notification/domain/entities/notification_entity.dart';
import 'package:uzxarid/features/notification/domain/repositories/notification_repository.dart';
import 'package:uzxarid/features/notification/presentation/bloc/notification_event.dart';
import 'package:uzxarid/features/notification/presentation/bloc/notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository repository;

  static const int _pageSize = 10;

  NotificationBloc({required this.repository})
      : super(const NotificationState()) {
    on<NotificationBadgeLoadRequested>(_onBadgeLoadRequested);
    on<NotificationTabLoadRequested>(_onTabLoadRequested);
    on<NotificationTabLoadMoreRequested>(_onTabLoadMoreRequested);
    on<NotificationMarkAllReadRequested>(_onMarkAllReadRequested);
    on<NotificationOpened>(_onOpened);
  }

  Future<void> _onBadgeLoadRequested(
    NotificationBadgeLoadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    final count = await repository.getUnreadCount();
    emit(state.copyWith(unreadBadgeCount: count));
  }

  Future<void> _onTabLoadRequested(
    NotificationTabLoadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    final current = state.tabFor(event.kind);

    if (!event.refresh && current.status == NotificationStatus.loading) return;

    emit(_setTab(
      event.kind,
      current.copyWith(status: NotificationStatus.loading),
    ));

    try {
      final data = await repository.getNotifications(
        notificationType: event.kind,
        page: 1,
        pageSize: _pageSize,
      );
      emit(_setTab(
        event.kind,
        current.copyWith(
          status: NotificationStatus.success,
          items: data.items,
          totalItems: data.totalItems,
          totalPages: data.totalPages,
          currentPage: data.currentPage,
          hasReachedMax: data.currentPage >= data.totalPages,
          isLoadingMore: false,
        ),
      ));
    } catch (e) {
      emit(_setTab(
        event.kind,
        current.copyWith(
          status: NotificationStatus.failure,
          errorMessage: e.toString(),
        ),
      ));
    }
  }

  Future<void> _onTabLoadMoreRequested(
    NotificationTabLoadMoreRequested event,
    Emitter<NotificationState> emit,
  ) async {
    final current = state.tabFor(event.kind);
    if (current.hasReachedMax || current.isLoadingMore) return;

    emit(_setTab(event.kind, current.copyWith(isLoadingMore: true)));

    try {
      final nextPage = current.currentPage + 1;
      final data = await repository.getNotifications(
        notificationType: event.kind,
        page: nextPage,
        pageSize: _pageSize,
      );
      final merged = <NotificationEntity>[...current.items, ...data.items];
      emit(_setTab(
        event.kind,
        current.copyWith(
          items: merged,
          totalItems: data.totalItems,
          totalPages: data.totalPages,
          currentPage: data.currentPage,
          hasReachedMax: data.currentPage >= data.totalPages,
          isLoadingMore: false,
        ),
      ));
    } catch (e) {
      emit(_setTab(
        event.kind,
        current.copyWith(
          isLoadingMore: false,
          errorMessage: e.toString(),
        ),
      ));
    }
  }

  Future<void> _onMarkAllReadRequested(
    NotificationMarkAllReadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    final updatedOrder = state.orderTab.copyWith(
      items: state.orderTab.items.map((n) => n.copyWith(isRead: true)).toList(),
    );
    final updatedSystem = state.systemTab.copyWith(
      items: state.systemTab.items.map((n) => n.copyWith(isRead: true)).toList(),
    );
    emit(state.copyWith(
      unreadBadgeCount: 0,
      orderTab: updatedOrder,
      systemTab: updatedSystem,
    ));

    await repository.markAllRead();
    add(const NotificationBadgeLoadRequested());
  }

  Future<void> _onOpened(
    NotificationOpened event,
    Emitter<NotificationState> emit,
  ) async {
    final orderItems = state.orderTab.items;
    final systemItems = state.systemTab.items;

    final orderIdx = orderItems.indexWhere((n) => n.id == event.id);
    final systemIdx = systemItems.indexWhere((n) => n.id == event.id);

    bool wasUnread = false;

    NotificationTabData newOrder = state.orderTab;
    NotificationTabData newSystem = state.systemTab;

    if (orderIdx != -1) {
      wasUnread = wasUnread || !orderItems[orderIdx].isRead;
      final next = List<NotificationEntity>.from(orderItems);
      next[orderIdx] = next[orderIdx].copyWith(isRead: true);
      newOrder = state.orderTab.copyWith(items: next);
    }
    if (systemIdx != -1) {
      wasUnread = wasUnread || !systemItems[systemIdx].isRead;
      final next = List<NotificationEntity>.from(systemItems);
      next[systemIdx] = next[systemIdx].copyWith(isRead: true);
      newSystem = state.systemTab.copyWith(items: next);
    }

    final newBadge = wasUnread
        ? (state.unreadBadgeCount > 0 ? state.unreadBadgeCount - 1 : 0)
        : state.unreadBadgeCount;

    emit(state.copyWith(
      unreadBadgeCount: newBadge,
      orderTab: newOrder,
      systemTab: newSystem,
    ));

    await repository.markRead(event.id);
    add(const NotificationBadgeLoadRequested());
  }

  NotificationState _setTab(NotificationKind kind, NotificationTabData data) {
    return kind == NotificationKind.order
        ? state.copyWith(orderTab: data)
        : state.copyWith(systemTab: data);
  }
}
