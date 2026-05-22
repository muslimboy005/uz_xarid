import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uzxarid/core/cubit/app_mode_cubit.dart';
import 'package:uzxarid/core/theme/theme_colors.dart';
import 'package:uzxarid/features/currency/domain/currency.dart';
import 'package:uzxarid/features/currency/presentation/cubit/currency_cubit.dart';

class CurrencySelectorSection extends StatelessWidget {
  const CurrencySelectorSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrencyCubit, CurrencyState>(
      builder: (context, state) {
        if (state.loading && state.currencies.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              height: 48,
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          );
        }

        if (state.currencies.isEmpty) {
          return const SizedBox.shrink();
        }

        final selected = state.selected!;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CurrencyDropdown(selected: selected, currencies: state.currencies),
              const SizedBox(height: 8),
              _RateDisplay(currency: selected),
            ],
          ),
        );
      },
    );
  }
}

/// Modern, all-in-one currency card that combines selector + live rate display.
/// Used in the new support menu redesign.
class CurrencyHeroCard extends StatelessWidget {
  const CurrencyHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrencyCubit, CurrencyState>(
      builder: (context, state) {
        if (state.loading && state.currencies.isEmpty) {
          return _HeroCardShell(
            child: const SizedBox(
              height: 120,
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          );
        }

        if (state.currencies.isEmpty) {
          return const SizedBox.shrink();
        }

        final selected = state.selected!;
        return _HeroCardShell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HeroCurrencyDropdown(
                selected: selected,
                currencies: state.currencies,
              ),
              const SizedBox(height: 14),
              _HeroRateRow(currency: selected),
            ],
          ),
        );
      },
    );
  }
}

class _HeroCardShell extends StatelessWidget {
  const _HeroCardShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<AppModeCubit>().state;
    final accent = mode.primaryColor;
    final isDark = context.isDark;
    final card = context.cardSurface;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.black.withValues(alpha: 0.04),
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: isDark ? 0.15 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _HeroCurrencyDropdown extends StatefulWidget {
  const _HeroCurrencyDropdown({
    required this.selected,
    required this.currencies,
  });

  final Currency selected;
  final List<Currency> currencies;

  @override
  State<_HeroCurrencyDropdown> createState() => _HeroCurrencyDropdownState();
}

class _HeroCurrencyDropdownState extends State<_HeroCurrencyDropdown> {
  final LayerLink _link = LayerLink();
  final GlobalKey _key = GlobalKey();
  OverlayEntry? _overlay;
  bool _open = false;

  @override
  void dispose() {
    _overlay?.remove();
    _overlay = null;
    super.dispose();
  }

  void _toggle() {
    if (_open) {
      _hide();
    } else {
      _show();
    }
  }

