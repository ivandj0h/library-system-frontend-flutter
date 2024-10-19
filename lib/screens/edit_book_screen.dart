import 'package:flutter/material.dart';
import '../api_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EditBookScreen extends StatefulWidget {
  final Map<String, dynamic> book;

  const EditBookScreen({
    super.key,
    required this.book,
  });

  @override
  _EditBookScreenState createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  final ApiService apiService = ApiService();
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _descriptionController;
  late TextEditingController _yearController;
  late TextEditingController _pageController;
  late TextEditingController _publisherController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.book['title']);
    _authorController = TextEditingController(text: widget.book['author']);
    _descriptionController =
        TextEditingController(text: widget.book['description']);
    _yearController =
        TextEditingController(text: widget.book['year'].toString());
    _pageController =
        TextEditingController(text: widget.book['page'].toString());
    _publisherController =
        TextEditingController(text: widget.book['publisher']);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    _yearController.dispose();
    _pageController.dispose();
    _publisherController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() {
      isLoading = true;
    });

    final updatedBook = {
      'title': _titleController.text,
      'author': _authorController.text,
      'description': _descriptionController.text,
      'year': int.tryParse(_yearController.text) ?? 0,
      'page': int.tryParse(_pageController.text) ?? 0,
      'publisher': _publisherController.text,
    };

    try {
      await apiService.updateBook(widget.book['id'], updatedBook);

      Navigator.pop(context, true);
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to update book: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Book'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _authorController,
                decoration: const InputDecoration(
                  labelText: 'Author',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _yearController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Published Year',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _pageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Pages',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _publisherController,
                decoration: const InputDecoration(
                  labelText: 'Publisher',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : _saveChanges,
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
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
