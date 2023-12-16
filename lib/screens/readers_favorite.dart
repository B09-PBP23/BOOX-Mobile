import 'package:flutter/material.dart';
import 'package:boox_mobile/widgets/left_drawer.dart';
import 'package:boox_mobile/models/books.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReadersFavorite extends StatefulWidget {
  const ReadersFavorite({Key? key}) : super(key: key);

  @override
  _ReadersFavoriteState createState() => _ReadersFavoriteState();
}

class _ReadersFavoriteState extends State<ReadersFavorite> {
  late String selectedSearchCriteria;
  late TextEditingController searchController;
  late List<Product> allProducts;
  List<Product> displayedProducts = [];

  @override
  void initState() {
    super.initState();
    allProducts = [];

    // Fetch all products initially
    fetchItems();
  }

  Future<List<Product>> fetchItems() async {
    // TODO: ubah link sesuai dengan link django
    var url = Uri.parse("https://boox-b09-tk.pbp.cs.ui.ac.id/");
    var response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    var data = jsonDecode(utf8.decode(response.bodyBytes));

    List<Product> products = [];
    for (var d in data) {
      if (d != null) {
        Product product = Product.fromJson(d);
        products.add(product);
      }
    }

    // Sort products based on totalReviews in descending order
    products
        .sort((a, b) => b.fields.totalReviews.compareTo(a.fields.totalReviews));

    // Limit the list to the top 10 books
    List<Product> top10Books = products.take(10).toList();

    top10Books
        .sort((a, b) => b.fields.totalUpvotes.compareTo(a.fields.totalUpvotes));

    setState(() {
      allProducts = top10Books;
      displayedProducts = allProducts;
    });

    return top10Books;
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
        future: Future.value(displayedProducts),
        builder: (context, AsyncSnapshot<List<Product>> snapshot) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Our Readers Top 10 Voted Books!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Here you can view this month's top 10 most reviewed books by our readers! Contribute by upvoting your favorite books!",
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
                  itemCount: displayedProducts.length,
                  itemBuilder: (_, index) =>
                      top10books(displayedProducts[index]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget top10books(Product product) {
    String bookTitle = product.fields.title;
    String bookAuthor = product.fields.author;
    String bookReviews = product.fields.totalReviews.toString();
    String bookUpvotes = product.fields.totalUpvotes.toString();

    bookTitle =
        bookTitle.length > 30 ? bookTitle.substring(0, 30) + "..." : bookTitle;

    return InkWell(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  bottomLeft: Radius.circular(15.0),
                ),
                child: Image.network(
                  product.fields.imageUrlM,
                  height: 150,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        bookTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Author: ${bookAuthor}',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      Text(
                        'Reviews count: ${bookReviews}',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      Text(
                        'Upvotes Count: ${bookUpvotes}',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.arrow_upward),
                onPressed: () {
                  handleUpvote(product);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> handleUpvote(Product product) async {
    await Future.delayed(Duration(seconds: 1));

    final response = await http.get(
      Uri.parse(
          'https://boox-b09-tk.pbp.cs.ui.ac.id/readers-favorite/check_upvote_status/${product.pk}'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final bool isUpvoted = jsonDecode(response.body)['has_upvoted'];
      if (isUpvoted) {
        _showPopup('Product is already upvoted.');
      } else {
        _showPopup('Product is not upvoted. Perform upvote action.');
        await performUpvote(product);
        // Fetch items again after upvote
        await fetchItems();
      }
    } else {
      _showPopup(
          'Failed to check upvote status. Error: ${response.reasonPhrase}');
    }
  }

  Future<void> performUpvote(Product product) async {
    final response = await http.post(
      Uri.parse(
          'https://boox-b09-tk.pbp.cs.ui.ac.id/readers-favorite/add_upvote_ajax/${product.pk}'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData['success'] == true) {
        setState(() {
          product.fields.totalUpvotes += 1;
        });

        // Show a success popup
        _showPopup('Upvote Successful');
        // Fetch items again after upvote
        await fetchItems();
      } else {
        // Show a failure popup
        _showPopup('Upvote Failed: ${responseData['message']}');
      }
    } else {
      // Show a failure popup
      _showPopup('Failed to perform upvote. Error: ${response.reasonPhrase}');
    }
  }

  void _showPopup(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Upvote Status'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the popup
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
