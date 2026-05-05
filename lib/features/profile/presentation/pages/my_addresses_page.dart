import 'package:flutter/material.dart';
import 'package:uz_xarid/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uz_xarid/features/profile/presentation/bloc/address/address_bloc.dart';
import 'package:uz_xarid/features/profile/presentation/bloc/address/address_event.dart';
import 'package:go_router/go_router.dart';
import 'package:uz_xarid/core/constants/app_assets.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/constants/app_dimens.dart';
import 'package:uz_xarid/core/cubit/app_mode_cubit.dart';
import 'package:uz_xarid/core/widgets/app_image.dart';
import 'package:uz_xarid/core/widgets/app_text.dart';
import 'package:uz_xarid/core/theme/theme_colors.dart';
import 'package:uz_xarid/core/widgets/uzxarid_app_bar.dart';
import 'package:uz_xarid/core/widgets/w__container.dart';

class MyAddressesPage extends StatefulWidget {
  const MyAddressesPage({super.key});

  @override
  State<MyAddressesPage> createState() => _MyAddressesPageState();
}

class _MyAddressesPageState extends State<MyAddressesPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final primaryColor = context.watch<AppModeCubit>().state.primaryColor;
    final l10n = AppLocalizations.of(context)!;
    // final bodyBg = context.bodyBackground;
    final cardColor = context.cardSurface;
    final textColor = context.textPrimary;
    final textSecondary = context.textSecondary;

    return Scaffold(
      appBar: UzXaridAppBar(onSearchChanged: (query) {}, onMenuTap: () {}),

      body: Container(
        color: isDark ? AppColors.darkBackground : AppColors.black50,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: ContainerW(
                        color: cardColor,
                        radius: 8,
                        // borderColor: AppColors.black100,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: AppImage(
                            path: AppAssets.backDropleft,
                            color: textColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    AppText(
                      text: l10n.addressMyAddressesTitle,
                      fontSize: 20,
                      fontWeight: 700,
                      color: textColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.paddingMedium,
                  ),
                  child: BlocBuilder<AddressBloc, AddressState>(
                    builder: (context, state) {
                      if (state.status == AddressStatus.loading &&
                          state.addresses.isEmpty) {
                        return Center(
                          child: CircularProgressIndicator(color: primaryColor),
                        );
                      }

                      if (state.status == AddressStatus.failure &&
                          state.addresses.isEmpty) {
                        return Center(
                          child: AppText(
                            text: state.errorMessage ?? 'Xatolik yuz berdi',
                            color: AppColors.red,
                          ),
                        );
                      }

                      if (state.addresses.isEmpty &&
                          (state.status == AddressStatus.success ||
                              state.status == AddressStatus.initial)) {
                        return _buildEmptyState(
                          context,
                          primaryColor,
                          cardColor,
                          textColor,
                          textSecondary,
                        );
                      }

                      if (state.addresses.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return Column(
                        children: [
                          ContainerW(
                            width: double.infinity,
                            onTap: () async {
                              final result = await context.push('/add-address');
                              if (result == true && context.mounted) {
                                context.read<AddressBloc>().add(
                                  LoadAddressesEvent(),
                                );
                              }
                            },
                            color: primaryColor,
                            radius: 8,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.add,
                                    color: AppColors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  AppText(
                                    text: l10n.addressAdd,
                                    fontSize: 16,
                                    fontWeight: 500,
                                    color: AppColors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: ListView.separated(
                              itemCount: state.addresses.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final address = state.addresses[index];
                                final isSelected =
                                    index == 0; // Mock selection logic
                                return ContainerW(
                                  color: isSelected
                                      ? primaryColor.withValues(alpha: 0.04)
                                      : cardColor,
                                  radius: 12,
                                  border: Border.all(
                                    color: isSelected
                                        ? primaryColor
                                        : (context.borderColor),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 2,
                                              ),
                                              child: AppImage(
                                                path: AppAssets.mapLocation,
                                                color: primaryColor,
                                                size: 24,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  AppText(
                                                    text:
                                                        address.name.isNotEmpty
                                                        ? address.name
                                                        : l10n.addressIndexLabel(index + 1),
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
                                              onChanged: (_) {},
                                              activeColor: primaryColor,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            ContainerW(
                                              color: AppColors.red.withOpacity(
                                                0.1,
                                              ),
                                              radius: 8,
                                              onTap: () {
                                                if (address.id == null) return;
                                                showDialog(
                                                  context: context,
                                                  builder: (dialogContext) {
                                                    return AlertDialog(
                                                      title: const Text(
                                                        'Tasdiqlash',
                                                      ),
                                                      content: const Text(
                                                        'Ushbu manzilni o`chirishni xohlaysizmi?',
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                dialogContext,
                                                              ),
                                                          child: const Text(
                                                            'Bekor qilish',
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                              dialogContext,
                                                            );
                                                            context
                                                                .read<
                                                                  AddressBloc
                                                                >()
                                                                .add(
                                                                  DeleteAddressEvent(
                                                                    address.id!,
                                                                  ),
                                                                );
                                                          },
                                                          child: const Text(
                                                            'O`chirish',
                                                            style: TextStyle(
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                              child: const Padding(
                                                padding: EdgeInsets.all(12.0),
                                                child: Icon(
                                                  Icons.delete_outline,
                                                  color: AppColors.red,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: ContainerW(
                                                color: primaryColor,
                                                radius: 8,
                                                onTap: () async {
                                                  final result = await context
                                                      .pushNamed(
                                                        'profile-add-address',
                                                        extra: address,
                                                      );
                                                  if (result == true &&
                                                      context.mounted) {
                                                    context
                                                        .read<AddressBloc>()
                                                        .add(
                                                          LoadAddressesEvent(),
                                                        );
                                                  }
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 12,
                                                      ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      const Icon(
                                                        Icons.edit,
                                                        color: AppColors.white,
                                                        size: 16,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      AppText(
                                                        text: l10n.addressEdit,
                                                        color: AppColors.white,
                                                        fontSize: 14,
                                                        fontWeight: 500,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    Color primaryColor,
    Color cardColor,
    Color textColor,
    Color textSecondary,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return ContainerW(
      width: double.infinity,
      color: cardColor,
      radius: 12,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ContainerW(
            color: primaryColor,
            radius: 12,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: AppImage(
                path: AppAssets.locationOn,
                color: AppColors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: 24),
          AppText(
            text: l10n.addressAddOwn,
            fontSize: 20,
            fontWeight: 700,
            color: textColor,
          ),
          const SizedBox(height: 8),
          AppText(
            text: l10n.addressAddOwnSub,
            fontSize: 14,
            fontWeight: 400,
            color: textSecondary,
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
          const SizedBox(height: 24),
          ContainerW(
            onTap: () async {
              final result = await context.push('/add-address');
              if (result == true && context.mounted) {
                context.read<AddressBloc>().add(LoadAddressesEvent());
              }
            },
            color: primaryColor,
            radius: 8,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add, color: AppColors.white, size: 20),
                  const SizedBox(width: 8),
                  AppText(
                    text: l10n.addressAdd,
                    fontSize: 16,
                    fontWeight: 500,
                    color: AppColors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
