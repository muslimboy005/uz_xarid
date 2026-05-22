import 'package:equatable/equatable.dart';
import 'package:uzxarid/features/notification/domain/entities/notification_entity.dart';

enum NotificationStatus { initial, loading, success, failure }

class NotificationTabData extends Equatable {
  final NotificationStatus status;
  final List<NotificationEntity> items;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final String? errorMessage;

  const NotificationTabData({
    this.status = NotificationStatus.initial,
    this.items = const [],
    this.totalItems = 0,
    this.currentPage = 1,
    this.totalPages = 1,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  NotificationTabData copyWith({
    NotificationStatus? status,
    List<NotificationEntity>? items,
    int? totalItems,
    int? currentPage,
    int? totalPages,
    bool? hasReachedMax,
    bool? isLoadingMore,
    String? errorMessage,
  }) {
    return NotificationTabData(
      status: status ?? this.status,
      items: items ?? this.items,
      totalItems: totalItems ?? this.totalItems,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        items,
        totalItems,
        currentPage,
        totalPages,
        hasReachedMax,
        isLoadingMore,
        errorMessage,
      ];
}

class NotificationState extends Equatable {
  /// Server-driven unread count — drives the red badge on the bell.
  /// Loaded via `GET /user-notification/?is_read=false&page_size=1`.
  final int unreadBadgeCount;

  final NotificationTabData orderTab;
  final NotificationTabData systemTab;

  const NotificationState({
    this.unreadBadgeCount = 0,
    this.orderTab = const NotificationTabData(),
    this.systemTab = const NotificationTabData(),
  });

  NotificationTabData tabFor(NotificationKind kind) {
    return kind == NotificationKind.order ? orderTab : systemTab;
  }

  NotificationState copyWith({
    int? unreadBadgeCount,
    NotificationTabData? orderTab,
    NotificationTabData? systemTab,
  }) {
    return NotificationState(
      unreadBadgeCount: unreadBadgeCount ?? this.unreadBadgeCount,
      orderTab: orderTab ?? this.orderTab,
      systemTab: systemTab ?? this.systemTab,
    );
  }

  @override
  List<Object?> get props => [unreadBadgeCount, orderTab, systemTab];
}
