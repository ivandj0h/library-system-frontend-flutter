import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../api_service.dart';
import 'edit_book_screen.dart';

class BookDetailScreen extends StatefulWidget {
  final String bookId;

  const BookDetailScreen({super.key, required this.bookId});

  @override
  // ignore: library_private_types_in_public_api
  _BookDetailScreenState createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  Map<String, dynamic>? bookDetails;
  final ApiService apiService = ApiService();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookDetails();
  }

  Future<void> _fetchBookDetails() async {
    try {
      final fetchedBook = await apiService.getBookById(widget.bookId);
      setState(() {
        bookDetails = fetchedBook;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(
        msg: "Failed to load book details: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _showDeleteConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          title: const Text('Delete Book'),
          content: Text(
            'Are you sure you want to delete "${bookDetails!['title']}"?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFdf3123),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteBook();
              },
              child: const Text('Yes', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteBook() async {
    try {
      await apiService.deleteBook(widget.bookId);
      Fluttertoast.showToast(
        msg: "Book deleted successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      // ignore: use_build_context_synchronously
      Navigator.pop(context, 'deleted');
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to delete book: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _goBackToAllBooks() async {
    Navigator.pop(context, 'backToAllBooks');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F1F5),
      appBar: AppBar(
        title: Text(bookDetails != null ? bookDetails!['title'] : 'Loading...'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(Icons.book, size: 100, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Title: ${bookDetails!['title']}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Author: ${bookDetails!['author']}',
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Year: ${bookDetails!['year']}',
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Description: ${bookDetails!['description']}',
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pages: ${bookDetails!['page']}',
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Publisher: ${bookDetails!['publisher']}',
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 20),
                  const Divider(thickness: 1, color: Colors.black12),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditBookScreen(book: bookDetails!),
                            ),
                          );
                          if (result == true) {
                            _fetchBookDetails();
                            Fluttertoast.showToast(
                              msg: "Book updated successfully!",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.TOP,
                              backgroundColor: Colors.green,
                              textColor: Colors.white,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: const Color(0xFF024CAA),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: const Size.fromHeight(50),
                        ),
                        child: const Text(
                          'Edit Book',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _showDeleteConfirmationDialog,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: const Color(0xFFdf3123),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: const Size.fromHeight(50),
                        ),
                        child: const Text(
                          'Delete Book',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _goBackToAllBooks,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: const Color(0xFFEC8305),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: const Size.fromHeight(50),
                        ),
                        child: const Text(
                          'Back to All Books',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
