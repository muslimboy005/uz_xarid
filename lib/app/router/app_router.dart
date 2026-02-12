import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/localization/app_localizations.dart';
import 'package:uz_xarid/features/home/presentation/pages/home_page.dart';
import 'package:uz_xarid/features/catalog/presentation/pages/catalog_page.dart';
import 'package:uz_xarid/features/favorites/presentation/pages/favorites_page.dart';
import 'package:uz_xarid/features/profile/presentation/pages/profile_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

class AppRouter {
  const AppRouter._();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          final String location = state.uri.path;
          final int currentIndex = _getIndexFromLocation(location);
          final l10n = AppLocalizations.of(context);

          return Scaffold(
            body: child,
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: currentIndex,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textSecondary,
              onTap: (index) => _onItemTapped(context, index),
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home_outlined),
                  label: l10n.navHome,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.menu),
                  label: l10n.navCatalog,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.favorite_border),
                  label: l10n.navFavorites,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.person_outline),
                  label: l10n.navProfile,
                ),
              ],
            ),
          );
        },
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomePage(),
            ),
          ),
          GoRoute(
            path: '/catalog',
            name: 'catalog',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CatalogPage(),
            ),
          ),
          GoRoute(
            path: '/favorites',
            name: 'favorites',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: FavoritesPage(),
            ),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfilePage(),
            ),
          ),
        ],
      ),
    ],
  );

  static int _getIndexFromLocation(String location) {
    if (location.startsWith('/catalog')) {
      return 1;
    }
    if (location.startsWith('/favorites')) {
      return 2;
    }
    if (location.startsWith('/profile')) {
      return 3;
    }
    return 0;
  }

  static void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/catalog');
        break;
      case 2:
        context.go('/favorites');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }
}

