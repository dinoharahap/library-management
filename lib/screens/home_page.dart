import 'package:flutter/material.dart';
import 'package:library_management/models/book.dart';
import 'package:library_management/screens/add_edit_book_page.dart';
import 'package:library_management/screens/book_details_page.dart';
import 'package:library_management/services/auth_service.dart';
import 'package:library_management/services/book_service.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final BookService _bookService = BookService();
  String _userFullName = 'User';
  String _searchQuery = '';
  String? _selectedCategory;
  String? _selectedStatus;

  final List<String> _categories = [
    'Fiction',
    'Non-Fiction',
    'Science',
    'History',
    'Biography',
    'Technology',
    'Other'
  ];

  final List<String> _statuses = ['available', 'borrowed'];

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final name = await Provider.of<AuthService>(context, listen: false)
        .getUserFullName();
    if (mounted) {
      setState(() {
        _userFullName = name;
      });
    }
  }

  Future<void> _signOut() async {
    await Provider.of<AuthService>(context, listen: false).signOut();
  }

  Stream<List<Book>> _getFilteredBooks() {
    if (_searchQuery.isNotEmpty) {
      return _bookService.searchBooks(_searchQuery);
    } else if (_selectedCategory != null) {
      return _bookService.filterBooksByCategory(_selectedCategory!);
    } else if (_selectedStatus != null) {
      return _bookService.filterBooksByStatus(_selectedStatus!);
    } else {
      return _bookService.getBooks();
    }
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedCategory = null;
      _selectedStatus = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting and search
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, $_userFullName',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),

                // Search bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search books by title or author',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      // Clear other filters when searching
                      _selectedCategory = null;
                      _selectedStatus = null;
                    });
                  },
                ),

                const SizedBox(height: 16),

                // Filter options
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Category filter
                      DropdownButton<String>(
                        hint: const Text('Filter by Category'),
                        value: _selectedCategory,
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                            _selectedStatus = null;
                            _searchQuery = '';
                          });
                        },
                        items: _categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                      ),
                      const SizedBox(width: 16),

                      // Status filter
                      DropdownButton<String>(
                        hint: const Text('Filter by Status'),
                        value: _selectedStatus,
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value;
                            _selectedCategory = null;
                            _searchQuery = '';
                          });
                        },
                        items: _statuses.map((status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(StringExtension(status).capitalize()),
                          );
                        }).toList(),
                      ),

                      if (_searchQuery.isNotEmpty ||
                          _selectedCategory != null ||
                          _selectedStatus != null) ...[
                        const SizedBox(width: 16),
                        TextButton.icon(
                          onPressed: _clearFilters,
                          icon: const Icon(Icons.clear),
                          label: const Text('Clear Filters'),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Book list
          Expanded(
            child: StreamBuilder<List<Book>>(
              stream: _getFilteredBooks(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final books = snapshot.data ?? [];

                if (books.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.menu_book,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty ||
                                  _selectedCategory != null ||
                                  _selectedStatus != null
                              ? 'No books match your filters'
                              : 'No books in your library yet',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.grey,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        if (_searchQuery.isEmpty &&
                            _selectedCategory == null &&
                            _selectedStatus == null)
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddEditBookPage(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add Your First Book'),
                          ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookDetailsPage(book: book),
                          ),
                        );
                      },
                      child: BookGridCard(book: book),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditBookPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class BookGridCard extends StatelessWidget {
  final Book book;
  const BookGridCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cover image
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: book.coverImageUrl != null &&
                      book.coverImageUrl!.isNotEmpty
                  ? Image.network(
                      book.coverImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image,
                            size: 48, color: Colors.grey),
                      ),
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: progress.expectedTotalBytes != null
                                ? progress.cumulativeBytesLoaded /
                                    (progress.expectedTotalBytes ?? 1)
                                : null,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.menu_book,
                          size: 48, color: Colors.grey),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.bookTitle,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  book.author,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  book.category,
                  style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
