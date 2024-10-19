import 'package:flutter/material.dart';
import '../api_service.dart';
import 'add_book_screen.dart';
import 'book_detail_screen.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  _BookListScreenState createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen>
    with TickerProviderStateMixin {
  final ApiService apiService = ApiService();
  late Future<List<dynamic>> books;
  List<dynamic> _filteredBooks = [];
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    books = apiService.fetchBooks();
    _searchController.addListener(_onSearchChanged);
    _tabController = TabController(length: 2, vsync: this);
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
            book['name'].toLowerCase().contains(searchTerm.toLowerCase()))
        .toList();
  }

  Future<void> _refreshBooks() async {
    setState(() {
      books = apiService.fetchBooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDBD3D3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.book, color: Colors.black), // Icon Buku di Kiri
            const SizedBox(width: 10),
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
          Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search by Book Name',
                    labelStyle: const TextStyle(color: Colors.black),
                    prefixIcon: const Icon(Icons.search, color: Colors.black),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.black),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  future: books,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                          child: Text('Error: ${snapshot.error}',
                              style: const TextStyle(color: Colors.black)));
                    } else {
                      _filteredBooks = snapshot.data ?? [];
                      final List<dynamic> displayedBooks =
                          _filterBooks(_searchController.text);
                      return RefreshIndicator(
                        onRefresh: _refreshBooks,
                        child: ListView.builder(
                          itemCount: displayedBooks.length,
                          itemBuilder: (context, index) {
                            final book = displayedBooks[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 4.0), // Mengurangi jarak antar card
                              child: Card(
                                color: const Color(0xFFFFFFFF),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      8), // Mengurangi border radius
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
                                              book['name'],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Author: ${book['author']}',
                                              style: const TextStyle(
                                                  color: Colors.black54),
                                            ),
                                            Text(
                                              'Published Year: ${book['publishedYear']}',
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
                                                  BookDetailScreen(book: book),
                                            ),
                                          );
                                          if (result == 'deleted') {
                                            _refreshBooks();
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
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          const AddBookScreen(), // Tampilan untuk menambahkan buku baru
        ],
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: const Color(0xFFDBD3D3),
  //     appBar: AppBar(
  //       backgroundColor: Colors.white,
  //       elevation: 0,
  //       title: Row(
  //         children: [
  //           Icon(Icons.book, color: Colors.black), // Icon Buku di Kiri
  //           const SizedBox(width: 10),
  //         ],
  //       ),
  //       bottom: TabBar(
  //         controller: _tabController,
  //         indicatorColor: const Color(0xFFEC8305),
  //         labelColor: const Color(0xFFEC8305),
  //         unselectedLabelColor: Colors.grey,
  //         labelStyle: const TextStyle(fontWeight: FontWeight.bold),
  //         tabs: const [
  //           Tab(text: 'ALL BOOKS'),
  //           Tab(text: 'NEW BOOK'),
  //         ],
  //       ),
  //     ),
  //     body: TabBarView(
  //       controller: _tabController,
  //       children: [
  //         Column(
  //           children: [
  //             const SizedBox(height: 20),
  //             Padding(
  //               padding: const EdgeInsets.symmetric(horizontal: 16.0),
  //               child: TextField(
  //                 controller: _searchController,
  //                 decoration: InputDecoration(
  //                   labelText: 'Search by Book Name',
  //                   labelStyle: const TextStyle(color: Colors.black),
  //                   prefixIcon: const Icon(Icons.search, color: Colors.black),
  //                   filled: true,
  //                   fillColor: Colors.white,
  //                   border: OutlineInputBorder(
  //                     borderRadius: BorderRadius.circular(8),
  //                     borderSide: BorderSide.none,
  //                   ),
  //                 ),
  //                 style: const TextStyle(color: Colors.black),
  //               ),
  //             ),
  //             const SizedBox(height: 10),
  //             Expanded(
  //               child: FutureBuilder<List<dynamic>>(
  //                 future: books,
  //                 builder: (context, snapshot) {
  //                   if (snapshot.connectionState == ConnectionState.waiting) {
  //                     return const Center(child: CircularProgressIndicator());
  //                   } else if (snapshot.hasError) {
  //                     return Center(
  //                         child: Text('Error: ${snapshot.error}',
  //                             style: const TextStyle(color: Colors.black)));
  //                   } else {
  //                     _filteredBooks = snapshot.data ?? [];
  //                     final List<dynamic> displayedBooks =
  //                         _filterBooks(_searchController.text);
  //                     return RefreshIndicator(
  //                       onRefresh: _refreshBooks,
  //                       child: ListView.builder(
  //                         itemCount: displayedBooks.length,
  //                         itemBuilder: (context, index) {
  //                           final book = displayedBooks[index];
  //                           return Padding(
  //                             padding: const EdgeInsets.symmetric(
  //                                 horizontal: 16.0,
  //                                 vertical: 4.0), // Mengurangi jarak antar card
  //                             child: Card(
  //                               color: const Color(0xFFFFFFFF),
  //                               shape: RoundedRectangleBorder(
  //                                 borderRadius: BorderRadius.circular(
  //                                     8), // Mengurangi border radius
  //                               ),
  //                               child: Padding(
  //                                 padding: const EdgeInsets.all(16.0),
  //                                 child: Row(
  //                                   children: [
  //                                     Container(
  //                                       width: 50,
  //                                       height: 50,
  //                                       decoration: BoxDecoration(
  //                                         color: const Color(0xFFEFF3F7),
  //                                         borderRadius:
  //                                             BorderRadius.circular(8),
  //                                       ),
  //                                       child: const Center(
  //                                         child: Icon(Icons.book,
  //                                             color: Colors.grey),
  //                                       ),
  //                                     ),
  //                                     const SizedBox(width: 16),
  //                                     Expanded(
  //                                       child: Column(
  //                                         crossAxisAlignment:
  //                                             CrossAxisAlignment.start,
  //                                         children: [
  //                                           Text(
  //                                             book['name'],
  //                                             style: const TextStyle(
  //                                               fontWeight: FontWeight.bold,
  //                                               fontSize: 16,
  //                                               color: Colors.black,
  //                                             ),
  //                                           ),
  //                                           const SizedBox(height: 4),
  //                                           Text(
  //                                             'Author: ${book['author']}',
  //                                             style: const TextStyle(
  //                                                 color: Colors.black54),
  //                                           ),
  //                                           Text(
  //                                             'Published Year: ${book['publishedYear']}',
  //                                             style: const TextStyle(
  //                                                 color: Colors.black54),
  //                                           ),
  //                                         ],
  //                                       ),
  //                                     ),
  //                                     IconButton(
  //                                       icon: const Icon(
  //                                           Icons.arrow_forward_ios,
  //                                           color: Color(0xFFEC8305)),
  //                                       onPressed: () async {
  //                                         final result = await Navigator.push(
  //                                           context,
  //                                           MaterialPageRoute(
  //                                             builder: (context) =>
  //                                                 BookDetailScreen(book: book),
  //                                           ),
  //                                         );
  //                                         if (result == 'deleted') {
  //                                           _refreshBooks();
  //                                         }
  //                                       },
  //                                     ),
  //                                   ],
  //                                 ),
  //                               ),
  //                             ),
  //                           );
  //                         },
  //                       ),
  //                     );
  //                   }
  //                 },
  //               ),
  //             ),
  //           ],
  //         ),
  //         const AddBookScreen(),
  //       ],
  //     ),
  //   );
  // }
}
