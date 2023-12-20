import 'package:boox_mobile/models/review.dart';
import 'package:flutter/material.dart';
import 'package:boox_mobile/models/books.dart';
import 'package:http/http.dart' as http;

class ReviewAddBottomSheet extends StatefulWidget {
  final Product product;
  final Function(Review) onReviewSubmitted;

  const ReviewAddBottomSheet({
    Key? key,
    required this.product,
    required this.onReviewSubmitted,
  }) : super(key: key);

  @override
  _ReviewAddBottomSheetState createState() => _ReviewAddBottomSheetState();
}

class _ReviewAddBottomSheetState extends State<ReviewAddBottomSheet> {
  TextEditingController _reviewController = TextEditingController();
  int _selectedRating = 1; // Default to 1 star

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: Colors.black87,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.network(widget.product.fields.imageUrlL, height: 100), // Adjust the height accordingly
            Text(
              'Add Your Review for "${widget.product.fields.title}"',
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
                  bool isSuccess = await submitReview(
                    widget.product.pk, // ID buku
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

Future<bool> submitReview(int bookId, String reviewText, int rating) async {
  var url = Uri.parse('https://boox-b09-tk.pbp.cs.ui.ac.id/add_review/add_review_ajax/');
  
  var response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Accept': 'application/json',
    },
    body: {
      'book': bookId.toString(),
      'review': reviewText,
      'rating': rating.toString(),
    },
  );

  if (response.statusCode == 201) {
    // Berhasil membuat review baru
    return true;
  } else if (response.statusCode == 200) {
    // Review sudah ada
    return false;
  } else {
    // Terjadi error
    throw Exception('Failed to submit review');
  }
}