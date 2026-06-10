import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uzxarid/core/constants/app_colors.dart';
import 'package:uzxarid/core/cubit/app_mode_cubit.dart';
import 'package:uzxarid/core/theme/theme_colors.dart';
import 'package:uzxarid/core/widgets/uzxarid_app_bar.dart';
import 'package:uzxarid/features/currency/presentation/widgets/currency_selector.dart';
import 'package:uzxarid/l10n/app_localizations.dart';

class SupportMenuPage extends StatelessWidget {
  const SupportMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<AppModeCubit>().state;
    final isBuying = mode == AppMode.buying;
    final l10n = AppLocalizations.of(context)!;
    final bg = context.bodyBackground;

    return UzXaridScaffold(
      backgroundColor: bg,
      onClose: () => context.pop(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 720;
          final horizontalPadding = isWide ? 24.0 : 16.0;
          final contentMaxWidth = isWide ? 640.0 : double.infinity;

          final services = <_ServiceItem>[
            _ServiceItem(
              icon: Icons.move_to_inbox_outlined,
              color: const Color(0xFF3B82F6),
              title: 'Ariza va taklif',
              subtitle: _subtitleFor(
                l10n,
                uz: 'O\'z fikr va takliflaringizni yuboring',
                ru: 'Отправьте свои отзывы и предложения',
                en: 'Send your feedback and suggestions',
              ),
              onTap: () {},
            ),
            _ServiceItem(
              icon: Icons.local_offer_outlined,
              color: AppColors.red,
              title: l10n.supportMenuChegirmalar,
              subtitle: _subtitleFor(
                l10n,
                uz: 'Eng yaxshi takliflar va chegirmalar',
                ru: 'Лучшие предложения и скидки',
                en: 'Best offers and discounts',
              ),
              onTap: () {},
            ),
            _ServiceItem(
              icon: Icons.card_giftcard_outlined,
              color: const Color(0xFFFF8C00),
              title: l10n.supportMenuAksiyalar,
              subtitle: _subtitleFor(
                l10n,
                uz: 'Cheklangan vaqtli aksiyalar',
                ru: 'Ограниченные по времени акции',
                en: 'Limited-time promotions',
              ),
              onTap: () {},
            ),
            _ServiceItem(
              icon: Icons.headset_mic_outlined,
              color: mode.primaryColor,
              title: l10n.supportMenuQollabQuvvatlash,
              subtitle: _subtitleFor(
                l10n,
                uz: 'Operator bilan bog\'lanish',
                ru: 'Связаться с оператором',
                en: 'Contact an operator',
              ),
              onTap: () => context.push('/profile/support'),
            ),
          ];

          final infos = <_InfoItem>[
            _InfoItem(
              icon: Icons.help_outline_rounded,
              title: l10n.supportMenuHowToOrder,
              onTap: () {},
            ),
            _InfoItem(
              icon: Icons.local_shipping_outlined,
              title: l10n.supportMenuDeliveryAndPayment,
              onTap: () {},
            ),
          ];

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              left: horizontalPadding,
              right: horizontalPadding,
              top: 12,
              bottom: MediaQuery.of(context).padding.bottom + 24,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentMaxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const CurrencyHeroCard(),
                    const SizedBox(height: 10),
                    _ModeToggle(
                      isBuying: isBuying,
                      sellLabel: l10n.supportMenuSotaman,
                      buyLabel: l10n.supportMenuSotibOlaman,
                    ),
                    const SizedBox(height: 16),
                    _SectionLabel(text: _sectionLabelFor(l10n)),
                    const SizedBox(height: 8),
                    _GroupedCard(
                      children: [
                        for (int i = 0; i < services.length; i++) ...[
                          services[i],
                          if (i != services.length - 1) const _ListDivider(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    _SectionLabel(text: _infoSectionLabelFor(l10n)),
                    const SizedBox(height: 8),
                    _GroupedCard(
                      children: [
                        for (int i = 0; i < infos.length; i++) ...[
                          infos[i],
                          if (i != infos.length - 1) const _ListDivider(),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _sectionLabelFor(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'ru':
        return 'СЕРВИСЫ';
      case 'en':
        return 'SERVICES';
      case 'uz':
      default:
        return 'XIZMATLAR';
    }
  }

  String _infoSectionLabelFor(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'ru':
        return 'ИНФОРМАЦИЯ';
      case 'en':
        return 'INFORMATION';
      case 'uz':
      default:
        return 'MA\'LUMOT';
    }
  }

  String _subtitleFor(
    AppLocalizations l10n, {
    required String uz,
    required String ru,
    required String en,
  }) {
    switch (l10n.localeName) {
      case 'ru':
        return ru;
      case 'en':
        return en;
      case 'uz':
      default:
        return uz;
    }
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: context.textSecondary,
        ),
      ),
    );
  }
}

class _GroupedCard extends StatelessWidget {
  const _GroupedCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Container(
      decoration: BoxDecoration(
        color: context.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.black.withValues(alpha: 0.04),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class _ListDivider extends StatelessWidget {
  const _ListDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 70),
      child: Divider(
        height: 1,
        thickness: 1,
        color: context.borderColor.withValues(alpha: 0.35),
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({
    required this.isBuying,
    required this.sellLabel,
    required this.buyLabel,
  });

  final bool isBuying;
  final String sellLabel;
  final String buyLabel;

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<AppModeCubit>().state;
    final selectedBg = mode.primaryColor;
    final card = context.cardSurface;
    final isDark = context.isDark;

    return Container(
      height: 52,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.black.withValues(alpha: 0.04),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final segmentWidth = c.maxWidth / 2;
          return Stack(
            children: [
              AnimatedAlign(
                alignment:
                    isBuying ? Alignment.centerRight : Alignment.centerLeft,
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                child: Container(
                  width: segmentWidth,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: selectedBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              Row(
                children: [
                  _ToggleSegment(
                    label: sellLabel,
                    selected: !isBuying,
                    onTap: () => context.read<AppModeCubit>().setSelling(),
                  ),
                  _ToggleSegment(
                    label: buyLabel,
                    selected: isBuying,
                    onTap: () => context.read<AppModeCubit>().setBuying(),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ToggleSegment extends StatelessWidget {
  const _ToggleSegment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 240),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : context.textSecondary,
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}

class _ServiceItem extends StatelessWidget {
  const _ServiceItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withValues(alpha: 0.22),
                      color.withValues(alpha: 0.10),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: context.textPrimary,
                        height: 1.25,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: context.textSecondary,
                        height: 1.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: context.textSecondary.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: context.textSecondary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 20, color: context.textSecondary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: context.textPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: context.textSecondary.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
