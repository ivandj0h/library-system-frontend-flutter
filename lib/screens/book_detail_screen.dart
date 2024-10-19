import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'edit_book_screen.dart';
import '../api_service.dart';

class BookDetailScreen extends StatefulWidget {
  final Map<String, dynamic> book;

  const BookDetailScreen({super.key, required this.book});

  @override
  _BookDetailScreenState createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  late Map<String, dynamic> bookDetails;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    bookDetails = widget.book;
  }

  Future<void> _showDeleteConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss dialog
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4), // Border radius lebih kecil
          ),
          title: const Text('Delete Book'),
          content: Text(
            'Are you sure you want to delete "${bookDetails['name']}"?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            ElevatedButton(
              child: const Text('Yes', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFdf3123), // Warna merah
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero, // Tanpa border radius
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _deleteBook(); // Call delete function
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteBook() async {
    setState(() {
      // Optionally, tambahkan spinner atau loading indicator
    });

    try {
      await apiService.deleteBook(bookDetails['id']);
      Fluttertoast.showToast(
        msg: "Book deleted successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      Navigator.pop(context, 'deleted'); // Redirect kembali ke BookListScreen
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF0F1F5), // Ubah background menjadi #f0f1f5
      appBar: AppBar(
        title: Text(bookDetails['name']),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(
                    8), // Tambahkan border radius jika diinginkan
              ),
              child: const Center(
                child: Icon(Icons.book, size: 100, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Title: ${bookDetails['name']}',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            const SizedBox(height: 8),
            Text(
              'Published Year: ${bookDetails['publishedYear']}',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            const Divider(thickness: 1, color: Colors.black12),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditBookScreen(book: bookDetails),
                        ),
                      );
                      if (result == true) {
                        setState(() {
                          bookDetails = result['updatedBook'];
                        });
                        Fluttertoast.showToast(
                          msg: "Book updated successfully!",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.TOP,
                          backgroundColor: Colors.green,
                          textColor: Colors.white,
                        );
                      }
                    },
                    child: const Text(
                      'Edit Book',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor:
                          const Color(0xFF024CAA), // Warna background #024CAA
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
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor:
                          const Color(0xFFdf3123), // Warna background #df3123
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
