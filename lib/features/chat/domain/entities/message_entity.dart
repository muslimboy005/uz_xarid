import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  final int id;
  final int? senderId;
  final String content;
  final DateTime createdAt;
  final bool? isRead;
  final String? fileUrl;

  const MessageEntity({
    required this.id,
    this.senderId,
    required this.content,
    required this.createdAt,
    this.isRead,
    this.fileUrl,
  });

  @override
  List<Object?> get props => [id, senderId, content, createdAt, isRead, fileUrl];
}
