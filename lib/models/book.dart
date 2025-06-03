import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String bookId;
  final String bookTitle;
  final String author;
  final String category;
  final String status; // 'available' or 'borrowed'
  final DateTime dateAdded;
  final String? coverImageUrl;

  Book({
    required this.bookId,
    required this.bookTitle,
    required this.author,
    required this.category,
    required this.status,
    required this.dateAdded,
    this.coverImageUrl,
  });

  // Create Book from Firestore document
  factory Book.fromMap(Map<String, dynamic> map, String id) {
    return Book(
      bookId: id,
      bookTitle: map['bookTitle'] ?? '',
      author: map['author'] ?? '',
      category: map['category'] ?? '',
      status: map['status'] ?? 'available',
      dateAdded: (map['dateAdded'] as Timestamp).toDate(),
      coverImageUrl: map['coverImageUrl'],
    );
  }

  // Convert Book to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'bookTitle': bookTitle,
      'author': author,
      'category': category,
      'status': status,
      'dateAdded': dateAdded,
      'coverImageUrl': coverImageUrl,
    };
  }

  // Create a copy of Book with updated fields
  Book copyWith({
    String? bookTitle,
    String? author,
    String? category,
    String? status,
    DateTime? dateAdded,
    String? coverImageUrl,
  }) {
    return Book(
      bookId: this.bookId,
      bookTitle: bookTitle ?? this.bookTitle,
      author: author ?? this.author,
      category: category ?? this.category,
      status: status ?? this.status,
      dateAdded: dateAdded ?? this.dateAdded,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
    );
  }
}
