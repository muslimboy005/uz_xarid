import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/constants/app_dimens.dart';
import 'package:uz_xarid/core/dp/infection.dart';
import 'package:uz_xarid/core/soliq_id/soliq_id_flow.dart';
import 'package:uz_xarid/core/cubit/app_mode_cubit.dart';
import 'package:uz_xarid/core/service/local_service.dart';
import 'package:uz_xarid/core/theme/theme_colors.dart';
import 'package:uz_xarid/core/widgets/app_image.dart';
import 'package:uz_xarid/core/widgets/app_text.dart';
import 'package:uz_xarid/core/widgets/uzxarid_app_bar.dart';
import 'package:uz_xarid/core/widgets/w__container.dart';
import 'package:uz_xarid/features/add_listing/domain/entities/create_ad_params.dart';
import 'package:uz_xarid/features/add_listing/domain/entities/category_field_entity.dart';
import 'package:uz_xarid/features/add_listing/domain/entities/location_place_entity.dart';
import 'package:uz_xarid/features/add_listing/domain/repositories/listing_repository.dart';
import 'package:uz_xarid/features/catalog/domain/entities/category_entity.dart';
import 'package:uz_xarid/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:uz_xarid/features/profile/data/models/my_listing_item_dto.dart';
import 'package:uz_xarid/features/product_detail/domain/entities/ad_detail_entity.dart';
import 'package:uz_xarid/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:uz_xarid/features/add_listing/presentation/bloc/add_listing_bloc.dart';
import 'package:uz_xarid/features/add_listing/presentation/widgets/color_dropdown_field.dart';
import 'package:uz_xarid/features/add_listing/presentation/widgets/size_dropdown_field.dart';
import 'package:uz_xarid/features/profile/presentation/widgets/bottom_sheets/name_bottom_sheet.dart';
import 'package:uz_xarid/features/profile/presentation/widgets/bottom_sheets/otp_bottom_sheet.dart';
import 'package:uz_xarid/features/profile/presentation/widgets/bottom_sheets/phone_bottom_sheet.dart';
import 'package:uz_xarid/l10n/app_localizations.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:uz_xarid/features/add_listing/presentation/pages/map_selection_page.dart';

enum _ListingType { product, service, car, home, equipment }

enum _NameLang { uz, ru, en }

class AddListingPage extends StatefulWidget {
  const AddListingPage({super.key, this.editSlug, this.editFallbackItem});

  /// Tahrirlash rejimida e'lon slug'i (product detail dan yuklanadi).
  final String? editSlug;

  /// 404 bo'lsa forma shu ma'lumotlar bilan to'ldiriladi (Mening e'lonlarimdan uzatiladi).
  final Object? editFallbackItem;

  @override
  State<AddListingPage> createState() => _AddListingPageState();
}

class _ParamRowData {
  final TextEditingController name = TextEditingController();
  final TextEditingController value = TextEditingController();
}

class _ColorRowData {
  int? selectedColorId;
  final TextEditingController price = TextEditingController();
  final TextEditingController discount = TextEditingController();
}

class _SizeRowData {
  int? selectedSizeId;
  final TextEditingController price = TextEditingController();
  final TextEditingController discount = TextEditingController();
}

class _AddListingPageState extends State<AddListingPage> {
  late bool _isLoggedIn;

  _ListingType _listingType = _ListingType.product;
  String _adType = 'Sell';
  _NameLang _nameLang = _NameLang.uz;
  String _currency = 'UZS';

  CategoryEntity? _selectedCategory;
  CategoryEntity? _selectedSubcategory;
  CategoryEntity? _selectedSubSubcategory;

  /// GET /api/v2/category/{id}/children/ — v1 daraxtdagi bo‘sh `children` o‘rniga.
  int? _loadedSubcategoriesParentId;
  List<CategoryEntity> _loadedSubcategories = [];
  bool _loadingSubcategories = false;

  int? _loadedSubSubcategoriesParentId;
  List<CategoryEntity> _loadedSubSubcategories = [];
  bool _loadingSubSubcategories = false;
  final _amountController = TextEditingController();
  final _nameUzController = TextEditingController();
  final _nameRuController = TextEditingController();
  final _nameEnController = TextEditingController();
  final _descUzController = TextEditingController();
  final _descRuController = TextEditingController();
  final _descEnController = TextEditingController();
  final _weightValueController = TextEditingController();
  final _lengthController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();

  String _weightUnit = 'KG';
  String _dimensionUnit = 'cm';

  static const double _kInputHeight = 48.0;

  static const int _maxParams = 20;
  static const int _maxColors = 10;
  static const int _maxSizes = 10;

  final List<_ParamRowData> _paramRows = [_ParamRowData()];
  final List<_ColorRowData> _colorRows = [_ColorRowData()];
  final List<_SizeRowData> _sizeRows = [_SizeRowData()];

  final List<String?> _imagePaths = [null, null, null, null];
  static final _imagePicker = ImagePicker();
  bool _formFilledFromEdit = false;
  bool _usedFallbackForEdit = false;
  bool _isFaceVerificationInProgress = false;

  /// Yuz ID muvaffaqiyatli o‘tganidan keyin (sessiya) yoki server `is_verify`.
  bool _soliqSessionVerified = false;

  bool _isUserFaceVerified(dynamic user) {
    if (user == null) return false;
    return user.isFaceVerified == true || user.isVerify == true;
  }

  double? _latitude;
  double? _longitude;
  String? _addressName;

  List<LocationPlaceEntity> _regions = [];
  List<LocationPlaceEntity> _districts = [];
  List<LocationPlaceEntity> _neighborhoods = [];
  bool _regionsLoading = false;
  bool _districtsLoading = false;
  bool _neighborhoodsLoading = false;
  int? _selectedRegionId;
  int? _selectedDistrictId;
  int? _selectedNeighborhoodId;

  List<CategoryFieldEntity> _dynamicFields = [];
  bool _dynamicFieldsLoading = false;
  final Map<String, TextEditingController> _dynamicTextControllers = {};
  final Map<String, dynamic> _dynamicValues = {};

