import 'package:flutter/material.dart';
import '../api_service.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  _AddBookScreenState createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final ApiService apiService = ApiService();
  bool _isNameEmpty = false;
  bool _isAuthorEmpty = false;
  bool _isYearEmpty = false;
  bool isLoading = false;

  Future<void> _addBook() async {
    setState(() {
      _isNameEmpty = _nameController.text.isEmpty;
      _isAuthorEmpty = _authorController.text.isEmpty;
      _isYearEmpty = _yearController.text.isEmpty;
      isLoading = true;
    });

    if (!_isNameEmpty && !_isAuthorEmpty && !_isYearEmpty) {
      final newBook = {
        'name': _nameController.text,
        'author': _authorController.text,
        'publishedYear': int.tryParse(_yearController.text) ?? 0,
      };

      try {
        setState(() {
          isLoading = true;
        });

        await apiService.addBook(newBook);
        // await Future.delayed(const Duration(seconds: 2));
        _showTopSnackBar('Book added successfully!', Colors.green);
        // Navigator.pop(context, true);

        setState(() {
          isLoading = false;
          _nameController.clear();
          _authorController.clear();
          _yearController.clear();
        });
      } catch (e) {
        _showTopSnackBar('Failed to add book: $e', Colors.red);
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showTopSnackBar(String message, Color backgroundColor) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(8.0),
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Title',
                errorText: _isNameEmpty ? 'Title cannot be empty' : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _authorController,
              decoration: InputDecoration(
                labelText: 'Author',
                errorText: _isAuthorEmpty ? 'Author cannot be empty' : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _yearController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Published Year',
                errorText:
                    _isYearEmpty ? 'Published Year cannot be empty' : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  isLoading ? null : _addBook, // Disable button saat loading
              child: isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white, // Spinner berwarna putih
                    )
                  : const Text(
                      'Add Book',
                      style:
                          TextStyle(color: Colors.white), // Teks berwarna putih
                    ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFFDF3123), // Warna background tombol
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size.fromHeight(50), // Ukuran minimum tombol
              ),
            )
          ],
        ),
      ),
    );
  }
}
