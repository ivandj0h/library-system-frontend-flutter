import 'package:flutter_test/flutter_test.dart';

import 'api_service_test.dart';

Future<String> fetchData(MockClient client) async {
  await Future.delayed(const Duration(seconds: 1));
  return "Data berhasil diambil";
}

void main() {
  test('fetchData returns the correct data', () async {
    final result = await fetchData(MockClient());

    expect(result, "Data berhasil diambil");
  });
}
