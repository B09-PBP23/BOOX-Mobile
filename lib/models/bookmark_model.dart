
import 'dart:convert';

class BookmarModel {
  final int userId;
  final int bookId;
  final String isbn;
  final String title;
  final String author;
  final int year;
  final String publisher;
  final String imageUrlS;
  final String imageUrlM;
  final String imageUrlL;
  final int totalRatings;
  final int totalReviews;
  final int totalUpvotes;

  BookmarModel({
    required this.userId,
    required this.bookId,
    required this.isbn,
    required this.title,
    required this.author,
    required this.year,
    required this.publisher,
    required this.imageUrlS,
    required this.imageUrlM,
    required this.imageUrlL,
    required this.totalRatings,
    required this.totalReviews,
    required this.totalUpvotes,
  });

  factory BookmarModel.fromJson(Map<String, dynamic> json) => BookmarModel(
    userId: json["user_id"]??0,
    bookId: json["book_id"]??0,
    isbn: json["isbn"]??"",
    title: json["title"]??"",
    author: json["author"]??"",
    year: json["year"]??0,
    publisher: json["publisher"]??"",
    imageUrlS: json["imageUrlS"]??"https://lightwidget.com/wp-content/uploads/localhost-file-not-found.jpg",
    imageUrlM: json["imageUrlM"]??"https://lightwidget.com/wp-content/uploads/localhost-file-not-found.jpg",
    imageUrlL: json["imageUrlL"]??"https://lightwidget.com/wp-content/uploads/localhost-file-not-found.jpg",
    totalRatings: json["totalRatings"]??0,
    totalReviews: json["totalReviews"]??0,
    totalUpvotes: json["totalUpvotes"]??0,
  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "book_id": bookId,
    "isbn": isbn,
    "title": title,
    "author": author,
    "year": year,
  };
}
