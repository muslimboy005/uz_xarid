import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:latlong2/latlong.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/cubit/app_mode_cubit.dart';
import 'package:uz_xarid/core/dio/dio_client.dart';
import 'package:uz_xarid/core/dp/infection.dart';
import 'package:uz_xarid/core/service/local_service.dart';
import 'package:uz_xarid/features/home/presentation/pages/home_page.dart';
import 'package:uz_xarid/features/catalog/presentation/pages/catalog_page.dart';
import 'package:uz_xarid/features/catalog/domain/usecases/get_categories.dart';
import 'package:uz_xarid/features/product_list/domain/entities/subcategory_item.dart';
import 'package:uz_xarid/features/product_list/presentation/pages/product_list_page.dart';
import 'package:uz_xarid/features/profile/data/model/address_model.dart';
import 'package:uz_xarid/features/profile/presentation/bloc/address/address_event.dart';
import 'package:uz_xarid/features/search/presentation/pages/search_page.dart';
import 'package:uz_xarid/features/cart/presentation/pages/cart_page.dart';
import 'package:uz_xarid/features/favorites/presentation/pages/favorites_page.dart';
import 'package:uz_xarid/features/favorites/presentation/pages/keraklilar_page.dart';
import 'package:uz_xarid/features/chat/presentation/pages/chat_list_page.dart';
import 'package:uz_xarid/features/chat/presentation/pages/chat_room_page.dart';
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
import 'package:uz_xarid/features/profile/presentation/pages/support_chat_page.dart';
import 'package:uz_xarid/features/profile/presentation/bloc/chat/chat_bloc.dart';
import 'package:uz_xarid/features/profile/presentation/bloc/chat/chat_event.dart';
import 'package:uz_xarid/features/contracts/presentation/pages/contracts_page.dart';
import 'package:uz_xarid/features/contracts/presentation/pages/document_detail_page.dart';
import 'package:uz_xarid/features/add_listing/presentation/pages/add_listing_page.dart';
import 'package:uz_xarid/features/add_listing/presentation/pages/soon_page.dart';
import 'package:uz_xarid/features/author/presentation/pages/author_page.dart';
import 'package:uz_xarid/features/author/presentation/bloc/author/author_bloc.dart';
import 'package:uz_xarid/features/feedback/data/feedback_repository.dart';
import 'package:uz_xarid/features/feedback/presentation/pages/feedback_page.dart';
import 'package:uz_xarid/features/home/presentation/pages/support_menu_page.dart';
import 'package:uz_xarid/l10n/app_localizations.dart';

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
              final ad = state.extra as AdDetailEntity?;
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
            path: '/add-listing',
            name: 'add-listing',
            pageBuilder: (context, state) => NoTransitionPage(
              key: const ValueKey('shell-add-listing'),
              child: BlocProvider<ProfileBloc>(
                create: (_) {
                  final bloc = getIt<ProfileBloc>();
                  getIt<SecureStorageService>().hasToken().then((hasToken) {
                    if (hasToken) bloc.add(const ProfileLoadEvent());
                  });
                  return bloc;
                },
                child: const AddListingPage(editSlug: null),
              ),
            ),
            routes: [
              GoRoute(
                path: ':slug',
                name: 'add-listing-edit',
                pageBuilder: (context, state) {
                  final slug = state.pathParameters['slug'] ?? '';
                  final fallbackItem = state.extra;
                  return NoTransitionPage(
                    key: ValueKey('shell-add-listing-edit-$slug'),
                    child: BlocProvider<ProfileBloc>(
                      create: (_) {
                        final bloc = getIt<ProfileBloc>();
                        getIt<SecureStorageService>().hasToken().then((
                          hasToken,
                        ) {
                          if (hasToken) bloc.add(const ProfileLoadEvent());
                        });
                        return bloc;
                      },
                      child: AddListingPage(
                        editSlug: slug.isNotEmpty ? slug : null,
                        editFallbackItem: fallbackItem,
                      ),
                    ),
                  );
                },
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
                        ..add(const MyAdsLoadRequested('active')),
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
                          ..add(GetChatMessagesEvent(chatRoomId: chatRoomId)),
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
    if (location.startsWith('/add-listing')) {
      return 2;
    }
    if (location.startsWith('/keraklilar')) {
      return 3;
    }
    if (location.startsWith('/profile')) {
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
        context.go('/add-listing');
        break;
      case 3:
        context.go('/keraklilar');
        break;
      case 4:
        context.go('/profile');
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
  late NotchBottomBarController _controller;
  int? _lastColorArgb;

  @override
  void initState() {
    super.initState();
    _controller = NotchBottomBarController(index: widget.currentIndex);
  }

  @override
  void didUpdateWidget(covariant ScaffoldWithNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _controller.jumpTo(widget.currentIndex);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final appMode = context.watch<AppModeCubit>().state;
    final barColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final selectedColor = appMode.primaryColor;
    final unselectedColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;

    if (_lastColorArgb != null && _lastColorArgb != selectedColor.toARGB32()) {
      final oldController = _controller;
      _controller = NotchBottomBarController(index: widget.currentIndex);
      oldController.dispose();
    }
    _lastColorArgb = selectedColor.toARGB32();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: widget.child,
      extendBody: false,
      bottomNavigationBar: SafeArea(
        child: AnimatedNotchBottomBar(
          key: ValueKey(selectedColor.toARGB32()),
          notchBottomBarController: _controller,
          color: barColor,
          showLabel: true,
          notchColor: selectedColor,
          removeMargins: true,
          showBottomRadius: false,
          showTopRadius: false,
          bottomBarWidth: 500.0,
          showShadow: true,
          durationInMilliSeconds: 300,
          elevation: 8,
          kBottomRadius: 28.0,
          kIconSize: 24.0,
          itemLabelStyle: TextStyle(
            color: unselectedColor,
            fontSize: 10.0,
            fontWeight: FontWeight.w500,
          ),
          bottomBarItems: [
            BottomBarItem(
              inActiveItem: Icon(Icons.home_outlined, color: unselectedColor),
              activeItem: const Icon(Icons.home_filled, color: Colors.white),
              itemLabel: l10n.navHome,
            ),
            BottomBarItem(
              inActiveItem: Icon(Icons.menu, color: unselectedColor),
              activeItem: const Icon(Icons.menu, color: Colors.white),
              itemLabel: l10n.navCatalog,
            ),
            // Add Listing - markazda
            BottomBarItem(
              inActiveItem: Icon(
                Icons.add_circle_outline,
                color: unselectedColor,
              ),
              activeItem: const Icon(Icons.add, color: Colors.white),
              itemLabel: 'Qo\'shish',
            ),
            BottomBarItem(
              inActiveItem: Icon(Icons.star_border, color: unselectedColor),
              activeItem: const Icon(Icons.star, color: Colors.white),
              itemLabel: 'Keraklilar',
            ),
            BottomBarItem(
              inActiveItem: Icon(Icons.person_outline, color: unselectedColor),
              activeItem: const Icon(Icons.person, color: Colors.white),
              itemLabel: l10n.navProfile,
            ),
          ],
          onTap: (index) {
            AppRouter._onItemTapped(context, index);
          },
        ),
      ),
    );
  }
}

