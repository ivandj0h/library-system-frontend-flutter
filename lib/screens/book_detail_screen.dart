import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../api_service.dart';
import 'edit_book_screen.dart';

class BookDetailScreen extends StatefulWidget {
  final String bookId;

  const BookDetailScreen({super.key, required this.bookId});

  @override
  _BookDetailScreenState createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? bookDetails;
  final ApiService apiService = ApiService();
  bool isLoading = true;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
              child: const Text('Yes', style: TextStyle(color: Colors.white)),
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
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteBook() async {
    try {
      await apiService.deleteBook(widget.bookId);
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

  Future<void> _updateBook() async {
    setState(() {
      isUpdating = true;
    });

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditBookScreen(
          book: bookDetails!,
          tabController: _tabController,
        ),
      ),
    );

    if (result == 'updated') {
      await _fetchBookDetails();
      Fluttertoast.showToast(
        msg: "Book updated successfully!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    }

    setState(() {
      isUpdating = false;
    });
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
          : isUpdating
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
                          child:
                              Icon(Icons.book, size: 100, color: Colors.grey),
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
                        'Published Year: ${bookDetails!['publishedYear']}',
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black54),
                      ),
                      const SizedBox(height: 20),
                      const Divider(thickness: 1, color: Colors.black12),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _updateBook,
                              child: const Text(
                                'Edit Book',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                backgroundColor: const Color(0xFF024CAA),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _showDeleteConfirmationDialog,
                              child: const Text(
                                'Delete Book',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                backgroundColor: const Color(0xFFdf3123),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
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
