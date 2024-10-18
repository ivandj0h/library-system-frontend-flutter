import 'package:flutter/material.dart';
import 'edit_book_screen.dart';

class BookDetailScreen extends StatefulWidget {
  final Map<String, dynamic> book;

  const BookDetailScreen({super.key, required this.book});

  @override
  _BookDetailScreenState createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  late Map<String, dynamic> bookDetails;

  @override
  void initState() {
    super.initState();
    bookDetails = widget.book;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(bookDetails['name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title: ${bookDetails['name']}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Author: ${bookDetails['author']}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Published Year: ${bookDetails['publishedYear']}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditBookScreen(book: bookDetails),
                  ),
                );

                if (result == true) {
                  setState(() {
                    bookDetails = result['updatedBook'];
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Book updated successfully!')),
                  );
                }
              },
              child: const Text('Edit'),
            ),
          ],
        ),
      ),
    );
  }
}
