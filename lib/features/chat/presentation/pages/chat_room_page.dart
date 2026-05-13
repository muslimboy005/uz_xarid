import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:uzxarid/core/theme/theme_colors.dart';
import 'package:uzxarid/features/chat/presentation/bloc/ad_chat_bloc.dart';
import 'package:uzxarid/features/chat/presentation/widgets/chat_bubble.dart';

class ChatRoomPage extends StatefulWidget {
  final String adSlug;
  final int participantId;
  final String participantName;

  const ChatRoomPage({
    super.key,
    required this.adSlug,
    required this.participantId,
    required this.participantName,
  });

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.I<AdChatBloc>()..add(ChatRoomOpened(widget.adSlug)),
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.participantName,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              BlocBuilder<AdChatBloc, ChatState>(
                builder: (context, state) {
                  if (state.room != null && state.room!.otherParticipant != null) {
                    return Text(
                      state.room!.otherParticipant!.firstName ?? 
                      state.room!.otherParticipant!.phone ?? '',
                      style: const TextStyle(
                        fontSize: 12, 
                        fontWeight: FontWeight.normal,
                        color: Colors.white70,
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ],
          ),
          backgroundColor: context.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Container(
          color: context.bodyBackground,
          child: Column(
            children: [
              Expanded(
                child: BlocBuilder<AdChatBloc, ChatState>(
                  builder: (context, state) {
                    if (state.status == ChatStatus.loading && state.messages.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.status == ChatStatus.failure && state.messages.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(state.error ?? 'Error loading chat'),
                            TextButton(
                              onPressed: () => context.read<AdChatBloc>().add(ChatRoomOpened(widget.adSlug)),
                              child: const Text('Try Again'),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    if (state.messages.isEmpty && state.status == ChatStatus.success) {
                      return const Center(
                        child: Text('Hali xabarlar yo\'q. Birinchi bo\'lib yozing!'),
                      );
                    }

                    return ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      itemCount: state.messages.length,
                      itemBuilder: (context, index) {
                        final message = state.messages[index];
                        // If senderId matches otherParticipant.id, it's NOT me.
                        final isMe = message.senderId != state.room!.otherParticipantId;
                        return ChatBubble(message: message, isMe: isMe);
                      },
                    );
                  },
                ),
              ),
              _buildInput(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(8, 8, 8, MediaQuery.of(context).padding.bottom + 8),
      decoration: BoxDecoration(
        color: context.cardSurface,
        border: Border(top: BorderSide(color: context.borderColor, width: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.grey),
            onPressed: () {
              // Future: implementation for file picking
            },
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: context.isDark ? Colors.grey[900] : Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _controller,
                onChanged: (val) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Xabar yozing...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                maxLines: 5,
                minLines: 1,
                style: TextStyle(color: context.textPrimary),
              ),
            ),
          ),
          BlocBuilder<AdChatBloc, ChatState>(
            builder: (context, state) {
              final canSend = _controller.text.trim().isNotEmpty;
              return AnimatedScale(
                scale: canSend ? 1.0 : 0.8,
                duration: const Duration(milliseconds: 200),
                child: IconButton(
                  icon: Icon(
                    Icons.send_rounded, 
                    color: canSend ? context.primaryColor : Colors.grey,
                  ),
                  onPressed: canSend ? () {
                    context.read<AdChatBloc>().add(ChatMessageSent(_controller.text));
                    _controller.clear();
                    setState(() {});
                  } : null,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
