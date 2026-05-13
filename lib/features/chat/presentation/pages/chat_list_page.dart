import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:uzxarid/core/theme/theme_colors.dart';
import 'package:uzxarid/features/chat/presentation/bloc/chat_list_bloc.dart';
import 'package:uzxarid/features/chat/presentation/bloc/chat_list_event.dart';
import 'package:uzxarid/features/chat/presentation/bloc/chat_list_state.dart';
import 'package:uzxarid/features/chat/presentation/widgets/chat_room_list_item.dart';
import 'package:uzxarid/l10n/app_localizations.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textPrimary = context.textPrimary;
    final bodyBg = context.bodyBackground;

    return BlocProvider(
      create: (context) => GetIt.I<ChatListBloc>()..add(const LoadChatRooms(refresh: true)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.chatTitle ?? 'Mening chatlarim',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: textPrimary, size: 20),
            onPressed: () => context.pop(),
          ),
        ),
        body: Container(
          color: bodyBg,
          child: BlocBuilder<ChatListBloc, ChatListState>(
            builder: (context, state) {
              if (state.status == ChatListStatus.loading && state.rooms.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.status == ChatListStatus.failure && state.rooms.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.error ?? 'Failed to load chats'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<ChatListBloc>().add(const LoadChatRooms(refresh: true));
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (state.rooms.isEmpty) {
                return Center(
                  child: Text(
                    l10n.chatEmpty ?? 'Sizda hali chatlar mavjud emas',
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<ChatListBloc>().add(const LoadChatRooms(refresh: true));
                },
                child: ListView.builder(
                  itemCount: state.rooms.length + (state.hasReachedMax ? 0 : 1),
                  itemBuilder: (context, index) {
                    if (index >= state.rooms.length) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        context.read<ChatListBloc>().add(const LoadChatRooms());
                      });
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final room = state.rooms[index];
                    return ChatRoomListItem(
                      room: room,
                      onTap: () {
                        context.push(
                          '/keraklilar/chats/room',
                          extra: {
                            'adSlug': room.adInfo?.slug ?? '',
                            'participantId': room.otherParticipantId ?? 0,
                            'participantName': room.otherParticipant?.firstName ?? 'User',
                          },
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
