import 'dart:convert';
import 'package:boox_mobile/models/review.dart';
import 'package:boox_mobile/screens/show_reply.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:timeago/timeago.dart' as timeago;

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

Widget buildReviewList(BuildContext context, List<Review> reviews, String currentUsername, Function onReviewDeleted, Function checkUserReviewStatus) {
  if (reviews.isEmpty) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Text('No reviews yet.', style: TextStyle(color: Colors.white, fontSize: 16)),
    );
  }

  return Column(
    children: reviews.map((Review review) {
      bool isCurrentUserReview = review.fields.username == currentUsername;
      String timeAgo = timeago.format(review.fields.createdAt);

      return Card(
        color: Colors.grey[850], // Adjust the color to match your theme
        child: Stack(
          children: [
            ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    review.fields.username,
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  buildRatingStars(review.fields.rating), // Show the rating stars here
                ],
              ),
              subtitle: Text(
                review.fields.review,
                style: TextStyle(color: Colors.white),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Positioned(
              right: 10,
              top: 10,
              child: Text(
                timeAgo,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
            ),
            Positioned(
              right: 4,
              bottom: 4,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isCurrentUserReview) IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      bool shouldDelete = await showDeleteConfirmationDialog(context);
                      if (shouldDelete) {
                        bool success = await deleteReview(review.pk);
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Review deleted successfully"),
                            backgroundColor: Colors.green,
                          ));
                           onReviewDeleted();
                           checkUserReviewStatus();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Failed to delete review"),
                            backgroundColor: Colors.red,
                          ));
                        }
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.reply, color: Colors.blue),
                    onPressed: () {
                      showReplyBottomSheet(context, review.pk);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList(),
  );
}

Future<bool> showDeleteConfirmationDialog(BuildContext context) async {
  return await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.black87,
        title: Text('Delete Review', style: TextStyle(color: Colors.white)),
        content: Text('Do you want to delete this review?', style: TextStyle(color: Colors.white)),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel', style: TextStyle(color: Colors.white)),
            onPressed: () {
              Navigator.of(context).pop(false); // User chooses not to delete the review
            },
          ),
          TextButton(
            child: Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.of(context).pop(true); // User confirms to delete the review
            },
          ),
        ],
      );
    },
  ) ?? false; // Returning false if dialog is dismissed
}

Future<bool> deleteReview(int idReview) async {
  var url = Uri.parse('https://boox-b09-tk.pbp.cs.ui.ac.id/add_review/delete-review-flutter/$idReview/');

  try {
    var response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Request berhasil dan review berhasil dihapus
      return true;
    } else {
      // Terjadi kesalahan saat menghapus review
      print('Failed to delete review: ${response.body}');
      return false;
    }
  } catch (e) {
    // Handle any errors that occur during the request
    print('Error deleting review: $e');
    return false;
  }
}



