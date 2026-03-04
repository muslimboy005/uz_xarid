import 'package:flutter/material.dart';
import 'package:uz_xarid/core/theme/theme_colors.dart';
import 'package:uz_xarid/core/widgets/uzxarid_app_bar.dart';
import 'package:uz_xarid/l10n/app_localizations.dart';

class ViewHistoryPage extends StatelessWidget {
  const ViewHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // final isDark = context.isDark;
    // final bodyBg = context.bodyBackground;
    // final cardColor = context.cardSurface;
    // final textColor = context.textPrimary;
    // final textSecondary = context.textSecondary;
    // final borderColor = context.borderColor;
    // final surfaceContainer = context.surfaceContainer;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: UzXaridAppBar(onSearchChanged: (query) {}, onMenuTap: () {}),
      backgroundColor: context.bodyBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: Text(l10n.comingSoonSection(l10n.viewHistoryTitle)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
