import 'package:flutter/material.dart';
import '../api_service.dart';
import 'add_book_screen.dart';
import 'book_detail_screen.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  _BookListScreenState createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  ApiService apiService = ApiService();
  late Future<List<dynamic>> books;

  @override
  void initState() {
    super.initState();
    books = apiService.fetchBooks();
  }

  Future<void> _refreshBooks() async {
    setState(() {
      books = apiService.fetchBooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library Books'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: books,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final List<dynamic> bookList = snapshot.data ?? [];
                  return RefreshIndicator(
                    onRefresh: _refreshBooks,
                    child: ListView.builder(
                      itemCount: bookList.length,
                      itemBuilder: (context, index) {
                        final book = bookList[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 15,
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey[300],
                              child: const Center(
                                child: Text(
                                  'No Image',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                            title: Text(
                              book['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Author: ${book['author']}'),
                                Text(
                                    'Published Year: ${book['publishedYear']}'),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                try {
                                  await apiService.deleteBook(book['id']);
                                  _refreshBooks(); // Refresh setelah menghapus
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('Failed to delete book: $e')),
                                  );
                                }
                              },
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      BookDetailScreen(book: book),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                bottom: 30.0), // Jarak dari bagian bawah
            child: ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddBookScreen()),
                );
                if (result == true) {
                  _refreshBooks(); // Refresh setelah menambahkan buku baru
                }
              },
              child: const Text('Add New Book',
                  style: TextStyle(color: Colors.white)), // Text putih
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                backgroundColor: Colors.black,
                disabledForegroundColor: Colors.grey[700]?.withOpacity(0.38),
                disabledBackgroundColor: Colors.grey[700]
                    ?.withOpacity(0.12), // Warna background hitam
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(8), // Radius tidak terlalu banyak
                ),
                shadowColor: Colors.grey,
                elevation: 4,
                minimumSize:
                    const Size.fromHeight(50), // Minimal height untuk tombol
              ).copyWith(
                elevation: MaterialStateProperty.resolveWith<double>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.hovered)) {
                      return 6; // Efek hover
                    }
                    return 4; // Normal elevation
                  },
                ),
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.hovered)) {
                      return Colors
                          .grey[800]!; // Warna saat hover (hitam agak muda)
                    }
                    return Colors.black; // Warna normal
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
