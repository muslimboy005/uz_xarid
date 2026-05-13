import 'package:flutter/material.dart';
import 'package:uzxarid/core/constants/app_colors.dart';
import 'package:uzxarid/core/theme/theme_colors.dart';
import 'package:uzxarid/core/utils/image_parser.dart';
import 'package:uzxarid/features/chat/domain/entities/chat_room_entity.dart';
import 'package:intl/intl.dart';

class ChatRoomListItem extends StatelessWidget {
  final ChatRoomEntity room;
  final VoidCallback onTap;

  const ChatRoomListItem({
    super.key,
    required this.room,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final participant = room.otherParticipant;
    final lastMessage = room.lastMessage;
    final textPrimary = context.textPrimary;
    final textSecondary = context.textSecondary;
    final cardColor = context.cardSurface;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: cardColor,
          border: Border(
            bottom: BorderSide(
              color: textSecondary.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.blue50,
              backgroundImage: participant?.avatarUrl != null
                  ? NetworkImage(participant!.avatarUrl!.cdnUrl)
                  : null,
              child: participant?.avatarUrl == null
                  ? const Icon(Icons.person, color: AppColors.blue500)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          participant?.firstName ?? 'User',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (lastMessage != null)
                        Text(
                          _formatDate(lastMessage.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: textSecondary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage?.content ?? 'No messages yet',
                          style: TextStyle(
                            fontSize: 14,
                            color: textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (room.unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.blue500,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            room.unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return DateFormat.Hm().format(date);
    } else if (difference.inDays < 7) {
      return DateFormat.E().format(date);
    } else {
      return DateFormat.yMd().format(date);
    }
  }
}
