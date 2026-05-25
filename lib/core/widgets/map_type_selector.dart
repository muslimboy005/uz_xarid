import 'package:flutter/material.dart';
import 'package:uzxarid/core/theme/theme_colors.dart';
import 'package:uzxarid/core/widgets/app_text.dart';
import 'package:uzxarid/core/widgets/glass_container.dart';
import 'package:uzxarid/l10n/app_localizations.dart';

enum AppMapType { scheme, satellite, hybrid }

class MapTypeSelector extends StatelessWidget {
  const MapTypeSelector({
    super.key,
    required this.current,
    required this.onChanged,
  });

  final AppMapType current;
  final ValueChanged<AppMapType> onChanged;

  Future<void> _showMenu(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final cardColor = context.cardSurface;
    final textColor = context.textPrimary;
    final primary = context.primaryColor;

    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final Offset buttonPosition = button.localToGlobal(
      Offset.zero,
      ancestor: overlay,
    );
    final RelativeRect position = RelativeRect.fromLTRB(
      buttonPosition.dx - 80,
      buttonPosition.dy + button.size.height + 6,
      overlay.size.width - buttonPosition.dx - button.size.width,
      0,
    );

    final entries = <(AppMapType, String)>[
      (AppMapType.scheme, l10n.mapTypeScheme),
      (AppMapType.satellite, l10n.mapTypeSatellite),
      (AppMapType.hybrid, l10n.mapTypeHybrid),
    ];

    final selected = await showMenu<AppMapType>(
      context: context,
      position: position,
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      items: [
        for (final entry in entries)
          PopupMenuItem<AppMapType>(
            value: entry.$1,
            height: 40,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  child: entry.$1 == current
                      ? Icon(Icons.check, size: 16, color: primary)
                      : const SizedBox.shrink(),
                ),
                const SizedBox(width: 4),
                AppText(
                  text: entry.$2,
                  color: textColor,
                  fontSize: 14,
                  fontWeight: 500,
                ),
              ],
            ),
          ),
      ],
    );

    if (selected != null && selected != current) {
      onChanged(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = context.textPrimary;

    return GlassContainer(
      borderRadius: 14,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _showMenu(context),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(Icons.layers_outlined, color: textColor, size: 22),
          ),
        ),
      ),
    );
  }
}
