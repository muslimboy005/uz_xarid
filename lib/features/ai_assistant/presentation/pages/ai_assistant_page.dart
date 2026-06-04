import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uzxarid/core/constants/app_colors.dart';
import 'package:uzxarid/core/theme/theme_colors.dart';
import 'package:uzxarid/core/widgets/app_text.dart';
import 'package:uzxarid/features/ai_assistant/domain/entities/ai_message.dart';
import 'package:uzxarid/features/ai_assistant/presentation/bloc/ai_assistant_bloc.dart';
import 'package:uzxarid/features/ai_assistant/presentation/bloc/ai_assistant_event.dart';
import 'package:uzxarid/features/ai_assistant/presentation/bloc/ai_assistant_state.dart';
import 'package:uzxarid/features/ai_assistant/presentation/widgets/robot_mascot.dart';
import 'package:uzxarid/l10n/app_localizations.dart';

// Web URL → mobile route name. Locale prefix is stripped before lookup.
const Map<String, String> _routeMap = {
  'dashboard/listings/add': 'add-listing',
  'dashboard/listings': 'profile-my-ads',
  'dashboard/my-ads': 'profile-my-ads',
  'dashboard/orders': 'profile-my-orders',
  'dashboard/addresses': 'profile-my-addresses',
  'dashboard/payment': 'profile-payment',
  'dashboard/notifications': 'profile-notifications',
  'dashboard/support': 'profile-support',
  'dashboard/view-history': 'profile-view-history',
  'dashboard/feedback': 'profile-feedback',
  'dashboard/contracts': 'profile-contracts',
};

String? _resolveRouteName(String webRoute) {
  var path = webRoute.trim();
  if (path.startsWith('/')) path = path.substring(1);
  if (path.endsWith('/')) path = path.substring(0, path.length - 1);
  for (final locale in const ['uz/', 'ru/', 'en/']) {
    if (path.startsWith(locale)) {
      path = path.substring(locale.length);
      break;
    }
  }
  return _routeMap[path];
}

class AiAssistantPage extends StatefulWidget {
  const AiAssistantPage({super.key});

  @override
  State<AiAssistantPage> createState() => _AiAssistantPageState();
}

class _AiAssistantPageState extends State<AiAssistantPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _hasText = false;
  bool _greeted = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) {
        setState(() => _hasText = hasText);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final l10n = AppLocalizations.of(context)!;
    context.read<AiAssistantBloc>().add(
          AiAssistantSendMessageEvent(
            text: text,
            errorFallback: l10n.aiAssistantError,
          ),
        );
    _controller.clear();
    setState(() => _hasText = false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _openRoute(String route) {
    final name = _resolveRouteName(route);
    final l10n = AppLocalizations.of(context)!;
    if (name == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.aiAssistantRouteNotFound)),
      );
      return;
    }
    context.pushNamed(name);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bg = context.bodyBackground;
    final cardColor = context.cardSurface;
    final textColor = context.textPrimary;
    final textSecondary = context.textSecondary;
    final borderColor = context.borderColor;
    final primary = context.primaryColor;

    if (!_greeted) {
      _greeted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context
            .read<AiAssistantBloc>()
            .add(AiAssistantInitEvent(l10n.aiAssistantGreeting));
      });
    }

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: cardColor,
              padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    // Leadingdagi kichik 2D robot — doim shu yerda turadi va
                    // sekin harakatlanadi (bodyga tushmaydi).
                    child: const Center(
                      child: RobotMascot(
                        size: Size(34, 42),
                        flat: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppText(
                          text: l10n.aiAssistantTitle,
                          fontSize: 18,
                          fontWeight: 700,
                          color: textColor,
                        ),
                        const SizedBox(height: 2),
                        AppText(
                          text: l10n.aiAssistantSubtitle,
                          fontSize: 13,
                          fontWeight: 400,
                          color: textSecondary,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: textColor),
                    splashRadius: 22,
                  ),
                ],
              ),
            ),
            Container(height: 1, color: borderColor),
            Expanded(
              child: BlocBuilder<AiAssistantBloc, AiAssistantState>(
                builder: (context, state) {
                  if (state.messages.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  final reversed = state.messages.reversed.toList();
                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    itemCount: reversed.length,
                    itemBuilder: (context, index) {
                      final message = reversed[index];
                      return _AiBubble(
                        message: message,
                        onOpenRoute: _openRoute,
                      );
                    },
                  );
                },
              ),
            ),
            BlocBuilder<AiAssistantBloc, AiAssistantState>(
              builder: (context, state) {
                final canSend = _hasText && !state.isSending;
                return Container(
                  color: cardColor,
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          maxLines: 4,
                          minLines: 1,
                          textCapitalization: TextCapitalization.sentences,
                          style: TextStyle(
                            fontSize: 14,
                            color: textColor,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: l10n.aiAssistantHint,
                            hintStyle: TextStyle(
                              color: textSecondary,
                              fontSize: 14,
                            ),
                            filled: true,
                            fillColor: bg,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(color: primary),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(color: primary),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(color: primary, width: 1.5),
                            ),
                          ),
                          onSubmitted: (_) {
                            if (canSend) _send();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: canSend ? _send : null,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: canSend
                                ? primary.withValues(alpha: 0.12)
                                : primary.withValues(alpha: 0.06),
                            shape: BoxShape.circle,
                          ),
                          child: state.isSending
                              ? Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: CircularProgressIndicator(
                                    color: primary,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  Icons.send_rounded,
                                  color: canSend
                                      ? primary
                                      : primary.withValues(alpha: 0.4),
                                  size: 20,
                                ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AiBubble extends StatelessWidget {
  final AiMessage message;
  final void Function(String route) onOpenRoute;

  const _AiBubble({required this.message, required this.onOpenRoute});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isUser = message.isUser;
    final primary = context.primaryColor;
    final isDark = context.isDark;
    final bubbleColor = isUser
        ? primary
        : (isDark ? AppColors.darkCard : const Color(0xFFF1F2F4));
    final textColor = isUser
        ? Colors.white
        : context.textPrimary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.78,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (message.isLoading)
                    _TypingDots(color: textColor)
                  else
                    Text(
                      message.text,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.35,
                        color: textColor,
                      ),
                    ),
                  if (message.route != null) ...[
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => onOpenRoute(message.route!),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isUser
                              ? Colors.white.withValues(alpha: 0.18)
                              : primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n.aiAssistantOpenPage,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isUser ? Colors.white : primary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: isUser ? Colors.white : primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  final Color color;
  const _TypingDots({required this.color});

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final t = (_controller.value - i * 0.2).clamp(0.0, 1.0);
            final opacity = (1.0 - (t - 0.5).abs() * 2).clamp(0.3, 1.0);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: opacity),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
