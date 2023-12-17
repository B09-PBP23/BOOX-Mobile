import 'package:boox_mobile/models/review.dart';
import 'package:boox_mobile/models/user.dart';
import 'package:boox_mobile/screens/add_review.dart';
import 'package:boox_mobile/screens/edit_review.dart';
import 'package:boox_mobile/screens/show_review.dart';
import 'package:flutter/material.dart';
import 'package:boox_mobile/models/books.dart';

class BookDetailsPage extends StatefulWidget {
  final Product product;

  const BookDetailsPage({Key? key, required this.product}) : super(key: key);

  @override
  _BookDetailsPageState createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  List<Review> reviews = []; // List to store reviews
  TextEditingController reviewController = TextEditingController();
  bool userHasReviewed = false;
  bool isLoadingReviews = true; // Track loading status
  String currentUsername = User.username;

  void _showAddReviewSheet() async {
    final bool? result = await showModalBottomSheet<bool>(
      context: context,
      builder: (BuildContext context) {
        return ReviewAddBottomSheet(
          product: widget.product,
          onReviewSubmitted: (Review review) {
            setState(() {
              reviews.add(review);
            });
          },
        );
      },
    );
    if (result == true) {
      _refreshPage();
    }
  }

  void _showEditReviewSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ReviewEditBottomSheet(
          product: widget.product,
          onReviewSubmitted: (Review review) {
            setState(() {
              reviews.add(review);
            });
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  _loadReviews() async {
    setState(() {
      isLoadingReviews = true; // Start loading
    });
    try {
      List<Review> fetchedReviews = await fetchReviewsByBookId(widget.product.pk);

      for (var review in fetchedReviews) {
        String username = await fetchUsernameForReview(review.fields.user);
        setState(() {
          review.fields.username = username;
          if (username == currentUsername) {
            userHasReviewed = true; // Set true if the user has already reviewed
          }
        });
      }

      setState(() {
        reviews = fetchedReviews;
        isLoadingReviews = false;
      });
    } catch (e) {
      setState(() {
        isLoadingReviews = false; // Stop loading on error
      });
      print('Error loading reviews: $e');
      // Handle errors or show an error message
    }
  }

  _refreshPage() async {
    await _loadReviews();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.fields.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(widget.product.fields.imageUrlL)
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              '${widget.product.fields.title}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Author: ${widget.product.fields.author}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Year: ${widget.product.fields.year}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Publisher: ${widget.product.fields.publisher}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'ISBN: ${widget.product.fields.isbn}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Divider(height: 1, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Reviews:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            isLoadingReviews? Center(child: CircularProgressIndicator()): _buildReviewList(reviews),
            
            SizedBox(height: 16),
            Divider(height: 1, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Add a Review:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            isLoadingReviews? Center(child: CircularProgressIndicator()) : Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: userHasReviewed ? _showEditReviewSheet : _showAddReviewSheet,
                style: ElevatedButton.styleFrom(
                  primary: userHasReviewed ? Color(0xFFFFFFFF) : Color(0xFFD85EA9), // Change button color
                  onPrimary: userHasReviewed ? Color(0xFFD85EA9) : Color(0xFFFFFFFF), // Change text color
                ),
                child: Text(
                  userHasReviewed ? 'Edit Review' : 'Add Review',
                  style: TextStyle(
                    color: userHasReviewed ? Color(0xFFD85EA9) : Color(0xFFFFFFFF), // Change text color
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

 Widget _buildReviewList(List<Review> reviews) {
  if (reviews.isNotEmpty) {
    return Column(
      children: reviews.map((Review review) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            title: Text(
              review.fields.username,
              style: TextStyle(fontWeight: FontWeight.bold), 
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(review.fields.review),
                SizedBox(height: 8),
                buildRatingStars(review.fields.rating),
              ],
            ),
            trailing: Text(review.fields.createdAt.toIso8601String()),
          ),
        );
      }).toList(),
    );
  } else {
    return Text('No reviews yet.');
  }
}
