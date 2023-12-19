import 'dart:convert';

import 'package:boox_mobile/models/review.dart';
import 'package:flutter/material.dart';
import 'package:boox_mobile/models/books.dart';
import 'package:http/http.dart' as http;

class ReviewEditBottomSheet extends StatefulWidget {
  final Product product;
  final Function(Review) onReviewSubmitted;

  const ReviewEditBottomSheet({
    Key? key,
    required this.product,
    required this.onReviewSubmitted,
  }) : super(key: key);

  @override
  _ReviewEditBottomSheetState createState() => _ReviewEditBottomSheetState();
}

class _ReviewEditBottomSheetState extends State<ReviewEditBottomSheet> {
  TextEditingController _reviewController = TextEditingController();
  int _selectedRating = 1;
  bool _isLoading = true;
  Review? _existingReview;
  int _idreview = 0;

  @override
  void initState() {
    super.initState();
    _fetchAndSetReview();
  }

  void _fetchAndSetReview() async {
    try {
      var reviews = await fetchReviewsByUser(widget.product.pk);
      if (reviews.isNotEmpty) {
        setState(() {
          _existingReview = reviews.first;
          _reviewController.text = _existingReview!.fields.review;
          _selectedRating = _existingReview!.fields.rating;
          _isLoading = false;
          _idreview = _existingReview!.pk;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching review: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading? CircularProgressIndicator() : SingleChildScrollView(
      child: Container(
        color: Colors.black87,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.network(widget.product.fields.imageUrlL, height: 100), // Adjust the height accordingly
            Text(
              'Edit Your Review for "${widget.product.fields.title}"',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _reviewController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Write your review here...',
                hintStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
              ),
              minLines: 3,
              maxLines: 5,
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _selectedRating,
              items: List.generate(5, (index) {
                int starCount = index + 1;
                return DropdownMenuItem(
                  value: starCount,
                  child: Row(
                    children: List.generate(starCount, (index) => Icon(Icons.star, color: Colors.amber)),
                  ),
                );
              }),
              onChanged: (int? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedRating = newValue;
                  });
                }
              },
              decoration: InputDecoration(
                labelText: 'Rating',
                border: OutlineInputBorder(),
              ),
               dropdownColor: Colors.black87,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (_reviewController.text.isNotEmpty) {
                  bool isSuccess = await editReviewFlutter(
                    _idreview, // ID review
                    _reviewController.text, // Teks review
                    _selectedRating, // Rating
                  );

                  if (isSuccess) {
                    Navigator.pop(context, true);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Review successfully submitted!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Review submission failed'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                primary: Color(0xFFD85EA9), // Button background color
                onPrimary: Color(0xFFFFFFFF), // Button text color
              ),
              child: Text(
                'Save Review',
                style: TextStyle(
                  color: Color(0xFFFFFFFF),
                ),
              ),
            ),
          ],
        ),
      ),
    ); 
  }
}

Future<List<Review>> fetchReviewsByUser(int bookId) async {
  try {
    final response = await http.get(
      Uri.parse('https://boox-b09-tk.pbp.cs.ui.ac.id/add_review/get_review_by_user/$bookId'),

      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((review) => Review.fromJson(review)).toList();
    } else {
      // If server returns an OK response with an empty list, handle that case
      if (response.body.isEmpty) return [];
      throw Exception('Failed to load reviews for book ID: $bookId with status code: ${response.statusCode}');
    }
  } on Exception catch (e) {
    // For any exceptions thrown during the HTTP request
    throw Exception('Error fetching reviews for book ID: $bookId: $e');
  }
}

Future<bool> editReviewFlutter(int reviewId, String reviewText, int rating) async {
  var url = Uri.parse('https://boox-b09-tk.pbp.cs.ui.ac.id/editreview/edit-review-flutter/');  
  var response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Accept': 'application/json',
      // Sertakan header autentikasi jika diperlukan, seperti token
    },
    body: {
      'id': reviewId.toString(),  // Pastikan untuk mengirimkan ID review yang benar
      'review': reviewText,
      'rating': rating.toString(),
    },
  );

  if (response.statusCode == 200) {
    // Request berhasil dan review telah diperbarui
    return true;
  } else {
    // Terjadi kesalahan saat mengedit review
    print('Failed to edit review: ${response.body}');
    return false;
  }
}


