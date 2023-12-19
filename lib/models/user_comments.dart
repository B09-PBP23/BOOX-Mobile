// To parse this JSON data, do
//
//     final commenters = commentersFromJson(jsonString);

import 'dart:convert';

List<Commenters> commentersFromJson(String str) =>
    List<Commenters>.from(json.decode(str).map((x) => Commenters.fromJson(x)));

String commentersToJson(List<Commenters> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Commenters {
  String model;
  int pk;
  Fields fields;

  Commenters({
    required this.model,
    required this.pk,
    required this.fields,
  });

  factory Commenters.fromJson(Map<String, dynamic> json) => Commenters(
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
  int userContribution;

  Fields({
    required this.user,
    required this.userContribution,
  });

  factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        user: json["user"],
        userContribution: json["user_contribution"],
      );

  Map<String, dynamic> toJson() => {
        "user": user,
        "user_contribution": userContribution,
      };
}

// To parse this JSON data, do
//
//     final username = usernameFromJson(jsonString);

Username usernameFromJson(String str) => Username.fromJson(json.decode(str));

String usernameToJson(Username data) => json.encode(data.toJson());

class Username {
  String username;

  Username({
    required this.username,
  });

  factory Username.fromJson(Map<String, dynamic> json) => Username(
        username: json["username"],
      );

  Map<String, dynamic> toJson() => {
        "username": username,
      };
}
