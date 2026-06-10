import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:uzxarid/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uzxarid/core/constants/app_colors.dart';
import 'package:uzxarid/core/cubit/app_mode_cubit.dart';
import 'package:uzxarid/core/theme/theme_colors.dart';
import 'package:uzxarid/core/widgets/app_text.dart';
import 'package:uzxarid/features/profile/data/model/chat/chat_model.dart';
import 'package:uzxarid/features/profile/presentation/bloc/chat/chat_bloc.dart';
import 'package:uzxarid/features/profile/presentation/bloc/chat/chat_event.dart';
import 'package:uzxarid/features/profile/presentation/bloc/chat/chat_state.dart';
import 'package:uzxarid/features/profile/presentation/bloc/profile_bloc.dart';

class SupportChatPage extends StatefulWidget {
  final int chatRoomId;

  const SupportChatPage({super.key, required this.chatRoomId});

  @override
  State<SupportChatPage> createState() => _SupportChatPageState();
}

class _SupportChatPageState extends State<SupportChatPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  bool _isLoadingMore = false;
  bool _hasText = false;

  List<String> _quickReplies(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      l10n.supportQuickReply1,
      l10n.supportQuickReply2,
      l10n.supportQuickReply3,
      l10n.supportQuickReply4,
      l10n.supportQuickReply5,
    ];
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _messageController.addListener(_onTextChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.chatRoomId > 0) {
        context.read<ChatBloc>().add(StartChatPollingEvent(widget.chatRoomId));
      }
    });
  }

  @override
  void dispose() {
    _stopPollingSafe();
    _messageController.removeListener(_onTextChanged);
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _messageController.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _stopPollingSafe() {
    try {
      if (mounted) {
        context.read<ChatBloc>().add(StopChatPollingEvent());
      }
    } catch (_) {}
  }

  void _onScroll() {
    if (_isBottom && !_isLoadingMore) {
      final chatBloc = context.read<ChatBloc>();
      if (chatBloc.state.status != ChatStatus.loading &&
          !chatBloc.state.hasReachedMax) {
        setState(() {
          _isLoadingMore = true;
        });

        Future.delayed(const Duration(milliseconds: 200), () {
          if (!mounted) return;

          chatBloc.add(
            GetChatMessagesEvent(
              chatRoomId: widget.chatRoomId,
              page: chatBloc.state.currentPage + 1,
            ),
          );
          if (mounted) {
            setState(() {
              _isLoadingMore = false;
            });
          }
        });
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.7);
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    final bloc = context.read<ChatBloc>();
    final filePaths = bloc.state.pickedFilePaths;

    if (content.isEmpty && filePaths.isEmpty) return;

    bloc.add(
      SendChatMessageEvent(
        chatRoomId: widget.chatRoomId,
        content: content,
        filePaths: filePaths,
      ),
    );
    _messageController.clear();
  }

  void _sendQuickReply(String reply) {
    final state = context.read<ChatBloc>().state;
    context.read<ChatBloc>().add(
      SendChatMessageEvent(
        chatRoomId: state.chatRoomId ?? widget.chatRoomId,
        content: reply,
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      context.read<ChatBloc>().add(PickFilesEvent([image.path]));
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null && mounted) {
      context.read<ChatBloc>().add(
        PickFilesEvent(result.paths.whereType<String>().toList()),
      );
    }
  }

  void _showAddMediaSource() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: context.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: context.borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                _SheetItem(
                  icon: Icons.image_outlined,
                  label: l10n.supportSourceGallery,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickImage();
                  },
                ),
                _SheetItem(
                  icon: Icons.insert_drive_file_outlined,
                  label: l10n.supportSourceDocument,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickFile();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final initialUserId = context
        .read<ProfileBloc>()
        .state
        .profileModel
        ?.data
        .user
        ?.id;
    if (initialUserId != null &&
        context.read<ChatBloc>().state.currentUserId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<ChatBloc>().add(SetChatUserIdEvent(initialUserId));
        }
      });
    }

    return MultiBlocListener(
      listeners: [
        BlocListener<ProfileBloc, ProfileState>(
          listenWhen: (prev, curr) =>
              prev.profileModel?.data.user?.id !=
              curr.profileModel?.data.user?.id,
          listener: (context, state) {
            final userId = state.profileModel?.data.user?.id;
            if (userId != null) {
              context.read<ChatBloc>().add(SetChatUserIdEvent(userId));
            }
          },
        ),
        BlocListener<ChatBloc, ChatState>(
          listenWhen: (prev, curr) => prev.errorMessage != curr.errorMessage,
          listener: (context, state) {
            if (state.errorMessage != null &&
                state.errorMessage!.isNotEmpty &&
                state.errorMessage != 'CHAT_ROOM_NOT_FOUND') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: context.bodyBackground,
        appBar: _buildAppBar(context),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: BlocBuilder<ChatBloc, ChatState>(
                  builder: (context, state) {
                    if (state.isInitializing ||
                        state.status == ChatStatus.initial ||
                        (state.status == ChatStatus.loading &&
                            state.messages.isEmpty &&
                            (state.chatRoomId ?? 0) > 0)) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.status == ChatStatus.failure &&
                        state.messages.isEmpty &&
                        (state.chatRoomId ?? 0) <= 0) {
                      return _buildErrorState(context, state);
                    }

                    if (state.messages.isEmpty) {
                      return _buildEmptyState(context);
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount:
                          state.messages.length +
                          (state.hasReachedMax ? 0 : 1),
                      itemBuilder: (context, index) {
                        if (index >= state.messages.length) {
                          return const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          );
                        }

                        final message = state.messages[index];
                        final isMe = message.id < 0 ||
                            (state.currentUserId != null &&
                                message.sender == state.currentUserId);

                        return _buildMessageBubble(context, message, isMe);
                      },
                    );
                  },
                ),
              ),
              _buildChatInput(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, ChatState state) {
    final isRoomNotFound = state.errorMessage == 'CHAT_ROOM_NOT_FOUND';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: (isRoomNotFound ? Colors.orange : Colors.red)
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isRoomNotFound
                    ? Icons.chat_bubble_outline
                    : Icons.error_outline,
                size: 36,
                color: isRoomNotFound ? Colors.orange : Colors.red,
              ),
            ),
            const SizedBox(height: 14),
            AppText(
              text: isRoomNotFound
                  ? 'Qo\'llab-quvvatlash xizmati hali sozlanmagan.\nIltimos, keyinroq urinib ko\'ring.'
                  : (state.errorMessage ??
                        AppLocalizations.of(context)!.supportErrorDefault),
              textAlign: TextAlign.center,
              fontSize: 14,
              color: context.textSecondary,
            ),
            const SizedBox(height: 14),
            if (!isRoomNotFound)
              FilledButton(
                onPressed: () {
                  context.read<ChatBloc>().add(
                    GetChatMessagesEvent(chatRoomId: widget.chatRoomId),
                  );
                },
                child: const Text('Qayta urinish'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      children: _quickReplies(context)
          .map(
            (reply) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _QuickReplyChip(
                label: reply,
                onTap: () => _sendQuickReply(reply),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildChatInput(BuildContext context) {
    final primaryColor = context.read<AppModeCubit>().state.primaryColor;
    final borderColor = context.borderColor;

    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        final canSend = (_hasText || state.pickedFilePaths.isNotEmpty) &&
            !state.isSending;
        return Container(
          decoration: BoxDecoration(
            color: context.cardSurface,
            border: Border(
              top: BorderSide(color: borderColor.withValues(alpha: 0.5)),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                if (state.pickedFilePaths.isNotEmpty)
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      itemCount: state.pickedFilePaths.length,
                      itemBuilder: (context, index) {
                        final path = state.pickedFilePaths[index];
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              margin: const EdgeInsets.only(right: 12, top: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: borderColor),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: _isImagePath(path)
                                    ? Image.file(File(path), fit: BoxFit.cover)
                                    : Icon(
                                        Icons.insert_drive_file_outlined,
                                        color: context.textSecondary,
                                      ),
                              ),
                            ),
                            Positioned(
                              right: 4,
                              top: -4,
                              child: GestureDetector(
                                onTap: () => context.read<ChatBloc>().add(
                                  RemoveFileEvent(path),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: context.cardSurface,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 10,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: _showAddMediaSource,
                        customBorder: const CircleBorder(),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.add,
                            color: context.textSecondary,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          maxLines: 4,
                          minLines: 1,
                          textCapitalization: TextCapitalization.sentences,
                          style: TextStyle(
                            fontSize: 14,
                            color: context.textPrimary,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: AppLocalizations.of(context)!.supportHint,
                            hintStyle: TextStyle(
                              color: context.textSecondary,
                              fontSize: 14,
                            ),
                            filled: true,
                            fillColor: context.bodyBackground,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: canSend ? _sendMessage : null,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: canSend
                                ? primaryColor
                                : primaryColor.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                          ),
                          child: state.isSending
                              ? const Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.send_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isImagePath(String path) {
    final p = path.toLowerCase();
    return p.endsWith('.jpg') ||
        p.endsWith('.jpeg') ||
        p.endsWith('.png') ||
        p.endsWith('.webp');
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textColor = context.textPrimary;
    final primaryColor = context.read<AppModeCubit>().state.primaryColor;

    return AppBar(
      backgroundColor: context.cardSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      shape: Border(
        bottom: BorderSide(
          color: context.borderColor.withValues(alpha: 0.5),
        ),
      ),
      title: Row(
        children: [
          const SizedBox(width: 8),
          _RoundIconButton(
            icon: Icons.arrow_back_ios_new,
            iconSize: 16,
            onTap: () => context.pop(),
            color: textColor,
            background: context.bodyBackground,
          ),
          const SizedBox(width: 12),
          Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.support_agent_outlined,
                  color: primaryColor,
                  size: 22,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.cardSurface,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(
                  text: l10n.supportTitle,
                  fontSize: 16,
                  fontWeight: 700,
                  color: textColor,
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                AppText(
                  text: 'Onlayn',
                  fontSize: 12,
                  color: const Color(0xFF22C55E),
                  fontWeight: 500,
                ),
              ],
            ),
          ),
          _RoundIconButton(
            icon: Icons.close,
            iconSize: 18,
            onTap: () => context.pop(),
            color: textColor,
            background: context.bodyBackground,
            tooltip: l10n.supportCloseChat,
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    BuildContext context,
    ChatMessageModel message,
    bool isMe,
  ) {
    final primaryColor = context.read<AppModeCubit>().state.primaryColor;
    final isOptimistic = message.id < 0;

    String timeStr = "";
    try {
      final date = DateTime.parse(message.createdAt).toLocal();
      timeStr =
          "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } catch (_) {}

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Opacity(
        opacity: isOptimistic ? 0.7 : 1.0,
        child: Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe) ...[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  image: message.senderInfo.avatarUrl != null
                      ? DecorationImage(
                          image: NetworkImage(message.senderInfo.avatarUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: message.senderInfo.avatarUrl == null
                    ? Icon(
                        Icons.support_agent_outlined,
                        size: 18,
                        color: primaryColor,
                      )
                    : null,
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isMe ? primaryColor : context.cardSurface,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(isMe ? 18 : 4),
                        bottomRight: Radius.circular(isMe ? 4 : 18),
                      ),
                      border: isMe
                          ? null
                          : Border.all(color: context.borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        if (message.content != null &&
                            message.content!.isNotEmpty)
                          AppText(
                            text: message.content!,
                            fontSize: 14,
                            color:
                                isMe ? AppColors.white : context.textPrimary,
                          ),
                        if (message.fileUrl != null ||
                            message.files.isNotEmpty) ...[
                          if (message.content != null &&
                              message.content!.isNotEmpty)
                            const SizedBox(height: 8),
                          ...({
                            if (message.fileUrl != null) message.fileUrl!,
                            ...message.files.map(
                              (f) => f.fileUrlDisplay ?? f.file,
                            ),
                          }).whereType<String>().map((url) {
                            final isLocalFile = url.startsWith('/');
                            return GestureDetector(
                              onTap: isLocalFile
                                  ? null
                                  : () => _previewImage(context, url),
                              child: Container(
                                constraints: const BoxConstraints(
                                  maxHeight: 200,
                                  maxWidth: 200,
                                ),
                                margin: const EdgeInsets.only(top: 4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: isLocalFile
                                      ? Image.file(File(url), fit: BoxFit.cover)
                                      : Image.network(
                                          url,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(Icons.file_present),
                                        ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: EdgeInsets.only(
                      left: isMe ? 0 : 6,
                      right: isMe ? 6 : 0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppText(
                          text: timeStr,
                          fontSize: 11,
                          color: context.textSecondary,
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 4),
                          Icon(
                            isOptimistic ? Icons.access_time : Icons.done_all,
                            size: 13,
                            color: isOptimistic
                                ? context.textSecondary
                                : primaryColor,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _previewImage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            InteractiveViewer(child: Center(child: Image.network(url))),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickReplyChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickReplyChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.cardSurface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.borderColor),
          ),
          child: AppText(
            text: label,
            fontSize: 14,
            fontWeight: 500,
            color: context.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final Color background;
  final double iconSize;
  final String? tooltip;

  const _RoundIconButton({
    required this.icon,
    required this.onTap,
    required this.color,
    required this.background,
    this.iconSize = 20,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: background,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: iconSize, color: color),
        ),
      ),
    );
    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}

class _SheetItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SheetItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = context.read<AppModeCubit>().state.primaryColor;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: primaryColor, size: 22),
            ),
            const SizedBox(width: 14),
            AppText(
              text: label,
              fontSize: 15,
              fontWeight: 500,
              color: context.textPrimary,
            ),
          ],
        ),
      ),
    );
  }
}
