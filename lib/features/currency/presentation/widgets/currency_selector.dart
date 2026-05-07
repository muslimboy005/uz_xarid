import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uz_xarid/core/theme/theme_colors.dart';
import 'package:uz_xarid/features/currency/domain/currency.dart';
import 'package:uz_xarid/features/currency/presentation/cubit/currency_cubit.dart';

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
