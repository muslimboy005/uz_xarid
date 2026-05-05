import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uz_xarid/core/constants/api_urls.dart';
import 'package:uz_xarid/core/constants/app_assets.dart';
import 'package:uz_xarid/core/constants/app_dimens.dart';
import 'package:uz_xarid/core/cubit/app_mode_cubit.dart';
import 'package:uz_xarid/core/dio/dio_client.dart';
import 'package:uz_xarid/core/dp/infection.dart';
import 'package:uz_xarid/core/theme/theme_colors.dart';
import 'package:uz_xarid/core/utils/input_formatters.dart';
import 'package:uz_xarid/core/widgets/app_image.dart';
import 'package:uz_xarid/core/widgets/app_text.dart';
import 'package:uz_xarid/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:uz_xarid/l10n/app_localizations.dart';

class PhoneBottomSheet extends StatefulWidget {
  final ValueChanged<String> onCodeSent;

  const PhoneBottomSheet({super.key, required this.onCodeSent});

  static void show(
    BuildContext parentContext, {
    required ValueChanged<String> onCodeSent,
  }) {
    showModalBottomSheet<void>(
      context: parentContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return BlocProvider.value(
          value: parentContext.read<ProfileBloc>(),
          child: PhoneBottomSheet(onCodeSent: onCodeSent),
        );
      },
    );
  }

  @override
  State<PhoneBottomSheet> createState() => _PhoneBottomSheetState();
}

class _PhoneBottomSheetState extends State<PhoneBottomSheet> {
  final TextEditingController _phoneController = TextEditingController();
  final Dio _dio = getIt<DioClient>().dio;

  bool _offerAccepted = false;
  bool _isOfferLoading = true;
  _ActiveOffer? _activeOffer;
  late final TapGestureRecognizer _offerTapRecognizer;

