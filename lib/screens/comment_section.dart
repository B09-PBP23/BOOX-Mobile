import 'package:boox_mobile/models/all_comments.dart';
import 'package:boox_mobile/models/user_comments.dart';
import 'package:boox_mobile/screens/add_comment.dart';
import 'package:flutter/material.dart';
import 'package:boox_mobile/widgets/left_drawer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CommentSection extends StatefulWidget {
  const CommentSection({Key? key}) : super(key: key);

  @override
  _CommentSectionState createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  late String selectedSearchCriteria;
  late TextEditingController searchController;
  late List<AllComments> allComments;
  List<AllComments> displayedComments = [];
  late List<Commenters> topContributors;
  List<Commenters> displayedContributors = [];

  @override
  void initState() {
    super.initState();
    allComments = [];
    topContributors = [];

    // Fetch all products initially
    fetchComments();
    fetchCommenters();
  }

  Future<List<AllComments>> fetchComments() async {
    // TODO: ubah link sesuai dengan link django
    var url = Uri.parse(
        "https://boox-b09-tk.pbp.cs.ui.ac.id/readers-favorite/get_all_comments/");
    var response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    var data = jsonDecode(utf8.decode(response.bodyBytes));

    List<AllComments> comments = [];
    for (var d in data) {
      if (d != null) {
        AllComments comment = AllComments.fromJson(d);
        comments.add(comment);
      }
    }

    comments.sort((a, b) => b.fields.timestamp.compareTo(a.fields.timestamp));

    List<AllComments> topcomments = comments.take(6).toList();

    setState(() {
      allComments = topcomments;
      displayedComments = allComments;
    });

    return topcomments;
  }

  Future<List<Commenters>> fetchCommenters() async {
    // TODO: ubah link sesuai dengan link django
    var url = Uri.parse(
        "https://boox-b09-tk.pbp.cs.ui.ac.id/readers-favorite/get_commenters/");
    var response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    var data = jsonDecode(utf8.decode(response.bodyBytes));

    List<Commenters> comments = [];
    for (var d in data) {
      if (d != null) {
        Commenters comment = Commenters.fromJson(d);
        comments.add(comment);
      }
    }

    // Sort products based on timeStamp in descending order
    comments.sort((a, b) =>
        b.fields.userContribution.compareTo(a.fields.userContribution));

    // Limit the list to the top 10 books
    List<Commenters> topcontributors = comments.take(6).toList();

    setState(() {
      topContributors = topcontributors;
      displayedContributors = topContributors;
    });

    return topcontributors;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'BOOX',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.pink, // Pink color for the title
          ),
        ),
        backgroundColor: Colors.black, // Black background for the app bar
        foregroundColor: Colors.white, // Pink text color for the app bar title
      ),
      drawer: const LeftDrawer(), // drawer
      backgroundColor: Colors.black87,
      body: FutureBuilder(
        future: Future.value(displayedComments),
        builder: (context, AsyncSnapshot<List<AllComments>> snapshot) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Our Readers Comment Section!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Engage with your fellow readers in this open comment section!",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: displayedComments.length,
                  itemBuilder: (_, index) =>
                      refreshCommentSection(displayedComments[index]),
                ),
              ),
              // Add a centered "Add Comment" button
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: FloatingActionButton(
                    onPressed: () async {
                      // Navigate to AddCommentScreen and wait for result
                      var result = await Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AddCommentScreen()),
                      );
                      fetchComments();
                      fetchCommenters();
                    },
                    child: const Text(
                      'Add Comment',
                      textAlign: TextAlign.center,
                    ),
                    backgroundColor: Colors.pink,
                  ),
                ),
              ),
              const Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Top Commenters!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: displayedComments.length,
                  itemBuilder: (_, index) =>
                      refreshCommenters(displayedContributors[index]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget refreshCommenters(Commenters person) {
    int userPK = person.fields.user;
    int userContribution = person.fields.userContribution;

    return InkWell(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder(
              future: fetchUsername(userPK),
              builder: (context, AsyncSnapshot<String> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  String username = snapshot.data!;
                  return Text(
                    '$username : $userContribution comments !',
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.normal,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget refreshCommentSection(AllComments comments) {
    String userComment = comments.fields.userComment;
    DateTime timestamp = comments.fields.timestamp;
    int userPK = comments.fields.user;

    return InkWell(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder(
              future: fetchUsername(userPK),
              builder: (context, AsyncSnapshot<String> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  String username = snapshot.data!;
                  return Text(
                    '$username said: "$userComment"',
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.normal,
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 8.0),
            Text(
              'Posted on: ${timestamp.toLocal()}',
              style: const TextStyle(
                fontSize: 12.0,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> fetchUsername(int userId) async {
    var url = Uri.parse(
        "https://boox-b09-tk.pbp.cs.ui.ac.id/readers-favorite/get_username_by_id/$userId/");

    try {
      var response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      // Check if the response is a valid JSON
      if (response.statusCode == 200 && isJson(response.body)) {
        var data = jsonDecode(utf8.decode(response.bodyBytes));
        String username = 'Unknown User';

        if (data != null) {
          Username usernameCommenter = Username.fromJson(data);
          username = usernameCommenter.username;
        }

        return username;
      } else {
        // Handle the case where the response is not valid JSON
        print('Invalid JSON response: ${response.body}');
        return 'Unknown User';
      }
    } catch (e) {
      // Handle other exceptions (e.g., network errors)
      print('Error fetching username: $e');
      return 'Unknown User';
    }
  }

// Function to check if a string is valid JSON
  bool isJson(String str) {
    try {
      jsonDecode(str);
      return true;
    } catch (_) {
      return false;
    }
  }
}