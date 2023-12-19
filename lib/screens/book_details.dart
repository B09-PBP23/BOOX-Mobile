import 'package:boox_mobile/models/review.dart';
import 'package:boox_mobile/models/user.dart';
import 'package:boox_mobile/screens/add_review.dart';
import 'package:boox_mobile/screens/homepage.dart';
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

  void onReviewDeleted() {
    _loadReviews();
  }

  void checkUserReviewStatus() {
    userHasReviewed = false;
  }

  Widget _buildReviewActionButton() {
    if (userHasReviewed) {
      return ElevatedButton(
        onPressed: _showEditReviewSheet,
        style: ElevatedButton.styleFrom(
          primary: Color(0xFFFFFFFF),
          onPrimary: Color(0xFFD85EA9),
        ),
        child: Text(
          'Edit Review',
          style: TextStyle(color: Color(0xFFD85EA9)),
        ),
      );
    } else {
      return ElevatedButton(
        onPressed: _showAddReviewSheet,
        style: ElevatedButton.styleFrom(
          primary: Color(0xFFD85EA9),
          onPrimary: Color(0xFFFFFFFF),
        ),
        child: Text(
          'Add Review',
          style: TextStyle(color: Color(0xFFFFFFFF)),
        ),
      );
    }
  }

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
      refreshPageForReview();
    }
  }

  void _showEditReviewSheet() async {
    final bool? result = await showModalBottomSheet<bool>(
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
    if (result == true) {
      refreshPageForReview();
    }
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

  refreshPageForReview() async {
    await _loadReviews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product.fields.title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
             Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
          },
        ),
      ),
      backgroundColor: Colors.black87,
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              'Author: ${widget.product.fields.author}',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              'Year: ${widget.product.fields.year}',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              'Publisher: ${widget.product.fields.publisher}',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              'ISBN: ${widget.product.fields.isbn}',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            SizedBox(height: 16),
            Divider(height: 1, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Reviews:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            isLoadingReviews? Center(child: CircularProgressIndicator()): buildReviewList(context, reviews, currentUsername, onReviewDeleted, checkUserReviewStatus),
            SizedBox(height: 16),
            Divider(height: 1, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              userHasReviewed ? 'Edit Your Review' : 'Add a Review',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            if (!isLoadingReviews) 
              Align(
                alignment: Alignment.center,
                child: _buildReviewActionButton(),
              ),
          ],
        ),
      ),
    );
  }
}

