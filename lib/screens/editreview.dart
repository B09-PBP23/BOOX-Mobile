import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'dart:async'; // Required for asynchronous features

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BOOX',
      theme: ThemeData(
        primaryColor: Colors.black,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Colors.pinkAccent,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: const TextTheme( // Add const here
          bodyText1: TextStyle(color: Colors.white),
          bodyText2: TextStyle(color: Colors.white),
        ),
      ),
      // You should only use EditReviewPage() directly like this for testing.
      // In a real app, you would navigate to EditReviewPage from another widget and pass the 'review' argument.
      home: EditReviewPage(review: 'Your initial review text for testing'), // Provide a default review text here
    );
  }
}



class EditReviewPage extends StatefulWidget {
  final String review; // Add this line to hold the review text

  // Update the constructor to include the review parameter
  const EditReviewPage({Key? key, required this.review}) : super(key: key);

  @override
  _EditReviewPageState createState() => _EditReviewPageState();
}


class _EditReviewPageState extends State<EditReviewPage> {
  late TextEditingController _reviewController = TextEditingController();
  double _currentRating = 3; // Default rating is 3 stars
  String _bookTitle = ''; // Book title will be fetched from the database

  @override
  void initState() {
    super.initState();
    _reviewController = TextEditingController(text: widget.review); // Use the review text passed in
    fetchBookData();
  }

  Future<void> fetchBookData() async {
    // Simulate a network request to fetch book data
    await Future.delayed(Duration(seconds: 2)); // Mock delay
    setState(() {
      // Once data is fetched, update the state of your app
      _bookTitle = 'Atomic Habits'; // Replace with actual data fetched from your database
      // _currentRating = fetchedRating; // Replace with actual rating fetched from your database
      // _reviewController.text = fetchedReviewText; // Replace with actual review text fetched from your database
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Edit Review'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              // Handle menu button action
            },
          ),
        ],
      ),
      body: _bookTitle.isEmpty
          ? Center(child: CircularProgressIndicator()) // Show a loading spinner while fetching data
          : SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Card(
                      color: Colors.grey[850],
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              _bookTitle,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            RatingBar.builder(
                              initialRating: _currentRating,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                              itemBuilder: (context, _) => Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              onRatingUpdate: (rating) {
                                setState(() {
                                  _currentRating = rating;
                                });
                              },
                            ),
                            SizedBox(height: 16),
                            TextField(
                              controller: _reviewController,
                              maxLines: 5,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                fillColor: Colors.grey[700],
                                filled: true,
                                hintText: 'Write your review...',
                                hintStyle: TextStyle(color: Colors.white70),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  // Handle save changes action
                                },
                                child: Text('Save Changes'),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.pinkAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                  ),
                                ),
                              ),
                            ),
                          ],
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
