part of 'ad_chat_bloc.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class ChatRoomOpened extends ChatEvent {
  final String adSlug;
  const ChatRoomOpened(this.adSlug);

  @override
  List<Object?> get props => [adSlug];
}

class ChatMessageSent extends ChatEvent {
  final String content;
  const ChatMessageSent(this.content);

  @override
  List<Object?> get props => [content];
}

class ChatRealtimeMessageReceived extends ChatEvent {
  final Map<String, dynamic> data;
  const ChatRealtimeMessageReceived(this.data);

  @override
  List<Object?> get props => [data];
}

class ChatLoadMoreMessages extends ChatEvent {}
