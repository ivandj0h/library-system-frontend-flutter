import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'fetch_data_test.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  test('fetchData returns expected data', () async {
    final client = MockClient();

    // Setup mock response
    when(client.get(Uri.parse('http://localhost:9000/api/v1/books')))
        .thenAnswer((_) async => http.Response('{"data": "Berhasil"}', 200));
    final result = await fetchData(client);

    expect(result, '{"data": "Berhasil"}');
  });
}
