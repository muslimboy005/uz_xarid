import 'package:flutter/material.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/constants/app_dimens.dart';
import 'package:uz_xarid/core/theme/theme_colors.dart';
import 'package:uz_xarid/core/widgets/uzxarid_app_bar.dart';
import 'package:uz_xarid/l10n/app_localizations.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bodyBg = context.bodyBackground;
    final textColor = context.textSecondary;

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: UzXaridAppBar(
        onSearchChanged: (query) {
          // TODO: implement favorites search or filter
        },
        onMenuTap: () {
          // TODO: open favorites menu
        },
      ),
      body: Container(
        color: bodyBg,
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.paddingMedium),
          child: Center(
            child: Text(
              l10n.favoritesBody,
              style: TextStyle(color: textColor),
            ),
          ),
        ),
      ),
    );
  }
}
