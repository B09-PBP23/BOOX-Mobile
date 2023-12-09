import 'package:flutter/material.dart';
import 'package:boox_mobile/widgets/left_drawer.dart';
import 'package:boox_mobile/screens/book_details.dart';
import 'package:boox_mobile/models/books.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String selectedSearchCriteria;
  late TextEditingController searchController;
  late List<Product> allProducts;
  List<Product> displayedProducts = [];

  @override
  void initState() {
    super.initState();
    selectedSearchCriteria = 'Title';
    searchController = TextEditingController();
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

    setState(() {
      allProducts = products;
      displayedProducts = allProducts;
    });

    return products;
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
          if (snapshot.data == null) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.pink, // Pink color for CircularProgressIndicator
              ),
            );
          } else {
            if (!snapshot.hasData) {
              return const Column(
                children: [
                  Text("No Data",
                      style: TextStyle(
                          color: Color(0xff59A5D8), fontSize: 20)),
                  SizedBox(height: 8),
                ],
              );
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Featured Books',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white), // Pink color for the title
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Discover the latest and most popular books.',
                          style: TextStyle(
                              fontSize: 16, color: Colors.white), // Pink color for the description
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        DropdownButton<String>(
                          value: selectedSearchCriteria,
                          onChanged: (value) {
                            setState(() {
                              selectedSearchCriteria = value!;
                            });
                            performSearch();
                          },
                          items: ['Title', 'Author', 'Publisher'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                          dropdownColor: Colors.black,
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              hintText: 'Find your book(s)...',
                              hintStyle: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            onChanged: (value) {
                              performSearch();
                            },
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ), 
                          ),
                        ),
                        SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {
                            performReset();
                          },
                          child: Text('Reset'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                            itemCount: displayedProducts.length,
                            itemBuilder: (_, index) =>
                                buildItemList(displayedProducts[index]),
                          ),
                  ),
                ],
              );
            }
          }
        },
      ),
    );
  }

  Future<void> performReset() async {
    setState(() {
      searchController.text = '';
      displayedProducts = allProducts;
      selectedSearchCriteria = 'Title';
    });
  }

  Future<void> performSearch() async {
    String searchTerm = searchController.text.toLowerCase();

    setState(() {
      displayedProducts = allProducts.where((product) {
        switch (selectedSearchCriteria) {
          case 'Title':
            return product.fields.title.toLowerCase().contains(searchTerm);
          case 'Author':
            return product.fields.author.toLowerCase().contains(searchTerm);
          case 'Publisher':
            return product.fields.publisher.toLowerCase().contains(searchTerm);
          default:
            return false;
        }
      }).toList();
    });
  }

  Widget buildItemList(Product product) {
    final rating = (product.fields.totalReviews == 0)
        ? 0
        : product.fields.totalRatings / product.fields.totalReviews;

    String bookTItle = product.fields.title;
    String bookAuthor = product.fields.author;
    String bookYear = product.fields.year.toString();
    String bookPublisher = product.fields.publisher;

    bookTItle = bookTItle.length > 30
        ? bookTItle.substring(0, 30) + "..."
        : bookTItle;

    return InkWell(
      onTap: () {
        // TODO: Bagian routing
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetailsPage(product: product),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    children: [
                      Text(
                        bookTItle,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black), // Black color for the title
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Author: ${bookAuthor}',
                        style: const TextStyle(
                            fontSize: 16, color: Colors.grey), // Black color for the text
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Year: ${bookYear}',
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Publisher: ${bookPublisher}',
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black), 
                      ),
                      Text(
                        'Rating: ${rating.toStringAsFixed(1)}/5.0',
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black), 
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
