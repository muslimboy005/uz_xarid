import 'package:flutter_test/flutter_test.dart';
import 'package:uzxarid/core/utils/price_formatter.dart';

void main() {
  test('formatPrice strips ".00" and inserts thousand separators', () {
    expect(formatPrice('14000.00'), '14 000');
    expect(formatPrice('28000.00'), '28 000');
    expect(formatPrice('1500000.00'), '1 500 000');
    expect(formatPrice('1000.50'), '1 000.5');
    expect(formatPrice('999'), '999');
    expect(formatPrice(''), '');
    expect(formatPrice(null), '');
  });
}