  @override
  void initState() {
    super.initState();
    // Yangi e'lon yaratishda (yoki edit data hali kelmagan paytda) tablar
    // global mode (`AppModeCubit`)ga mos ko'rinsin.
    final mode = context.read<AppModeCubit>().state;
    _adType = mode == AppMode.buying ? 'Buy' : 'Sell';
    _isLoggedIn = getIt<SecureStorageService>().hasTokenSync();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadRegions();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _nameUzController.dispose();
    _nameRuController.dispose();
    _nameEnController.dispose();
    _descUzController.dispose();
    _descRuController.dispose();
    _descEnController.dispose();
    _weightValueController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    for (final r in _paramRows) {
      r.name.dispose();
      r.value.dispose();
    }
    for (final r in _colorRows) {
      r.price.dispose();
      r.discount.dispose();
    }
    for (final r in _sizeRows) {
      r.price.dispose();
      r.discount.dispose();
    }
    for (final c in _dynamicTextControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _refreshAuth() {
    final newValue = getIt<SecureStorageService>().hasTokenSync();
    if (_isLoggedIn != newValue) {
      setState(() {
        _isLoggedIn = newValue;
      });
    }
  }

  void _showPhoneBottomSheet() {
    PhoneBottomSheet.show(
      context,
      onCodeSent: (phone) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) _showOtpBottomSheet(phone);
        });
      },
    );
  }

  void _showOtpBottomSheet(String phone) {
    OtpBottomSheet.show(
      context,
      phone,
      onAskName: () {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) _showNameBottomSheet();
        });
      },
      onOtpSuccess: () {
        if (mounted) {
          context.read<ProfileBloc>().add(const ProfileLoadEvent());
          _refreshAuth();
        }
      },
    );
  }

  void _showNameBottomSheet() {
    NameBottomSheet.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final bodyBg = context.bodyBackground;
    final cardColor = context.cardSurface;
    final textColor = context.textPrimary;
    final textSecondary = context.textSecondary;
    final borderColor = context.borderColor;
    final l10n = AppLocalizations.of(context)!;
    final primaryColor = context.watch<AppModeCubit>().state.primaryColor;

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: UzXaridAppBar(onSearchChanged: (_) {}, onMenuTap: () {}),
      body: Container(
        color: bodyBg,
        height: MediaQuery.of(context).size.height,
        child: BlocListener<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state.status == ProfileStatus.success) _refreshAuth();
          },
          child: Builder(
            builder: (context) {
              if (!_isLoggedIn) {
                return _buildLoginRequired(
                  l10n,
                  cardColor,
                  textColor,
                  textSecondary,
                  borderColor,
                );
              }
              return BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, profileState) {
                  final isEdit =
                      widget.editSlug != null && widget.editSlug!.isNotEmpty;
                  if (!isEdit) {
                    if (profileState.status == ProfileStatus.initial ||
                        profileState.status == ProfileStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final user = profileState.profileModel?.data.user;
                    if (user != null &&
                        !_isUserFaceVerified(user) &&
                        !_soliqSessionVerified) {
                      return _buildSoliqGateRequired(
                        l10n,
                        cardColor,
                        textColor,
                        textSecondary,
                        borderColor,
                        context,
                      );
                    }
                  }
                  return BlocProvider(
                    create: (_) {
                      final bloc = getIt<AddListingBloc>()
                        ..add(
                          AddListingLoadCategoriesRequested(
                            categoryType: _categoryTypeForListingType(
                              _listingType,
                            ),
                          ),
                        )
                        ..add(const AddListingLoadColorsRequested())
                        ..add(const AddListingLoadSizesRequested());
                      if (widget.editSlug != null &&
                          widget.editSlug!.isNotEmpty) {
                        developer.log(
                          'AddListingPage: edit mode, loading ad slug=${widget.editSlug}',
                          name: 'AddListingPage',
                        );
                        bloc.add(
                          AddListingLoadAdForEditRequested(widget.editSlug!),
                        );
                      }
                      return bloc;
                    },
                    child: Builder(
                      builder: (formContext) => _buildForm(
                        formContext,
                        cardColor,
                        textColor,
                        textSecondary,
                        borderColor,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // ─── LOGIN REQUIRED ─────────────────────────────────────────────

  Widget _buildLoginRequired(
    AppLocalizations l10n,
    Color cardColor,
    Color textColor,
    Color textSecondary,
    Color borderColor,
  ) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(
                  text: l10n.addListingCreateHeadline,
                  fontSize: 24,
                  fontWeight: 700,
                  color: textColor,
                ),
                const SizedBox(height: 8),
                AppText(
                  text: l10n.addListingLoginDescription,
                  fontSize: 14,
                  fontWeight: 400,
                  color: textSecondary,
                ),
                const SizedBox(height: 32),
                _card(
                  cardColor: cardColor,
                  borderColor: borderColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: l10n.profileAuthBenefitsTitle,
                        fontSize: 18,
                        fontWeight: 600,
                        color: textColor,
                      ),
                      const SizedBox(height: 16),
                      AppText(
                        text: l10n.profileAuthDescription,
                        fontSize: 14,
                        fontWeight: 400,
                        color: textSecondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: _primaryButton(
            l10n.loginSheetTitle,
            onTap: _showPhoneBottomSheet,
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  /// Yangi e'lon: profil tasdiqlanmagan bo‘lsa, forma ochilishidan oldin Yuz ID.
  Widget _buildSoliqGateRequired(
    AppLocalizations l10n,
    Color cardColor,
    Color textColor,
    Color textSecondary,
    Color borderColor,
    BuildContext context,
  ) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(
                  text: l10n.addListingCreateHeadline,
                  fontSize: 24,
                  fontWeight: 700,
                  color: textColor,
                ),
                const SizedBox(height: 8),
                AppText(
                  text:
                      'E\'lon joylash uchun avval shaxsingizni Yuz ID (SoliqID) orqali tasdiqlang.',
                  fontSize: 14,
                  fontWeight: 400,
                  color: textSecondary,
                ),
                const SizedBox(height: 24),
                _card(
                  cardColor: cardColor,
                  borderColor: borderColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: 'Nima kerak?',
                        fontSize: 18,
                        fontWeight: 600,
                        color: textColor,
                      ),
                      const SizedBox(height: 12),
                      AppText(
                        text:
                            'Passport ma\'lumotlari va tug\'ilgan sana (kun.oy.yil). Token avtomatik olinadi.',
                        fontSize: 14,
                        fontWeight: 400,
                        color: textSecondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: _primaryButton(
            'Yuz ID bilan tasdiqlash',
            onTap: _isFaceVerificationInProgress
                ? () {}
                : () {
                    _runSoliqVerification();
                  },
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  static String _categoryTypeForListingType(_ListingType type) {
    return switch (type) {
      _ListingType.product => 'Product',
      _ListingType.service => 'Service',
      _ListingType.car => 'Auto',
      _ListingType.home => 'Home',
      _ListingType.equipment => 'Equipment',
    };
  }

  int? get _selectedCategoryForDynamicFields =>
      _selectedSubSubcategory?.id ??
      _selectedSubcategory?.id ??
      _selectedCategory?.id;

  /// `category-fields` faqat oxirgi turkum aniq bo‘lganda kerak — aks holda ortiqcha ikkinchi so‘rov bo‘ladi.
  bool _shouldLoadCategoryFieldsNow() {
    final root = _selectedCategory;
    if (root == null) return false;

    if (_selectedSubSubcategory != null) return true;

    if (_selectedSubcategory != null) {
      if (_loadedSubSubcategoriesParentId != _selectedSubcategory!.id) {
        return false;
      }
      return _loadedSubSubcategories.isEmpty;
    }

    if (_loadedSubcategoriesParentId != root.id) return false;
    return _loadedSubcategories.isEmpty;
  }

  void _clearDynamicFieldsWithoutFetch() {
    if (!_dynamicFieldsLoading && _dynamicFields.isEmpty) return;
    setState(() {
      _dynamicFieldsLoading = false;
      _dynamicFields = [];
    });
  }

  void _refreshDynamicFieldsAfterCategoryStep() {
    if (!mounted) return;
    if (_shouldLoadCategoryFieldsNow()) {
      _loadDynamicFields();
    } else {
      _clearDynamicFieldsWithoutFetch();
    }
  }

  Future<void> _loadDynamicFields() async {
    setState(() {
      _dynamicFieldsLoading = true;
    });
    final listingType = _categoryTypeForListingType(_listingType);
    final categoryId = _selectedCategoryForDynamicFields;
    final result = await getIt<ListingRepository>().getCategoryFields(
      listingType: listingType,
      categoryId: categoryId,
    );
    if (!mounted) return;
    result.either(
      (_) {
        setState(() {
          _dynamicFieldsLoading = false;
          _dynamicFields = [];
        });
      },
      (fields) {
        setState(() {
          _dynamicFieldsLoading = false;
          _dynamicFields = fields;
        });
      },
    );
  }

  static const int _categoryChildrenPageSize = 12;

  Future<void> _fetchSubcategoriesForCategory(int parentId) async {
    setState(() => _loadingSubcategories = true);
    final result = await getIt<CatalogRepository>().getCategoryChildren(
      parentCategoryId: parentId,
      pageSize: _categoryChildrenPageSize,
    );
    if (!mounted) return;
    if (_selectedCategory?.id != parentId) return;
    result.either(
      (_) {
        setState(() {
          _loadingSubcategories = false;
          _loadedSubcategoriesParentId = parentId;
          _loadedSubcategories = _selectedCategory?.children ?? [];
        });
      },
      (list) {
        setState(() {
          _loadingSubcategories = false;
          _loadedSubcategoriesParentId = parentId;
          _loadedSubcategories = list;
        });
      },
    );
    _refreshDynamicFieldsAfterCategoryStep();
  }

  Future<void> _fetchSubSubcategoriesForSubcategory(int parentId) async {
    setState(() => _loadingSubSubcategories = true);
    final result = await getIt<CatalogRepository>().getCategoryChildren(
      parentCategoryId: parentId,
      pageSize: _categoryChildrenPageSize,
    );
    if (!mounted) return;
    if (_selectedSubcategory?.id != parentId) return;
    result.either(
      (_) {
        setState(() {
          _loadingSubSubcategories = false;
          _loadedSubSubcategoriesParentId = parentId;
          _loadedSubSubcategories = _selectedSubcategory?.children ?? [];
        });
      },
      (list) {
        setState(() {
          _loadingSubSubcategories = false;
          _loadedSubSubcategoriesParentId = parentId;
          _loadedSubSubcategories = list;
        });
      },
    );
    _refreshDynamicFieldsAfterCategoryStep();
  }

  void _clearLoadedNestedCategories() {
    _loadedSubcategoriesParentId = null;
    _loadedSubcategories = [];
    _loadingSubcategories = false;
    _loadedSubSubcategoriesParentId = null;
    _loadedSubSubcategories = [];
    _loadingSubSubcategories = false;
  }

  TextEditingController _controllerForDynamicField(String key) {
    return _dynamicTextControllers.putIfAbsent(key, TextEditingController.new);
  }

  bool _isDynamicFieldVisible(CategoryFieldEntity field) {
    final condition = field.condition;
    if (condition == null) return true;
    if (condition.field == 'category') {
      final selectedName =
          (_selectedSubSubcategory ?? _selectedSubcategory ?? _selectedCategory)
              ?.displayName;
      return selectedName == condition.equals;
    }
    final current = _dynamicValues[condition.field];
    return current?.toString() == condition.equals;
  }

  /// Kategoriya daraxtida id bo‘yicha yo‘lni qaytaradi [root, ..., leaf].
  static List<CategoryEntity>? _findCategoryPath(
    List<CategoryEntity>? list,
    int id,
  ) {
    if (list == null) return null;
    for (final c in list) {
      if (c.id == id) return [c];
      final childPath = _findCategoryPath(c.children, id);
      if (childPath != null) return [c, ...childPath];
    }
    return null;
  }

  void _fillFormFromAdDetail(
    AdDetailEntity ad,
    List<CategoryEntity>? categories,
  ) {
    if (_formFilledFromEdit) {
      developer.log(
        'AddListing: _fillFormFromAdDetail skipped (already filled)',
        name: 'AddListingPage',
      );
      return;
    }
    _formFilledFromEdit = true;
    developer.log(
      'AddListing: _fillFormFromAdDetail applying title=${ad.title}, price=${ad.price}, categoryId=${ad.categoryId}',
      name: 'AddListingPage',
    );
    _nameUzController.text = ad.title;
    _nameRuController.text = '';
    _nameEnController.text = '';
    _descUzController.text = ad.description ?? '';
    _descRuController.text = '';
    _descEnController.text = '';
    _amountController.text = ad.price ?? ad.finalPrice ?? '';
    _currency = (ad.currency ?? 'uzs').toUpperCase();
    if (ad.weight != null) _weightValueController.text = ad.weight.toString();
    if (ad.width != null) _widthController.text = ad.width.toString();
    if (ad.length != null) _lengthController.text = ad.length.toString();
    if (ad.height != null) _heightController.text = ad.height.toString();
    if (ad.weightUnit != null) _weightUnit = ad.weightUnit!.toUpperCase();
    if (ad.dimensionUnit != null) {
      final u = ad.dimensionUnit!.toLowerCase();
      _dimensionUnit = (u == 'sm') ? 'cm' : u;
    }
    if (ad.adType != null) {
      final t = ad.adType!;
      if (t == 'Sell' || t == 'Buy') {
        _adType = t;
      }
    }
    if (ad.listingType != null) {
      switch (ad.listingType!) {
        case 'Product':
          _listingType = _ListingType.product;
          break;
        case 'Service':
          _listingType = _ListingType.service;
          break;
        case 'Auto':
          _listingType = _ListingType.car;
          break;
        case 'Home':
          _listingType = _ListingType.home;
          break;
        case 'Equipment':
          _listingType = _ListingType.equipment;
          break;
      }
    }
    if (ad.categoryId != null && categories != null && categories.isNotEmpty) {
      final path = _findCategoryPath(categories, ad.categoryId!);
      if (path != null && path.isNotEmpty) {
        _selectedCategory = path[0];
        _selectedSubcategory = path.length > 1 ? path[1] : null;
        _selectedSubSubcategory = path.length > 2 ? path[2] : null;
      }
    }
    _latitude = ad.latitude;
    _longitude = ad.longitude;
    _addressName = ad.address;
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_selectedCategory != null) {
        _fetchSubcategoriesForCategory(_selectedCategory!.id).then((_) {
          if (!mounted) return;
          if (_selectedSubcategory != null) {
            _fetchSubSubcategoriesForSubcategory(_selectedSubcategory!.id);
          }
        });
      }
    });
  }

  void _fillFormFromMyListingItem(
    MyListingItemDto item,
    List<CategoryEntity>? categories,
  ) {
    if (_formFilledFromEdit) return;
    _formFilledFromEdit = true;
    _usedFallbackForEdit = true;
    developer.log(
      'AddListing: _fillFormFromMyListingItem slug=${item.slug}, title=${item.title}',
      name: 'AddListingPage',
    );
    _nameUzController.text = item.title;
    _nameRuController.text = '';
    _nameEnController.text = '';
    _descUzController.text = item.description ?? '';
    _descRuController.text = '';
    _descEnController.text = '';
    _amountController.text = item.price ?? item.finalPrice ?? '';
    _currency = (item.currency).toUpperCase();
    if (item.adType != null) {
      final t = item.adType!;
      if (t == 'Sell' || t == 'Buy') {
        _adType = t;
      }
    }
    if (item.listingType != null) {
      switch (item.listingType!) {
        case 'Product':
          _listingType = _ListingType.product;
          break;
        case 'Service':
          _listingType = _ListingType.service;
          break;
        case 'Auto':
          _listingType = _ListingType.car;
          break;
        case 'Home':
          _listingType = _ListingType.home;
          break;
        case 'Equipment':
          _listingType = _ListingType.equipment;
          break;
        default:
          _listingType = _ListingType.product;
      }
    }
    if (item.categoryId != null &&
        categories != null &&
        categories.isNotEmpty) {
      final path = _findCategoryPath(categories, item.categoryId!);
      if (path != null && path.isNotEmpty) {
        _selectedCategory = path[0];
        _selectedSubcategory = path.length > 1 ? path[1] : null;
        _selectedSubSubcategory = path.length > 2 ? path[2] : null;
      }
    }
    _latitude = item.latitude;
    _longitude = item.longitude;
    _addressName = item.address;
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_selectedCategory != null) {
        _fetchSubcategoriesForCategory(_selectedCategory!.id).then((_) {
          if (!mounted) return;
          if (_selectedSubcategory != null) {
            _fetchSubSubcategoriesForSubcategory(_selectedSubcategory!.id);
          }
        });
      }
    });
  }

  // ─── FORM ───────────────────────────────────────────────────────

  Widget _buildForm(
    BuildContext formContext,
    Color cardColor,
    Color textColor,
    Color textSecondary,
    Color borderColor,
  ) {
    return BlocConsumer<AddListingBloc, AddListingState>(
      listenWhen: (prev, cur) {
        final adChanged =
            cur.adDetailForEdit != null &&
            prev.adDetailForEdit != cur.adDetailForEdit;
        final categoriesArrived =
            cur.adDetailForEdit != null && prev.categories != cur.categories;
        final errorArrived =
            cur.loadAdForEditError != null &&
            prev.loadAdForEditError != cur.loadAdForEditError;
        final shouldListen =
            prev.createAdSlug != cur.createAdSlug ||
            prev.createAdError != cur.createAdError ||
            adChanged ||
            categoriesArrived ||
            errorArrived;
        return shouldListen;
      },
      listener: (context, state) {
        final l10n = AppLocalizations.of(context)!;
        final fallback = widget.editFallbackItem is MyListingItemDto
            ? widget.editFallbackItem as MyListingItemDto
            : null;
        if (state.loadAdForEditError != null &&
            state.adDetailForEdit == null &&
            fallback != null &&
            !_formFilledFromEdit) {
          _fillFormFromMyListingItem(fallback, state.categories);
          return;
        }
        final hasDetail = state.adDetailForEdit != null;
        final hasCategories =
            state.categories != null && state.categories!.isNotEmpty;
        if (hasDetail && hasCategories && !_formFilledFromEdit) {
          developer.log(
            'AddListing: filling form from adDetail slug=${state.adDetailForEdit!.slug}, '
            'title=${state.adDetailForEdit!.title}, categoryId=${state.adDetailForEdit!.categoryId}',
            name: 'AddListingPage',
          );
          _fillFormFromAdDetail(state.adDetailForEdit!, state.categories!);
        } else if (hasDetail && !hasCategories && !_formFilledFromEdit) {
          developer.log(
            'AddListing: waiting for categories (adDetail loaded, categories=${state.categories?.length ?? 0})',
            name: 'AddListingPage',
          );
        } else if (!hasDetail && widget.editSlug != null) {
          developer.log(
            'AddListing: adDetail not loaded yet, loadAdForEditLoading=${state.loadAdForEditLoading}, error=${state.loadAdForEditError}',
            name: 'AddListingPage',
          );
        }
        if (state.createAdSlug != null && state.createAdSlug!.isNotEmpty) {
          ScaffoldMessenger.of(formContext).showSnackBar(
            SnackBar(
              content: Text(
                widget.editSlug != null
                    ? l10n.addListingUpdated
                    : l10n.addListingCreated,
              ),
              backgroundColor: Colors.green,
            ),
          );
          formContext.go('/profile/my-ads');
          return;
        }
        if (state.createAdError != null) {
          ScaffoldMessenger.of(formContext).showSnackBar(
            SnackBar(
              content: Text(state.createAdError!),
              backgroundColor: AppColors.red,
            ),
          );
        }
      },
      buildWhen: (prev, cur) =>
          prev.loadAdForEditLoading != cur.loadAdForEditLoading ||
          prev.loadAdForEditError != cur.loadAdForEditError ||
          prev.adDetailForEdit != cur.adDetailForEdit,
      builder: (context, state) {
        final l10n = AppLocalizations.of(context)!;
        if (widget.editSlug != null &&
            state.loadAdForEditLoading &&
            state.adDetailForEdit == null &&
            !_usedFallbackForEdit) {
          return const Center(child: CircularProgressIndicator());
        }
        if (widget.editSlug != null &&
            state.loadAdForEditError != null &&
            state.adDetailForEdit == null &&
            !_usedFallbackForEdit) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.loadAdForEditError!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: textSecondary),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => formContext.pop(),
                    child: Text(l10n.addListingBack),
                  ),
                ],
              ),
            ),
          );
        }
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAdTypeTabs(cardColor, textColor, borderColor),
                    const SizedBox(height: 16),
                    _buildTypeTabs(
                      formContext,
                      cardColor,
                      textColor,
                      borderColor,
                    ),
                    const SizedBox(height: 16),
                    _buildSummaCard(
                      cardColor,
                      textColor,
                      textSecondary,
                      borderColor,
                    ),
                    const SizedBox(height: 16),
                    _buildCategoryCard(
                      cardColor,
                      textColor,
                      textSecondary,
                      borderColor,
                    ),
                    const SizedBox(height: 16),
                    _buildDynamicFieldsCard(
                      cardColor,
                      textColor,
                      textSecondary,
                      borderColor,
                    ),
                    const SizedBox(height: 16),
                    _buildProductNameCard(
                      cardColor,
                      textColor,
                      textSecondary,
                      borderColor,
                    ),
                    const SizedBox(height: 16),
                    _buildImageUploadCard(
                      cardColor,
                      textColor,
                      textSecondary,
                      borderColor,
                    ),
                    const SizedBox(height: 16),
                    _buildLocationCard(
                      cardColor,
                      textColor,
                      textSecondary,
                      borderColor,
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: BlocBuilder<AddListingBloc, AddListingState>(
                        buildWhen: (prev, cur) =>
                            prev.createAdLoading != cur.createAdLoading,
                        builder: (context, state) {
                          final l10n = AppLocalizations.of(context)!;
                          final isEdit =
                              widget.editSlug != null &&
                              widget.editSlug!.isNotEmpty;
                          final isBusy =
                              state.createAdLoading ||
                              _isFaceVerificationInProgress;
                          final label = isBusy
                              ? l10n.addListingLoading
                              : (isEdit
                                    ? l10n.addListingSave
                                    : l10n.addListingCreateHeadline);
                          return _primaryButton(
                            label,
                            onTap: isBusy
                                ? () {}
                                : () => _submitCreateAd(context),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitCreateAd(BuildContext formContext) async {
    final l10n = AppLocalizations.of(formContext)!;
    final category =
        _selectedSubSubcategory ?? _selectedSubcategory ?? _selectedCategory;
    if (category == null) {
      ScaffoldMessenger.of(formContext).showSnackBar(
        SnackBar(
          content: Text(l10n.addListingSelectCategory),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }
    final titleUz = _nameUzController.text.trim();
    if (titleUz.isEmpty) {
      ScaffoldMessenger.of(formContext).showSnackBar(
        SnackBar(
          content: Text(l10n.addListingEnterProductName),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }
    final price = _amountController.text.trim();
    if (price.isEmpty) {
      ScaffoldMessenger.of(formContext).showSnackBar(
        SnackBar(
          content: Text(l10n.addListingEnterAmount),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    final visibleDynamicFields = _dynamicFields.where(_isDynamicFieldVisible);
    final dynamicPayload = <String, dynamic>{};
    for (final field in visibleDynamicFields) {
      final type = field.type.toLowerCase();
      dynamic value;
      if (type == 'text' || type == 'number') {
        final c = _dynamicTextControllers[field.name];
        value = c?.text.trim();
      } else {
        value = _dynamicValues[field.name];
      }
      if (field.required) {
        final missing =
            value == null ||
            (value is String && value.isEmpty) ||
            (type == 'checkbox' && value != true);
        if (missing) {
          ScaffoldMessenger.of(formContext).showSnackBar(
            SnackBar(
              content: Text('${field.label} to\'ldirilishi shart'),
              backgroundColor: AppColors.red,
            ),
          );
          return;
        }
      }
      if (value != null && (value is! String || value.isNotEmpty)) {
        dynamicPayload[field.name] = value;
      }
    }
    final isEdit = widget.editSlug != null && widget.editSlug!.isNotEmpty;
    final blocState = formContext.read<AddListingBloc>().state;
    final adDetail = blocState.adDetailForEdit;
    final fallbackItem = widget.editFallbackItem is MyListingItemDto
        ? widget.editFallbackItem as MyListingItemDto
        : null;
    final hasExistingImages =
        isEdit &&
        ((adDetail != null &&
                ((adDetail.mainImage != null &&
                        adDetail.mainImage!.isNotEmpty) ||
                    adDetail.images.isNotEmpty)) ||
            (fallbackItem?.mainImage != null &&
                fallbackItem!.mainImage!.isNotEmpty));
    final mainImage = _imagePaths[0];
    if ((mainImage == null || mainImage.isEmpty) && !hasExistingImages) {
      ScaffoldMessenger.of(formContext).showSnackBar(
        SnackBar(
          content: Text(l10n.addListingUploadMainImage),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }
    if (!isEdit) {
      if (_selectedRegionId == null) {
        ScaffoldMessenger.of(formContext).showSnackBar(
          SnackBar(
            content: Text(l10n.addListingSelectViloyat),
            backgroundColor: AppColors.red,
          ),
        );
        return;
      }
      if (_selectedDistrictId == null) {
        ScaffoldMessenger.of(formContext).showSnackBar(
          SnackBar(
            content: Text(l10n.addListingSelectTuman),
            backgroundColor: AppColors.red,
          ),
        );
        return;
      }
    }
    final listingTypeStr = switch (_listingType) {
      _ListingType.product => 'Product',
      _ListingType.service => 'Service',
      _ListingType.car => 'Auto',
      _ListingType.home => 'Home',
      _ListingType.equipment => 'Equipment',
    };
    final adTypeStr = _adType;
    final existingMainUrl = isEdit
        ? (adDetail?.mainImage ?? fallbackItem?.mainImage)
        : null;
    final existingUrls = isEdit && adDetail != null
        ? adDetail.images
        : const <String>[];
    final params = CreateAdParams(
      title: titleUz,
      titleEn: _nameEnController.text.trim(),
      titleRu: _nameRuController.text.trim(),
      description: _descUzController.text.trim(),
      descriptionEn: _descEnController.text.trim(),
      descriptionRu: _descRuController.text.trim(),
      adType: adTypeStr,
      listingType: listingTypeStr,
      categoryId: category.id,
      price: price,
      currency: _currency,
      mainImagePath: (mainImage != null && mainImage.isNotEmpty)
          ? mainImage
          : null,
      additionalImagePaths: _imagePaths.skip(1).whereType<String>().toList(),
      existingMainImageUrl: existingMainUrl,
      existingImageUrls: existingUrls,
      weight: _weightValueController.text.trim().isEmpty
          ? null
          : _weightValueController.text.trim(),
      width: _widthController.text.trim().isEmpty
          ? null
          : _widthController.text.trim(),
      length: _lengthController.text.trim().isEmpty
          ? null
          : _lengthController.text.trim(),
      height: _heightController.text.trim().isEmpty
          ? null
          : _heightController.text.trim(),
      dimensionUnit: _dimensionUnit.isEmpty ? null : _dimensionUnit,
      weightUnit: _weightUnit.toLowerCase(),
      latitude: _latitude,
      longitude: _longitude,
      address: _addressName,
      regionId: _selectedRegionId,
      districtId: _selectedDistrictId,
      neighborhoodId: _selectedNeighborhoodId,
      dynamicFields: dynamicPayload,
    );
    if (!isEdit) {
      final user = formContext
          .read<ProfileBloc>()
          .state
          .profileModel
          ?.data
          .user;
      if (!_isUserFaceVerified(user) && !_soliqSessionVerified) {
        final verified = await _runSoliqVerification();
        if (!verified) return;
      }
    }
    if (!mounted || !formContext.mounted) return;
    if (isEdit) {
      formContext.read<AddListingBloc>().add(
        AddListingUpdateAdRequested(slug: widget.editSlug!, params: params),
      );
    } else {
      formContext.read<AddListingBloc>().add(
        AddListingCreateAdRequested(params),
      );
    }
  }

  Future<bool> _runSoliqVerification() async {
    if (_isFaceVerificationInProgress) return false;
    if (!mounted) return false;
    final user = context.read<ProfileBloc>().state.profileModel?.data.user;
    if (_isUserFaceVerified(user) || _soliqSessionVerified) return true;
    setState(() {
      _isFaceVerificationInProgress = true;
    });
    final data = await showSoliqIdentityInputSheet(context);
    if (data == null) {
      if (mounted) {
        setState(() {
          _isFaceVerificationInProgress = false;
        });
      }
      return false;
    }

    if (!mounted || !context.mounted) {
      return false;
    }
    final scan = await runSoliqIdFaceScan(context, identity: data);
    if (!scan.isSuccess && mounted && context.mounted) {
      debugPrint(
        '[FACE_VERIFY][SNACKBAR] verification failed: '
        '${scan.failureMessage ?? "Yuz ID tasdiqlanmadi."}',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(scan.failureMessage ?? "Yuz ID tasdiqlanmadi."),
          backgroundColor: AppColors.red,
        ),
      );
    }
    final ok = scan.isSuccess;
    if (mounted) {
      setState(() {
        _isFaceVerificationInProgress = false;
      });
    }
    if (ok && mounted && context.mounted) {
      setState(() {
        _soliqSessionVerified = true;
      });
      context.read<ProfileBloc>().add(const ProfileLoadEvent());
    }
    return ok;
  }

  // ─── AD TYPE TABS (Sell / Buy) ──────────────────────────────────

  Widget _buildAdTypeTabs(Color cardColor, Color textColor, Color borderColor) {
    final l10n = AppLocalizations.of(context)!;
    final types = [
      ('Sell', l10n.supportMenuSotaman),
      ('Buy', l10n.supportMenuSotibOlaman),
    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        color: cardColor,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: types.map((e) {
          final selected = _adType == e.$1;
          final selectedColor = e.$1 == 'Buy'
              ? AppColors.primaryBuying
              : AppColors.primary;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _adType = e.$1;
                });

                // Global app mode (theme/appbar va home list) ham yangilanishi uchun
                if (e.$1 == 'Buy') {
                  context.read<AppModeCubit>().setBuying();
                } else {
                  context.read<AppModeCubit>().setSelling();
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? selectedColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: AppText(
                  text: e.$2,
                  fontSize: 14,
                  fontWeight: selected ? 600 : 500,
                  color: selected ? AppColors.white : textColor,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── LISTING TYPE TABS (segmented) ──────────────────────────────

  Widget _buildTypeTabs(
    BuildContext formContext,
    Color cardColor,
    Color textColor,
    Color borderColor,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final primaryColor = context.read<AppModeCubit>().state.primaryColor;
    final types = [
      (_ListingType.product, l10n.listingTypeProduct),
      (_ListingType.service, l10n.listingTypeService),
      (_ListingType.car, l10n.listingTypeAuto),
      (_ListingType.home, l10n.listingTypeHome),
      (_ListingType.equipment, 'Uskuna'),
    ];

    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: types.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final e = types[i];
          final selected = _listingType == e.$1;
          return GestureDetector(
            onTap: () {
              setState(() {
                _listingType = e.$1;
                _selectedCategory = null;
                _selectedSubcategory = null;
                _selectedSubSubcategory = null;
                _dynamicValues.clear();
                _clearLoadedNestedCategories();
                _dynamicFields = [];
                _dynamicFieldsLoading = false;
              });
              formContext.read<AddListingBloc>().add(
                AddListingLoadCategoriesRequested(
                  categoryType: _categoryTypeForListingType(e.$1),
                ),
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: selected ? primaryColor : cardColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor),
              ),
              alignment: Alignment.center,
              child: AppText(
                text: e.$2,
                fontSize: 14,
                fontWeight: selected ? 600 : 500,
                color: selected ? AppColors.white : textColor,
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── SUMMA CARD ─────────────────────────────────────────────────

  Widget _buildSummaCard(
    Color cardColor,
    Color textColor,
    Color textSecondary,
    Color borderColor,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return _card(
      cardColor: cardColor,
      borderColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: AppText(
                  text: l10n.addListingPrice,
                  fontSize: 16,
                  fontWeight: 600,
                  color: textColor,
                ),
              ),
              AppText(
                text: '${l10n.addListingCurrency} ',
                fontSize: 14,
                fontWeight: 600,
                color: textColor,
              ),
              AppText(
                text: '*',
                fontSize: 14,
                fontWeight: 600,
                color: AppColors.red,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _inputField(
                  hint: l10n.addListingPrice,
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () => _showCurrencyPicker(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: context.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.borderColor),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppText(
                            text: _currency,
                            fontSize: 14,
                            fontWeight: 500,
                            color: textColor,
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── KATEGORIYA CARD ────────────────────────────────────────────

  Widget _buildCategoryCard(
    Color cardColor,
    Color textColor,
    Color textSecondary,
    Color borderColor,
  ) {
    return BlocBuilder<AddListingBloc, AddListingState>(
      buildWhen: (prev, cur) =>
          prev.categories != cur.categories ||
          prev.categoriesLoading != cur.categoriesLoading,
      builder: (context, state) {
        final l10n = AppLocalizations.of(context)!;
        final categories = state.categories ?? [];
        final isLoading = state.categoriesLoading;

        final subcategories = _selectedCategory == null
            ? <CategoryEntity>[]
            : (_loadedSubcategoriesParentId == _selectedCategory!.id
                  ? _loadedSubcategories
                  : <CategoryEntity>[]);

        final subSubcategories = _selectedSubcategory == null
            ? <CategoryEntity>[]
            : (_loadedSubSubcategoriesParentId == _selectedSubcategory!.id
                  ? _loadedSubSubcategories
                  : <CategoryEntity>[]);

        final showSubcategoryRow =
            _selectedCategory != null &&
            (_loadingSubcategories || subcategories.isNotEmpty);
        final showSubSubcategoryRow =
            _selectedSubcategory != null &&
            (_loadingSubSubcategories || subSubcategories.isNotEmpty);

        return _card(
          cardColor: cardColor,
          borderColor: borderColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppText(
                    text: l10n.addListingCategory,
                    fontSize: 16,
                    fontWeight: 600,
                    color: textColor,
                  ),
                  const SizedBox(width: 4),
                  AppText(
                    text: '*',
                    fontSize: 16,
                    fontWeight: 600,
                    color: AppColors.red,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (isLoading)
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: context.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  alignment: Alignment.center,
                  child: const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else
                _categoryDropdown(
                  hint: l10n.addListingSelectCategory,
                  items: categories,
                  selected: _selectedCategory,
                  textColor: textColor,
                  textSecondary: textSecondary,
                  borderColor: borderColor,
                  onSelected: (cat) {
                    setState(() {
                      _selectedCategory = cat;
                      _selectedSubcategory = null;
                      _selectedSubSubcategory = null;
                      _dynamicValues.clear();
                      _clearLoadedNestedCategories();
                    });
                    _fetchSubcategoriesForCategory(cat.id);
                  },
                ),
              if (showSubcategoryRow) ...[
                const SizedBox(height: 10),
                if (_loadingSubcategories)
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: context.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    alignment: Alignment.center,
                    child: const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else
                  _categoryDropdown(
                    hint: l10n.addListingSelectSubcategory,
                    items: subcategories,
                    selected: _selectedSubcategory,
                    textColor: textColor,
                    textSecondary: textSecondary,
                    borderColor: borderColor,
                    onSelected: (cat) {
                      setState(() {
                        _selectedSubcategory = cat;
                        _selectedSubSubcategory = null;
                        _dynamicValues.clear();
                        _loadedSubSubcategoriesParentId = null;
                        _loadedSubSubcategories = [];
                        _loadingSubSubcategories = false;
                      });
                      _fetchSubSubcategoriesForSubcategory(cat.id);
                    },
                  ),
              ],
              if (showSubSubcategoryRow) ...[
                const SizedBox(height: 10),
                if (_loadingSubSubcategories)
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: context.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    alignment: Alignment.center,
                    child: const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else
                  _categoryDropdown(
                    hint: l10n.addListingSelectType,
                    items: subSubcategories,
                    selected: _selectedSubSubcategory,
                    textColor: textColor,
                    textSecondary: textSecondary,
                    borderColor: borderColor,
                    onSelected: (cat) {
                      setState(() {
                        _selectedSubSubcategory = cat;
                        _dynamicValues.clear();
                      });
                      _refreshDynamicFieldsAfterCategoryStep();
                    },
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _categoryDropdown({
    required String hint,
    required List<CategoryEntity> items,
    required CategoryEntity? selected,
    required Color textColor,
    required Color textSecondary,
    required Color borderColor,
    required void Function(CategoryEntity) onSelected,
  }) {
    final primaryColor = context.read<AppModeCubit>().state.primaryColor;
    return GestureDetector(
      onTap: () => _showCategorySheet(
        hint: hint,
        items: items,
        selected: selected,
        textColor: textColor,
        textSecondary: textSecondary,
        borderColor: borderColor,
        onSelected: onSelected,
      ),
      child: Container(
        height: _kInputHeight,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: context.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected != null ? primaryColor : borderColor,
            width: selected != null ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: AppText(
                text: selected?.displayName ?? hint,
                fontSize: 14,
                fontWeight: selected != null ? 500 : 400,
                color: selected != null ? textColor : textSecondary,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void _showCategorySheet({
    required String hint,
    required List<CategoryEntity> items,
    required CategoryEntity? selected,
    required Color textColor,
    required Color textSecondary,
    required Color borderColor,
    required void Function(CategoryEntity) onSelected,
  }) {
    final pageContext = context;
    final primaryColor = context.read<AppModeCubit>().state.primaryColor;
    showModalBottomSheet<void>(
      context: pageContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (sheetContext, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: sheetContext.cardSurface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: borderColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: AppText(
                      text: hint,
                      fontSize: 16,
                      fontWeight: 600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: items.length,
                      separatorBuilder: (_, _) =>
                          Divider(height: 1, color: borderColor),
                      itemBuilder: (_, i) {
                        final item = items[i];
                        final isSelected = selected?.id == item.id;
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          leading: item.image != null && item.image!.isNotEmpty
                              ? Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: context.surfaceContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: AppImage(
                                    path: item.image!,
                                    size: 40,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                )
                              : Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: context.surfaceContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.category_outlined,
                                    color: textSecondary,
                                    size: 20,
                                  ),
                                ),
                          title: AppText(
                            text: item.displayName,
                            fontSize: 15,
                            fontWeight: isSelected ? 600 : 400,
                            color: isSelected ? primaryColor : textColor,
                          ),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle_rounded,
                                  color: primaryColor,
                                  size: 20,
                                )
                              : null,
                          onTap: () {
                            Navigator.pop(sheetContext);
                            onSelected(item);
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ─── MAHSULOT NOMI CARD ─────────────────────────────────────────

  Widget _buildDynamicFieldsCard(
    Color cardColor,
    Color textColor,
    Color textSecondary,
    Color borderColor,
  ) {
    if (_dynamicFieldsLoading) {
      return _card(
        cardColor: cardColor,
        borderColor: borderColor,
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(8),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    final visible = _dynamicFields.where(_isDynamicFieldVisible).toList();
    if (visible.isEmpty) return const SizedBox.shrink();

    return _card(
      cardColor: cardColor,
      borderColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader("Qo'shimcha maydonlar", textColor, textSecondary),
          const SizedBox(height: 12),
          ...visible.map((field) {
            final isRequired = field.required;
            final label = isRequired ? '${field.label} *' : field.label;
            final type = field.type.toLowerCase();
            if (type == 'checkbox') {
              final checked = _dynamicValues[field.name] == true;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: CheckboxListTile(
                  value: checked,
                  contentPadding: EdgeInsets.zero,
                  title: Text(label, style: TextStyle(color: textColor)),
                  onChanged: (v) {
                    setState(() => _dynamicValues[field.name] = v == true);
                  },
                ),
              );
            }
            if (type == 'select') {
              final options = field.options;
              final selected = _dynamicValues[field.name]?.toString();
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: label,
                      fontSize: 14,
                      fontWeight: 600,
                      color: textColor,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: _kInputHeight,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: context.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selected,
                          isExpanded: true,
                          hint: Text(
                            field.placeholder?.isNotEmpty == true
                                ? field.placeholder!
                                : 'Tanlang',
                            style: TextStyle(color: textSecondary),
                          ),
                          items: options
                              .map(
                                (e) => DropdownMenuItem<String>(
                                  value: e.value,
                                  child: Text(
                                    e.label,
                                    style: TextStyle(color: textColor),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            setState(() => _dynamicValues[field.name] = v);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            final controller = _controllerForDynamicField(field.name);
            if (_dynamicValues[field.name] != null && controller.text.isEmpty) {
              controller.text = _dynamicValues[field.name].toString();
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _labeledInput(
                label,
                field.placeholder?.isNotEmpty == true
                    ? field.placeholder!
                    : field.label,
                controller,
                context.surfaceContainer,
                borderColor,
                isNumber: type == 'number',
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProductNameCard(
    Color cardColor,
    Color textColor,
    Color textSecondary,
    Color borderColor,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return _card(
      cardColor: cardColor,
      borderColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: l10n.addListingProductName,
            fontSize: 16,
            fontWeight: 600,
            color: textColor,
          ),
          const SizedBox(height: 12),
          _buildLangTabs(cardColor, textColor, borderColor),
          const SizedBox(height: 12),
          _inputField(
            hint: l10n.addListingProductName,
            controller: switch (_nameLang) {
              _NameLang.uz => _nameUzController,
              _NameLang.ru => _nameRuController,
              _NameLang.en => _nameEnController,
            },
          ),
          const SizedBox(height: 12),
          _inputField(
            hint: l10n.addListingDescription,
            controller: switch (_nameLang) {
              _NameLang.uz => _descUzController,
              _NameLang.ru => _descRuController,
              _NameLang.en => _descEnController,
            },
            maxLines: 4,
            minLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildLangTabs(Color cardColor, Color textColor, Color borderColor) {
    final primaryColor = context.read<AppModeCubit>().state.primaryColor;
    const tabs = [
      (_NameLang.uz, 'UZ', '🇺🇿'),
      (_NameLang.ru, 'RU', '🇷🇺'),
      (_NameLang.en, 'EN', '🇬🇧'),
    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
        color: context.surfaceContainer,
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final tab = tabs[i];
          final selected = _nameLang == tab.$1;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _nameLang = tab.$1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  border: i > 0 && !selected
                      ? Border(left: BorderSide(color: borderColor, width: 0.5))
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(tab.$3, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    AppText(
                      text: tab.$2,
                      fontSize: 14,
                      fontWeight: 600,
                      color: selected ? AppColors.white : textColor,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─── RASM YUKLASH CARD ──────────────────────────────────────────

  Future<void> _pickImage(int index) async {
    final file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file != null && mounted) {
      setState(() {
        _imagePaths[index] = file.path;
      });
    }
  }

  Widget _buildImageUploadCard(
    Color cardColor,
    Color textColor,
    Color textSecondary,
    Color borderColor,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final labels = [
      l10n.addListingMainImage,
      l10n.addListingImageUpload,
      l10n.addListingImageUpload,
      l10n.addListingImageUpload,
    ];
    return _card(
      cardColor: cardColor,
      borderColor: borderColor,
      child: Column(
        children: [
          _sectionHeader(l10n.addListingImageUpload, textColor, textSecondary),
          const SizedBox(height: 16),
          Row(
            children: List.generate(4, (i) {
              final path = _imagePaths[i];
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < 3 ? 10 : 0),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: GestureDetector(
                      onTap: () => _pickImage(i),
                      child: Container(
                        decoration: BoxDecoration(
                          color: context.surfaceContainer,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: path != null && path.isNotEmpty
                            ? Image.file(
                                File(path),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.file_upload_outlined,
                                    size: 26,
                                    color: textSecondary,
                                  ),
                                  const SizedBox(height: 6),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 2,
                                    ),
                                    child: Text(
                                      labels[i],
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w400,
                                        color: textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ─── PARAMETRLAR CARD (toggle / expand pastga) ───────────────────

  // ignore: unused_element
  Widget _buildParametersCard(
    Color cardColor,
    Color textColor,
    Color textSecondary,
    Color borderColor,
  ) {
    final surface = context.surfaceContainer;
    final primaryColor = context.read<AppModeCubit>().state.primaryColor;
    final l10n = AppLocalizations.of(context)!;

    return _card(
      cardColor: cardColor,
      borderColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(l10n.addListingParameters, textColor, textSecondary),
          const SizedBox(height: 8),
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(top: 12, bottom: 8),
              leading: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withValues(alpha: 0.1),
                ),
                child: Icon(Icons.add, size: 16, color: primaryColor),
              ),
              title: AppText(
                text: l10n.addListingAddParameter,
                fontSize: 14,
                fontWeight: 600,
                color: textColor,
              ),
              subtitle: AppText(
                text: l10n.addListingAddParameterDescription(_maxParams),
                fontSize: 12,
                fontWeight: 400,
                color: textSecondary,
              ),
              children: [_buildParamForm(surface, borderColor, textColor)],
            ),
          ),
          Divider(color: borderColor, height: 1),
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(top: 12, bottom: 8),
              leading: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withValues(alpha: 0.1),
                ),
                child: Icon(Icons.add, size: 16, color: primaryColor),
              ),
              title: AppText(
                text: l10n.addListingAddColors,
                fontSize: 14,
                fontWeight: 600,
                color: textColor,
              ),
              subtitle: AppText(
                text: l10n.addListingAddColorsDescription(_maxColors),
                fontSize: 12,
                fontWeight: 400,
                color: textSecondary,
              ),
              children: [
                _buildColorsForm(
                  surface,
                  borderColor,
                  textColor,
                  textSecondary,
                ),
              ],
            ),
          ),
          Divider(color: borderColor, height: 1),
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(top: 12, bottom: 8),
              leading: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withValues(alpha: 0.1),
                ),
                child: Icon(Icons.add, size: 16, color: primaryColor),
              ),
              title: AppText(
                text: l10n.addListingAddSizes,
                fontSize: 14,
                fontWeight: 600,
                color: textColor,
              ),
              subtitle: AppText(
                text: l10n.addListingAddSizesDescription(_maxSizes),
                fontSize: 12,
                fontWeight: 400,
                color: textSecondary,
              ),
              children: [
                _buildSizesForm(surface, borderColor, textColor, textSecondary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── O'LCHAM VA OG'IRLIK CARD ────────────────────────────────────

  LocationPlaceEntity? _placeById(List<LocationPlaceEntity> list, int? id) {
    if (id == null) return null;
    for (final e in list) {
      if (e.id == id) return e;
    }
    return null;
  }

  void _applyCoordsFromPlace(LocationPlaceEntity? place) {
    if (place?.latitude != null && place?.longitude != null) {
      _latitude = place!.latitude;
      _longitude = place.longitude;
    }
  }

  Future<void> _loadRegions() async {
    setState(() => _regionsLoading = true);
    final result = await getIt<ListingRepository>().getRegions();
    if (!mounted) return;
    result.either(
      (failure) {
        setState(() {
          _regionsLoading = false;
        });
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
      (_) {
        setState(() => _districtsLoading = false);
      },
      (list) {
        setState(() {
          _districts = list;
          _districtsLoading = false;
        });
      },
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
      (_) {
        setState(() => _neighborhoodsLoading = false);
      },
      (list) {
        setState(() {
          _neighborhoods = list;
          _neighborhoodsLoading = false;
        });
      },
    );
  }

  Widget _locationCascadeDropdown({
    required String labelText,
    required bool isRequiredField,
    required List<LocationPlaceEntity> items,
    required int? value,
    required bool loading,
    required bool enabled,
    required ValueChanged<int?> onChanged,
    required VoidCallback onClear,
    required Color surface,
    required Color borderColor,
    required Color textColor,
    required Color textSecondary,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final label = isRequiredField ? '$labelText *' : labelText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(text: label, fontSize: 14, fontWeight: 600, color: textColor),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                height: _kInputHeight,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                alignment: Alignment.centerLeft,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: value,
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
                              AppText(
                                text: l10n.addListingLoading,
                                fontSize: 14,
                                fontWeight: 400,
                                color: textSecondary,
                              ),
                            ],
                          )
                        : AppText(
                            text: l10n.addListingTanlang,
                            fontSize: 14,
                            fontWeight: 400,
                            color: textSecondary,
                          ),
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: textSecondary,
                    ),
                    items: items
                        .map(
                          (e) => DropdownMenuItem<int>(
                            value: e.id,
                            child: AppText(
                              text: e.name,
                              fontSize: 14,
                              fontWeight: 500,
                              color: textColor,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: enabled && !loading ? onChanged : null,
                  ),
                ),
              ),
            ),
            if (value != null)
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

  Widget _buildLocationCard(
    Color cardColor,
    Color textColor,
    Color textSecondary,
    Color borderColor,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final surface = context.surfaceContainer;
    return _card(
      cardColor: cardColor,
      borderColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: l10n.addListingLocation,
            fontSize: 14,
            fontWeight: 600,
            color: textColor,
          ),
          const SizedBox(height: 12),
          _locationCascadeDropdown(
            labelText: l10n.addListingViloyat,
            isRequiredField: true,
            items: _regions,
            value: _selectedRegionId,
            loading: _regionsLoading,
            enabled: true,
            surface: surface,
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
                if (id != null) {
                  _applyCoordsFromPlace(_placeById(_regions, id));
                } else {
                  _latitude = null;
                  _longitude = null;
                  _addressName = null;
                }
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
                _latitude = null;
                _longitude = null;
                _addressName = null;
              });
            },
          ),
          const SizedBox(height: 14),
          _locationCascadeDropdown(
            labelText: l10n.districtLabel,
            isRequiredField: true,
            items: _districts,
            value: _selectedDistrictId,
            loading: _districtsLoading,
            enabled: _selectedRegionId != null,
            surface: surface,
            borderColor: borderColor,
            textColor: textColor,
            textSecondary: textSecondary,
            onChanged: (id) {
              setState(() {
                _selectedDistrictId = id;
                _selectedNeighborhoodId = null;
                _neighborhoods = [];
                if (id != null) {
                  _applyCoordsFromPlace(_placeById(_districts, id));
                } else {
                  _applyCoordsFromPlace(
                    _placeById(_regions, _selectedRegionId),
                  );
                }
              });
              if (id != null) _loadNeighborhoods(id);
            },
            onClear: () {
              setState(() {
                _selectedDistrictId = null;
                _selectedNeighborhoodId = null;
                _neighborhoods = [];
                _applyCoordsFromPlace(_placeById(_regions, _selectedRegionId));
              });
            },
          ),
          const SizedBox(height: 14),
          _locationCascadeDropdown(
            labelText: l10n.addListingMahalla,
            isRequiredField: false,
            items: _neighborhoods,
            value: _selectedNeighborhoodId,
            loading: _neighborhoodsLoading,
            enabled: _selectedDistrictId != null,
            surface: surface,
            borderColor: borderColor,
            textColor: textColor,
            textSecondary: textSecondary,
            onChanged: (id) {
              setState(() {
                _selectedNeighborhoodId = id;
                if (id != null) {
                  _applyCoordsFromPlace(_placeById(_neighborhoods, id));
                } else {
                  _applyCoordsFromPlace(
                    _placeById(_districts, _selectedDistrictId),
                  );
                }
              });
            },
            onClear: () {
              setState(() {
                _selectedNeighborhoodId = null;
                _applyCoordsFromPlace(
                  _placeById(_districts, _selectedDistrictId),
                );
              });
            },
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _pickLocation,
            child: Container(
              padding: const EdgeInsets.all(AppDimens.paddingMedium),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on_outlined, color: textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppText(
                      text:
                          _addressName ??
                          ((_latitude != null && _longitude != null)
                              ? l10n.addListingCoordinates(
                                  _latitude!.toStringAsFixed(5),
                                  _longitude!.toStringAsFixed(5),
                                )
                              : l10n.addListingSelectOnMap),
                      fontSize: 14,
                      color: (_latitude != null) ? textColor : textSecondary,
                    ),
                  ),
                  Icon(Icons.chevron_right, color: textSecondary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => MapSelectionPage(
          initialPoint: (_latitude != null && _longitude != null)
              ? Point(latitude: _latitude!, longitude: _longitude!)
              : null,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        final point = result['point'] as Point;
        _latitude = point.latitude;
        _longitude = point.longitude;
        _addressName = result['address'] as String?;
      });
    }
  }

  // ignore: unused_element
  Widget _buildDimensionsWeightCard(
    Color cardColor,
    Color textColor,
    Color textSecondary,
    Color borderColor,
  ) {
    final surface = context.surfaceContainer;
    const weightUnits = ['KG', 'g'];
    const dimensionUnits = ['cm', 'm'];

    final l10n = AppLocalizations.of(context)!;
    return _card(
      cardColor: cardColor,
      borderColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            l10n.addListingDimensionsAndWeight,
            textColor,
            textSecondary,
          ),
          const SizedBox(height: 16),
          // Og'irlik
          AppText(
            text: l10n.addListingWeight,
            fontSize: 16,
            fontWeight: 600,
            color: textColor,
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _labeledInput(
                  l10n.addListingValue,
                  l10n.addListingValue,
                  _weightValueController,
                  surface,
                  borderColor,
                  isNumber: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _unitDropdown(
                  label: l10n.addListingUnit,
                  value: _weightUnit,
                  items: weightUnits,
                  surface: surface,
                  borderColor: borderColor,
                  textColor: textColor,
                  textSecondary: textSecondary,
                  onChanged: (v) => setState(() => _weightUnit = v ?? 'KG'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // O'lchamlar
          AppText(
            text: l10n.addListingDimensions,
            fontSize: 16,
            fontWeight: 600,
            color: textColor,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _labeledInput(
                  l10n.addListingLength,
                  l10n.addListingLength,
                  _lengthController,
                  surface,
                  borderColor,
                  isNumber: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _labeledInput(
                  l10n.addListingWidth,
                  l10n.addListingWidth,
                  _widthController,
                  surface,
                  borderColor,
                  isNumber: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _labeledInput(
                  l10n.addListingHeight,
                  l10n.addListingHeight,
                  _heightController,
                  surface,
                  borderColor,
                  isNumber: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _unitDropdown(
            label: l10n.addListingDimensionUnit,
            value: _dimensionUnit,
            items: dimensionUnits,
            surface: surface,
            borderColor: borderColor,
            textColor: textColor,
            textSecondary: textSecondary,
            displayLabels: const {'cm': 'sm (santimetr)', 'm': 'm (metr)'},
            onChanged: (v) => setState(() => _dimensionUnit = v ?? 'cm'),
          ),
        ],
      ),
    );
  }

  Widget _unitDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Color surface,
    required Color borderColor,
    required Color textColor,
    required Color textSecondary,
    Map<String, String>? displayLabels,
    required ValueChanged<String?> onChanged,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(text: label, fontSize: 14, fontWeight: 600, color: textColor),
        const SizedBox(height: 8),
        Container(
          height: _kInputHeight,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          alignment: Alignment.centerLeft,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: AppText(
                text: l10n.addListingTanlang,
                fontSize: 14,
                fontWeight: 400,
                color: textSecondary,
              ),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: textSecondary,
              ),
              items: items
                  .map(
                    (e) => DropdownMenuItem<String>(
                      value: e,
                      child: AppText(
                        text: displayLabels?[e] ?? e,
                        fontSize: 14,
                        fontWeight: 500,
                        color: textColor,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildParamForm(Color surface, Color borderColor, Color textColor) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(_paramRows.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _labeledInput(
                    l10n.addListingParameterName,
                    l10n.addListingParameterHint,
                    _paramRows[i].name,
                    surface,
                    borderColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _labeledInput(
                    l10n.addListingParameterValue,
                    l10n.addListingParameterValueHint,
                    _paramRows[i].value,
                    surface,
                    borderColor,
                  ),
                ),
                const SizedBox(width: 8),
                _removeIconBtn(() {
                  if (_paramRows.length <= 1) return;
                  setState(() {
                    _paramRows[i].name.dispose();
                    _paramRows[i].value.dispose();
                    _paramRows.removeAt(i);
                  });
                }),
              ],
            ),
          );
        }),
        _addRowBtn(
          '${l10n.addListingAddParameter} (${_paramRows.length}/$_maxParams)',
          () {
            if (_paramRows.length >= _maxParams) return;
            setState(() => _paramRows.add(_ParamRowData()));
          },
          _paramRows.length < _maxParams,
          surface,
          borderColor,
          textColor,
        ),
      ],
    );
  }

  Widget _buildColorsForm(
    Color surface,
    Color borderColor,
    Color textColor,
    Color textSecondary,
  ) {
    return BlocBuilder<AddListingBloc, AddListingState>(
      builder: (context, state) {
        final colors = state.colors;
        final isLoading = state.colorsLoading;
        final errorMessage = state.colorsError;
        final l10n = AppLocalizations.of(context)!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...List.generate(_colorRows.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ColorDropdownField(
                      label: l10n.addListingSelectColor,
                      surface: surface,
                      borderColor: borderColor,
                      textColor: textColor,
                      textSecondary: textSecondary,
                      colors: colors,
                      value: _colorRows[i].selectedColorId,
                      onChanged: (id) =>
                          setState(() => _colorRows[i].selectedColorId = id),
                      isLoading: isLoading,
                      errorMessage: errorMessage,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _labeledInput(
                            l10n.addListingPrice,
                            l10n.addListingPrice,
                            _colorRows[i].price,
                            surface,
                            borderColor,
                            isNumber: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _labeledInput(
                            l10n.addListingDiscount,
                            l10n.addListingDiscountHint,
                            _colorRows[i].discount,
                            surface,
                            borderColor,
                            isNumber: true,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _removeIconBtn(() {
                          if (_colorRows.length <= 1) return;
                          setState(() {
                            _colorRows[i].price.dispose();
                            _colorRows[i].discount.dispose();
                            _colorRows.removeAt(i);
                          });
                        }),
                      ],
                    ),
                  ],
                ),
              );
            }),
            _addRowBtn(
              '${l10n.addListingAddColors} (${_colorRows.length}/$_maxColors)',
              () {
                if (_colorRows.length >= _maxColors) return;
                setState(() => _colorRows.add(_ColorRowData()));
              },
              _colorRows.length < _maxColors,
              surface,
              borderColor,
              textColor,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSizesForm(
    Color surface,
    Color borderColor,
    Color textColor,
    Color textSecondary,
  ) {
    return BlocBuilder<AddListingBloc, AddListingState>(
      builder: (context, state) {
        final sizes = state.sizes;
        final isLoading = state.sizesLoading;
        final errorMessage = state.sizesError;
        final l10n = AppLocalizations.of(context)!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...List.generate(_sizeRows.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizeDropdownField(
                      label: l10n.addListingSelectSize,
                      surface: surface,
                      borderColor: borderColor,
                      textColor: textColor,
                      textSecondary: textSecondary,
                      sizes: sizes,
                      value: _sizeRows[i].selectedSizeId,
                      onChanged: (id) =>
                          setState(() => _sizeRows[i].selectedSizeId = id),
                      isLoading: isLoading,
                      errorMessage: errorMessage,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _labeledInput(
                            l10n.addListingPrice,
                            l10n.addListingPrice,
                            _sizeRows[i].price,
                            surface,
                            borderColor,
                            isNumber: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _labeledInput(
                            l10n.addListingDiscount,
                            l10n.addListingDiscountHint,
                            _sizeRows[i].discount,
                            surface,
                            borderColor,
                            isNumber: true,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _removeIconBtn(() {
                          if (_sizeRows.length <= 1) return;
                          setState(() {
                            _sizeRows[i].price.dispose();
                            _sizeRows[i].discount.dispose();
                            _sizeRows.removeAt(i);
                          });
                        }),
                      ],
                    ),
                  ],
                ),
              );
            }),
            _addRowBtn(
              '${l10n.addListingAddSizes} (${_sizeRows.length}/$_maxSizes)',
              () {
                if (_sizeRows.length >= _maxSizes) return;
                setState(() => _sizeRows.add(_SizeRowData()));
              },
              _sizeRows.length < _maxSizes,
              surface,
              borderColor,
              textColor,
            ),
          ],
        );
      },
    );
  }

  Widget _labeledInput(
    String label,
    String hint,
    TextEditingController? controller,
    Color surface,
    Color borderColor, {
    bool isNumber = false,
    bool readOnly = false,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: label,
          fontSize: 14,
          fontWeight: 600,
          color: context.textPrimary,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: _kInputHeight,
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: isNumber ? TextInputType.number : null,
            style: TextStyle(fontSize: 14, color: context.textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(fontSize: 14, color: context.textSecondary),
              filled: true,
              fillColor: surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              suffixIcon: suffix,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderColor),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _removeIconBtn(VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.red.withValues(alpha: 0.1),
          ),
          child: Icon(Icons.close, size: 22, color: AppColors.red),
        ),
      ),
    );
  }

  Widget _addRowBtn(
    String text,
    VoidCallback onTap,
    bool enabled,
    Color surface,
    Color borderColor,
    Color textColor,
  ) {
    final primaryColor = context.read<AppModeCubit>().state.primaryColor;
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add,
                  size: 22,
                  color: enabled ? primaryColor : textColor,
                ),
                const SizedBox(width: 8),
                AppText(
                  text: text,
                  fontSize: 14,
                  fontWeight: 600,
                  color: textColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── SHARED WIDGETS ─────────────────────────────────────────────

  Widget _card({
    required Color cardColor,
    required Color borderColor,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor.withValues(alpha: 0.5)),
      ),
      child: child,
    );
  }

  Widget _sectionHeader(String title, Color textColor, Color textSecondary) {
    return Row(
      children: [
        Expanded(
          child: AppText(
            text: title,
            fontSize: 16,
            fontWeight: 600,
            color: textColor,
          ),
        ),
        Icon(Icons.arrow_forward_ios_rounded, size: 16, color: textSecondary),
      ],
    );
  }

  Widget _inputField({
    required String hint,
    TextEditingController? controller,
    TextInputType? keyboardType,
    bool readOnly = false,
    int maxLines = 1,
    int minLines = 1,
    VoidCallback? onTap,
  }) {
    final surfaceBg = context.surfaceContainer;
    final border = context.borderColor;
    final hintColor = context.textSecondary;
    final primaryColor = context.read<AppModeCubit>().state.primaryColor;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: maxLines,
      minLines: minLines,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: context.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: hintColor,
        ),
        filled: true,
        fillColor: surfaceBg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
      ),
    );
  }

  Widget _primaryButton(String text, {required VoidCallback onTap}) {
    final primaryColor = context.read<AppModeCubit>().state.primaryColor;
    return SizedBox(
      width: double.infinity,
      child: ContainerW(
        onTap: onTap,
        color: primaryColor,
        radius: 12,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: AppText(
              text: text,
              fontSize: 16,
              fontWeight: 600,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _showCurrencyPicker() {
    final l10n = AppLocalizations.of(context)!;
    final textColor = context.textPrimary;
    final primaryColor = context.read<AppModeCubit>().state.primaryColor;
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(
                  text: l10n.addListingSelectCurrency,
                  fontSize: 18,
                  fontWeight: 700,
                  color: textColor,
                ),
                const SizedBox(height: 8),
                for (final c in ['UZS', 'USD', 'EUR'])
                  ListTile(
                    title: AppText(
                      text: c,
                      fontSize: 16,
                      fontWeight: 500,
                      color: textColor,
                    ),
                    trailing: _currency == c
                        ? Icon(Icons.check_circle, color: primaryColor)
                        : null,
                    onTap: () {
                      setState(() => _currency = c);
                      Navigator.pop(ctx);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
