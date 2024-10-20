import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../api_service.dart';
import 'add_book_screen.dart';
import 'book_detail_screen.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BookListScreenState createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen>
    with SingleTickerProviderStateMixin {
  final ApiService apiService = ApiService();
  List<dynamic> _books = [];
  List<dynamic> _allBooks = [];
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBooks();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _searchController.addListener(_onSearchChanged);
  }

  void _handleTabChange() {
    if (_tabController.index == 0) {
      setState(() {
        _isLoading = true;
      });
      Future.delayed(const Duration(seconds: 2), () {
        _fetchBooks();
      });
    }
  }

  Future<void> _fetchBooks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await apiService.fetchBooks();
      List<dynamic> fetchedBooks = response['data'];

      setState(() {
        _allBooks = fetchedBooks;
        _books = fetchedBooks;
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

  void _onSearchChanged() {
    setState(() {
      _books = _filterBooks(_searchController.text);
    });
  }

  List<dynamic> _filterBooks(String searchTerm) {
    if (searchTerm.isEmpty) {
      return _allBooks;
    }
    return _allBooks
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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.red,
            Colors.white,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.red,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'LibraryApp',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.limeAccent,
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
                ? const Center(
                    child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ))
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
                          onRefresh: _fetchBooks,
                          child: ListView.builder(
                            itemCount: _books.length,
                            itemBuilder: (context, index) {
                              final book = _books[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 1.0),
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
                                          width: 10,
                                          height: 10,
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
                                        const SizedBox(width: 26),
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
                                                '${book['author'] ?? 'Unknown Author'}, ${book['year'] ?? 'Unknown Year'}',
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

                                            print('Result: $result');

                                            if (result == 'deleted') {
                                              _fetchBooks();
                                            } else if (result ==
                                                'backToAllBooks') {
                                              setState(() {
                                                _isLoading = true;
                                              });
                                              _fetchBooks();
                                            } else if (result ==
                                                'showSpinner') {
                                              setState(() {
                                                _isLoading = true;
                                              });

                                              Future.delayed(
                                                  const Duration(seconds: 2),
                                                  () {
                                                _fetchBooks();
                                              });
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
      ),
    );
  }
}
