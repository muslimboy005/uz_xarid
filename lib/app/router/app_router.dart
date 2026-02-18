// routes/app_router.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/dp/infection.dart';
import 'package:uz_xarid/core/service/local_service.dart';
import 'package:uz_xarid/features/home/presentation/pages/home_page.dart';
import 'package:uz_xarid/features/catalog/presentation/pages/catalog_page.dart';
import 'package:uz_xarid/features/favorites/presentation/pages/favorites_page.dart';
import 'package:uz_xarid/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:uz_xarid/features/profile/presentation/pages/favorites_profile_page.dart';
import 'package:uz_xarid/features/profile/presentation/pages/my_addresses_page.dart';
import 'package:uz_xarid/features/profile/presentation/pages/my_ads_page.dart';
import 'package:uz_xarid/features/profile/presentation/pages/my_orders_page.dart';
import 'package:uz_xarid/features/profile/presentation/pages/notifications_page.dart';
import 'package:uz_xarid/features/profile/presentation/pages/payment_page.dart';
import 'package:uz_xarid/features/profile/presentation/pages/personal_data_page.dart';
import 'package:uz_xarid/features/profile/presentation/pages/profile_page.dart';
import 'package:uz_xarid/features/profile/presentation/pages/support_page.dart';
import 'package:uz_xarid/features/profile/presentation/pages/view_history_page.dart';
import 'package:uz_xarid/l10n/app_localizations.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'shell',
);

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
          final l10n = AppLocalizations.of(context)!;

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
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomePage()),
          ),
          GoRoute(
            path: '/catalog',
            name: 'catalog',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: CatalogPage()),
          ),
          GoRoute(
            path: '/favorites',
            name: 'favorites',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: FavoritesPage()),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => BlocProvider(
              create: (_) {
                final bloc = getIt<ProfileBloc>();
                getIt<SecureStorageService>().hasToken().then((hasToken) {
                  if (hasToken) {
                    bloc.add(const ProfileLoadEvent());
                  }
                });
                return bloc;
              },
              child: const ProfilePage(),
            ),
            routes: [
              GoRoute(
                path: 'edit',
                name: 'profile-edit',
                builder: (context, state) => BlocProvider(
                  create: (_) {
                    final bloc = getIt<ProfileBloc>();
                    getIt<SecureStorageService>().hasToken().then((hasToken) {
                      if (hasToken) bloc.add(const ProfileLoadEvent());
                    });
                    return bloc;
                  },
                  child: const PersonalDataPage(),
                ),
              ),
              GoRoute(
                path: 'personal-data',
                name: 'profile-personal-data',
                builder: (context, state) => BlocProvider(
                  create: (_) {
                    final bloc = getIt<ProfileBloc>();
                    getIt<SecureStorageService>().hasToken().then((hasToken) {
                      if (hasToken) bloc.add(const ProfileLoadEvent());
                    });
                    return bloc;
                  },
                  child: const PersonalDataPage(),
                ),
              ),
              GoRoute(
                path: 'my-ads',
                name: 'profile-my-ads',
                builder: (context, state) => const MyAdsPage(),
              ),
              GoRoute(
                path: 'my-orders',
                name: 'profile-my-orders',
                builder: (context, state) => const MyOrdersPage(),
              ),
              GoRoute(
                path: 'favorites',
                name: 'profile-favorites',
                builder: (context, state) => const FavoritesProfilePage(),
              ),
              GoRoute(
                path: 'notifications',
                name: 'profile-notifications',
                builder: (context, state) => const NotificationsPage(),
              ),
              GoRoute(
                path: 'my-addresses',
                name: 'profile-my-addresses',
                builder: (context, state) => const MyAddressesPage(),
              ),
              GoRoute(
                path: 'payment',
                name: 'profile-payment',
                builder: (context, state) => const PaymentPage(),
              ),
              GoRoute(
                path: 'support',
                name: 'profile-support',
                builder: (context, state) => const SupportPage(),
              ),
              GoRoute(
                path: 'view-history',
                name: 'profile-view-history',
                builder: (context, state) => const ViewHistoryPage(),
              ),
            ],
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
