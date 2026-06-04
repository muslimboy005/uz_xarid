import 'package:dio/dio.dart';
import 'package:uzxarid/core/constants/api_urls.dart';
import 'package:uzxarid/features/notification/domain/entities/notification_entity.dart';
import 'package:uzxarid/features/notification/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl({required this.dio});

  final Dio dio;

  @override
  Future<NotificationListEntity> getNotifications({
    NotificationKind? notificationType,
    int page = 1,
    int pageSize = 10,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
    };
    final typeParam = _notificationTypeParam(notificationType);
    if (typeParam != null) {
      params['notification_type'] = typeParam;
    }

    final response = await dio.get(
      ApiUrls.userNotification,
      queryParameters: params,
    );

    final data = _extractDataMap(response.data);
    final results = (data['results'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(_parseItem)
        .toList();

    return NotificationListEntity(
      items: results,
      totalItems: (data['total_items'] as num?)?.toInt() ?? results.length,
      totalPages: (data['total_pages'] as num?)?.toInt() ?? 1,
      currentPage: (data['current_page'] as num?)?.toInt() ?? page,
    );
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await dio.get(
        ApiUrls.userNotification,
        queryParameters: {'is_read': false, 'page_size': 1},
      );
      final data = _extractDataMap(response.data);
      return (data['total_items'] as num?)?.toInt() ?? 0;
    } on DioException {
      return 0;
    }
  }

  @override
  Future<void> markAllRead() async {
    try {
      await dio.post(ApiUrls.userNotificationMarkAllRead);
    } on DioException {
      // Backend may not expose this endpoint yet — fail soft so UI updates.
    }
  }

  @override
  Future<void> markRead(int id) async {
    final path = ApiUrls.userNotificationId.replaceFirst('{id}', '$id');
    try {
      await dio.patch(path, data: {'is_read': true});
    } on DioException {
      // Best-effort; ignore if endpoint not available.
    }
  }

  String? _notificationTypeParam(NotificationKind? kind) {
    switch (kind) {
      case NotificationKind.order:
        return 'Order';
      case NotificationKind.system:
        return 'System';
      case NotificationKind.unknown:
      case null:
        return null;
    }
    return null;
  }

  Map<String, dynamic> _extractDataMap(dynamic raw) {
    if (raw is! Map<String, dynamic>) {
      throw Exception('Invalid notification response');
    }
    final data = raw['data'];
    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid notification data');
    }
    return data;
  }

  NotificationEntity _parseItem(Map<String, dynamic> json) {
    final senderMap = json['sender'];
    NotificationSenderEntity? sender;
    if (senderMap is Map<String, dynamic>) {
      sender = NotificationSenderEntity(
        id: (senderMap['id'] as num?)?.toInt() ?? 0,
        fullName: (senderMap['full_name'] as String?) ??
            [senderMap['first_name'], senderMap['last_name']]
                .whereType<String>()
                .where((s) => s.isNotEmpty)
                .join(' '),
        avatar: senderMap['avatar'] as String?,
        phone: senderMap['phone'] as String?,
      );
    }

    final adMap = json['ad'];
    NotificationAdEntity? ad;
    if (adMap is Map<String, dynamic>) {
      ad = NotificationAdEntity(
        id: (adMap['id'] as num?)?.toInt() ?? 0,
        title: (adMap['title'] as String?) ?? '',
      );
    }

    DateTime? createdAt;
    final createdRaw = json['created_at'];
    if (createdRaw is String) {
      createdAt = DateTime.tryParse(createdRaw);
    }

    return NotificationEntity(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      kind: notificationKindFromString(json['notification_type'] as String?),
      createdAt: createdAt,
      sender: sender,
      ad: ad,
      isRead: (json['is_read'] as bool?) ?? false,
    );
  }
}
