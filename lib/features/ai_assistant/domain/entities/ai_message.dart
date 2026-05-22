import 'package:equatable/equatable.dart';

class AiMessage extends Equatable {
  final String text;
  final bool isUser;
  final String? route;
  final bool isLoading;
  final bool isError;

  const AiMessage({
    required this.text,
    required this.isUser,
    this.route,
    this.isLoading = false,
    this.isError = false,
  });

  @override
  List<Object?> get props => [text, isUser, route, isLoading, isError];
}
