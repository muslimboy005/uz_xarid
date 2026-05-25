import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:uzxarid/core/constants/app_colors.dart';
import 'package:uzxarid/core/cubit/app_mode_cubit.dart';
import 'package:uzxarid/core/dio/dio_client.dart';
import 'package:uzxarid/core/dp/infection.dart';
import 'package:uzxarid/core/service/local_service.dart';
import 'package:uzxarid/features/home/presentation/pages/home_page.dart';
import 'package:uzxarid/features/catalog/presentation/pages/catalog_page.dart';
import 'package:uzxarid/features/catalog/domain/usecases/get_categories.dart';
import 'package:uzxarid/features/product_list/domain/entities/subcategory_item.dart';
import 'package:uzxarid/features/product_list/presentation/pages/product_list_page.dart';
import 'package:uzxarid/features/profile/data/model/address_model.dart';
import 'package:uzxarid/features/profile/presentation/bloc/address/address_event.dart';
import 'package:uzxarid/features/search/presentation/pages/search_page.dart';
import 'package:uzxarid/features/cart/presentation/pages/cart_page.dart';
import 'package:uzxarid/features/favorites/presentation/pages/favorites_page.dart';
import 'package:uzxarid/features/favorites/presentation/pages/keraklilar_page.dart';
import 'package:uzxarid/features/chat/presentation/pages/chat_list_page.dart';
import 'package:uzxarid/features/chat/presentation/pages/chat_room_page.dart';
import 'package:uzxarid/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:uzxarid/features/product_detail/domain/entities/ad_detail_entity.dart';
import 'package:uzxarid/features/product_detail/presentation/pages/order_page.dart';
import 'package:uzxarid/features/product_detail/presentation/pages/product_detail_page.dart';
import 'package:uzxarid/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:uzxarid/features/profile/presentation/pages/my_addresses_page.dart';
import 'package:uzxarid/features/profile/presentation/pages/my_ads_page.dart';
import 'package:uzxarid/features/profile/presentation/pages/my_business_page.dart';
import 'package:uzxarid/features/profile/presentation/pages/my_orders_page.dart';
import 'package:uzxarid/features/profile/presentation/pages/notifications_page.dart';
import 'package:uzxarid/features/profile/presentation/pages/payment_page.dart';
import 'package:uzxarid/features/profile/presentation/pages/personal_data_page.dart';
import 'package:uzxarid/features/profile/presentation/pages/profile_page.dart';
import 'package:uzxarid/features/profile/presentation/pages/support_page.dart';
import 'package:uzxarid/features/profile/presentation/pages/view_history_page.dart';
import 'package:uzxarid/features/profile/presentation/pages/add_address_page.dart';
import 'package:uzxarid/features/profile/presentation/pages/add_address_map_page.dart';
import 'package:uzxarid/features/profile/presentation/bloc/address/address_bloc.dart';
import 'package:uzxarid/features/profile/presentation/bloc/my_ads/my_ads_bloc.dart';
import 'package:uzxarid/features/profile/presentation/pages/settings_page.dart';
import 'package:uzxarid/features/profile/presentation/pages/support_chat_page.dart';
import 'package:uzxarid/features/profile/presentation/bloc/chat/chat_bloc.dart';
import 'package:uzxarid/features/profile/presentation/bloc/chat/chat_event.dart';
import 'package:uzxarid/features/ai_assistant/presentation/bloc/ai_assistant_bloc.dart';
import 'package:uzxarid/features/ai_assistant/presentation/pages/ai_assistant_page.dart';
import 'package:uzxarid/features/contracts/presentation/pages/contracts_page.dart';
import 'package:uzxarid/features/contracts/presentation/pages/document_detail_page.dart';
import 'package:uzxarid/features/add_listing/presentation/pages/add_listing_page.dart';
import 'package:uzxarid/features/add_listing/presentation/pages/soon_page.dart';
import 'package:uzxarid/features/author/presentation/pages/author_page.dart';
import 'package:uzxarid/features/author/presentation/bloc/author/author_bloc.dart';
import 'package:uzxarid/features/feedback/data/feedback_repository.dart';
import 'package:uzxarid/features/feedback/presentation/pages/feedback_page.dart';
import 'package:uzxarid/features/home/presentation/pages/support_menu_page.dart';
import 'package:uzxarid/l10n/app_localizations.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'shell',
);

class AppRouter {
  const AppRouter._();

