import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../api_service.dart';

class EditBookScreen extends StatefulWidget {
  final Map<String, dynamic> book;

  const EditBookScreen({super.key, required this.book});

  @override
  EditBookScreenState createState() => EditBookScreenState();
}

class EditBookScreenState extends State<EditBookScreen> {
  late TextEditingController titleController;
  late TextEditingController authorController;
  late TextEditingController descriptionController;
  late TextEditingController yearController;
  late TextEditingController pageController;
  late TextEditingController publisherController;

  late final ApiService apiService;
  final logger = Logger();

  @override
  void initState() {
    super.initState();
    apiService = ApiService();
    titleController = TextEditingController(text: widget.book['title']);
    authorController = TextEditingController(text: widget.book['author']);
    descriptionController =
        TextEditingController(text: widget.book['description']);
    yearController =
        TextEditingController(text: widget.book['year'].toString());
    pageController =
        TextEditingController(text: widget.book['page'].toString());
    publisherController = TextEditingController(text: widget.book['publisher']);

    // Setup logging level based on environment
    if (kReleaseMode) {
      Logger.level = Level.error;
    } else {
      Logger.level = Level.debug;
    }
  }

  Future<void> _saveBook() async {
    final updatedBook = {
      'id': widget.book['id'],
      'title': titleController.text,
      'author': authorController.text,
      'description': descriptionController.text,
      'year': int.parse(yearController.text),
      'page': int.parse(pageController.text),
      'publisher': publisherController.text,
    };

    // Log untuk ngecek data sebelum dikirim
    logger.d('Updated Book: $updatedBook');

    try {
      await apiService.updateBook(updatedBook['id'], updatedBook);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      logger.e('Error updating book: $e');
      Fluttertoast.showToast(
        msg: "Failed to update book: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    authorController.dispose();
    descriptionController.dispose();
    yearController.dispose();
    pageController.dispose();
    publisherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Wrap(
        children: [
          Center(
            child: Text(
              'Edit Book',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextField(
              controller: authorController,
              decoration: InputDecoration(
                labelText: 'Author',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextField(
              controller: yearController,
              decoration: InputDecoration(
                labelText: 'Published Year',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextField(
              controller: pageController,
              decoration: InputDecoration(
                labelText: 'Pages',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextField(
              controller: publisherController,
              decoration: InputDecoration(
                labelText: 'Publisher',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          SizedBox(height: 20),
          Divider(
            thickness: 1,
            color: Colors.black12,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saveBook,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(vertical: 16.0),
              minimumSize: Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Save Changes',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
