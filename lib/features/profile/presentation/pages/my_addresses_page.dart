import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/widgets/profile_breadcrumb.dart';
import 'package:uz_xarid/core/widgets/uzxarid_app_bar.dart';
import 'package:uz_xarid/l10n/app_localizations.dart';

class MyAddressesPage extends StatelessWidget {
  const MyAddressesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: UzXaridAppBar(onSearchChanged: (query) {}, onMenuTap: () {}),
      backgroundColor: AppColors.black50,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileBreadcrumb(
              labels: [l10n.navHome, l10n.profileTitle, l10n.myAddressesTitle],
              onTaps: [
                () => context.go('/home'),
                () => context.go('/profile'),
                null,
              ],
            ),
            Expanded(
              child: Center(
                child: Text(
                  l10n.comingSoonSection(l10n.myAddressesTitle),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