  static GlobalKey<NavigatorState> get navigatorKey => rootNavigatorKey;

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/support-menu',
        name: 'support-menu',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SupportMenuPage(),
      ),
      GoRoute(
        path: '/ad/:slug',
        name: 'product-detail',
        builder: (context, state) {
          final slug = state.pathParameters['slug'] ?? '';
          final favoritesBloc = context.read<FavoritesBloc>();
          final fallbackItem = state.extra;
          return BlocProvider<FavoritesBloc>.value(
            value: favoritesBloc,
            child: ProductDetailPage(slug: slug, fallbackAdItem: fallbackItem),
          );
        },
        routes: [
          GoRoute(
            path: 'order',
            name: 'order',
            builder: (context, state) {
              final raw = state.extra;
              AdDetailEntity? ad;
              int initialQty = 1;
              if (raw is AdDetailEntity) {
                ad = raw;
              } else if (raw is Map) {
                ad = raw['ad'] as AdDetailEntity?;
                final q = raw['quantity'];
                if (q is int && q > 0) initialQty = q;
              }
              if (ad == null) {
                return const SizedBox.shrink();
              }
              return MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (_) =>
                        getIt<AddressBloc>()..add(LoadAddressesEvent()),
                  ),
                  BlocProvider(
                    create: (_) =>
                        getIt<ProfileBloc>()..add(const ProfileLoadEvent()),
                  ),
                ],
                child: OrderPage(ad: ad, initialQuantity: initialQty),
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
        path: '/cart',
        name: 'cart',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const CartPage(),
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const SearchPage(),
      ),
      GoRoute(
        path: '/soon',
        name: 'soon',
        builder: (context, state) => const SoonPage(),
      ),
      GoRoute(
        path: '/add-listing',
        name: 'add-listing',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => BlocProvider<ProfileBloc>(
          create: (_) {
            final bloc = getIt<ProfileBloc>();
            getIt<SecureStorageService>().hasToken().then((hasToken) {
              if (hasToken) bloc.add(const ProfileLoadEvent());
            });
            return bloc;
          },
          child: const AddListingPage(editSlug: null),
        ),
        routes: [
          GoRoute(
            path: ':slug',
            name: 'add-listing-edit',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) {
              final slug = state.pathParameters['slug'] ?? '';
              final fallbackItem = state.extra;
              return BlocProvider<ProfileBloc>(
                create: (_) {
                  final bloc = getIt<ProfileBloc>();
                  getIt<SecureStorageService>().hasToken().then((hasToken) {
                    if (hasToken) bloc.add(const ProfileLoadEvent());
                  });
                  return bloc;
                },
                child: AddListingPage(
                  editSlug: slug.isNotEmpty ? slug : null,
                  editFallbackItem: fallbackItem,
                ),
              );
            },
          ),
        ],
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
          return ScaffoldWithNavBar(currentIndex: currentIndex, child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            pageBuilder: (context, state) => NoTransitionPage(
              key: const ValueKey('shell-home'),
              child: const HomePage(),
            ),
          ),
          GoRoute(
            path: '/catalog',
            name: 'catalog',
            pageBuilder: (context, state) {
              final type = state.uri.queryParameters['type'];
              final idStr = state.uri.queryParameters['categoryId'];
              final id = int.tryParse(idStr ?? '');
              return NoTransitionPage(
                key: ValueKey('shell-catalog-${state.uri}'),
                child: CatalogPage(
                  initialCategoryType: type,
                  initialCategoryId: id != null && id > 0 ? id : null,
                ),
              );
            },
          ),
          GoRoute(
            path: '/favorites',
            name: 'favorites-tab',
            pageBuilder: (context, state) => NoTransitionPage(
              key: const ValueKey('shell-favorites'),
              child: BlocProvider<FavoritesBloc>.value(
                value: context.read<FavoritesBloc>(),
                child: const FavoritesPage(),
              ),
            ),
          ),
          GoRoute(
            path: '/keraklilar',
            name: 'keraklilar',
            pageBuilder: (context, state) => NoTransitionPage(
              key: const ValueKey('shell-keraklilar'),
              child: const KeraklilarPage(),
            ),
            routes: [
              GoRoute(
                path: 'favorites',
                name: 'keraklilar-favorites',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) => BlocProvider<FavoritesBloc>.value(
                  value: context.read<FavoritesBloc>(),
                  child: const FavoritesPage(),
                ),
              ),
              GoRoute(
                path: 'chats',
                name: 'keraklilar-chats',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) => const ChatListPage(),
                routes: [
                  GoRoute(
                    path: 'room',
                    name: 'chat-room',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) {
                      final extra = state.extra as Map<String, dynamic>;
                      return ChatRoomPage(
                        adSlug: extra['adSlug'] as String,
                        participantId: extra['participantId'] as int,
                        participantName: extra['participantName'] as String,
                      );
                    },
                  ),
                ],
              ),
            ],
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
                  create: (_) =>
                      getIt<MyAdsBloc>()
                        ..add(const MyAdsLoadRequested('active'))
                        ..add(const MyAdsLimitInfoRequested()),
                  child: const MyAdsPage(),
                ),
              ),
              GoRoute(
                path: 'my-orders',
                name: 'profile-my-orders',
                builder: (context, state) => const MyOrdersPage(),
              ),
              GoRoute(
                path: 'contracts',
                name: 'profile-contracts',
                builder: (context, state) => const ContractsPage(),
              ),
              GoRoute(
                path: 'contracts/:id',
                name: 'profile-contract-detail',
                builder: (context, state) {
                  final idStr = state.pathParameters['id'] ?? '0';
                  final documentId = int.tryParse(idStr) ?? 0;
                  return DocumentDetailPage(documentId: documentId);
                },
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
                path: 'ai-assistant',
                name: 'ai-assistant',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) => BlocProvider(
                  create: (_) => getIt<AiAssistantBloc>(),
                  child: const AiAssistantPage(),
                ),
              ),
              GoRoute(
                path: 'feedback',
                name: 'profile-feedback',
                builder: (context, state) => FeedbackPage(
                  repository: FeedbackRepository(
                    dio: getIt<DioClient>().dio,
                    getCategories: getIt<GetCategories>(),
                  ),
                ),
              ),
              GoRoute(
                path: 'view-history',
                name: 'profile-view-history',
                builder: (context, state) => const ViewHistoryPage(),
              ),
              GoRoute(
                path: 'support-chat',
                name: 'support-chat',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  final chatRoomId = extra?['chatRoomId'] ?? 0;
                  return MultiBlocProvider(
                    providers: [
                      BlocProvider(
                        create: (_) => getIt<ChatBloc>()
                          ..add(InitializeChatEvent(chatRoomId)),
                      ),
                      BlocProvider.value(
                        value: getIt<ProfileBloc>()
                          ..add(const ProfileLoadEvent()),
                      ),
                    ],
                    child: SupportChatPage(chatRoomId: chatRoomId),
                  );
                },
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

  /// App1 SDK removed, fallback to home.
  static void openApp1(BuildContext context) {
    context.go('/home');
  }

  /// App2 SDK removed, fallback to home.
  static void openApp2(BuildContext context) {
    context.go('/home');
  }

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
    if (location.startsWith('/keraklilar')) {
      return 4;
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
      case 4:
        context.go('/keraklilar');
        break;
    }
  }
}

