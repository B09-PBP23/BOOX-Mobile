import 'package:boox_mobile/screens/comment_section.dart';
import 'package:boox_mobile/models/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddCommentScreen extends StatefulWidget {
  const AddCommentScreen({Key? key}) : super(key: key);

  @override
  _AddCommentScreenState createState() => _AddCommentScreenState();
}

class _AddCommentScreenState extends State<AddCommentScreen> {
  late TextEditingController commentController;

  @override
  void initState() {
    super.initState();
    commentController = TextEditingController();
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  Future<void> addComment() async {
    String comment = commentController.text;

    var url = Uri.parse(
        "https://boox-b09-tk.pbp.cs.ui.ac.id/readers-favorite/add_comment_flutter/${User.username}/");

    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'user_comment': comment},
      );

      if (response.statusCode == 201) {
        // Comment added successfully
        var result = await Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CommentSection()),
        );
      } else {
        // Handle errors or display a message to the user
        print('Failed to add comment. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle other exceptions (e.g., network errors)
      print('Error adding comment: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Comment',
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
                builder: (context) => CommentSection(),
              ),
            );
          },
        ),
      ),
      backgroundColor: Colors.black87,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: commentController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Enter your comment',
                labelStyle: TextStyle(color: Colors.white),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: addComment,
              style: ElevatedButton.styleFrom(
                primary: Colors.pink,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Add Comment',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
