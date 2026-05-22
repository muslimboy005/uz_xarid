import 'package:equatable/equatable.dart';
import 'package:uzxarid/features/ai_assistant/domain/entities/ai_message.dart';

class AiAssistantState extends Equatable {
  final List<AiMessage> messages;
  final bool isSending;

  const AiAssistantState({
    this.messages = const [],
    this.isSending = false,
  });

  AiAssistantState copyWith({
    List<AiMessage>? messages,
    bool? isSending,
  }) {
    return AiAssistantState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
    );
  }

  @override
  List<Object?> get props => [messages, isSending];
}
