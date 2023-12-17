import 'dart:convert';
import 'package:boox_mobile/models/review.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<List<Review>> fetchReviewsByBookId(int bookId) async {
  final response = await http.get(
    Uri.parse('https://boox-b09-tk.pbp.cs.ui.ac.id/add_review/get_reviews/$bookId'),
    headers: {"Content-Type": "application/json"},
  );

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((review) => Review.fromJson(review)).toList();
  } else {
    throw Exception('Failed to load reviews for book ID: $bookId');
  }
}

// Method to build the rating stars widget
Widget buildRatingStars(int rating) {
  List<Widget> stars = List.generate(5, (index) {
    return Icon(
      index < rating ? Icons.star : Icons.star_border,
      color: Colors.amber,
      size: 20,
    );
  });
  return Row(children: stars);
}

Future<String> fetchUsernameForReview(int userId) async {
  final url = Uri.parse('https://boox-b09-tk.pbp.cs.ui.ac.id/readers-favorite/get_username_by_id/$userId/');

  try {
    final response = await http.get(url, headers: {"Content-Type": "application/json"});
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['username'];
    } else {
      print('Error: ${response.statusCode}');
      return 'Unknown User';
    }
  } catch (e) {
    print('Error fetching username: $e');
    return 'Unknown User';
  }
}