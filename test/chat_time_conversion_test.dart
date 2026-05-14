import 'package:flutter_test/flutter_test.dart';

void main() {
  test('UTC ISO string parses and converts to local time', () {
    const utcString = '2026-05-14T12:10:00Z';

    final parsed = DateTime.tryParse(utcString);
    expect(parsed, isNotNull);
    expect(parsed!.isUtc, isTrue);
    expect(parsed.hour, 12);

    final local = parsed.toLocal();
    expect(local.isUtc, isFalse);

    final offsetHours = DateTime.now().timeZoneOffset.inHours;
    final expectedLocalHour = (12 + offsetHours) % 24;
    expect(local.hour, expectedLocalHour);
  });

  test('non-UTC offset string also normalizes via toLocal()', () {
    const offsetString = '2026-05-14T17:10:00+05:00';
    final parsed = DateTime.tryParse(offsetString);
    expect(parsed, isNotNull);
    final local = parsed!.toLocal();
    expect(local.toUtc().hour, 12);
  });
}
