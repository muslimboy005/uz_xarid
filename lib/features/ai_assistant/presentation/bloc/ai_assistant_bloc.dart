import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uzxarid/features/ai_assistant/data/repositories/ai_assistant_repository.dart';
import 'package:uzxarid/features/ai_assistant/domain/entities/ai_message.dart';
import 'ai_assistant_event.dart';
import 'ai_assistant_state.dart';

class AiAssistantBloc extends Bloc<AiAssistantEvent, AiAssistantState> {
  final AiAssistantRepository _repository;

  AiAssistantBloc({required AiAssistantRepository repository})
      : _repository = repository,
        super(const AiAssistantState()) {
    on<AiAssistantInitEvent>(_onInit);
    on<AiAssistantSendMessageEvent>(_onSendMessage);
  }

  void _onInit(AiAssistantInitEvent event, Emitter<AiAssistantState> emit) {
    if (state.messages.isNotEmpty) return;
    emit(
      state.copyWith(
        messages: [AiMessage(text: event.greeting, isUser: false)],
      ),
    );
  }

  Future<void> _onSendMessage(
    AiAssistantSendMessageEvent event,
    Emitter<AiAssistantState> emit,
  ) async {
    final text = event.text.trim();
    if (text.isEmpty || state.isSending) return;

    final messages = List<AiMessage>.from(state.messages)
      ..add(AiMessage(text: text, isUser: true))
      ..add(const AiMessage(text: '', isUser: false, isLoading: true));

    emit(state.copyWith(messages: messages, isSending: true));

    try {
      final response = await _repository.ask(text);
      final updated = List<AiMessage>.from(state.messages)
        ..removeLast()
        ..add(
          AiMessage(
            text: response.message,
            isUser: false,
            route: response.route,
          ),
        );
      emit(state.copyWith(messages: updated, isSending: false));
    } catch (_) {
      final updated = List<AiMessage>.from(state.messages)
        ..removeLast()
        ..add(AiMessage(text: event.errorFallback, isUser: false, isError: true));
      emit(state.copyWith(messages: updated, isSending: false));
    }
  }
}
