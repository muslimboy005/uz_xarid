import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:uzxarid/core/constants/app_assets.dart';
import 'package:uzxarid/core/constants/app_colors.dart';
import 'package:uzxarid/core/constants/app_dimens.dart';
import 'package:uzxarid/core/constants/app_keys.dart';
import 'package:uzxarid/core/cubit/app_mode_cubit.dart';
import 'package:uzxarid/core/dp/infection.dart';
import 'package:uzxarid/core/theme/theme_colors.dart';
import 'package:uzxarid/core/widgets/app_image.dart';
import 'package:uzxarid/core/widgets/app_text.dart';
import 'package:uzxarid/core/widgets/uzxarid_app_bar.dart';
import 'package:uzxarid/core/widgets/w__container.dart';
import 'package:uzxarid/core/widgets/w_text_form.dart';
import 'package:uzxarid/features/add_listing/domain/entities/location_place_entity.dart';
import 'package:uzxarid/features/add_listing/domain/repositories/listing_repository.dart';
import 'package:uzxarid/features/profile/data/model/address_model.dart';
import 'package:uzxarid/features/profile/presentation/bloc/address/address_bloc.dart';
import 'package:uzxarid/features/profile/presentation/bloc/address/address_event.dart';
import 'package:uzxarid/l10n/app_localizations.dart';

class AddAddressPage extends StatefulWidget {
  final LatLng? coordinates;
  final AddressModel? address;
  const AddAddressPage({super.key, this.coordinates, this.address});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _houseController = TextEditingController();
  final TextEditingController _apartmentController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();

  List<LocationPlaceEntity> _regions = [];
  List<LocationPlaceEntity> _districts = [];
  List<LocationPlaceEntity> _neighborhoods = [];

  int? _selectedRegionId;
  int? _selectedDistrictId;
  int? _selectedNeighborhoodId;

  bool _regionsLoading = false;
  bool _districtsLoading = false;
  bool _neighborhoodsLoading = false;

