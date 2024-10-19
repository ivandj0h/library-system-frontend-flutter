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
  List<dynamic> _books = [];
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  bool _isLoading = true;
  bool _isFetchingMore = false;
  bool _hasMoreBooks = true;

  // Pagination & ScrollController
  ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  int _totalPages = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _fetchBooks(page: _currentPage);

    _searchController.addListener(_onSearchChanged);

    // Listen for scrolling events for lazy loading
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_isFetchingMore &&
          _hasMoreBooks) {
        _fetchMoreBooks();
      }
    });
  }

  Future<void> _fetchBooks({int page = 1}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await apiService.fetchBooks(page: page);
      List<dynamic> fetchedBooks = response['data']['books'];

      setState(() {
        _books = fetchedBooks;
        _currentPage = int.tryParse(
                response['data']['pagination']['currentPage'].toString()) ??
            1;
        _totalPages = int.tryParse(
                response['data']['pagination']['totalPages'].toString()) ??
            1;
        _isLoading = false;
        _hasMoreBooks = _currentPage < _totalPages;
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

  Future<void> _fetchMoreBooks() async {
    if (!_hasMoreBooks || _isFetchingMore) return; // Hindari pemanggilan ganda
    setState(() {
      _isFetchingMore = true;
    });

    try {
      final response = await apiService.fetchBooks(page: _currentPage + 1);
      List<dynamic> fetchedBooks = response['data']['books'];

      setState(() {
        _books.addAll(fetchedBooks);
        _currentPage = int.tryParse(
                response['data']['pagination']['currentPage'].toString()) ??
            1;
        _totalPages = int.tryParse(
                response['data']['pagination']['totalPages'].toString()) ??
            1;
        _isFetchingMore = false;
        _hasMoreBooks = _currentPage < _totalPages;
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error fetching more books: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      setState(() {
        _isFetchingMore = false;
      });
    }
  }

  void _handleTabChange() {
    if (_tabController.index == 0) {
      _fetchBooks(page: 1);
    }
  }

  void _onSearchChanged() {
    setState(() {
      _books = _filterBooks(_searchController.text);
    });
  }

  List<dynamic> _filterBooks(String searchTerm) {
    if (searchTerm.isEmpty) {
      return _books;
    }
    return _books
        .where((book) =>
            book['title'].toLowerCase().contains(searchTerm.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          children: [
            SizedBox(width: 10),
            Text(
              'Home',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                textBaseline: TextBaseline.alphabetic,
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
                        onRefresh: () => _fetchBooks(page: 1),
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: _books.length + 1, // Add one for loading
                          itemBuilder: (context, index) {
                            if (index == _books.length) {
                              return _isFetchingMore
                                  ? const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                  : const SizedBox.shrink();
                            }

                            final book = _books[index];
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
                                                      bookId: book['id'],
                                                    )),
                                          );
                                          if (result == 'deleted') {
                                            _fetchBooks(page: _currentPage);
                                          }
                                          if (result == 'updated') {
                                            _fetchBooks(page: _currentPage);
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
                    )
                  ],
                ),
          AddBookScreen(tabController: _tabController),
        ],
      ),
    );
  }
}
