import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_loading/link_handler.dart';

void main() {
  test('Generate and verify exact SecureString bytes for proxy and URLs', () {
    final accountBytes = SecureString.encode('vn2proxy');
    final passwordBytes = SecureString.encode('63567Raj');
    final countryBytes = SecureString.encode('US');
    final url1Bytes = SecureString.encode('https://quiz192.freecase24.com');
    final url2Bytes = SecureString.encode('https://rblxgo192.freecase24.com');

    print('Exact account bytes: $accountBytes');
    print('Exact password bytes: $passwordBytes');
    print('Exact country bytes: $countryBytes');
    print('Exact url1 bytes: $url1Bytes');
    print('Exact url2 bytes: $url2Bytes');

    expect(SecureString.decode(accountBytes), 'vn2proxy');
    expect(SecureString.decode(passwordBytes), '63567Raj');
    expect(SecureString.decode(countryBytes), 'US');
    expect(SecureString.decode(url1Bytes), 'https://quiz192.freecase24.com');
    expect(SecureString.decode(url2Bytes), 'https://rblxgo192.freecase24.com');
  });
}
