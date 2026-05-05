import 'package:equatable/equatable.dart';

abstract class ChatListEvent extends Equatable {
  const ChatListEvent();

  @override
  List<Object?> get props => [];
}

class LoadChatRooms extends ChatListEvent {
  final bool refresh;
  const LoadChatRooms({this.refresh = false});

  @override
  List<Object?> get props => [refresh];
}
