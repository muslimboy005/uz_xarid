import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/cubit/app_mode_cubit.dart';
import 'package:uz_xarid/core/theme/theme_colors.dart';
import 'package:uz_xarid/core/widgets/app_text.dart';
import 'package:uz_xarid/core/widgets/w__container.dart';
import 'package:uz_xarid/features/profile/data/model/chat/chat_model.dart';
import 'package:uz_xarid/features/profile/presentation/bloc/chat/chat_bloc.dart';
import 'package:uz_xarid/features/profile/presentation/bloc/chat/chat_event.dart';
import 'package:uz_xarid/features/profile/presentation/bloc/chat/chat_state.dart';
import 'package:uz_xarid/features/profile/presentation/bloc/profile_bloc.dart';

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

  final List<String> _quickReplies = [
    'Жалоба на пользователя или объявление',
    'Технические проблемы',
    'Проблемы с объявлением',
    'Другое / Задать вопрос',
    'Предложения и отзывы',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Initialize the BLoC with the room ID (could be 0 for new chat)
    context.read<ChatBloc>().add(InitializeChatEvent(widget.chatRoomId));

    // Start polling for new messages when the page is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
       if (widget.chatRoomId > 0) {
          context.read<ChatBloc>().add(StartChatPollingEvent(widget.chatRoomId));
       }
    });
  }

  @override
  void dispose() {
    // Stop polling before disposing
    _stopPollingSafe();
    
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _stopPollingSafe() {
    try {
      if (mounted) {
        context.read<ChatBloc>().add(StopChatPollingEvent());
      }
    } catch (_) {
      // Bloc might be already gone
    }
  }

  void _onScroll() {
    if (_isBottom && !_isLoadingMore) {
      final chatBloc = context.read<ChatBloc>(); // Use local reference
      if (chatBloc.state.status != ChatStatus.loading && !chatBloc.state.hasReachedMax) {
        setState(() {
          _isLoadingMore = true;
        });
        
        // Debounce: wait 200ms before adding event
        Future.delayed(const Duration(milliseconds: 200), () {
          if (!mounted) return;
          
          chatBloc.add(GetChatMessagesEvent(
            chatRoomId: widget.chatRoomId,
            page: chatBloc.state.currentPage + 1,
          ));
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

    bloc.add(SendChatMessageEvent(
      chatRoomId: widget.chatRoomId,
      content: content,
      filePaths: filePaths,
    ));
    _messageController.clear();
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
      context.read<ChatBloc>().add(PickFilesEvent(result.paths.whereType<String>().toList()));
    }
  }

  void _showAddMediaSource() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Галерея (Фото)'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.file_present),
                title: const Text('Документ / Файл'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFile();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Initial sync of user ID if available
    final initialUserId = context.read<ProfileBloc>().state.profileModel?.data.user?.id;
    if (initialUserId != null && context.read<ChatBloc>().state.currentUserId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
         if (mounted) context.read<ChatBloc>().add(SetChatUserIdEvent(initialUserId));
      });
    }

    return MultiBlocListener(
      listeners: [
        BlocListener<ProfileBloc, ProfileState>(
          listenWhen: (prev, curr) =>
              prev.profileModel?.data.user?.id != curr.profileModel?.data.user?.id,
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
        backgroundColor: context.isDark ? AppColors.darkBackground : AppColors.black50,
        appBar: _buildAppBar(context),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ContainerW(
                  color: context.cardSurface,
                  margin: const EdgeInsets.all(16),
                  radius: 12,
                  child: Column(
                    children: [
                      Expanded(
                        child: BlocBuilder<ChatBloc, ChatState>(
                          builder: (context, state) {
                            if (state.status == ChatStatus.initial ||
                                (state.status == ChatStatus.loading && state.messages.isEmpty)) {
                              return const Center(child: CircularProgressIndicator());
                            }
      
                            if (state.status == ChatStatus.failure && state.messages.isEmpty) {
                              final isRoomNotFound = state.errorMessage == 'CHAT_ROOM_NOT_FOUND';
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isRoomNotFound ? Icons.chat_bubble_outline : Icons.error_outline,
                                        size: 48,
                                        color: isRoomNotFound ? Colors.orange : Colors.red,
                                      ),
                                      const SizedBox(height: 16),
                                      AppText(
                                        text: isRoomNotFound
                                            ? 'Qo\'llab-quvvatlash xizmati hali sozlanmagan.\nIltimos, keyinroq urinib ko\'ring yoki administrator bilan bog\'laning.'
                                            : (state.errorMessage ?? 'Xatolik yuz berdi'),
                                        textAlign: TextAlign.center,
                                        color: context.textPrimary,
                                      ),
                                      const SizedBox(height: 16),
                                      if (!isRoomNotFound) ElevatedButton(
                                        onPressed: () {
                                          context.read<ChatBloc>().add(GetChatMessagesEvent(chatRoomId: widget.chatRoomId));
                                        },
                                        child: const Text('Qayta urinish'),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            
                            if (state.messages.isEmpty) {
                              return Column(
                                 children: [
                                   const Spacer(),
                                   _buildQuickReplies(context),
                                 ],
                              );
                            }
      
                            return ListView.builder(
                              controller: _scrollController,
                              reverse: true,
                              padding: const EdgeInsets.all(16),
                              itemCount: state.messages.length + (state.hasReachedMax ? 0 : 1),
                              itemBuilder: (context, index) {
                                if (index >= state.messages.length) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
      
                                final message = state.messages[index];
                                
                                // Simplified stable 'isMe' check:
                                final isMe = message.id < 0 || 
                                            (state.currentUserId != null && message.sender == state.currentUserId);
  
                                return _buildMessageBubble(context, message, isMe);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildChatInput(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatInput(BuildContext context) {
    final primaryColor = context.read<AppModeCubit>().state.primaryColor;
    final borderColor = context.borderColor;
    final cardColor = context.cardSurface;

    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        return Column(
          children: [
            if (state.pickedFilePaths.isNotEmpty)
              Container(
                height: 80,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.pickedFilePaths.length,
                  itemBuilder: (context, index) {
                    final path = state.pickedFilePaths[index];
                    return Stack(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          margin: const EdgeInsets.only(right: 8, top: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: borderColor),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _isImagePath(path)
                                ? Image.file(File(path), fit: BoxFit.cover)
                                : const Icon(Icons.file_present),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: GestureDetector(
                            onTap: () => context.read<ChatBloc>().add(RemoveFileEvent(path)),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, size: 12, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _showAddMediaSource,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.isDark ? AppColors.darkBackground : AppColors.black50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, size: 24),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Напишите ваш вопрос...',
                        hintStyle: TextStyle(color: context.textSecondary),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryColor),
                        ),
                        filled: true,
                        fillColor: cardColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: state.isSending ? null : _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: state.isSending 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.send, color: Colors.white, size: 24),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  bool _isImagePath(String path) {
    final p = path.toLowerCase();
    return p.endsWith('.jpg') || p.endsWith('.jpeg') || p.endsWith('.png') || p.endsWith('.webp');
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final textColor = context.textPrimary;
    final cardColor = context.cardSurface;
    final borderColor = context.borderColor;

    return AppBar(
      backgroundColor: context.isDark ? AppColors.darkBackground : AppColors.black50,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ContainerW(
                onTap: () => context.pop(),
                radius: 10,
                color: cardColor,
                border: Border.all(color: borderColor),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(Icons.arrow_back_ios_new, size: 18, color: textColor),
                ),
              ),
              const SizedBox(width: 16),
              AppText(
                text: 'Поддержка',
                fontSize: 22,
                fontWeight: 700,
                color: textColor,
              ),
            ],
          ),
          ContainerW(
            onTap: () => context.pop(),
            radius: 10,
            color: cardColor,
            border: Border.all(color: borderColor),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Icon(Icons.close, size: 18, color: textColor),
                  const SizedBox(width: 8),
                  AppText(
                    text: 'Закрыть чат',
                    fontSize: 14,
                    fontWeight: 500,
                    color: textColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, ChatMessageModel message, bool isMe) {
    final primaryColor = context.read<AppModeCubit>().state.primaryColor;
    final isOptimistic = message.id < 0;

    // Time formatting
    String timeStr = "";
    try {
      final date = DateTime.parse(message.createdAt);
      timeStr = "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } catch (_) {}

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Opacity(
        opacity: isOptimistic ? 0.7 : 1.0,
        child: Row(
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe) ...[
              CircleAvatar(
                radius: 16,
                backgroundImage: message.senderInfo.avatar != null
                    ? NetworkImage(message.senderInfo.avatar!)
                    : null,
                child: message.senderInfo.avatar == null
                    ? const Icon(Icons.person, size: 16)
                    : null,
              ),
              const SizedBox(width: 12),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isMe ? primaryColor : AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                        bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        if (message.content != null && message.content!.isNotEmpty)
                          AppText(
                            text: message.content!,
                            fontSize: 14,
                            color: isMe ? AppColors.white : context.textPrimary,
                          ),
                        if (message.fileUrl != null || message.files.isNotEmpty) ...[
                          if (message.content != null && message.content!.isNotEmpty) const SizedBox(height: 8),
                          ...({
                            if (message.fileUrl != null) message.fileUrl!,
                            ...message.files.map((f) => f.fileUrlDisplay ?? f.file)
                          }).whereType<String>().map((url) {
                            final isLocalFile = url.startsWith('/');
                            return GestureDetector(
                              onTap: isLocalFile ? null : () => _previewImage(context, url),
                              child: Container(
                                constraints: const BoxConstraints(maxHeight: 200, maxWidth: 200),
                                margin: const EdgeInsets.only(bottom: 4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: isLocalFile 
                                    ? Image.file(File(url), fit: BoxFit.cover)
                                    : Image.network(
                                        url,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Icon(Icons.file_present),
                                      ),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppText(
                        text: timeStr,
                        fontSize: 12,
                        color: context.textSecondary,
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          isOptimistic ? Icons.access_time : Icons.done_all,
                          size: 14,
                          color: isOptimistic ? context.textSecondary : primaryColor,
                        ),
                      ],
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

  Widget _buildQuickReplies(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      // Only rebuild if room ID changes which might affect how we send 
      buildWhen: (prev, curr) => prev.chatRoomId != curr.chatRoomId,
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: _quickReplies.map((reply) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: GestureDetector(
                  onTap: () {
                     context.read<ChatBloc>().add(SendChatMessageEvent(
                       chatRoomId: state.chatRoomId ?? widget.chatRoomId,
                       content: reply,
                     ));
                  },
                   child: ContainerW(
                     radius: 16,
                     color: context.surfaceContainer,
                 child: Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                   child: AppText(
                     text: reply,
                     fontSize: 14,
                     fontWeight: 500,
                     color: context.textSecondary,
                   ),
                 ),
               ),
            ),
          );
        }).toList(),
      ),
    );
      },
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
            InteractiveViewer(
              child: Center(
                child: Image.network(url),
              ),
            ),
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