  bool get _isPhoneValid {
    final digits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    return digits.length == 12 && digits.startsWith('998');
  }

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onPhoneChanged);
    _offerTapRecognizer = TapGestureRecognizer()..onTap = _openOfferPageView;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadActiveOffer();
      }
    });
  }

  void _onPhoneChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadActiveOffer() async {
    setState(() {
      _isOfferLoading = true;
    });

    try {
      final code = Localizations.localeOf(context).languageCode.toLowerCase();
      final response = await _dio.get(
        ApiUrls.activeOffer,
        options: Options(
          headers: {'Accept-Language': _buildAcceptLanguage(code)},
        ),
      );

      final offer = _ActiveOffer.fromAny(response.data);
      if (!mounted) return;
      setState(() {
        _activeOffer = offer;
        _isOfferLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _activeOffer = null;
        _isOfferLoading = false;
      });
    }
  }

  String _buildAcceptLanguage(String current) {
    const supported = ['uz', 'ru', 'en'];
    final ordered = <String>[current, ...supported.where((e) => e != current)];
    return ordered.join(', ');
  }

  Future<void> _openOfferPageView() async {
    final offer = _activeOffer;
    if (offer == null) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _OfferPageView(offer: offer),
    );
  }

  @override
  void dispose() {
    _phoneController.removeListener(_onPhoneChanged);
    _phoneController.dispose();
    _offerTapRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state.status == ProfileStatus.success) {
          Navigator.of(context).pop();
          widget.onCodeSent(_phoneController.text);
        }
      },
      builder: (context, state) {
        final isLoading = state.status == ProfileStatus.loading;
        final cardColor = context.cardSurface;
        final textColor = context.textPrimary;
        final textSecondary = context.textSecondary;
        final borderColor = context.borderColor;
        final primaryColor = context.watch<AppModeCubit>().state.primaryColor;
        final canSubmit =
            !isLoading &&
            !_isOfferLoading &&
            _activeOffer != null &&
            _offerAccepted &&
            _isPhoneValid;

        return Container(
          height:
              MediaQuery.of(context).size.height -
              (MediaQuery.of(context).padding.top + 250),
          padding: EdgeInsets.only(
            left: AppDimens.paddingMedium,
            right: AppDimens.paddingMedium,
            top: AppDimens.paddingSmall2,
            bottom:
                MediaQuery.of(context).viewInsets.bottom +
                AppDimens.paddingMedium,
          ),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: textSecondary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 24),
                  AppText(
                    text: l10n.loginSheetTitle,
                    fontSize: 16,
                    fontWeight: 700,
                    color: textColor,
                  ),
                  AppImage(
                    path: AppAssets.close,
                    size: 24,
                    color: textColor,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 21),
              AppText(
                text: l10n.loginSheetDescription,
                textAlign: TextAlign.center,
                fontSize: 14,
                fontWeight: 400,
                color: textSecondary,
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: AppText(
                  text: l10n.loginPhoneLabel,
                  fontSize: 14,
                  fontWeight: 700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.number,
                enabled: !isLoading,
                style: TextStyle(color: textColor),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  UzbekPhoneInputFormatter(),
                ],
                decoration: InputDecoration(
                  hintText: l10n.loginPhoneHint,
                  hintStyle: TextStyle(color: textSecondary),
                  fillColor: context.surfaceContainer,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    disabledBackgroundColor: primaryColor.withValues(
                      alpha: 0.35,
                    ),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: canSubmit
                      ? () {
                          final digits = _phoneController.text.replaceAll(
                            RegExp(r'\D'),
                            '',
                          );
                          context.read<ProfileBloc>().add(
                            ProfileSendOtpEvent(otpModel: digits),
                          );
                        }
                      : null,
                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          l10n.loginGetCode,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              if (_isOfferLoading)
                SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: primaryColor,
                  ),
                )
              else if (_activeOffer != null)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _offerAccepted,
                      onChanged: isLoading
                          ? null
                          : (value) {
                              setState(() {
                                _offerAccepted = value ?? false;
                              });
                            },
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 11),
                        child: Text.rich(
                          TextSpan(
                            text: l10n.loginPolicyPrefix,
                            style: TextStyle(
                              fontSize: 12,
                              color: textSecondary,
                            ),
                            children: [
                              TextSpan(
                                text: l10n.loginPolicyLink,
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                                recognizer: _offerTapRecognizer,
                              ),
                              TextSpan(
                                text: l10n.loginPolicySuffix,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                  ],
                )
              else
                TextButton(
                  onPressed: _loadActiveOffer,
                  child: Text(
                    'Oferta yuklanmadi. Qayta yuklash',
                    style: TextStyle(color: primaryColor, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

class _ActiveOffer {
  const _ActiveOffer({
    required this.id,
    required this.title,
    required this.pdfUrl,
  });

  final int id;
  final String title;
  final String pdfUrl;

  static _ActiveOffer fromAny(dynamic raw) {
    final map = raw is Map<String, dynamic>
        ? raw
        : (raw as Map).cast<String, dynamic>();
    final payload = map['data'] is Map
        ? (map['data'] as Map).cast<String, dynamic>()
        : map;

    final idRaw = payload['id'];
    final id = idRaw is int ? idRaw : int.tryParse(idRaw?.toString() ?? '');
    final title = payload['title']?.toString() ?? 'Oferta';
    final pdfUrl = payload['pdf_file']?.toString() ?? '';
    if (id == null || pdfUrl.isEmpty) {
      throw Exception('Offer response is invalid');
    }
    return _ActiveOffer(id: id, title: title, pdfUrl: pdfUrl);
  }
}

class _OfferPageView extends StatefulWidget {
  const _OfferPageView({required this.offer});

  final _ActiveOffer offer;

  @override
  State<_OfferPageView> createState() => _OfferPageViewState();
}

class _OfferPageViewState extends State<_OfferPageView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _openOfferFile() async {
    final uri = Uri.tryParse(widget.offer.pdfUrl);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = context.watch<AppModeCubit>().state.primaryColor;
    final textColor = context.textPrimary;
    final textSecondary = context.textSecondary;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.82,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: textSecondary.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Spacer(),
                AppText(
                  text: 'Oferta',
                  fontSize: 16,
                  fontWeight: 700,
                  color: textColor,
                ),
                const Spacer(),
                AppImage(
                  path: AppAssets.close,
                  size: 24,
                  color: textColor,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: context.surfaceContainer,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: context.borderColor),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            text: widget.offer.title,
                            fontSize: 18,
                            fontWeight: 700,
                            color: textColor,
                          ),
                          const SizedBox(height: 8),
                          AppText(
                            text:
                                'Davom etishdan oldin oferta matnini ko‘rib chiqing.',
                            fontSize: 14,
                            fontWeight: 400,
                            color: textSecondary,
                          ),
                          const Spacer(),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 220),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: const Text('Keyingi'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: context.surfaceContainer,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: context.borderColor),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            text: 'PDF havola',
                            fontSize: 16,
                            fontWeight: 700,
                            color: textColor,
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Text(
                                widget.offer.pdfUrl,
                                style: TextStyle(
                                  color: primaryColor,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: _openOfferFile,
                              child: const Text('Ofertani ochish'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              2,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                width: _currentPage == index ? 18 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? primaryColor
                      : textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
