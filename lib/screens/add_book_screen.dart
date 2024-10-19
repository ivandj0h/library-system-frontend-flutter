import 'package:flutter/material.dart';
import '../api_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddBookScreen extends StatefulWidget {
  final TabController tabController;
  const AddBookScreen({super.key, required this.tabController});

  @override
  _AddBookScreenState createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final ApiService apiService = ApiService();
  bool _isTitleEmpty = false;
  bool _isAuthorEmpty = false;
  bool _isYearEmpty = false;
  bool isLoading = false;

  Future<void> _addBook() async {
    setState(() {
      _isTitleEmpty = _nameController.text.isEmpty;
      _isAuthorEmpty = _authorController.text.isEmpty;
      _isYearEmpty = _yearController.text.isEmpty;
    });

    if (!_isTitleEmpty && !_isAuthorEmpty && !_isYearEmpty) {
      setState(() {
        isLoading = true;
      });

      final newBook = {
        'title': _nameController.text,
        'author': _authorController.text,
        'publishedYear': int.tryParse(_yearController.text) ?? 0,
      };

      try {
        await apiService.addBook(newBook);
        await Future.delayed(const Duration(seconds: 2));

        setState(() {
          isLoading = false;
        });

        // Tampilkan toaster sukses
        Fluttertoast.showToast(
          msg: "Book added successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        _nameController.clear();
        _authorController.clear();
        _yearController.clear();

        widget.tabController.animateTo(0);
      } catch (e) {
        setState(() {
          isLoading = false;
        });

        Fluttertoast.showToast(
          msg: "Failed to add book: $e",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Title',
                errorText: _isTitleEmpty ? 'Title cannot be empty' : null,
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
              onPressed: isLoading ? null : _addBook,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDF3123),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size.fromHeight(50),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Add Book',
                      style: TextStyle(color: Colors.white),
                    ),
            )
          ],
        ),
      ),
    );
  }
}
