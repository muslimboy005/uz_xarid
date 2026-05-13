import 'dart:developer';

import 'package:get_it/get_it.dart';
import 'package:uzxarid/core/dio/dio_client.dart';
import 'package:uzxarid/core/service/local_service.dart';
import 'package:uzxarid/core/service/chat_socket_service.dart';
import 'package:uzxarid/features/favorites/data/datasources/favorites_api.dart';
import 'package:uzxarid/features/favorites/data/datasources/favorites_local_datasource.dart';
import 'package:uzxarid/features/catalog/data/datasources/catalog_api.dart';
import 'package:uzxarid/features/catalog/data/datasources/category_children_api.dart';
import 'package:uzxarid/features/catalog/data/repositories/catalog_repository_impl.dart';
import 'package:uzxarid/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:uzxarid/features/home/data/datasources/home_api.dart';
import 'package:uzxarid/features/product_detail/data/datasources/product_detail_api.dart';
import 'package:uzxarid/features/product_detail/data/repositories/product_detail_repository_impl.dart';
import 'package:uzxarid/features/product_detail/domain/repositories/product_detail_repository.dart';
import 'package:uzxarid/features/product_list/data/datasources/product_list_remote_datasource.dart';
import 'package:uzxarid/features/product_list/data/repositories/product_list_repository_impl.dart';
import 'package:uzxarid/features/product_list/domain/repositories/product_list_repository.dart';
import 'package:uzxarid/features/add_listing/data/datasources/listing_api.dart';
import 'package:uzxarid/features/add_listing/data/repositories/listing_repository_impl.dart';
import 'package:uzxarid/features/add_listing/domain/repositories/listing_repository.dart';
import 'package:uzxarid/features/profile/data/datasource/profile_datasource.dart';
import 'package:uzxarid/features/profile/data/repositories/my_listings_repository_impl.dart';
import 'package:uzxarid/features/profile/domain/repositories/my_listings_repository.dart';
import 'package:uzxarid/features/profile/domain/repositories/profile_repository.dart';
import 'package:uzxarid/features/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:uzxarid/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:uzxarid/features/author/data/datasources/author_api.dart';
import 'package:uzxarid/features/author/data/repositories/author_repository_impl.dart';
import 'package:uzxarid/features/author/domain/repositories/author_repository.dart';
import 'package:uzxarid/features/order/data/datasources/order_api.dart';
import 'package:uzxarid/features/order/data/repositories/order_repository_impl.dart';
import 'package:uzxarid/features/order/domain/repositories/order_repository.dart';
import 'package:uzxarid/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:uzxarid/features/chat/domain/repositories/chat_repository.dart';
import 'package:uzxarid/features/chat/data/datasources/chat_api.dart';

import 'package:uzxarid/features/cart/data/datasources/cart_remote_data_source.dart';
import 'package:uzxarid/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:uzxarid/features/cart/domain/repositories/cart_repository.dart';

Future<void> registerRepositories(GetIt getIt) async {
  getIt
    ..registerLazySingleton<CartRepository>(
      () => CartRepositoryImpl(remoteDataSource: getIt<CartRemoteDataSource>()),
    )
    ..registerLazySingleton<ListingRepository>(
      () => ListingRepositoryImpl(
        api: getIt<ListingApi>(),
        dio: getIt<DioClient>().dio,
      ),
    )
    ..registerLazySingleton<CatalogRepository>(
      () => CatalogRepositoryImpl(
        homeApi: getIt<HomeApi>(),
        catalogApi: getIt<CatalogApi>(),
        categoryChildrenApi: getIt<CategoryChildrenApi>(),
        dio: getIt<DioClient>().dio,
      ),
    )
    ..registerLazySingleton<ProductDetailRepository>(
      () => ProductDetailRepositoryImpl(api: getIt<ProductDetailApi>()),
    )
    ..registerLazySingleton<ProductListRepository>(
      () => ProductListRepositoryImpl(getIt<ProductListRemoteDatasource>()),
    )
    ..registerLazySingleton(
      () => ProfileRepository(getIt<ProfileApi>(), getIt<DioClient>().dio),
    )
    ..registerLazySingleton<MyListingsRepository>(
      () => MyListingsRepositoryImpl(dio: getIt<DioClient>().dio),
    )
    ..registerLazySingleton<FavoritesRepository>(
      () => FavoritesRepositoryImpl(
        api: getIt<FavoritesApi>(),
        localDatasource: getIt<FavoritesLocalDatasource>(),
        secureStorage: getIt<SecureStorageService>(),
      ),
    )
    ..registerLazySingleton<AuthorRepository>(
      () => AuthorRepositoryImpl(remoteDataSource: getIt<AuthorApi>()),
    )
    ..registerLazySingleton<OrderRepository>(
      () => OrderRepositoryImpl(api: getIt<OrderApi>()),
    )
    ..registerLazySingleton<ChatRepository>(
      () => ChatRepositoryImpl(getIt<ChatApi>(), getIt<ChatSocketService>()),
    );
  log("Register Repositories Complate For GetIT");
}
