import 'package:flutter/material.dart';
import '../api_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EditBookScreen extends StatefulWidget {
  final Map<String, dynamic> book;
  final TabController tabController;

  const EditBookScreen({
    super.key,
    required this.book,
    required this.tabController,
  });

  @override
  _EditBookScreenState createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  final ApiService apiService = ApiService();
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _publishedYearController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.book['title']);
    _authorController = TextEditingController(text: widget.book['author']);
    _publishedYearController =
        TextEditingController(text: widget.book['publishedYear'].toString());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _publishedYearController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() {
      isLoading = true;
    });

    final updatedBook = {
      'title': _titleController.text,
      'author': _authorController.text,
      'publishedYear': int.tryParse(_publishedYearController.text) ?? 0,
    };

    try {
      await apiService.updateBook(widget.book['id'], updatedBook);
      widget.tabController.animateTo(0);
      Navigator.pop(context, 'updated');
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
              controller: _publishedYearController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Published Year',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : _saveChanges,
              child: isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : const Text(
                      'Save Changes',
                      style: TextStyle(color: Colors.white),
                    ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDF3123),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
