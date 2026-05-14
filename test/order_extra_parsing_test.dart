import 'package:flutter_test/flutter_test.dart';
import 'package:uzxarid/features/product_detail/domain/entities/ad_detail_entity.dart';

({AdDetailEntity? ad, int initialQty}) parseOrderExtra(Object? raw) {
  AdDetailEntity? ad;
  int initialQty = 1;
  if (raw is AdDetailEntity) {
    ad = raw;
  } else if (raw is Map) {
    ad = raw['ad'] as AdDetailEntity?;
    final q = raw['quantity'];
    if (q is int && q > 0) initialQty = q;
  }
  return (ad: ad, initialQty: initialQty);
}

void main() {
  final ad = AdDetailEntity(slug: 'sedan', title: 'Sedan');

  test('plain AdDetailEntity yields qty=1', () {
    final r = parseOrderExtra(ad);
    expect(r.ad, ad);
    expect(r.initialQty, 1);
  });

  test('map with quantity carries it through', () {
    final r = parseOrderExtra({'ad': ad, 'quantity': 2});
    expect(r.ad, ad);
    expect(r.initialQty, 2);
  });

  test('map with invalid quantity falls back to 1', () {
    expect(parseOrderExtra({'ad': ad, 'quantity': 0}).initialQty, 1);
    expect(parseOrderExtra({'ad': ad, 'quantity': -3}).initialQty, 1);
    expect(parseOrderExtra({'ad': ad}).initialQty, 1);
  });

  test('null extra yields null ad', () {
    expect(parseOrderExtra(null).ad, isNull);
  });
}