  double? _latitude;
  double? _longitude;
  String? _addressFromMap;
  bool _geocoding = false;
  int _geocodeSessionId = 0;

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      final addr = widget.address!;
      _apartmentController.text = addr.apartment;
      _landmarkController.text = addr.comment;
      _latitude = addr.latitude;
      _longitude = addr.longitude;
      _addressFromMap = addr.address;
      final parts = addr.address.split(',').map((e) => e.trim()).toList();
      if (parts.length >= 2) {
        _streetController.text = parts[parts.length - 2];
      }
      if (parts.isNotEmpty) {
        _houseController.text = parts.last;
      }
    }
    if (widget.coordinates != null) {
      _latitude = widget.coordinates!.latitude;
      _longitude = widget.coordinates!.longitude;
    }
    _initLoad();
  }

  Future<void> _initLoad() async {
    await _loadRegions();
    if (!mounted) return;
    if (widget.address == null && _latitude != null && _longitude != null) {
      await _autoPopulateFromCoordinates();
    }
  }

  @override
  void dispose() {
    _streetController.dispose();
    _houseController.dispose();
    _apartmentController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  Future<void> _loadRegions() async {
    setState(() => _regionsLoading = true);
    final result = await getIt<ListingRepository>().getRegions();
    if (!mounted) return;
    result.either(
      (failure) {
        setState(() => _regionsLoading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message ?? 'Tarmoq xatosi'),
            backgroundColor: AppColors.red,
          ),
        );
      },
      (list) {
        setState(() {
          _regions = list;
          _regionsLoading = false;
        });
      },
    );
  }

  Future<void> _loadDistricts(int regionId) async {
    setState(() {
      _districtsLoading = true;
      _districts = [];
      _neighborhoods = [];
    });
    final result = await getIt<ListingRepository>().getDistricts(regionId);
    if (!mounted) return;
    result.either(
      (_) => setState(() => _districtsLoading = false),
      (list) => setState(() {
        _districts = list;
        _districtsLoading = false;
      }),
    );
  }

  Future<void> _loadNeighborhoods(int districtId) async {
    setState(() {
      _neighborhoodsLoading = true;
      _neighborhoods = [];
    });
    final result = await getIt<ListingRepository>().getNeighborhoods(
      districtId,
    );
    if (!mounted) return;
    result.either(
      (_) => setState(() => _neighborhoodsLoading = false),
      (list) => setState(() {
        _neighborhoods = list;
        _neighborhoodsLoading = false;
      }),
    );
  }

  LocationPlaceEntity? _placeById(
    List<LocationPlaceEntity> items,
    int? id,
  ) {
    if (id == null) return null;
    for (final p in items) {
      if (p.id == id) return p;
    }
    return null;
  }

  void _applyCoordsFromPlace(LocationPlaceEntity? place) {
    if (place?.latitude != null && place?.longitude != null) {
      _latitude = place!.latitude;
      _longitude = place.longitude;
    }
  }

  String _normalizePlaceName(String s) {
    final lower = s.toLowerCase();
    final stripped = lower.replaceAll(
      RegExp(
        r"\b(viloyati|viloyat|tumani|tuman|shahri|shahar|mahallasi|mahalla|область|город|города|район|города|г\.)\b",
      ),
      '',
    );
    return stripped
        .replaceAll(RegExp(r"[\s\-']+"), ' ')
        .trim();
  }

  LocationPlaceEntity? _findPlaceByName(
    List<LocationPlaceEntity> items,
    String? name,
  ) {
    if (name == null || name.trim().isEmpty) return null;
    final target = _normalizePlaceName(name);
    if (target.isEmpty) return null;
    for (final p in items) {
      if (_normalizePlaceName(p.name) == target) return p;
    }
    for (final p in items) {
      final pn = _normalizePlaceName(p.name);
      if (pn.isEmpty) continue;
      if (pn.contains(target) || target.contains(pn)) return p;
    }
    return null;
  }

  Future<void> _autoPopulateFromCoordinates() async {
    final lat = _latitude;
    final lng = _longitude;
    if (lat == null || lng == null) return;
    final sessionId = ++_geocodeSessionId;
    setState(() => _geocoding = true);
    try {
      final response = await Dio().get(
        'https://geocode-maps.yandex.ru/1.x/',
        queryParameters: {
          'apikey': AppKeys.yandexGeocoderKey,
          'geocode': '$lng,$lat',
          'format': 'json',
          'lang': 'uz_UZ',
          'results': '1',
          'kind': 'house',
        },
      );
      if (!mounted || sessionId != _geocodeSessionId) return;
      if (response.statusCode != 200) return;
      final featureMember = response
              .data['response']?['GeoObjectCollection']?['featureMember']
          as List?;
      if (featureMember == null || featureMember.isEmpty) return;
      final meta =
          featureMember[0]['GeoObject']?['metaDataProperty']?['GeocoderMetaData'];
      if (meta == null) return;
      final text = meta['text']?.toString();
      final componentsRaw = meta['Address']?['Components'] as List?;
      String? province;
      String? area;
      String? locality;
      String? district;
      String? street;
      String? house;
      if (componentsRaw != null) {
        for (final c in componentsRaw) {
          final kind = c['kind']?.toString();
          final name = c['name']?.toString();
          if (kind == null || name == null) continue;
          switch (kind) {
            case 'province':
              province = name;
              break;
            case 'area':
              area = name;
              break;
            case 'locality':
              locality ??= name;
              break;
            case 'district':
              district = name;
              break;
            case 'street':
              street = name;
              break;
            case 'house':
              house = name;
              break;
          }
        }
      }
      setState(() {
        if (text != null && text.isNotEmpty) _addressFromMap = text;
        if (street != null && _streetController.text.isEmpty) {
          _streetController.text = street;
        }
        if (house != null && _houseController.text.isEmpty) {
          _houseController.text = house;
        }
      });
      final regionMatch = _findPlaceByName(_regions, province ?? locality);
      if (regionMatch == null) return;
      setState(() {
        _selectedRegionId = regionMatch.id;
        _selectedDistrictId = null;
        _selectedNeighborhoodId = null;
        _districts = [];
        _neighborhoods = [];
      });
      await _loadDistricts(regionMatch.id);
      if (!mounted || sessionId != _geocodeSessionId) return;
      final districtMatch =
          _findPlaceByName(_districts, area ?? locality ?? district);
      if (districtMatch == null) return;
      setState(() {
        _selectedDistrictId = districtMatch.id;
        _selectedNeighborhoodId = null;
        _neighborhoods = [];
      });
      await _loadNeighborhoods(districtMatch.id);
      if (!mounted || sessionId != _geocodeSessionId) return;
      final mahallaMatch =
          _findPlaceByName(_neighborhoods, district ?? locality);
      if (mahallaMatch != null) {
        setState(() => _selectedNeighborhoodId = mahallaMatch.id);
      }
    } catch (e) {
      debugPrint('Reverse geocode error: $e');
    } finally {
      if (mounted && sessionId == _geocodeSessionId) {
        setState(() => _geocoding = false);
      }
    }
  }

  String _composedAddress() {
    final viloyat = _placeById(_regions, _selectedRegionId)?.name;
    final tuman = _placeById(_districts, _selectedDistrictId)?.name;
    final mahalla =
        _placeById(_neighborhoods, _selectedNeighborhoodId)?.name;
    final street = _streetController.text.trim();
    final house = _houseController.text.trim();
    final parts = <String>[
      if (viloyat != null && viloyat.isNotEmpty) viloyat,
      if (tuman != null && tuman.isNotEmpty) tuman,
      if (mahalla != null && mahalla.isNotEmpty) mahalla,
      if (street.isNotEmpty) street,
      if (house.isNotEmpty) house,
    ];
    if (parts.isEmpty && _addressFromMap != null) return _addressFromMap!;
    return parts.join(', ');
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRegionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Viloyatni tanlang'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }
    if (_selectedDistrictId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tumanni tanlang'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final composed = _composedAddress();
    final name = composed.isNotEmpty
        ? composed
        : "${l10n.addressDefaultName} ${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";

    final Map<String, dynamic> data = {
      "name": name,
      "address": composed,
      "apartment": _apartmentController.text.trim(),
      "entrance": widget.address?.entrance ?? "",
      "floor": widget.address?.floor ?? "",
      "comment": _landmarkController.text.trim(),
      "longitude": _longitude ?? widget.address?.longitude ?? 0.0,
      "latitude": _latitude ?? widget.address?.latitude ?? 0.0,
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
    final l10n = AppLocalizations.of(context)!;
    final primaryColor = context.watch<AppModeCubit>().state.primaryColor;
    final bodyBg = context.bodyBackground;
    final cardColor = context.cardSurface;
    final textColor = context.textPrimary;
    final textSecondary = context.textSecondary;
    final borderColor = context.borderColor;

    return Scaffold(
      appBar: UzXaridAppBar(onSearchChanged: (query) {}, onMenuTap: () {}),
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
                      text: l10n.addressAddTitle,
                      fontSize: 24,
                      fontWeight: 700,
                      color: textColor,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    children: [
                      _mapCard(
                        cardColor: cardColor,
                        borderColor: borderColor,
                        textColor: textColor,
                        textSecondary: textSecondary,
                        primaryColor: primaryColor,
                        mapHint: l10n.addressAddMapHint,
                        mapSelectedLabel: l10n.addressAddMapSelectedLabel,
                        mapSelectedSub: l10n.addressAddMapSelectedSub,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _SectionLabel(
                                text: 'Manzil',
                                textColor: textColor,
                              ),
                              const SizedBox(height: 8),
                              _addressDisplay(
                                surface: context.surfaceContainer,
                                borderColor: borderColor,
                                textColor: textColor,
                                textSecondary: textSecondary,
                              ),
                              const SizedBox(height: 16),
                              _cascadeDropdown(
                                label: l10n.addListingViloyat,
                                required_: true,
                                items: _regions,
                                value: _selectedRegionId,
                                loading: _regionsLoading,
                                enabled: true,
                                surface: context.surfaceContainer,
                                borderColor: borderColor,
                                textColor: textColor,
                                textSecondary: textSecondary,
                                onChanged: (id) {
                                  setState(() {
                                    _selectedRegionId = id;
                                    _selectedDistrictId = null;
                                    _selectedNeighborhoodId = null;
                                    _districts = [];
                                    _neighborhoods = [];
                                    _applyCoordsFromPlace(
                                      _placeById(_regions, id),
                                    );
                                  });
                                  if (id != null) _loadDistricts(id);
                                },
                                onClear: () {
                                  setState(() {
                                    _selectedRegionId = null;
                                    _selectedDistrictId = null;
                                    _selectedNeighborhoodId = null;
                                    _districts = [];
                                    _neighborhoods = [];
                                  });
                                },
                              ),
                              const SizedBox(height: 14),
                              _cascadeDropdown(
                                label: '${l10n.districtLabel} (район)',
                                required_: true,
                                items: _districts,
                                value: _selectedDistrictId,
                                loading: _districtsLoading,
                                enabled: _selectedRegionId != null,
                                surface: context.surfaceContainer,
                                borderColor: borderColor,
                                textColor: textColor,
                                textSecondary: textSecondary,
                                onChanged: (id) {
                                  setState(() {
                                    _selectedDistrictId = id;
                                    _selectedNeighborhoodId = null;
                                    _neighborhoods = [];
                                    _applyCoordsFromPlace(
                                      _placeById(_districts, id) ??
                                          _placeById(
                                            _regions,
                                            _selectedRegionId,
                                          ),
                                    );
                                  });
                                  if (id != null) _loadNeighborhoods(id);
                                },
                                onClear: () {
                                  setState(() {
                                    _selectedDistrictId = null;
                                    _selectedNeighborhoodId = null;
                                    _neighborhoods = [];
                                    _applyCoordsFromPlace(
                                      _placeById(_regions, _selectedRegionId),
                                    );
                                  });
                                },
                              ),
                              const SizedBox(height: 14),
                              _cascadeDropdown(
                                label: '${l10n.addListingMahalla} (квартал)',
                                required_: false,
                                items: _neighborhoods,
                                value: _selectedNeighborhoodId,
                                loading: _neighborhoodsLoading,
                                enabled: _selectedDistrictId != null,
                                surface: context.surfaceContainer,
                                borderColor: borderColor,
                                textColor: textColor,
                                textSecondary: textSecondary,
                                emptyLabel: 'Ma\'lumot topilmadi',
                                onChanged: (id) {
                                  setState(() {
                                    _selectedNeighborhoodId = id;
                                    _applyCoordsFromPlace(
                                      _placeById(_neighborhoods, id) ??
                                          _placeById(
                                            _districts,
                                            _selectedDistrictId,
                                          ),
                                    );
                                  });
                                },
                                onClear: () {
                                  setState(() {
                                    _selectedNeighborhoodId = null;
                                    _applyCoordsFromPlace(
                                      _placeById(
                                        _districts,
                                        _selectedDistrictId,
                                      ),
                                    );
                                  });
                                },
                              ),
                              const SizedBox(height: 14),
                              WTextField(
                                controller: _streetController,
                                title: l10n.addressStreetLabel,
                                hintText: l10n.addressStreetHint,
                                fillColor: context.surfaceContainer,
                                borderNoFocusColor: context.borderColor,
                                validator: (value) =>
                                    value == null || value.trim().isEmpty
                                    ? l10n.addressRequiredError
                                    : null,
                              ),
                              const SizedBox(height: 14),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: WTextField(
                                      controller: _houseController,
                                      title: '${l10n.addressHouseLabel} (дом)',
                                      hintText: l10n.addressHouseHint,
                                      keyboardType: TextInputType.text,
                                      fillColor: context.surfaceContainer,
                                      borderNoFocusColor: context.borderColor,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.deny(
                                          RegExp(r'\s'),
                                        ),
                                      ],
                                      validator: (value) =>
                                          value == null ||
                                              value.trim().isEmpty
                                          ? l10n.addressRequiredError
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: WTextField(
                                      controller: _apartmentController,
                                      title:
                                          'Xonadon (квартира)',
                                      hintText: l10n.addressAptHint,
                                      fillColor: context.surfaceContainer,
                                      borderNoFocusColor: context.borderColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              WTextField(
                                controller: _landmarkController,
                                title: 'Izoh',
                                hintText: l10n.addressLandmarkHint,
                                maxLines: 4,
                                minLines: 3,
                                fillColor: context.surfaceContainer,
                                borderNoFocusColor: context.borderColor,
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: bodyBg,
          child: ContainerW(
            width: double.infinity,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
            ),
            color: cardColor,
            child: BlocConsumer<AddressBloc, AddressState>(
              listener: (context, state) {
                if (state.status == AddressStatus.createSuccess ||
                    state.status == AddressStatus.updateSuccess) {
                  context.pop(true);
                }
              },
              builder: (context, state) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ContainerW(
                    height: 50,
                    onTap: state.status == AddressStatus.loading
                        ? null
                        : _submit,
                    color: primaryColor,
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
                                text: l10n.addressSave,
                                fontSize: 16,
                                fontWeight: 600,
                                color: AppColors.white,
                              ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _mapCard({
    required Color cardColor,
    required Color borderColor,
    required Color textColor,
    required Color textSecondary,
    required Color primaryColor,
    required String mapHint,
    required String mapSelectedLabel,
    required String mapSelectedSub,
  }) {
    return ContainerW(
      color: cardColor,
      radius: 16,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              text: mapHint,
              fontSize: 14,
              fontWeight: 400,
              color: textSecondary,
            ),
            const SizedBox(height: 16),
            ContainerW(
              color: cardColor,
              radius: 12,
              border: Border.all(color: borderColor),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    ContainerW(
                      color: primaryColor,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            text: _addressFromMap?.isNotEmpty == true
                                ? _addressFromMap!
                                : (_geocoding
                                    ? '...'
                                    : (_latitude != null && _longitude != null
                                        ? '${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}'
                                        : mapSelectedLabel)),
                            fontSize: 16,
                            fontWeight: 600,
                            color: textColor,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 4),
                          AppText(
                            text: mapSelectedSub,
                            fontSize: 14,
                            fontWeight: 400,
                            color: textSecondary,
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: textColor),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addressDisplay({
    required Color surface,
    required Color borderColor,
    required Color textColor,
    required Color textSecondary,
  }) {
    final composed = _composedAddress();
    final text = composed.isNotEmpty
        ? composed
        : (_addressFromMap?.isNotEmpty == true
            ? _addressFromMap!
            : 'Xaritadan manzilni tanlang yoki quyidagi maydonlarni to‘ldiring.');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: composed.isNotEmpty || _addressFromMap != null
              ? textColor
              : textSecondary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          height: 1.35,
        ),
      ),
    );
  }

  Widget _cascadeDropdown({
    required String label,
    required bool required_,
    required List<LocationPlaceEntity> items,
    required int? value,
    required bool loading,
    required bool enabled,
    required Color surface,
    required Color borderColor,
    required Color textColor,
    required Color textSecondary,
    required ValueChanged<int?> onChanged,
    required VoidCallback onClear,
    String? emptyLabel,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final showEmpty = enabled && !loading && items.isEmpty;
    final effectiveValue = items.any((e) => e.id == value) ? value : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(
          text: required_ ? '$label *' : label,
          textColor: textColor,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                alignment: Alignment.centerLeft,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: effectiveValue,
                    isExpanded: true,
                    hint: loading
                        ? Row(
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: textSecondary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                l10n.addListingLoading,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            showEmpty
                                ? (emptyLabel ?? l10n.addListingTanlang)
                                : l10n.addListingTanlang,
                            style: TextStyle(
                              fontSize: 14,
                              color: textSecondary,
                            ),
                          ),
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: textSecondary,
                    ),
                    items: items
                        .map(
                          (e) => DropdownMenuItem<int>(
                            value: e.id,
                            child: Text(
                              e.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: textColor,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: enabled && !loading ? onChanged : null,
                  ),
                ),
              ),
            ),
            if (effectiveValue != null)
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: enabled ? onClear : null,
                icon: Icon(Icons.close, size: 20, color: textSecondary),
              ),
          ],
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text, required this.textColor});

  final String text;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return AppText(
      text: text,
      color: textColor,
      fontSize: 14,
      fontWeight: 700,
    );
  }
}
