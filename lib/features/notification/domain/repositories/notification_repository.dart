import 'package:uzxarid/features/notification/domain/entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<NotificationListEntity> getNotifications({
    NotificationKind? notificationType,
    int page = 1,
    int pageSize = 10,
  });

  Future<int> getUnreadCount();

  Future<void> markAllRead();

  Future<void> markRead(int id);
}
