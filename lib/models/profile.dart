// To parse this JSON data, do
//
//     final product = productFromJson(jsonString);

import 'dart:convert';

List<Product> productFromJson(String str) => List<Product>.from(json.decode(str).map((x) => Product.fromJson(x)));

String productToJson(List<Product> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Product {
    String model;
    int pk;
    Fields fields;

    Product({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory Product.fromJson(Map<String, dynamic> json) => Product(
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
    int user;
    String profilePicture;
    String name;
    DateTime dateJoined;
    String description;
    String favoriteBooks;
    String favoriteAuthor;

    Fields({
        required this.user,
        required this.profilePicture,
        required this.name,
        required this.dateJoined,
        required this.description,
        required this.favoriteBooks,
        required this.favoriteAuthor,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        user: json["user"],
        profilePicture: json["profile_picture"],
        name: json["name"],
        dateJoined: DateTime.parse(json["date_joined"]),
        description: json["description"],
        favoriteBooks: json["favorite_books"],
        favoriteAuthor: json["favorite_author"],
    );

    Map<String, dynamic> toJson() => {
        "user": user,
        "profile_picture": profilePicture,
        "name": name,
        "date_joined": "${dateJoined.year.toString().padLeft(4, '0')}-${dateJoined.month.toString().padLeft(2, '0')}-${dateJoined.day.toString().padLeft(2, '0')}",
        "description": description,
        "favorite_books": favoriteBooks,
        "favorite_author": favoriteAuthor,
    };
}
