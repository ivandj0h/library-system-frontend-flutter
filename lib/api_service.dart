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
        'Authorization': 'my-static-token-123',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      if (jsonData.containsKey('data')) {
        return jsonData['data'];
      } else {
        throw 'Invalid response structure: No "data" field found';
      }
    } else {
      throw 'Failed to fetch books. Status code: ${response.statusCode}';
    }
  }

  // Method get book by Id
  Future<Map<String, dynamic>> getBookById(String bookId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/books/$bookId'),
      headers: {
        'Authorization': 'my-static-token-123',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Parse JSON response
      final Map<String, dynamic> jsonData = json.decode(response.body);

      // Cek apakah 'data' ada di dalam response
      if (jsonData.containsKey('data') && jsonData['data'] != null) {
        return jsonData['data']; // Return data jika ada
      } else {
        throw 'Invalid response structure: No "data" field found';
      }
    } else {
      // Jika status code bukan 200, lemparkan error dengan message dari server
      throw 'Failed to fetch book details: ${response.reasonPhrase}';
    }
  }

  // Method baru untuk mengupdate buku
  Future<void> updateBook(
      String id, Map<String, dynamic> updatedBookData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/books/$id'),
      headers: {
        'Authorization': 'my-static-token-123',
        'Content-Type': 'application/json',
      },
      body: json.encode(updatedBookData),
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
