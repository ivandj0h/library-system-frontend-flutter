import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://localhost:9000/api/v1';
  final String authToken = 'my-static-token-123';

  // Method untuk mengambil list buku (sudah ada)
  Future<List<dynamic>> fetchBooks() async {
    final response = await http.get(
      Uri.parse('$baseUrl/books'),
      headers: {
        'Authorization': authToken,
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'] as List<dynamic>;
    } else {
      throw Exception('Failed to load books');
    }
  }

  // Method baru untuk mengupdate buku
  Future<void> updateBook(
      String bookId, Map<String, dynamic> updatedData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/books/$bookId'),
      headers: {
        'Authorization': authToken,
        'Content-Type': 'application/json',
      },
      body: json.encode(updatedData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update book');
    }
  }
}
