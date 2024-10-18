import 'package:flutter/material.dart';
import '../api_service.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({Key? key}) : super(key: key);

  @override
  _AddBookScreenState createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _nameController = TextEditingController();
  final _authorController = TextEditingController();
  final _yearController = TextEditingController();
  ApiService apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Book'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Book Title'),
            ),
            TextField(
              controller: _authorController,
              decoration: const InputDecoration(labelText: 'Author'),
            ),
            TextField(
              controller: _yearController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Published Year'),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(
                  bottom: 30.0), // Jarak dari bagian bawah
              child: ElevatedButton(
                onPressed: () async {
                  final newBook = {
                    'name': _nameController.text,
                    'author': _authorController.text,
                    'publishedYear': int.parse(_yearController.text),
                  };
                  try {
                    await apiService.addBook(newBook);
                    Navigator.pop(
                        context, true); // Kembali ke halaman BookListScreen
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to add book: $e')),
                    );
                  }
                },
                child: const Text('Add Book',
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
      ),
    );
  }
}
