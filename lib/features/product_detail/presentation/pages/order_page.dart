import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uzxarid/core/constants/app_colors.dart';
import 'package:uzxarid/core/constants/app_assets.dart';
import 'package:uzxarid/core/cubit/app_mode_cubit.dart';
import 'package:uzxarid/core/theme/theme_colors.dart';
import 'package:uzxarid/core/utils/image_parser.dart';
import 'package:uzxarid/core/utils/price_formatter.dart';
import 'package:uzxarid/core/widgets/app_image.dart';
import 'package:uzxarid/core/widgets/app_text.dart';
import 'package:uzxarid/core/widgets/w__container.dart';
import 'package:uzxarid/features/currency/domain/currency.dart';
import 'package:uzxarid/features/currency/presentation/cubit/currency_cubit.dart';
import 'package:uzxarid/features/product_detail/domain/entities/ad_detail_entity.dart';
import 'package:uzxarid/features/order/data/models/order_create_dto.dart';
import 'package:uzxarid/features/order/presentation/bloc/order_create/order_create_cubit.dart';
import 'package:uzxarid/features/order/presentation/bloc/order_create/order_create_state.dart';
import 'package:uzxarid/features/profile/data/model/address_model.dart';
import 'package:uzxarid/core/dp/infection.dart';
import 'package:uzxarid/features/profile/presentation/bloc/address/address_bloc.dart';
import 'package:uzxarid/features/profile/presentation/bloc/address/address_event.dart';
import 'package:uzxarid/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:uzxarid/l10n/app_localizations.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key, required this.ad});

  final AdDetailEntity? ad;

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  int _quantity = 1;
  bool _sendToAll = false;
  final _commentCtrl = TextEditingController();
  AddressModel? _selectedAddress;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.ad == null) {
      return const Scaffold(body: Center(child: Text('Mahsulot topilmadi')));
    }
    final ad = widget.ad!;
    final primaryColor = context.watch<AppModeCubit>().state.primaryColor;
    final AppLocalizations l = AppLocalizations.of(context)!;
    final bg = context.bodyBackground;
    final card = context.cardSurface;
    final txt = context.textPrimary;
    final txtSec = context.textSecondary;
    final border = context.borderColor;

    final selectedCcy = context.watch<CurrencyCubit>().state.selectedCcy;
    final curr = currencyDisplayLabel(selectedCcy);
    final price = formatPrice(ad.finalPrice ?? ad.price);

    return BlocProvider(
      create: (context) => getIt<OrderCreateCubit>(), // Fixed locator call
      child: BlocConsumer<OrderCreateCubit, OrderCreateState>(
        listener: (context, state) {
          if (state is OrderCreateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Muvaffaqiyatli!',
                ), // l.actionSuccess might not exist
                backgroundColor: primaryColor,
              ),
            );
            context.go('/home');
          } else if (state is OrderCreateFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is OrderCreateLoading;
          return Scaffold(
            backgroundColor: bg,
            appBar: AppBar(
              backgroundColor: card,
              surfaceTintColor: card,
              elevation: 0,
              centerTitle: false,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () => context.pop(),
                color: txt,
              ),
              title: Text(
                l.orderSubmit,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: txt,
                ),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                children: [
                  _productCard(
                    ad,
                    price,
                    curr,
                    l,
                    card,
                    txt,
                    txtSec,
                    border,
                    primaryColor,
                  ),
                  const SizedBox(height: 16),
                  _deliveryCard(l, card, txt, txtSec, border, primaryColor),
                  const SizedBox(height: 16),
                  _commentCard(l, card, txt, border, primaryColor),
                ],
              ),
            ),
            bottomNavigationBar: _bottomBar(
              l,
              card,
              txt,
              border,
              isLoading,
              primaryColor,
            ),
          );
        },
      ),
    );
  }

  Widget _productCard(
    AdDetailEntity ad,
    String price,
    String curr,
    AppLocalizations l,
    Color card,
    Color txt,
    Color txtSec,
    Color border,
    Color primaryColor,
  ) {
    final img = ad.mainImage ?? (ad.images.isNotEmpty ? ad.images.first : null);

    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _img(img, txtSec),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ad.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: txt,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$price $curr',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700, color: txt),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(color: border, height: 1, thickness: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: _qtyRow(txt),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                Transform.scale(
                  scale: 0.7,
                  child: Switch(
                    value: _sendToAll,
                    onChanged: (v) => setState(() => _sendToAll = v),
                    activeThumbColor: primaryColor,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.orderSendToAllAds,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: txt),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _img(String? url, Color txtSec) {
    const size = 76.0;
    if (url != null && url.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: url.cdnUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          width: size,
          height: size,
          color: context.surfaceContainer,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (_, __, ___) => Container(
          width: size,
          height: size,
          color: context.surfaceContainer,
          child: Icon(Icons.image_not_supported, color: txtSec, size: 24),
        ),
      );
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.image, color: txtSec, size: 24),
    );
  }

  Widget _qtyRow(Color txt) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Miqdori:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: txt),
        ),
        Row(
          children: [
            _qtyBtn(Icons.remove, () {
              if (_quantity > 1) {
                setState(() => _quantity--);
              }
            }, txt),
            const SizedBox(width: 12),
            Text(
              '$_quantity',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: txt,
              ),
            ),
            const SizedBox(width: 12),
            _qtyBtn(Icons.add, () {
              setState(() => _quantity++);
            }, txt),
          ],
        ),
      ],
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap, Color txt) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: context.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: txt),
      ),
    );
  }

  Widget _deliveryCard(
    AppLocalizations l,
    Color card,
    Color txt,
    Color txtSec,
    Color border,
    Color primaryColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.orderDelivery,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: txt,
            ),
          ),
          const SizedBox(height: 12),
          BlocBuilder<AddressBloc, AddressState>(
            builder: (context, state) {
              if (state.status == AddressStatus.loading &&
                  state.addresses.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (state.addresses.isEmpty) {
                return _buildEmptyAddressState(l, txt, txtSec, primaryColor);
              }

              return _buildAddressList(
                state.addresses,
                primaryColor,
                card,
                txt,
                txtSec,
                border,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyAddressState(
    AppLocalizations l,
    Color txt,
    Color txtSec,
    Color primaryColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on,
              size: 26,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            l.orderAddressNotSelected,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: txt,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            l.orderSelectDeliveryAddress,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: txtSec),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final result = await context.push('/add-address');
              if (result == true && context.mounted) {
                context.read<AddressBloc>().add(LoadAddressesEvent());
              }
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 0,
            ),
            child: Text(
              l.orderSelectAddress,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressList(
    List<AddressModel> addresses,
    Color primaryColor,
    Color cardColor,
    Color textColor,
    Color textSecondary,
    Color borderColor,
  ) {
    if (_selectedAddress == null ||
        !addresses.any((a) => a.id == _selectedAddress!.id)) {
      if (addresses.isNotEmpty) {
        // Safe to mutate state here if we schedule a post-frame callback, or simply update on tap.
        // We'll trust flutter to handle the first build correctly or we should initialize it.
        _selectedAddress = addresses.first;
      }
    }

    return Column(
      children: [
        ContainerW(
          width: double.infinity,
          onTap: () async {
            final result = await context.push('/add-address');
            if (result == true && context.mounted) {
              context.read<AddressBloc>().add(LoadAddressesEvent());
            }
          },
          color: primaryColor,
          radius: 8,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add, color: AppColors.white, size: 20),
                const SizedBox(width: 8),
                AppText(
                  text: AppLocalizations.of(context)!.addressAdd,
                  fontSize: 16,
                  fontWeight: 500,
                  color: AppColors.white,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: addresses.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final address = addresses[index];
            final isSelected = _selectedAddress?.id == address.id;

            return ContainerW(
              onTap: () {
                setState(() {
                  _selectedAddress = address;
                });
              },
              color: isSelected
                  ? primaryColor.withValues(alpha: 0.04)
                  : cardColor,
              radius: 12,
              border: Border.all(
                color: isSelected ? primaryColor : borderColor,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: AppImage(
                        path: AppAssets.mapLocation,
                        color: primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            text: address.name.isNotEmpty
                                ? address.name
                                : AppLocalizations.of(context)!.addressIndexLabel(index + 1),
                            fontSize: 16,
                            fontWeight: 600,
                            color: textColor,
                          ),
                          const SizedBox(height: 4),
                          AppText(
                            text: address.address,
                            fontSize: 14,
                            fontWeight: 400,
                            color: textSecondary,
                          ),
                        ],
                      ),
                    ),
                    Radio(
                      value: true,
                      groupValue: isSelected,
                      onChanged: (_) {
                        setState(() {
                          _selectedAddress = address;
                        });
                      },
                      activeColor: primaryColor,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _commentCard(
    AppLocalizations l,
    Color card,
    Color txt,
    Color border,
    Color primaryColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.orderComment,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: txt,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _commentCtrl,
            maxLines: 4,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: txt),
            decoration: InputDecoration(
              hintText: l.orderCommentHint,
              hintStyle: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: context.textSecondary),
              filled: true,
              fillColor: context.surfaceContainer,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: primaryColor, width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(14),
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomBar(
    AppLocalizations l,
    Color card,
    Color txt,
    Color border,
    bool isLoading,
    Color primaryColor,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: card,
        border: Border(top: BorderSide(color: border, width: 0.5)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: OutlinedButton(
                onPressed: () => context.pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: txt,
                  side: BorderSide(color: border),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l.actionCancel,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: txt,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: BlocBuilder<OrderCreateCubit, OrderCreateState>(
                builder: (context, state) {
                  final profileState = context.watch<ProfileBloc>().state;
                  final isProfileLoading =
                      profileState.status == ProfileStatus.loading;
                  final user = profileState.profileModel?.data.user;
                  final hasProfileNames =
                      user != null && user.firstName.isNotEmpty;

                  return ElevatedButton(
                    onPressed:
                        isLoading ||
                            isProfileLoading ||
                            _selectedAddress == null ||
                            !hasProfileNames
                        ? null
                        : () {
                            FocusScope.of(context).unfocus();
                            final profile = context
                                .read<ProfileBloc>()
                                .state
                                .profileModel
                                ?.data
                                .user;
                            final req = OrderCreateDto(
                              adSlug: widget.ad!.slug,
                              quantity: _quantity,
                              firstName: profile?.firstName ?? '',
                              lastName: profile?.lastName ?? '',
                              addressId: _selectedAddress!.id ?? 0,
                              showSimilarProducts: _sendToAll,
                              notes: _commentCtrl.text.trim(),
                            );
                            context.read<OrderCreateCubit>().createOrder(req);
                          },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: AppColors.white,
                      backgroundColor: primaryColor,
                      disabledBackgroundColor: primaryColor.withValues(
                        alpha: 0.5,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: AppColors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            l.orderSubmit,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.white,
                                ),
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
