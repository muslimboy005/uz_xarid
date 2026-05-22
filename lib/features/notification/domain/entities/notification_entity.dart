import 'package:equatable/equatable.dart';

enum NotificationKind { system, order, unknown }

NotificationKind notificationKindFromString(String? value) {
  switch (value?.toLowerCase()) {
    case 'order':
      return NotificationKind.order;
    case 'system':
      return NotificationKind.system;
    default:
      return NotificationKind.unknown;
  }
}

class NotificationSenderEntity extends Equatable {
  final int id;
  final String fullName;
  final String? avatar;
  final String? phone;

  const NotificationSenderEntity({
    required this.id,
    required this.fullName,
    this.avatar,
    this.phone,
  });

  @override
  List<Object?> get props => [id, fullName, avatar, phone];
}

class NotificationAdEntity extends Equatable {
  final int id;
  final String title;

  const NotificationAdEntity({required this.id, required this.title});

  @override
  List<Object?> get props => [id, title];
}

class NotificationEntity extends Equatable {
  final int id;
  final String title;
  final String description;
  final NotificationKind kind;
  final DateTime? createdAt;
  final NotificationSenderEntity? sender;
  final NotificationAdEntity? ad;
  final bool isRead;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.kind,
    this.createdAt,
    this.sender,
    this.ad,
    this.isRead = false,
  });

  NotificationEntity copyWith({bool? isRead}) {
    return NotificationEntity(
      id: id,
      title: title,
      description: description,
      kind: kind,
      createdAt: createdAt,
      sender: sender,
      ad: ad,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  List<Object?> get props =>
      [id, title, description, kind, createdAt, sender, ad, isRead];
}

class NotificationListEntity extends Equatable {
  final List<NotificationEntity> items;
  final int totalItems;
  final int totalPages;
  final int currentPage;

  const NotificationListEntity({
    required this.items,
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
  });

  @override
  List<Object?> get props => [items, totalItems, totalPages, currentPage];
}
