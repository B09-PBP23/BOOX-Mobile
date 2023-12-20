// To parse this JSON data, do
//
//     final reply = replyFromJson(jsonString);

import 'dart:convert';

List<Reply> replyFromJson(String str) => List<Reply>.from(json.decode(str).map((x) => Reply.fromJson(x)));

String replyToJson(List<Reply> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Reply {
    String model;
    int pk;
    Fields fields;

    Reply({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory Reply.fromJson(Map<String, dynamic> json) => Reply(
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
    int review;
    String reply;
    String username;

    Fields({
        required this.user,
        required this.review,
        required this.reply,
        this.username = '',
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        user: json["user"],
        review: json["review"],
        reply: json["reply"] ?? '',
    );

    Map<String, dynamic> toJson() => {
        "user": user,
        "review": review,
        "reply": reply,
    };
}
