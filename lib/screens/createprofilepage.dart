import 'dart:convert';
import 'package:boox_mobile/models/books.dart';
import 'package:boox_mobile/models/user.dart';
import 'package:boox_mobile/screens/profilepage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class NewUserProfileForm extends StatefulWidget {
  const NewUserProfileForm({Key? key}) : super(key: key);

  @override
  _NewUserProfileFormState createState() => _NewUserProfileFormState();
}

class _NewUserProfileFormState extends State<NewUserProfileForm> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _nameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  String? _selectedFavoriteBook;
  String? _selectedFavoriteAuthor;

  List<Product> allProducts = [];
  List<Product> displayedProducts = [];

  List<String> favoriteBooks = [];
  List<String> favoriteAuthors = [];

  @override
  void initState() {
    super.initState();
    fetchData(); // Call the function to fetch data
  }

  Future<void> fetchData() async {
    try {
      List<Product> products = await fetchItems();
      favoriteBooks = products.map((product) => product.fields.title).toList();
      favoriteAuthors = products.map((product) => product.fields.author).toList();

      setState(() {
        allProducts = products;
        displayedProducts = allProducts;
        // Use the lists of favorite books and authors as needed
      });
    } catch (e) {
      print("Error fetching data: $e");
      // Handle error
    }
  }

  Future<List<Product>> fetchItems() async {
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

    return products;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
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
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: Colors.black87,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: Colors.white),
                hintStyle: TextStyle(color: Colors.white),
              ),
              style: TextStyle(color: Colors.white),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: Colors.white),
                  hintStyle: TextStyle(color: Colors.white),
                ),
                style: TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
              value: _selectedFavoriteBook,
              isExpanded: false,
              isDense: true,
              dropdownColor: Colors.black,
              items: favoriteBooks.map((book) {
                return DropdownMenuItem<String>(
                  value: book,
                  child: SizedBox(
                    width: 200,
                    child: Text(
                      book,
                      style: TextStyle(
                        color: Colors.white, 
                      ),
                    ),
                  ),
                );
              }).toList(),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintStyle: TextStyle(color: Colors.white),
                hintText: 'Select Favorite Books',
              ),
              onChanged: (value) {
                setState(() {
                  _selectedFavoriteBook = value as String?;
                });
              },
            ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
              value: _selectedFavoriteAuthor,
              isExpanded: false,
              isDense: true,
              dropdownColor: Colors.black,
              items: favoriteAuthors.map((author) {
                return DropdownMenuItem<String>(
                  value: author,
                  child: SizedBox(
                    width: 200,
                    child: Text(
                      author,
                      style: TextStyle(
                        color: Colors.white, 
                      ),
                    ),
                  ),
                );
              }).toList(),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintStyle: TextStyle(color: Colors.white),
                hintText: 'Select Favorite Author',
              ),
              onChanged: (value) {
                setState(() {
                  _selectedFavoriteAuthor = value as String?;
                });
              },
            ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final response = await request.postJson(
                      "https://boox-b09-tk.pbp.cs.ui.ac.id/profile/create-flutter/${User.username}/",
                      jsonEncode(<String, String>{
                        'name': _nameController.text,
                        'description': _descriptionController.text,
                        'favoriteBooks': _selectedFavoriteBook ?? '',
                        'favoriteAuthor': _selectedFavoriteAuthor ?? '',
                      }),
                    );
                    if (response['status'] == 'success') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Profile updated successfully!"),
                        ),
                      );
                      Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const UserProfilePage()),
                    );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("There was an error, please try again."),
                        ),
                      );
                    }
                  }
                },
                child: Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
