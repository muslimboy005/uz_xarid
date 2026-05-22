import 'package:equatable/equatable.dart';

abstract class AiAssistantEvent extends Equatable {
  const AiAssistantEvent();

  @override
  List<Object?> get props => [];
}

class AiAssistantInitEvent extends AiAssistantEvent {
  final String greeting;
  const AiAssistantInitEvent(this.greeting);

  @override
  List<Object?> get props => [greeting];
}

class AiAssistantSendMessageEvent extends AiAssistantEvent {
  final String text;
  final String errorFallback;
  const AiAssistantSendMessageEvent({
    required this.text,
    required this.errorFallback,
  });

  @override
  List<Object?> get props => [text, errorFallback];
}
