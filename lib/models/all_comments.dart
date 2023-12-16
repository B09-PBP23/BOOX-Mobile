// To parse this JSON data, do
//
//     final allComments = allCommentsFromJson(jsonString);

import 'dart:convert';

List<AllComments> allCommentsFromJson(String str) => List<AllComments>.from(
    json.decode(str).map((x) => AllComments.fromJson(x)));

String allCommentsToJson(List<AllComments> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AllComments {
  String model;
  int pk;
  Fields fields;

  AllComments({
    required this.model,
    required this.pk,
    required this.fields,
  });

  factory AllComments.fromJson(Map<String, dynamic> json) => AllComments(
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
  String userComment;
  DateTime timestamp;

  Fields({
    required this.user,
    required this.userComment,
    required this.timestamp,
  });

  factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        user: json["user"],
        userComment: json["user_comment"],
        timestamp: DateTime.parse(json["timestamp"]),
      );

  Map<String, dynamic> toJson() => {
        "user": user,
        "user_comment": userComment,
        "timestamp": timestamp.toIso8601String(),
      };
}