  void _show() {
    final renderBox = _key.currentContext?.findRenderObject() as RenderBox?;
    final width = renderBox?.size.width ?? 0;
    final cubit = context.read<CurrencyCubit>();

    _overlay = OverlayEntry(
      builder: (ctx) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _hide,
                child: const SizedBox.expand(),
              ),
            ),
            CompositedTransformFollower(
              link: _link,
              showWhenUnlinked: false,
              offset: const Offset(0, 64),
              child: Material(
                color: Colors.transparent,
                child: SizedBox(
                  width: width,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(ctx).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(maxHeight: 320),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      shrinkWrap: true,
                      itemCount: widget.currencies.length,
                      separatorBuilder: (_, _) => Divider(
                        height: 1,
                        color: context.borderColor.withValues(alpha: 0.4),
                        indent: 16,
                        endIndent: 16,
                      ),
                      itemBuilder: (_, i) {
                        final c = widget.currencies[i];
                        final isSelected = c.ccy == widget.selected.ccy;
                        return InkWell(
                          onTap: () {
                            cubit.select(c.ccy);
                            _hide();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                _Flag(ccy: c.ccy),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    c.ccy,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? Theme.of(ctx).primaryColor
                                          : context.textPrimary,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_rounded,
                                    size: 20,
                                    color: Theme.of(ctx).primaryColor,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_overlay!);
    setState(() => _open = true);
  }

  void _hide() {
    _overlay?.remove();
    _overlay = null;
    if (!mounted) return;
    setState(() => _open = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return CompositedTransformTarget(
      link: _link,
      child: GestureDetector(
        key: _key,
        behavior: HitTestBehavior.opaque,
        onTap: _toggle,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.black.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.06),
            ),
          ),
          child: Row(
            children: [
              _Flag(ccy: widget.selected.ccy),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.selected.ccy,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: context.textPrimary,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      _ccyName(widget.selected.ccy),
                      style: TextStyle(
                        fontSize: 12,
                        color: context.textSecondary,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedRotation(
                turns: _open ? 0.5 : 0,
                duration: const Duration(milliseconds: 220),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroRateRow extends StatelessWidget {
  const _HeroRateRow({required this.currency});
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<AppModeCubit>().state;
    final accent = mode.primaryColor;
    final symbol = currencySymbol(currency.ccy);
    final nominal = currency.nominal == 0 ? 1 : currency.nominal;
    final rateText = _formatRate(currency.rate);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accent.withValues(alpha: 0.20),
                accent.withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.trending_up_rounded, color: accent, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$nominal $symbol',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: context.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Flexible(
                    child: Text(
                      rateText,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: context.textPrimary,
                        height: 1.1,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'so\'m',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatRate(double v) {
    final fixed = v.toStringAsFixed(2);
    final parts = fixed.split('.');
    final intPart = parts[0];
    final buf = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      final fromEnd = intPart.length - i;
      buf.write(intPart[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) buf.write(' ');
    }
    return '${buf.toString()}.${parts[1]}';
  }
}

String _ccyName(String ccy) {
  switch (ccy.toUpperCase()) {
    case 'UZS':
      return 'O\'zbek so\'mi';
    case 'USD':
      return 'US Dollar';
    case 'EUR':
      return 'Euro';
    case 'RUB':
      return 'Russian Ruble';
    case 'GBP':
      return 'British Pound';
    case 'KZT':
      return 'Kazakh Tenge';
    case 'KGS':
      return 'Kyrgyz Som';
    case 'TJS':
      return 'Tajik Somoni';
    case 'TRY':
      return 'Turkish Lira';
    case 'CNY':
      return 'Chinese Yuan';
    case 'JPY':
      return 'Japanese Yen';
    default:
      return ccy;
  }
}

class _CurrencyDropdown extends StatefulWidget {
  const _CurrencyDropdown({required this.selected, required this.currencies});

  final Currency selected;
  final List<Currency> currencies;

  @override
  State<_CurrencyDropdown> createState() => _CurrencyDropdownState();
}

class _CurrencyDropdownState extends State<_CurrencyDropdown> {
  final LayerLink _link = LayerLink();
  final GlobalKey _key = GlobalKey();
  OverlayEntry? _overlay;
  bool _open = false;

  @override
  void dispose() {
    _overlay?.remove();
    _overlay = null;
    super.dispose();
  }

  void _toggle() {
    if (_open) {
      _hide();
    } else {
      _show();
    }
  }

  void _show() {
    final renderBox = _key.currentContext?.findRenderObject() as RenderBox?;
    final width = renderBox?.size.width ?? 0;
    final cubit = context.read<CurrencyCubit>();

    _overlay = OverlayEntry(
      builder: (ctx) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _hide,
                child: const SizedBox.expand(),
              ),
            ),
            CompositedTransformFollower(
              link: _link,
              showWhenUnlinked: false,
              offset: const Offset(0, 56),
              child: Material(
                color: Colors.transparent,
                child: SizedBox(
                  width: width,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(ctx).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(maxHeight: 320),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      shrinkWrap: true,
                      itemCount: widget.currencies.length,
                      separatorBuilder: (_, _) => Divider(
                        height: 1,
                        color: context.borderColor,
                        indent: 16,
                        endIndent: 16,
                      ),
                      itemBuilder: (_, i) {
                        final c = widget.currencies[i];
                        final isSelected = c.ccy == widget.selected.ccy;
                        return InkWell(
                          onTap: () {
                            cubit.select(c.ccy);
                            _hide();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                _Flag(ccy: c.ccy),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    c.ccy,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? Theme.of(ctx).primaryColor
                                          : context.textPrimary,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check,
                                    size: 20,
                                    color: Theme.of(ctx).primaryColor,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_overlay!);
    setState(() => _open = true);
  }

  void _hide() {
    _overlay?.remove();
    _overlay = null;
    if (!mounted) return;
    setState(() => _open = false);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: GestureDetector(
        key: _key,
        behavior: HitTestBehavior.opaque,
        onTap: _toggle,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: context.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _Flag(ccy: widget.selected.ccy),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.selected.ccy,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                ),
              ),
              AnimatedRotation(
                turns: _open ? 0.5 : 0,
                duration: const Duration(milliseconds: 180),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RateDisplay extends StatelessWidget {
  const _RateDisplay({required this.currency});

  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final symbol = currencySymbol(currency.ccy);
    final nominal = currency.nominal == 0 ? 1 : currency.nominal;
    final rateText = _formatRate(currency.rate);
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        '$nominal $symbol  =  $rateText so\'m',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: context.textPrimary,
        ),
      ),
    );
  }

  String _formatRate(double v) {
    final fixed = v.toStringAsFixed(2);
    final parts = fixed.split('.');
    final intPart = parts[0];
    final buf = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      final fromEnd = intPart.length - i;
      buf.write(intPart[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) buf.write(' ');
    }
    return '${buf.toString()}.${parts[1]}';
  }
}

class _Flag extends StatelessWidget {
  const _Flag({required this.ccy});
  final String ccy;

  @override
  Widget build(BuildContext context) {
    final emoji = currencyFlagEmoji(ccy);
    return Container(
      width: 28,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        color: emoji.isEmpty ? context.borderColor : null,
      ),
      child: emoji.isEmpty
          ? Text(
              ccy.substring(0, ccy.length >= 2 ? 2 : 1),
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
            )
          : Text(emoji, style: const TextStyle(fontSize: 18)),
    );
  }
}
