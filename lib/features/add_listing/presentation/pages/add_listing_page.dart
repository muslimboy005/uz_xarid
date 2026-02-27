import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/constants/app_dimens.dart';
import 'package:uz_xarid/core/dp/infection.dart';
import 'package:uz_xarid/core/service/local_service.dart';
import 'package:uz_xarid/core/theme/theme_colors.dart';
import 'package:uz_xarid/core/widgets/app_text.dart';
import 'package:uz_xarid/core/widgets/uzxarid_app_bar.dart';
import 'package:uz_xarid/core/widgets/w__container.dart';
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
  const AddListingPage({super.key});

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
  _NameLang _nameLang = _NameLang.uz;
  String _currency = 'UZS';
  final _amountController = TextEditingController();
  final _productNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _weightValueController = TextEditingController();
  final _lengthController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();

  String _weightUnit = 'KG';
  String _dimensionUnit = 'sm';

  static const double _kInputHeight = 48.0;

  static const int _maxParams = 20;
  static const int _maxColors = 10;
  static const int _maxSizes = 10;

  List<_ParamRowData> _paramRows = [_ParamRowData()];
  List<_ColorRowData> _colorRows = [_ColorRowData()];
  List<_SizeRowData> _sizeRows = [_SizeRowData()];

  @override
  void initState() {
    super.initState();
    _authFuture = getIt<SecureStorageService>().hasToken();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _productNameController.dispose();
    _descriptionController.dispose();
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
      backgroundColor: bodyBg,
      appBar: UzXaridAppBar(onSearchChanged: (_) {}, onMenuTap: () {}),
      body: SafeArea(
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
                create: (_) => getIt<AddListingBloc>()
                  ..add(const AddListingLoadColorsRequested())
                  ..add(const AddListingLoadSizesRequested()),
                child: _buildForm(
                  cardColor,
                  textColor,
                  textSecondary,
                  borderColor,
                ),
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

  // ─── FORM ───────────────────────────────────────────────────────

  Widget _buildForm(
    Color cardColor,
    Color textColor,
    Color textSecondary,
    Color borderColor,
  ) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTypeTabs(cardColor, textColor, borderColor),
                const SizedBox(height: 16),
                _buildCategorySummaCard(
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
          child: _primaryButton('E\'lon yaratish', onTap: () {}),
        ),
      ],
    );
  }

  // ─── LISTING TYPE TABS (segmented) ──────────────────────────────

  Widget _buildTypeTabs(Color cardColor, Color textColor, Color borderColor) {
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
              onTap: () => setState(() => _listingType = e.$1),
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

  // ─── KATEGORIYA + SUMMA CARD ────────────────────────────────────

  Widget _buildCategorySummaCard(
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
            text: 'Kategoriya',
            fontSize: 16,
            fontWeight: 600,
            color: textColor,
          ),
          const SizedBox(height: 10),
          _inputField(
            hint: 'Kategoriyani tanlang',
            readOnly: true,
            onTap: () {},
          ),
          const SizedBox(height: 20),
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
            controller: _productNameController,
          ),
          const SizedBox(height: 12),
          _inputField(
            hint: 'Tavsif',
            controller: _descriptionController,
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
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < 3 ? 10 : 0),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        decoration: BoxDecoration(
                          color: context.surfaceContainer,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
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
    const dimensionUnits = ['sm', 'm'];

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
            displayLabels: const {'sm': 'sm (santimetr)', 'm': 'm (metr)'},
            onChanged: (v) => setState(() => _dimensionUnit = v ?? 'sm'),
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