class ScaffoldWithNavBar extends StatefulWidget {
  const ScaffoldWithNavBar({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  final Widget child;
  final int currentIndex;

  @override
  State<ScaffoldWithNavBar> createState() => _ScaffoldWithNavBarState();
}

class _ScaffoldWithNavBarState extends State<ScaffoldWithNavBar> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final appMode = context.watch<AppModeCubit>().state;
    final selectedColor = appMode.primaryColor;
    final unselectedColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;

    final items = <_NavItem>[
      _NavItem(Icons.home_outlined, Icons.home_rounded, l10n.navHome),
      _NavItem(Icons.grid_view_outlined, Icons.grid_view_rounded, l10n.navCatalog),
      _NavItem(Icons.favorite_border_rounded, Icons.favorite_rounded, l10n.navFavorites),
      _NavItem(Icons.person_outline_rounded, Icons.person_rounded, l10n.navProfile),
      _NavItem(Icons.menu_rounded, Icons.menu_rounded, 'Boshqalar'),
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: widget.child,
      extendBody: true,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: FloatingActionButton(
          backgroundColor: selectedColor,
          elevation: 6,
          onPressed: () => context.push('/add-listing'),
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _LiquidGlassNavBar(
        items: items,
        currentIndex: widget.currentIndex,
        isDark: isDark,
        selectedColor: selectedColor,
        unselectedColor: unselectedColor,
        onTap: (i) => AppRouter._onItemTapped(context, i),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.iconOff, this.iconOn, this.label);
  final IconData iconOff;
  final IconData iconOn;
  final String label;
}

class _LiquidGlassNavBar extends StatelessWidget {
  const _LiquidGlassNavBar({
    required this.items,
    required this.currentIndex,
    required this.isDark,
    required this.selectedColor,
    required this.unselectedColor,
    required this.onTap,
  });

  final List<_NavItem> items;
  final int currentIndex;
  final bool isDark;
  final Color selectedColor;
  final Color unselectedColor;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final glassFill = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.72);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : Colors.white.withValues(alpha: 0.55);

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(36),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              decoration: BoxDecoration(
                color: glassFill,
                borderRadius: BorderRadius.circular(36),
                border: Border.all(color: borderColor, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(items.length, (i) {
                  final isSelected = currentIndex == i;
                  return Flexible(
                    child: _PillNavTab(
                      item: items[i],
                      isSelected: isSelected,
                      selectedColor: selectedColor,
                      unselectedColor: unselectedColor,
                      onTap: () => onTap(i),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PillNavTab extends StatelessWidget {
  const _PillNavTab({
    required this.item,
    required this.isSelected,
    required this.selectedColor,
    required this.unselectedColor,
    required this.onTap,
  });

  final _NavItem item;
  final bool isSelected;
  final Color selectedColor;
  final Color unselectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? selectedColor : unselectedColor;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? item.iconOn : item.iconOff,
                color: color,
                size: 24,
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  item.label,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: color,
                    fontSize: MediaQuery.sizeOf(context).width < 360 ? 10 : 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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

