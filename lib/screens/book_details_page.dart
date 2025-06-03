import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:library_management/models/book.dart';
import 'package:library_management/screens/add_edit_book_page.dart';
import 'package:library_management/services/book_service.dart';

class BookDetailsPage extends StatelessWidget {
  final Book book;
  
  const BookDetailsPage({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final BookService bookService = BookService();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditBookPage(book: book),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _showDeleteConfirmation(context, bookService);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book cover and basic info
            Container(
              width: double.infinity,
              color: Colors.brown.shade50,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Book cover
                  Container(
                    width: 180,
                    height: 240,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                      image: book.coverImageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(book.coverImageUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: book.coverImageUrl == null
                        ? const Icon(
                            Icons.menu_book,
                            size: 64,
                            color: Colors.grey,
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  
                  // Book title
                  Text(
                    book.bookTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  
                  // Author
                  Text(
                    'by ${book.author}',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  
                  // Status chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: book.status == 'available'
                          ? Colors.green.shade100
                          : Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: book.status == 'available'
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                    child: Text(
                      StringExtension(book.status).capitalize(),
                      style: TextStyle(
                        color: book.status == 'available'
                            ? Colors.green.shade800
                            : Colors.orange.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Book details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailItem(
                    context,
                    'Category',
                    book.category,
                    Icons.category,
                  ),
                  const Divider(),
                  _buildDetailItem(
                    context,
                    'Added on',
                    DateFormat('MMMM d, yyyy').format(book.dateAdded),
                    Icons.calendar_today,
                  ),
                  const Divider(),
                  _buildDetailItem(
                    context,
                    'Book ID',
                    book.bookId,
                    Icons.numbers,
                  ),
                  const SizedBox(height: 32),
                  
                  // Change status button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _changeBookStatus(context, bookService);
                      },
                      icon: Icon(
                        book.status == 'available'
                            ? Icons.book
                            : Icons.bookmark_remove,
                      ),
                      label: Text(
                        book.status == 'available'
                            ? 'Mark as Borrowed'
                            : 'Mark as Available',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.brown,
            size: 24,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _changeBookStatus(
    BuildContext context,
    BookService bookService,
  ) async {
    final newStatus = book.status == 'available' ? 'borrowed' : 'available';
    
    try {
      final updatedBook = book.copyWith(status: newStatus);
      await bookService.updateBook(updatedBook, null);
      
      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    BookService bookService,
  ) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Book'),
          content: Text(
            'Are you sure you want to delete "${book.bookTitle}"? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close dialog
                
                try {
                  await bookService.deleteBook(book.bookId);
                  if (context.mounted) {
                    Navigator.pop(context); // Return to previous screen
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
