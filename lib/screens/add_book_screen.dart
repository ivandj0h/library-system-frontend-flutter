import 'package:flutter/material.dart';
import '../api_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddBookScreen extends StatefulWidget {
  final TabController tabController;
  const AddBookScreen({super.key, required this.tabController});

  @override
  AddBookScreenState createState() => AddBookScreenState();
}

class AddBookScreenState extends State<AddBookScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _pageController = TextEditingController();
  final TextEditingController _publisherController = TextEditingController();
  final ApiService apiService = ApiService();
  bool isLoading = false;

  bool _isTitleEmpty = false;
  bool _isAuthorEmpty = false;
  bool _isDescriptionEmpty = false;
  bool _isYearEmpty = false;
  bool _isPageEmpty = false;
  bool _isPublisherEmpty = false;

  Future<void> _addBook() async {
    setState(() {
      _isTitleEmpty = _titleController.text.isEmpty;
      _isAuthorEmpty = _authorController.text.isEmpty;
      _isDescriptionEmpty = _descriptionController.text.isEmpty;
      _isYearEmpty = _yearController.text.isEmpty;
      _isPageEmpty = _pageController.text.isEmpty;
      _isPublisherEmpty = _publisherController.text.isEmpty;
    });

    if (_isTitleEmpty ||
        _isAuthorEmpty ||
        _isDescriptionEmpty ||
        _isYearEmpty ||
        _isPageEmpty ||
        _isPublisherEmpty) {
      Fluttertoast.showToast(
        msg: "All fields must be filled!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final newBook = {
      'title': _titleController.text,
      'author': _authorController.text,
      'description': _descriptionController.text,
      'year': int.tryParse(_yearController.text) ?? 0,
      'page': int.tryParse(_pageController.text) ?? 0,
      'publisher': _publisherController.text,
    };

    try {
      await apiService.addBook(newBook);
      Fluttertoast.showToast(
        msg: "Book added successfully!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      setState(() {
        isLoading = false;
      });

      _titleController.clear();
      _authorController.clear();
      _descriptionController.clear();
      _yearController.clear();
      _pageController.clear();
      _publisherController.clear();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Book'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
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
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                errorText:
                    _isDescriptionEmpty ? 'Description cannot be empty' : null,
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
            const SizedBox(height: 10),
            TextField(
              controller: _pageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Pages',
                errorText: _isPageEmpty ? 'Pages cannot be empty' : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _publisherController,
              decoration: InputDecoration(
                labelText: 'Publisher',
                errorText:
                    _isPublisherEmpty ? 'Publisher cannot be empty' : null,
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
            ),
          ],
        ),
      ),
    );
  }
}
