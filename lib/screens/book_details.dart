import 'package:flutter/material.dart';
import 'package:boox_mobile/models/books.dart';

class BookDetailsPage extends StatefulWidget {
  final Product product;

  const BookDetailsPage({Key? key, required this.product}) : super(key: key);

  @override
  _BookDetailsPageState createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  List<String> reviews = []; // List to store reviews
  TextEditingController reviewController = TextEditingController();

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
              'Author: ${widget.product.fields.author}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

            if (reviews.isNotEmpty)
              // TODO: Bagian reviews
              Column(
                children: reviews
                    .map((review) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text(review),
                          ),
                        ))
                    .toList(),
              )
            else 
              Text('No reviews yet.'), 
            
            SizedBox(height: 16),
            Divider(height: 1, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Add a Review:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),

            // TODO: Section ke bawah harus dihandle
            TextField(
              controller: reviewController,
              decoration: InputDecoration(
                hintText: 'Write your review...',
                border: OutlineInputBorder(),
              ),
              minLines: 3,
              maxLines: 5,
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                // TODO: Benerin handle add review
                if (reviewController.text.isNotEmpty) {
                  setState(() {
                    reviews.add(reviewController.text);
                    reviewController.clear();
                  });
                }
              },
              child: Text('Submit Review'),
            ),
          ],
        ),
      ),
    );
  }
}
