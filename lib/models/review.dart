// To parse this JSON data, do
//
//     final review = reviewFromJson(jsonString);

import 'dart:convert';

List<Review> reviewFromJson(String str) => List<Review>.from(json.decode(str).map((x) => Review.fromJson(x)));

String reviewToJson(List<Review> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Review {
    String model;
    int pk;
    Fields fields;

    Review({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory Review.fromJson(Map<String, dynamic> json) => Review(
        model: json["model"],
        pk: json["pk"],
        fields: Fields.fromJson(json["fields"]),
    );

    Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
    };
}

class Fields {
    int book;
    int user;
    String review;
    int rating;
    DateTime createdAt;
    String username;

    Fields({
        required this.book,
        required this.user,
        required this.review,
        required this.rating,
        required this.createdAt,
        this.username = '',
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        book: json["book"],
        user: json["user"],
        review: json["review"],
        rating: json["rating"],
        createdAt: DateTime.parse(json["created_at"]),
    );

    Map<String, dynamic> toJson() => {
        "book": book,
        "user": user,
        "review": review,
        "rating": rating,
        "created_at": createdAt.toIso8601String(),
    };
}
