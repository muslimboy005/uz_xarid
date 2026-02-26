import 'dart:developer';
import 'package:get_it/get_it.dart';
import 'package:uz_xarid/features/catalog/domain/usecases/get_categories.dart';
import 'package:uz_xarid/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:uz_xarid/features/product_detail/domain/usecases/get_ad_detail.dart';
import 'package:uz_xarid/features/product_detail/presentation/bloc/product_detail_bloc.dart';
import 'package:uz_xarid/features/profile/domain/usecase/profile_usecase.dart';
import 'package:uz_xarid/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:uz_xarid/features/profile/presentation/bloc/address/address_bloc.dart';

Future<void> registerBlocs(GetIt getIt) async {
  getIt
    ..registerFactory<ProductDetailBloc>(
      () => ProductDetailBloc(getIt<GetAdDetail>()),
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
    ..registerFactory<AddressBloc>(
      () => AddressBloc(
        getAddressesUsecase: getIt<ProfileGetAddressesUsecase>(),
        createAddressUsecase: getIt<ProfileCreateAddressUsecase>(),
        updateAddressUsecase: getIt<ProfileUpdateAddressUsecase>(),
        deleteAddressUsecase: getIt<ProfileDeleteAddressUsecase>(),
      ),
    );

  log("Register BLOC Complate For GetIT");
}
