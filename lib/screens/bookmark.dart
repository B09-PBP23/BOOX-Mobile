import 'dart:convert';

import 'package:boox_mobile/models/bookmark_model.dart';
import 'package:boox_mobile/models/books.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'book_details.dart';

void main() {
  runApp(MyBookmark());
}

class Bookmark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bookmarked Books',
      theme: ThemeData(
        primaryColor: Color(0xFFD85EA9),
        scaffoldBackgroundColor: Color(0xFF1F2122),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyBookmark(),
    );
  }
}

class MyBookmark extends StatefulWidget {
  @override
  State<MyBookmark> createState() => _MyBookmarkState();
}

class _MyBookmarkState extends State<MyBookmark> {
  Future<List<BookmarModel>> _getBookmark(BuildContext context) async {
    List<BookmarModel> bookMarks = [];
    try {
      final request = context.watch<CookieRequest>();

      print(request.cookies['csrftoken']!.value);
      print(request.cookies['sessionid']!.value);

      final response = await http.get(
        Uri.parse(
            "https://boox-b09-tk.pbp.cs.ui.ac.id/bookmarks/get_bookmark_per_user/"),
        headers: {
          "Content-Type": "application/json; charset=UTF-8",
          "X-CSRFToken": request.cookies['csrftoken']!.value,
          "Cookie":
              "csrftoken=${request.cookies['csrftoken']!.value};sessionid=${request.cookies['sessionid']!.value}",
        },
      );

      print(response.body);
      if (response.statusCode == 200) {
        var result = json.decode(response.body);

        List data = result["data"];

        print(result.runtimeType);
        for (int i = 0; i < data.length; i++) {
          print(data[i]);

          bookMarks.add(BookmarModel.fromJson(data[i]));
        }

        return bookMarks;
      }

      return bookMarks;
    } catch (e) {
      print("msuk e");
      return bookMarks;
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        title: Text('BOOX'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Adjust padding as needed
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bookmarked Books',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24.0, // Adjust the font size as needed
                fontWeight: FontWeight.bold, // Add bold if desired
              ),
            ),
            // Add more widgets for displaying bookmarked books or content
            SizedBox(
              height: 20,
            ),
            FutureBuilder(
                future: _getBookmark(context),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    if (snapshot.hasData) {
                      List<BookmarModel> booksmarks = snapshot.data!;
                      return Column(
                        children: [
                          ...booksmarks.map((data) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => BookDetailsPage(
                                          product: Product(
                                              model: Model.LANDING_PAGE_BOOKS,
                                              pk: 0,
                                              fields: Fields(
                                                  isbn: data.isbn,
                                                  title: data.title,
                                                  author: data.author,
                                                  year: data.year,
                                                  publisher: data.publisher,
                                                  imageUrlS: data.imageUrlS,
                                                  imageUrlM: data.imageUrlM,
                                                  imageUrlL: data.imageUrlL,
                                                  totalRatings:
                                                      data.totalRatings,
                                                  totalReviews:
                                                      data.totalReviews,
                                                  totalUpvotes:
                                                      data.totalUpvotes)))),
                                );
                              },
                              child: Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data.title,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors
                                                .black), // Black color for the title
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        "Isbn : " + data.isbn,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors
                                                .black), // Black color for the title
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      Center(
                                          child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red),
                                              onPressed: () async {
                                                try {
                                                  print(request
                                                      .cookies['csrftoken']!
                                                      .value);
                                                  print(request
                                                      .cookies['sessionid']!
                                                      .value);

                                                  final response =
                                                      await http.post(
                                                    Uri.parse(
                                                        "https://boox-b09-tk.pbp.cs.ui.ac.id/bookmarks/remove_from_bookmark/${data.bookId}/"),
                                                    headers: {
                                                      "Content-Type":
                                                          "application/json; charset=UTF-8",
                                                      "X-CSRFToken": request
                                                          .cookies['csrftoken']!
                                                          .value,
                                                      "Cookie":
                                                          "csrftoken=${request.cookies['csrftoken']!.value};sessionid=${request.cookies['sessionid']!.value}",
                                                    },
                                                  );

                                                  if (response.statusCode ==
                                                      200) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                            content: Text(
                                                                "remove success")));
                                                    setState(() {});
                                                  }
                                                } catch (e) {
                                                  print("msuk e : " +
                                                      e.runtimeType.toString());
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(
                                                          content: Text(
                                                              "remove failed")));
                                                }
                                              },
                                              child: Text(
                                                "Remove",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )))
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList()
                        ],
                      );
                    } else {
                      return Center(
                        child: Text(
                          "no data",
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black), // Black color for the title
                        ),
                      );
                    }
                  }
                })
          ],
        ),
      ),
    );
  }
}