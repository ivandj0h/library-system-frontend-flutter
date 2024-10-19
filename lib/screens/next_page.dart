import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:library_app/api_service.dart';

class NextPageScreen extends StatefulWidget {
  const NextPageScreen({super.key});

  @override
  _NextPageScreenState createState() => _NextPageScreenState();
}

class _NextPageScreenState extends State<NextPageScreen> {
  final ApiService apiService = ApiService();
  List<dynamic> _books = [];
  bool _isLoading = true;

  bool _hasMoreBooks = true;
  bool _isFetchingMore = false;
  int _currentPage = 1;
  int _totalPages = 1;

  @override
  void initState() {
    super.initState();
    _fetchBooks(2); // Page 2: 6-10
  }

  Future<void> _fetchBooks(int pageNumber) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await apiService.fetchBooks(page: pageNumber);
      if (response['books'] != null) {
        setState(() {
          _books = response['books'];
          _currentPage = response['pagination']['currentPage'];
          _totalPages = response['pagination']['totalPages'];
          _isLoading = false;
          _hasMoreBooks = _currentPage < _totalPages;
        });
      } else {
        setState(() {
          _books = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error fetching books: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Next Page of Books')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _books.length,
              itemBuilder: (context, index) {
                final book = _books[index];
                return ListTile(
                  title: Text(book['title']),
                  subtitle: Text('${book['author']}, ${book['year']}'),
                );
              },
            ),
    );
  }
}
