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

  // Fungsi untuk menambahkan buku baru
  Future<void> addBook(Map<String, dynamic> bookData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/books'),
      headers: {
        'Authorization': 'my-static-token-123',
        'Content-Type': 'application/json',
      },
      body: json.encode(bookData),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add book');
    }
  }

  // Fungsi untuk menghapus buku
  Future<void> deleteBook(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/books/$id'),
      headers: {
        'Authorization': 'my-static-token-123',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete book');
    }
  }
}
