import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uz_xarid/core/constants/app_assets.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/constants/app_dimens.dart';
import 'package:uz_xarid/core/widgets/app_image.dart';
import 'package:uz_xarid/core/widgets/app_text.dart';
import 'package:uz_xarid/core/widgets/uzxarid_app_bar.dart';
import 'package:uz_xarid/core/widgets/w__container.dart';
import 'package:uz_xarid/core/theme/theme_colors.dart';
import 'package:uz_xarid/core/widgets/w_text_form.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uz_xarid/features/profile/presentation/bloc/address/address_bloc.dart';
import 'package:uz_xarid/features/profile/presentation/bloc/address/address_event.dart';
import 'package:uz_xarid/features/profile/data/model/address_model.dart';
import 'package:latlong2/latlong.dart';

class AddAddressPage extends StatefulWidget {
  final LatLng? coordinates;
  final AddressModel? address;
  const AddAddressPage({super.key, this.coordinates, this.address});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _houseController = TextEditingController();
  final TextEditingController _apartmentController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      final addr = widget.address!;
      _nameController.text = addr.name;
      final parts = addr.address.split(', ');
      if (parts.isNotEmpty) _cityController.text = parts[0];
      if (parts.length > 1) {
        if (parts.length == 2) {
          _streetController.text = parts[1];
        } else {
          _streetController.text = parts
              .sublist(1, parts.length - 1)
              .join(', ');
          _houseController.text = parts.last;
        }
      }
      _apartmentController.text = addr.apartment;
      _landmarkController.text = addr.comment;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _streetController.dispose();
    _houseController.dispose();
    _apartmentController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final Map<String, dynamic> data = {
      "name": _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : "Мой адрес ${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}",
      "address":
          "${_cityController.text}, ${_streetController.text}${_houseController.text.isNotEmpty ? ', ${_houseController.text}' : ''}",
      "apartment": _apartmentController.text,
      "entrance": widget.address?.entrance ?? "",
      "floor": widget.address?.floor ?? "",
      "comment": _landmarkController.text,
      "longitude":
          widget.coordinates?.longitude ?? widget.address?.longitude ?? 0.0,
      "latitude":
          widget.coordinates?.latitude ?? widget.address?.latitude ?? 0.0,
    };

    if (widget.address != null && widget.address?.id != null) {
      context.read<AddressBloc>().add(
        UpdateAddressEvent(widget.address!.id!, data),
      );
    } else {
      context.read<AddressBloc>().add(CreateAddressEvent(data));
    }
  }

  @override
  Widget build(BuildContext context) {
    // final isDark = context.isDark;
    final bodyBg = context.bodyBackground;
    final cardColor = context.cardSurface;
    final textColor = context.textPrimary;
    final textSecondary = context.textSecondary;
    final borderColor = context.borderColor;

    return Scaffold(
      appBar: UzXaridAppBar(onSearchChanged: (query) {}, onMenuTap: () {}),
      backgroundColor: AppColors.primary,
      body: Container(
        color: bodyBg,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.paddingMedium),
            child: Column(
              children: [
                Row(
                  children: [
                    ContainerW(
                      onTap: () => context.pop(),
                      radius: 10,
                      color: cardColor,
                      // border: Border.all(color: borderColor),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: AppImage(
                          path: AppAssets.backDropleft,
                          color: textColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    AppText(
                      text: 'Qayerga yetkazamiz?',
                      fontSize: 24,
                      fontWeight: 700,
                      color: textColor,
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ContainerW(
                            color: cardColor,
                            radius: 16,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(
                                    text: 'Xaritadan manzilni kiriting',
                                    fontSize: 14,
                                    fontWeight: 400,
                                    color: textSecondary,
                                  ),
                                  const SizedBox(height: 24),
                                  ContainerW(
                                    color: cardColor,
                                    radius: 12,
                                    border: Border.all(color: borderColor),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        children: [
                                          ContainerW(
                                            color: AppColors.primary,
                                            radius: 20,
                                            child: const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Icon(
                                                Icons.location_on,
                                                color: AppColors.white,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                AppText(
                                                  text:
                                                      widget.coordinates != null
                                                      ? '${widget.coordinates!.latitude.toStringAsFixed(4)}, ${widget.coordinates!.longitude.toStringAsFixed(4)}'
                                                      : 'Адрес на карте',
                                                  fontSize: 16,
                                                  fontWeight: 600,
                                                  color: textColor,
                                                ),
                                                const SizedBox(height: 4),
                                                AppText(
                                                  text: 'Tanlangan manzil',
                                                  fontSize: 14,
                                                  fontWeight: 400,
                                                  color: textSecondary,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            Icons.chevron_right,
                                            color: textColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ContainerW(
                            color: cardColor,
                            radius: 16,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    WTextField(
                                      controller: _nameController,
                                      title: 'Название адреса',
                                      hintText: 'Дом, Работа, и т.д.',
                                      fillColor: context.surfaceContainer,
                                      borderNoFocusColor: context.borderColor,
                                      validator: (value) =>
                                          value == null || value.trim().isEmpty
                                          ? 'Maydonni to\'ldiring'
                                          : null,
                                    ),
                                    const SizedBox(height: 16),
                                    WTextField(
                                      controller: _cityController,
                                      title: 'Город',
                                      hintText: 'Введите город',
                                      fillColor: context.surfaceContainer,
                                      borderNoFocusColor: context.borderColor,
                                      validator: (value) =>
                                          value == null || value.trim().isEmpty
                                          ? 'Maydonni to\'ldiring'
                                          : null,
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: WTextField(
                                            controller: _streetController,
                                            title: 'Улица',
                                            hintText: 'Введите улицу',
                                            fillColor: context.surfaceContainer,
                                            borderNoFocusColor:
                                                context.borderColor,
                                            validator: (value) =>
                                                value == null ||
                                                    value.trim().isEmpty
                                                ? 'Maydonni to\'ldiring'
                                                : null,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: WTextField(
                                            controller: _houseController,
                                            title: 'Дом',
                                            hintText: 'Дом',
                                            fillColor: context.surfaceContainer,
                                            borderNoFocusColor:
                                                context.borderColor,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: WTextField(
                                            controller: _apartmentController,
                                            title: 'Квартира',
                                            hintText: 'Кв',
                                            fillColor: context.surfaceContainer,
                                            borderNoFocusColor:
                                                context.borderColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    WTextField(
                                      controller: _landmarkController,
                                      title: 'Ориентир',
                                      hintText: 'Укажите ближайший ориентир',
                                      fillColor: context.surfaceContainer,
                                      borderNoFocusColor: context.borderColor,
                                    ),
                                    const SizedBox(height: 48),
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
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: bodyBg,
        child: ContainerW(
          // height: 82,
          width: double.infinity,
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          color: cardColor,
          child: BlocConsumer<AddressBloc, AddressState>(
            listener: (context, state) {
              if (state.status == AddressStatus.createSuccess ||
                  state.status == AddressStatus.updateSuccess) {
                context.pop(true); // Return success
              }
            },
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  color: bodyBg,
                  child: ContainerW(
                    height: 50,
                    onTap: state.status == AddressStatus.loading
                        ? null
                        : _submit,
                    color: AppColors.primary,
                    radius: 12,
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: state.status == AddressStatus.loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: AppColors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : AppText(
                                text: 'Сохранить',
                                fontSize: 16,
                                fontWeight: 600,
                                color: AppColors.white,
                              ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
