import 'package:flutter/material.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';

import 'package:uz_xarid/core/constants/app_dimens.dart';
import 'package:uz_xarid/core/localization/app_localizations.dart';
import 'package:uz_xarid/core/widgets/uzxarid_app_bar.dart';

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: UzXaridAppBar(
        onSearchChanged: (query) {
          // TODO: implement catalog search
        },
        onMenuTap: () {
          // TODO: open catalog menu
        },
      ),
      body: Container(
        color: AppColors.background,
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.paddingMedium),
          child: Center(
            child: Text(l10n.catalogBody),
          ),
        ),
      ),
    );
  }
}
