import 'dart:developer';
import 'package:get_it/get_it.dart';
import 'package:uz_xarid/features/add_listing/domain/usecases/get_colors.dart';
import 'package:uz_xarid/features/add_listing/domain/usecases/create_ad.dart';
import 'package:uz_xarid/features/add_listing/domain/usecases/get_sizes.dart';
import 'package:uz_xarid/features/add_listing/domain/usecases/update_ad.dart';
import 'package:uz_xarid/features/add_listing/presentation/bloc/add_listing_bloc.dart';
import 'package:uz_xarid/features/author/domain/repositories/author_repository.dart';
import 'package:uz_xarid/features/author/presentation/bloc/author/author_bloc.dart';
import 'package:uz_xarid/features/catalog/domain/usecases/get_categories.dart';
import 'package:uz_xarid/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:uz_xarid/features/product_detail/domain/usecases/get_ad_detail.dart';
import 'package:uz_xarid/features/product_detail/presentation/bloc/product_detail_bloc.dart';
import 'package:uz_xarid/features/product_detail/domain/usecases/get_product_feedbacks.dart';
import 'package:uz_xarid/features/product_detail/domain/usecases/leave_product_feedback.dart';
import 'package:uz_xarid/features/product_detail/presentation/bloc/product_feedback_bloc.dart';
import 'package:uz_xarid/features/profile/domain/usecase/profile_usecase.dart';
import 'package:uz_xarid/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:uz_xarid/features/favorites/domain/usecases/get_favorites_list.dart';
import 'package:uz_xarid/features/favorites/domain/usecases/toggle_favorite.dart';
import 'package:uz_xarid/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:uz_xarid/features/order/presentation/bloc/my_orders/my_orders_bloc.dart';
import 'package:uz_xarid/features/order/presentation/bloc/order_create/order_create_cubit.dart';
import 'package:uz_xarid/features/profile/domain/usecases/delete_my_ad.dart';
import 'package:uz_xarid/features/profile/domain/usecases/get_my_listings.dart';
import 'package:uz_xarid/features/profile/presentation/bloc/address/address_bloc.dart';
import 'package:uz_xarid/features/profile/presentation/bloc/my_ads/my_ads_bloc.dart';
import 'package:uz_xarid/features/profile/presentation/bloc/view_history/view_history_bloc.dart';
import 'package:uz_xarid/features/profile/presentation/bloc/payment/payment_bloc.dart';
import 'package:uz_xarid/features/profile/presentation/bloc/chat/chat_bloc.dart';
import 'package:uz_xarid/features/chat/presentation/bloc/ad_chat_bloc.dart';
import 'package:uz_xarid/features/chat/presentation/bloc/chat_list_bloc.dart';
import 'package:uz_xarid/features/chat/domain/repositories/chat_repository.dart';
import 'package:uz_xarid/features/profile/domain/repositories/profile_repository.dart';
import 'package:uz_xarid/core/service/local_service.dart';

import 'package:uz_xarid/features/cart/domain/usecases/add_to_cart.dart';
import 'package:uz_xarid/features/cart/domain/usecases/cart_operations.dart';
import 'package:uz_xarid/features/cart/domain/usecases/get_cart.dart';
import 'package:uz_xarid/features/cart/domain/usecases/update_cart_quantity.dart';
import 'package:uz_xarid/features/cart/presentation/bloc/cart_bloc.dart';

Future<void> registerBlocs(GetIt getIt) async {
  getIt
    ..registerLazySingleton<CartBloc>(
      () => CartBloc(
        getCartItemsUseCase: getIt<GetCartItemsUseCase>(),
        addToCartUseCase: getIt<AddToCartUseCase>(),
        updateCartQuantityUseCase: getIt<UpdateCartQuantityUseCase>(),
        removeFromCartItemUseCase: getIt<RemoveFromCartItemUseCase>(),
        clearCartUseCase: getIt<ClearCartUseCase>(),
        checkoutUseCase: getIt<CheckoutUseCase>(),
      ),
    )
    ..registerFactory<AddListingBloc>(
      () => AddListingBloc(
        getIt<GetColors>(),
        getIt<GetSizes>(),
        getIt<GetCategories>(),
        getIt<CreateAd>(),
        getIt<UpdateAd>(),
        getIt<GetAdDetail>(),
      ),
    )
    ..registerFactory<ProductDetailBloc>(
      () => ProductDetailBloc(getIt<GetAdDetail>()),
    )
    ..registerFactory<ProductFeedbackBloc>(
      () => ProductFeedbackBloc(
        getIt<GetProductFeedbacks>(),
        getIt<LeaveProductFeedback>(),
      ),
    )
    ..registerFactory<ProfileBloc>(
      () => ProfileBloc(
        getIt<ProfileConfirmOtpUsecase>(),
        getIt<ProfileSendOtpUsecase>(),
        getIt<ProfileSignSubmitUsecase>(),
        getIt<ProfileGetUsecase>(),
        getIt<ProfileResendOtpUsecase>(),
        getIt<ProfileUpdateUsecase>(),
        getIt<ProfileCreateBusinessUsecase>(),
        getIt<ProfileUpdateBusinessUsecase>(),
      ),
    )
    ..registerFactory<CatalogBloc>(
      () => CatalogBloc(getIt<GetCategories>(), getIt<GetCategoriesParams>()),
    )
    ..registerFactory<FavoritesBloc>(
      () => FavoritesBloc(getIt<GetFavoritesList>(), getIt<ToggleFavorite>()),
    )
    ..registerFactory<AddressBloc>(
      () => AddressBloc(
        getAddressesUsecase: getIt<ProfileGetAddressesUsecase>(),
        createAddressUsecase: getIt<ProfileCreateAddressUsecase>(),
        updateAddressUsecase: getIt<ProfileUpdateAddressUsecase>(),
        deleteAddressUsecase: getIt<ProfileDeleteAddressUsecase>(),
      ),
    )
    ..registerFactory<AuthorBloc>(
      () => AuthorBloc(repository: getIt<AuthorRepository>()),
    )
    ..registerFactory<OrderCreateCubit>(
      () => OrderCreateCubit(repository: getIt()),
    )
    ..registerFactory<MyOrdersBloc>(() => MyOrdersBloc(repository: getIt()))
    ..registerFactory<MyAdsBloc>(
      () => MyAdsBloc(getIt<GetMyListings>(), getIt<DeleteMyAd>()),
    )
    ..registerFactory<ViewHistoryBloc>(
      () => ViewHistoryBloc(repository: getIt<ProfileRepository>()),
    )
    ..registerFactory<PaymentBloc>(
      () => PaymentBloc(repository: getIt<ProfileRepository>()),
    )
    ..registerFactory<ChatBloc>(
      () => ChatBloc(repository: getIt<ProfileRepository>()),
    )
    ..registerFactory<AdChatBloc>(
      () => AdChatBloc(
        repository: getIt<ChatRepository>(),
        storage: getIt<SecureStorageService>(),
      ),
    )
    ..registerFactory<ChatListBloc>(
      () => ChatListBloc(getIt<ChatRepository>()),
    );

  log("Register BLOC Complate For GetIT");
}
