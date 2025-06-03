import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:library_management/models/book.dart';
import 'package:uuid/uuid.dart';

class BookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'books';

  // Get all books
  Stream<List<Book>> getBooks() {
    return _firestore
        .collection(_collectionPath)
        .orderBy('dateAdded', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Book.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Get book by ID
  Future<Book?> getBookById(String bookId) async {
    final doc = await _firestore.collection(_collectionPath).doc(bookId).get();
    if (doc.exists) {
      return Book.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  // Add a new book (Cloudinary version)
  Future<String> addBook(Book book, File? coverImage) async {
    final bookId = const Uuid().v4();

    // Gunakan coverImageUrl dari objek Book (hasil upload Cloudinary)
    final bookData = book.toMap();
    bookData['bookId'] = bookId;
    bookData['dateAdded'] = Timestamp.now();

    await _firestore.collection(_collectionPath).doc(bookId).set(bookData);
    return bookId;
  }

  // Update an existing book (Cloudinary version)
  Future<void> updateBook(Book book, File? newCoverImage) async {
    final bookData = book.toMap();
    await _firestore
        .collection(_collectionPath)
        .doc(book.bookId)
        .update(bookData);
  }

  // Delete a book
  Future<void> deleteBook(String bookId) async {
    // Hapus dokumen buku saja, gambar di Cloudinary tidak dihapus otomatis
    await _firestore.collection(_collectionPath).doc(bookId).delete();
  }

  // Search books by title or author
  Stream<List<Book>> searchBooks(String query) {
    query = query.toLowerCase();

    return _firestore
        .collection(_collectionPath)
        .orderBy('dateAdded', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Book.fromMap(doc.data(), doc.id))
          .where((book) {
        final titleLower = book.bookTitle.toLowerCase();
        final authorLower = book.author.toLowerCase();
        return titleLower.contains(query) || authorLower.contains(query);
      }).toList();
    });
  }

  // Filter books by category
  Stream<List<Book>> filterBooksByCategory(String category) {
    return _firestore
        .collection(_collectionPath)
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Book.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Filter books by status
  Stream<List<Book>> filterBooksByStatus(String status) {
    return _firestore
        .collection(_collectionPath)
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Book.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
}
