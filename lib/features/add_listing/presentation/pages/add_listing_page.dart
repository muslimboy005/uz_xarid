import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/constants/app_dimens.dart';
import 'package:uz_xarid/core/dp/infection.dart';
import 'package:uz_xarid/core/service/local_service.dart';
import 'package:uz_xarid/core/theme/theme_colors.dart';
import 'package:uz_xarid/core/widgets/app_text.dart';
import 'package:uz_xarid/core/widgets/uzxarid_app_bar.dart';
import 'package:uz_xarid/core/widgets/w__container.dart';
import 'package:uz_xarid/features/add_listing/domain/entities/create_ad_params.dart';
import 'package:uz_xarid/features/catalog/domain/entities/category_entity.dart';
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

enum _ListingType { product, service, car, home }

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
  late Future<bool> _authFuture;

  _ListingType _listingType = _ListingType.product;
  String _adType = 'Sell';
  _NameLang _nameLang = _NameLang.uz;
  String _currency = 'UZS';

  CategoryEntity? _selectedCategory;
  CategoryEntity? _selectedSubcategory;
  CategoryEntity? _selectedSubSubcategory;
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

  @override
  void initState() {
    super.initState();
    _authFuture = getIt<SecureStorageService>().hasToken();
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
    super.dispose();
  }

  void _refreshAuth() {
    setState(() {
      _authFuture = getIt<SecureStorageService>().hasToken();
    });
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

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: UzXaridAppBar(
        onSearchChanged: (_) {},
        onMenuTap: () {},
        actions: [
          IconButton(
            onPressed: () {
              context.push('/soon');
            },
            icon: const Icon(
              Icons.sync_alt,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          color: bodyBg,
          height: MediaQuery.of(context).size.height,
          child: BlocListener<ProfileBloc, ProfileState>(
            listener: (context, state) {
              if (state.status == ProfileStatus.success) _refreshAuth();
            },
            child: FutureBuilder<bool>(
              future: _authFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final isLoggedIn = snapshot.data == true;
                if (!isLoggedIn) {
                  return _buildLoginRequired(
                    l10n,
                    cardColor,
                    textColor,
                    textSecondary,
                    borderColor,
                  );
                }
                return BlocProvider(
                  create: (_) {
                    final bloc = getIt<AddListingBloc>()
                      ..add(AddListingLoadCategoriesRequested(
                        categoryType: _categoryTypeForListingType(_listingType),
                      ))
                      ..add(const AddListingLoadColorsRequested())
                      ..add(const AddListingLoadSizesRequested());
                    if (widget.editSlug != null && widget.editSlug!.isNotEmpty) {
                      developer.log('AddListingPage: edit mode, loading ad slug=${widget.editSlug}', name: 'AddListingPage');
                      bloc.add(AddListingLoadAdForEditRequested(widget.editSlug!));
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
            ),
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
              children: [
                AppText(
                  text: 'E\'lon qo\'shish',
                  fontSize: 24,
                  fontWeight: 700,
                  color: textColor,
                ),
                const SizedBox(height: 8),
                AppText(
                  text: 'E\'lon berishdan oldin akkauntga kirish kerak.',
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
      ],
    );
  }

  static String _categoryTypeForListingType(_ListingType type) {
    return switch (type) {
      _ListingType.product => 'Product',
      _ListingType.service => 'Service',
      _ListingType.car => 'Auto',
      _ListingType.home => 'Home',
    };
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

  void _fillFormFromAdDetail(AdDetailEntity ad, List<CategoryEntity>? categories) {
    if (_formFilledFromEdit) {
      developer.log('AddListing: _fillFormFromAdDetail skipped (already filled)', name: 'AddListingPage');
      return;
    }
    _formFilledFromEdit = true;
    developer.log('AddListing: _fillFormFromAdDetail applying title=${ad.title}, price=${ad.price}, categoryId=${ad.categoryId}', name: 'AddListingPage');
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
    setState(() {});
  }

  void _fillFormFromMyListingItem(MyListingItemDto item, List<CategoryEntity>? categories) {
    if (_formFilledFromEdit) return;
    _formFilledFromEdit = true;
    _usedFallbackForEdit = true;
    developer.log('AddListing: _fillFormFromMyListingItem slug=${item.slug}, title=${item.title}', name: 'AddListingPage');
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
        default:
          _listingType = _ListingType.product;
      }
    }
    if (item.categoryId != null && categories != null && categories.isNotEmpty) {
      final path = _findCategoryPath(categories, item.categoryId!);
      if (path != null && path.isNotEmpty) {
        _selectedCategory = path[0];
        _selectedSubcategory = path.length > 1 ? path[1] : null;
        _selectedSubSubcategory = path.length > 2 ? path[2] : null;
      }
    }
    setState(() {});
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
        final adChanged = cur.adDetailForEdit != null && prev.adDetailForEdit != cur.adDetailForEdit;
        final categoriesArrived = cur.adDetailForEdit != null && prev.categories != cur.categories;
        final errorArrived = cur.loadAdForEditError != null && prev.loadAdForEditError != cur.loadAdForEditError;
        final shouldListen = prev.createAdSlug != cur.createAdSlug ||
            prev.createAdError != cur.createAdError ||
            adChanged ||
            categoriesArrived ||
            errorArrived;
        return shouldListen;
      },
      listener: (context, state) {
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
        final hasCategories = state.categories != null && state.categories!.isNotEmpty;
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
              content: Text(widget.editSlug != null
                  ? 'E\'lon yangilandi'
                  : 'E\'lon muvaffaqiyatli yaratildi'),
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
        if (widget.editSlug != null && state.loadAdForEditLoading && state.adDetailForEdit == null && !_usedFallbackForEdit) {
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
                    child: const Text('Orqaga'),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAdTypeTabs(cardColor, textColor, borderColor),
                  const SizedBox(height: 16),
                  _buildTypeTabs(formContext, cardColor, textColor, borderColor),
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
                _buildParametersCard(
                  cardColor,
                  textColor,
                  textSecondary,
                  borderColor,
                ),
                const SizedBox(height: 16),
                _buildDimensionsWeightCard(
                  cardColor,
                  textColor,
                  textSecondary,
                  borderColor,
                ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: BlocBuilder<AddListingBloc, AddListingState>(
              buildWhen: (prev, cur) =>
                  prev.createAdLoading != cur.createAdLoading,
              builder: (context, state) {
                final isEdit = widget.editSlug != null && widget.editSlug!.isNotEmpty;
                final label = state.createAdLoading
                    ? 'Yuklanmoqda...'
                    : (isEdit ? 'Saqlash' : 'E\'lon yaratish');
                return _primaryButton(
                  label,
                  onTap: state.createAdLoading
                      ? () {}
                      : () => _submitCreateAd(context),
                );
              },
            ),
          ),
        ],
      );
      },
    );
  }

  void _submitCreateAd(BuildContext formContext) {
    final category = _selectedSubSubcategory ??
        _selectedSubcategory ??
        _selectedCategory;
    if (category == null) {
      ScaffoldMessenger.of(formContext).showSnackBar(
        const SnackBar(
          content: Text('Kategoriyani tanlang'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }
    final titleUz = _nameUzController.text.trim();
    if (titleUz.isEmpty) {
      ScaffoldMessenger.of(formContext).showSnackBar(
        const SnackBar(
          content: Text('Mahsulot nomini kiriting'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }
    final price = _amountController.text.trim();
    if (price.isEmpty) {
      ScaffoldMessenger.of(formContext).showSnackBar(
        const SnackBar(
          content: Text('Summani kiriting'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }
    final isEdit = widget.editSlug != null && widget.editSlug!.isNotEmpty;
    final blocState = formContext.read<AddListingBloc>().state;
    final adDetail = blocState.adDetailForEdit;
    final fallbackItem = widget.editFallbackItem is MyListingItemDto
        ? widget.editFallbackItem as MyListingItemDto
        : null;
    final hasExistingImages = isEdit &&
        ((adDetail != null &&
            ((adDetail.mainImage != null && adDetail.mainImage!.isNotEmpty) ||
                adDetail.images.isNotEmpty)) ||
            (fallbackItem?.mainImage != null && fallbackItem!.mainImage!.isNotEmpty));
    final mainImage = _imagePaths[0];
    if ((mainImage == null || mainImage.isEmpty) && !hasExistingImages) {
      ScaffoldMessenger.of(formContext).showSnackBar(
        const SnackBar(
          content: Text('Asosiy rasmni yuklang'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }
    final listingTypeStr = switch (_listingType) {
      _ListingType.product => 'Product',
      _ListingType.service => 'Service',
      _ListingType.car => 'Auto',
      _ListingType.home => 'Home',
    };
    final adTypeStr = _adType;
    final existingMainUrl = isEdit
        ? (adDetail?.mainImage ?? fallbackItem?.mainImage)
        : null;
    final existingUrls = isEdit && adDetail != null ? adDetail.images : const <String>[];
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
      mainImagePath: (mainImage != null && mainImage.isNotEmpty) ? mainImage : null,
      additionalImagePaths:
          _imagePaths.skip(1).whereType<String>().toList(),
      existingMainImageUrl: existingMainUrl,
      existingImageUrls: existingUrls,
      weight: _weightValueController.text.trim().isEmpty ? null : _weightValueController.text.trim(),
      width: _widthController.text.trim().isEmpty ? null : _widthController.text.trim(),
      length: _lengthController.text.trim().isEmpty ? null : _lengthController.text.trim(),
      height: _heightController.text.trim().isEmpty ? null : _heightController.text.trim(),
      dimensionUnit: _dimensionUnit.isEmpty ? null : _dimensionUnit,
      weightUnit: _weightUnit.isEmpty ? null : _weightUnit,
    );
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

  // ─── AD TYPE TABS (Sell / Buy) ──────────────────────────────────

  Widget _buildAdTypeTabs(Color cardColor, Color textColor, Color borderColor) {
    const types = [
      ('Sell', 'Sotaman'),
      ('Buy', 'Sotib olaman'),
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
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _adType = e.$1;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.transparent,
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
    const types = [
      (_ListingType.product, 'Mahsulot'),
      (_ListingType.service, 'Xizmat'),
      (_ListingType.car, 'Avtomobil'),
      (_ListingType.home, 'Uy'),
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
          final selected = _listingType == e.$1;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _listingType = e.$1;
                  _selectedCategory = null;
                  _selectedSubcategory = null;
                  _selectedSubSubcategory = null;
                });
                formContext.read<AddListingBloc>().add(
                      AddListingLoadCategoriesRequested(
                        categoryType: _categoryTypeForListingType(e.$1),
                      ),
                    );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.transparent,
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

  // ─── SUMMA CARD ─────────────────────────────────────────────────

  Widget _buildSummaCard(
    Color cardColor,
    Color textColor,
    Color textSecondary,
    Color borderColor,
  ) {
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
                  text: 'Summa',
                  fontSize: 16,
                  fontWeight: 600,
                  color: textColor,
                ),
              ),
              AppText(
                text: 'Valiya ',
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
                  hint: 'Summa',
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
        final categories = state.categories ?? [];
        final isLoading = state.categoriesLoading;

        final subcategories = _selectedCategory?.children ?? [];
        final subSubcategories = _selectedSubcategory?.children ?? [];

        return _card(
          cardColor: cardColor,
          borderColor: borderColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppText(
                    text: 'Kategoriya',
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
                  hint: 'Kategoriyani tanlang',
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
                    });
                  },
                ),
              if (_selectedCategory != null && subcategories.isNotEmpty) ...[
                const SizedBox(height: 10),
                _categoryDropdown(
                  hint: 'Subkategoriyani tanlang',
                  items: subcategories,
                  selected: _selectedSubcategory,
                  textColor: textColor,
                  textSecondary: textSecondary,
                  borderColor: borderColor,
                  onSelected: (cat) {
                    setState(() {
                      _selectedSubcategory = cat;
                      _selectedSubSubcategory = null;
                    });
                  },
                ),
              ],
              if (_selectedSubcategory != null && subSubcategories.isNotEmpty) ...[
                const SizedBox(height: 10),
                _categoryDropdown(
                  hint: 'Turini tanlang',
                  items: subSubcategories,
                  selected: _selectedSubSubcategory,
                  textColor: textColor,
                  textSecondary: textSecondary,
                  borderColor: borderColor,
                  onSelected: (cat) {
                    setState(() => _selectedSubSubcategory = cat);
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
            color: selected != null ? AppColors.primary : borderColor,
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
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: borderColor,
                      ),
                      itemBuilder: (_, i) {
                        final item = items[i];
                        final isSelected = selected?.id == item.id;
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          title: AppText(
                            text: item.displayName,
                            fontSize: 15,
                            fontWeight: isSelected ? 600 : 400,
                            color: isSelected ? AppColors.primary : textColor,
                          ),
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.primary,
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

  Widget _buildProductNameCard(
    Color cardColor,
    Color textColor,
    Color textSecondary,
    Color borderColor,
  ) {
    return _card(
      cardColor: cardColor,
      borderColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: 'Mahsulot nomi',
            fontSize: 16,
            fontWeight: 600,
            color: textColor,
          ),
          const SizedBox(height: 12),
          _buildLangTabs(cardColor, textColor, borderColor),
          const SizedBox(height: 12),
          _inputField(
            hint: 'Mahsulot nomi',
            controller: switch (_nameLang) {
              _NameLang.uz => _nameUzController,
              _NameLang.ru => _nameRuController,
              _NameLang.en => _nameEnController,
            },
          ),
          const SizedBox(height: 12),
          _inputField(
            hint: 'Tavsif',
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
                  color: selected ? AppColors.primary : Colors.transparent,
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
    const labels = [
      'Asosiy rasm',
      'Rasm yuklash',
      'Rasm yuklash',
      'Rasm yuklash',
    ];
    return _card(
      cardColor: cardColor,
      borderColor: borderColor,
      child: Column(
        children: [
          _sectionHeader('Rasm yuklash', textColor, textSecondary),
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

  Widget _buildParametersCard(
    Color cardColor,
    Color textColor,
    Color textSecondary,
    Color borderColor,
  ) {
    final surface = context.surfaceContainer;

    return _card(
      cardColor: cardColor,
      borderColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Parametrlar', textColor, textSecondary),
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
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
                child: Icon(Icons.add, size: 16, color: AppColors.primary),
              ),
              title: AppText(
                text: 'Parametr qo\'shish',
                fontSize: 14,
                fontWeight: 600,
                color: textColor,
              ),
              subtitle: AppText(
                text: 'Mavjud ranglarni qo\'shing (maksimal $_maxParams ta)',
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
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
                child: Icon(Icons.add, size: 16, color: AppColors.primary),
              ),
              title: AppText(
                text: 'Ranglar qo\'shish',
                fontSize: 14,
                fontWeight: 600,
                color: textColor,
              ),
              subtitle: AppText(
                text: 'Mavjud ranglarni qo\'shing (maksimal $_maxColors ta)',
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
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
                child: Icon(Icons.add, size: 16, color: AppColors.primary),
              ),
              title: AppText(
                text: 'O\'lchamlar qo\'shish',
                fontSize: 14,
                fontWeight: 600,
                color: textColor,
              ),
              subtitle: AppText(
                text: 'Mavjud o\'lchamlarni qo\'shing (maksimal $_maxSizes ta)',
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

  Widget _buildDimensionsWeightCard(
    Color cardColor,
    Color textColor,
    Color textSecondary,
    Color borderColor,
  ) {
    final surface = context.surfaceContainer;
    const weightUnits = ['KG', 'g'];
    const dimensionUnits = ['cm', 'm'];

    return _card(
      cardColor: cardColor,
      borderColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('O\'lcham va og\'irlik', textColor, textSecondary),
          const SizedBox(height: 16),
          // Og'irlik
          AppText(
            text: 'Og\'irlik',
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
                  'Qiymat',
                  'Qiymat',
                  _weightValueController,
                  surface,
                  borderColor,
                  isNumber: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _unitDropdown(
                  label: 'Birlik',
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
            text: 'O\'lchamlar',
            fontSize: 16,
            fontWeight: 600,
            color: textColor,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _labeledInput(
                  'Uzunlik',
                  'Uzunlik',
                  _lengthController,
                  surface,
                  borderColor,
                  isNumber: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _labeledInput(
                  'Kenglik',
                  'Kenglik',
                  _widthController,
                  surface,
                  borderColor,
                  isNumber: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _labeledInput(
                  'Balandlik',
                  'Balandlik',
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
            label: 'O\'lchov birligi',
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
                text: 'Tanlang',
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
                    'Nomi',
                    'Rang, O\'lcham, Material',
                    _paramRows[i].name,
                    surface,
                    borderColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _labeledInput(
                    'Qiymat',
                    'Qizil, XL, Plastik',
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
          'Parametr qo\'shish (${_paramRows.length}/$_maxParams)',
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
                      label: 'Rang tanlang',
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
                            'Narx (ixtiyoriy)',
                            'Summa',
                            _colorRows[i].price,
                            surface,
                            borderColor,
                            isNumber: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _labeledInput(
                            'Chegirma % (ixtiyoriy)',
                            'Masalan: 10',
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
              'Rang qo\'shish (${_colorRows.length}/$_maxColors)',
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
                      label: 'O\'lchamni tanlang',
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
                            'Narx (ixtiyoriy)',
                            'Summa',
                            _sizeRows[i].price,
                            surface,
                            borderColor,
                            isNumber: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _labeledInput(
                            'Chegirma % (ixtiyoriy)',
                            'Masalan: 10',
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
              'O\'lcham qo\'shish (${_sizeRows.length}/$_maxSizes)',
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
                  color: enabled ? AppColors.primary : textColor,
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
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _primaryButton(String text, {required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      child: ContainerW(
        onTap: onTap,
        color: AppColors.primary,
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
    final textColor = context.textPrimary;
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
                  text: 'Valyutani tanlang',
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
                        ? Icon(Icons.check_circle, color: AppColors.primary)
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
