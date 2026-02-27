import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/theme/theme_colors.dart';
import 'package:uz_xarid/features/product_detail/domain/entities/ad_detail_entity.dart';
import 'package:uz_xarid/l10n/app_localizations.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key, required this.ad});

  final AdDetailEntity ad;

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  int _quantity = 1;
  bool _sendToAll = false;
  final _nameCtrl = TextEditingController();
  final _surnameCtrl = TextEditingController();
  final _commentCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _surnameCtrl.dispose();
    _commentCtrl.dispose();
    super.dispose();
  }

  String _fmtPrice(String? val) {
    if (val == null || val.isEmpty) return '';
    final s = val.split('.').first;
    final buf = StringBuffer();
    var c = 0;
    for (var i = s.length - 1; i >= 0; i--) {
      buf.write(s[i]);
      if (++c % 3 == 0 && i != 0) buf.write(' ');
    }
    return buf.toString().split('').reversed.join();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final bg = context.bodyBackground;
    final card = context.cardSurface;
    final txt = context.textPrimary;
    final txtSec = context.textSecondary;
    final border = context.borderColor;
    final ad = widget.ad;
    final curr = (ad.currency ?? 'uzs') == 'uzs' ? "so'm" : ad.currency!;
    final price = _fmtPrice(ad.finalPrice ?? ad.price);

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
          l.orderTitle,
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
            _productCard(ad, price, curr, l, card, txt, txtSec, border),
            const SizedBox(height: 16),
            _personalCard(l, card, txt, txtSec, border),
            const SizedBox(height: 16),
            _deliveryCard(l, card, txt, txtSec, border),
            const SizedBox(height: 16),
            _commentCard(l, card, txt, border),
          ],
        ),
      ),
      bottomNavigationBar: _bottomBar(l, card, txt, border),
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
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ad.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: txt,
                              height: 1.3,
                            ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (ad.description != null &&
                          ad.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          ad.description!,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: txtSec,
                                    height: 1.3,
                                  ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$price\n$curr',
                      textAlign: TextAlign.end,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: txt,
                            height: 1.2,
                          ),
                    ),
                    const SizedBox(height: 10),
                    _qtyRow(txt),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 0.5, color: border),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                Transform.scale(
                  scale: 0.7,
                  child: Switch(
                    value: _sendToAll,
                    onChanged: (v) => setState(() => _sendToAll = v),
                    activeColor: AppColors.primary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.orderSendToAllAds,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: txt,
                        ),
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
        imageUrl: url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          width: size,
          height: size,
          color: context.surfaceContainer,
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
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
    final border = context.borderColor;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _quantity > 1 ? () => setState(() => _quantity--) : null,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              border: Border.all(color: border, width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '–',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _quantity > 1 ? txt : context.textSecondary,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '$_quantity ${AppLocalizations.of(context)!.orderQuantityDona}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: txt,
                ),
          ),
        ),
        GestureDetector(
          onTap: () => setState(() => _quantity++),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(Icons.add, size: 18, color: AppColors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _personalCard(
    AppLocalizations l,
    Color card,
    Color txt,
    Color txtSec,
    Color border,
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
            l.profileMenuPersonalData,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: txt,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _labelField(l.firstNameLabel, l.firstNameHint, _nameCtrl, txt)),
              const SizedBox(width: 12),
              Expanded(child: _labelField(l.lastNameLabel, l.lastNameHint, _surnameCtrl, txt)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _labelField(
    String label,
    String hint,
    TextEditingController ctrl,
    Color txt,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: txt,
              ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: txt),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.textSecondary,
                ),
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
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            isDense: true,
          ),
        ),
      ],
    );
  }

  Widget _deliveryCard(
    AppLocalizations l,
    Color card,
    Color txt,
    Color txtSec,
    Color border,
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
          const SizedBox(height: 16),
          Container(
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
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
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
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: txtSec,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // TODO: manzil tanlash
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
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
          ),
        ],
      ),
    );
  }

  Widget _commentCard(
    AppLocalizations l,
    Color card,
    Color txt,
    Color border,
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
              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.textSecondary,
                  ),
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
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
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
              child: ElevatedButton(
                onPressed: () {
                  // TODO: buyurtmani yuborish API
                  context.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  l.orderSubmit,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
