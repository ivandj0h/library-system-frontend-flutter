import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../api_service.dart';
import 'add_book_screen.dart';
import 'book_detail_screen.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  _BookListScreenState createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen>
    with SingleTickerProviderStateMixin {
  final ApiService apiService = ApiService();
  List<dynamic> _filteredBooks = [];
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _fetchAndSortBooks();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _fetchAndSortBooks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<dynamic> fetchedBooks = await apiService.fetchBooks();
      fetchedBooks
          .sort((a, b) => b['publishedYear'].compareTo(a['publishedYear']));
      setState(() {
        _filteredBooks = fetchedBooks;
        _isLoading = false;
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error fetching books: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleTabChange() {
    if (_tabController.index == 0) {
      _fetchAndSortBooks();
    }
  }

  void _onSearchChanged() {
    setState(() {
      _filteredBooks = _filterBooks(_searchController.text);
    });
  }

  List<dynamic> _filterBooks(String searchTerm) {
    if (searchTerm.isEmpty) {
      return _filteredBooks;
    }
    return _filteredBooks
        .where((book) =>
            book['title'].toLowerCase().contains(searchTerm.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F1F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.book, color: Colors.black),
            const SizedBox(width: 10),
            const Text(
              'LibraryApp',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFEC8305),
          labelColor: const Color(0xFFEC8305),
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'ALL BOOKS'),
            Tab(text: 'NEW BOOK'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Search by Book Title',
                          labelStyle: const TextStyle(color: Colors.black),
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.black),
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Color(0xFFDDDDDD)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Color(0xFFDDDDDD)),
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Divider(
                      thickness: 1,
                      color: Colors.black12,
                      indent: 16,
                      endIndent: 16,
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _fetchAndSortBooks,
                        child: ListView.builder(
                          itemCount: _filteredBooks.length,
                          itemBuilder: (context, index) {
                            final book = _filteredBooks[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child: Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEFF3F7),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Center(
                                          child: Icon(Icons.book,
                                              color: Colors.grey),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              book['title'] ??
                                                  'No Title Available',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Published Year: ${book['publishedYear'] ?? 'Unknown Year'}',
                                              style: const TextStyle(
                                                  color: Colors.black54),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                            Icons.arrow_forward_ios,
                                            color: Color(0xFFEC8305)),
                                        onPressed: () async {
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  BookDetailScreen(
                                                      bookId: book['id']),
                                            ),
                                          );
                                          if (result == 'deleted') {
                                            _fetchAndSortBooks(); // Panggil ulang API jika buku dihapus
                                          } else if (result == 'goToAllBooks') {
                                            // Tampilkan spinner lalu fetch ulang data
                                            setState(() {
                                              _isLoading =
                                                  true; // Tampilkan spinner
                                            });
                                            await _fetchAndSortBooks(); // Panggil ulang data
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
          AddBookScreen(tabController: _tabController),
        ],
      ),
    );
  }
}
