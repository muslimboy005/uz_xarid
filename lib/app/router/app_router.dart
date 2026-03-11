import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/dp/infection.dart';
import 'package:uz_xarid/core/service/local_service.dart';
import 'package:uz_xarid/features/home/presentation/pages/home_page.dart';
import 'package:uz_xarid/features/catalog/presentation/pages/catalog_page.dart';
import 'package:uz_xarid/features/product_list/domain/entities/subcategory_item.dart';
import 'package:uz_xarid/features/product_list/presentation/pages/product_list_page.dart';
import 'package:uz_xarid/features/profile/data/model/address_model.dart';
import 'package:uz_xarid/features/profile/presentation/bloc/address/address_event.dart';
import 'package:uz_xarid/features/search/presentation/pages/search_page.dart';
import 'package:uz_xarid/features/favorites/presentation/pages/favorites_page.dart';
import 'package:uz_xarid/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:uz_xarid/features/product_detail/domain/entities/ad_detail_entity.dart';
import 'package:uz_xarid/features/product_detail/presentation/pages/order_page.dart';
import 'package:uz_xarid/features/product_detail/presentation/pages/product_detail_page.dart';
import 'package:uz_xarid/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:uz_xarid/features/profile/presentation/pages/my_addresses_page.dart';
import 'package:uz_xarid/features/profile/presentation/pages/my_ads_page.dart';
import 'package:uz_xarid/features/profile/presentation/pages/my_business_page.dart';
import 'package:uz_xarid/features/profile/presentation/pages/my_orders_page.dart';
import 'package:uz_xarid/features/profile/presentation/pages/notifications_page.dart';
import 'package:uz_xarid/features/profile/presentation/pages/payment_page.dart';
import 'package:uz_xarid/features/profile/presentation/pages/personal_data_page.dart';
import 'package:uz_xarid/features/profile/presentation/pages/profile_page.dart';
import 'package:uz_xarid/features/profile/presentation/pages/support_page.dart';
import 'package:uz_xarid/features/profile/presentation/pages/view_history_page.dart';
import 'package:uz_xarid/features/profile/presentation/pages/add_address_page.dart';
import 'package:uz_xarid/features/profile/presentation/pages/add_address_map_page.dart';
import 'package:uz_xarid/features/profile/presentation/bloc/address/address_bloc.dart';
import 'package:uz_xarid/features/profile/presentation/bloc/my_ads/my_ads_bloc.dart';
import 'package:uz_xarid/features/profile/presentation/pages/settings_page.dart';
import 'package:uz_xarid/features/add_listing/presentation/pages/add_listing_page.dart';
import 'package:uz_xarid/features/author/presentation/pages/author_page.dart';
import 'package:uz_xarid/features/author/presentation/bloc/author/author_bloc.dart';
import 'package:uz_xarid/features/home/presentation/pages/support_menu_page.dart';
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
      GoRoute(
        path: '/support-menu',
        name: 'support-menu',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SupportMenuPage(),
      ),
      GoRoute(
        path: '/ad/:slug',
        name: 'product-detail',
        builder: (context, state) {
          final slug = state.pathParameters['slug'] ?? '';
          final favoritesBloc = context.read<FavoritesBloc>();
          return BlocProvider<FavoritesBloc>.value(
            value: favoritesBloc,
            child: ProductDetailPage(slug: slug),
          );
        },
        routes: [
          GoRoute(
            path: 'order',
            name: 'order',
            builder: (context, state) {
              final ad = state.extra as AdDetailEntity?;
              if (ad == null) {
                return const SizedBox.shrink();
              }
              return MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (_) => getIt<AddressBloc>()..add(LoadAddressesEvent()),
                  ),
                  BlocProvider(
                    create: (_) => getIt<ProfileBloc>()..add(const ProfileLoadEvent()),
                  ),
                ],
                child: OrderPage(ad: ad),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/author/:id',
        name: 'author-profile',
        builder: (context, state) {
          final idStr = state.pathParameters['id'] ?? '0';
          final userId = int.tryParse(idStr) ?? 0;
          return BlocProvider(
            create: (_) => getIt<AuthorBloc>(),
            child: AuthorPage(userId: userId),
          );
        },
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const SearchPage(),
      ),
      GoRoute(
        path: '/add-address',
        name: 'profile-add-address',
        builder: (context, state) {
          final extra = state.extra;
          return AddAddressMapPage(
            address: extra is AddressModel ? extra : null,
          );
        },
      ),
      GoRoute(
        path: '/add-address-form',
        name: 'profile-add-address-form',
        builder: (context, state) {
          final extra = state.extra;
          LatLng? coordinates;
          AddressModel? addressModel;
          if (extra is LatLng) {
            coordinates = extra;
          } else if (extra is AddressModel) {
            addressModel = extra;
          }

          return BlocProvider(
            create: (_) => getIt<AddressBloc>(),
            child: AddAddressPage(
              coordinates: coordinates,
              address: addressModel,
            ),
          );
        },
      ),
      GoRoute(
        path: '/products',
        name: 'products',
        builder: (context, state) {
          final queryParams = state.uri.queryParameters;
          final searchQuery = queryParams['search'];
          final title = searchQuery != null && searchQuery.isNotEmpty
              ? 'Qidiruv: ${Uri.decodeComponent(searchQuery)}'
              : (queryParams['title'] ?? '');
          final idStr = queryParams['categoryId'];
          final categoryId = int.tryParse(idStr ?? '');
          final listSource = queryParams['source'] ?? 'recommendations';
          final categoryType = queryParams['categoryType'] ?? 'Product';
          List<SubcategoryItem> subcategories = const [];
          final extra = state.extra;
          if (extra is List && extra.isNotEmpty) {
            try {
              subcategories = extra
                  .map((e) {
                    if (e is Map) {
                      return SubcategoryItem(
                        id: (e['id'] as num).toInt(),
                        name: e['name'] as String? ?? '',
                        image: e['image'] as String?,
                      );
                    }
                    return null;
                  })
                  .whereType<SubcategoryItem>()
                  .toList();
            } catch (_) {}
          }
          return ProductListPage(
            title: title.isNotEmpty ? title : 'Mahsulotlar',
            searchQuery: searchQuery != null && searchQuery.isNotEmpty
                ? Uri.decodeComponent(searchQuery)
                : null,
            categoryId: (categoryId != null && categoryId > 0)
                ? categoryId
                : null,
            listSource: listSource,
            subcategories: subcategories,
            categoryType: categoryType,
          );
        },
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          final String location = state.uri.path;
          final int currentIndex = _getIndexFromLocation(location);
          final l10n = AppLocalizations.of(context)!;
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;
          final barColor = isDark ? AppColors.darkSurface : AppColors.surface;
          final selectedColor = AppColors.primary;
          final unselectedColor = isDark
              ? AppColors.darkTextSecondary
              : AppColors.textSecondary;

          final bool isAddListing = location.startsWith('/add-listing');
          final Widget body = isAddListing
              ? BlocProvider(
                  create: (_) {
                    final bloc = getIt<ProfileBloc>();
                    getIt<SecureStorageService>().hasToken().then((hasToken) {
                      if (hasToken) bloc.add(const ProfileLoadEvent());
                    });
                    return bloc;
                  },
                  child: child,
                )
              : child;

          return Scaffold(
            body: body,
            bottomNavigationBar: Builder(
              builder: (context) {
                final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
                return Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      height: 62 + bottomPadding,
                      decoration: BoxDecoration(
                        color: barColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 62,
                            child: Row(
                              children: [
                                Expanded(
                                  child: _NavItem(
                                    icon: Icons.home_outlined,
                                    label: l10n.navHome,
                                    isSelected: currentIndex == 0,
                                    selectedColor: selectedColor,
                                    unselectedColor: unselectedColor,
                                    onTap: () => _onItemTapped(context, 0),
                                  ),
                                ),
                                Expanded(
                                  child: _NavItem(
                                    icon: Icons.menu,
                                    label: l10n.navCatalog,
                                    isSelected: currentIndex == 1,
                                    selectedColor: selectedColor,
                                    unselectedColor: unselectedColor,
                                    onTap: () => _onItemTapped(context, 1),
                                  ),
                                ),
                                const Expanded(child: SizedBox.shrink()),
                                Expanded(
                                  child: _NavItem(
                                    icon: Icons.favorite_border,
                                    label: l10n.navFavorites,
                                    isSelected: currentIndex == 2,
                                    selectedColor: selectedColor,
                                    unselectedColor: unselectedColor,
                                    onTap: () => _onItemTapped(context, 2),
                                  ),
                                ),
                                Expanded(
                                  child: _NavItem(
                                    icon: Icons.person_outline,
                                    label: l10n.navProfile,
                                    isSelected: currentIndex == 3,
                                    selectedColor: selectedColor,
                                    unselectedColor: unselectedColor,
                                    onTap: () => _onItemTapped(context, 3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: bottomPadding),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 31 + bottomPadding,
                      child: Material(
                        elevation: 6,
                        shadowColor: AppColors.primary.withValues(alpha: 0.4),
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: () => context.go('/add-listing'),
                          customBorder: const CircleBorder(),
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                            ),
                            child: const Icon(
                              Icons.add,
                              color: AppColors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
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
            pageBuilder: (context, state) {
              final type = state.uri.queryParameters['type'];
              final idStr = state.uri.queryParameters['categoryId'];
              final id = int.tryParse(idStr ?? '');
              return NoTransitionPage(
                child: CatalogPage(
                  initialCategoryType: type,
                  initialCategoryId: id != null && id > 0 ? id : null,
                ),
              );
            },
          ),
          GoRoute(
            path: '/favorites',
            name: 'favorites',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: FavoritesPage()),
          ),
          GoRoute(
            path: '/add-listing',
            name: 'add-listing',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: AddListingPage()),
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
                builder: (context, state) => BlocProvider(
                  create: (_) => getIt<MyAdsBloc>()
                    ..add(const MyAdsLoadRequested('active')),
                  child: const MyAdsPage(),
                ),
              ),
              GoRoute(
                path: 'my-orders',
                name: 'profile-my-orders',
                builder: (context, state) => const MyOrdersPage(),
              ),
              // GoRoute(
              //   path: 'favorites',
              //   name: 'profile-favorites',
              //   builder: (context, state) => const FavoritesProfilePage(),
              // ),
              GoRoute(
                path: 'notifications',
                name: 'profile-notifications',
                builder: (context, state) => const NotificationsPage(),
              ),
              GoRoute(
                path: 'my-addresses',
                name: 'profile-my-addresses',
                builder: (context, state) => BlocProvider(
                  create: (_) =>
                      getIt<AddressBloc>()..add(LoadAddressesEvent()),
                  child: const MyAddressesPage(),
                ),
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
              GoRoute(
                path: 'settings',
                name: 'profile-settings',
                builder: (context, state) => const SettingsPage(),
              ),
              GoRoute(
                path: 'my-business',
                name: 'profile-my-business',
                builder: (context, state) => BlocProvider(
                  create: (_) => getIt<ProfileBloc>(),
                  child: const MyBusinessPage(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  static int _getIndexFromLocation(String location) {
    if (location.startsWith('/add-listing')) {
      return -1;
    }
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

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.selectedColor,
    required this.unselectedColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final Color selectedColor;
  final Color unselectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? selectedColor : unselectedColor;
    return InkWell(
      onTap: onTap,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: color),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Text(
                    label,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
