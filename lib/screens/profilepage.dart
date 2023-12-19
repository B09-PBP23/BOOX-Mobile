import 'package:boox_mobile/screens/comment_section.dart';
import 'package:boox_mobile/screens/createprofilepage.dart';
import 'package:boox_mobile/screens/readers_favorite.dart';
import 'package:flutter/material.dart';
import 'package:boox_mobile/widgets/left_drawer.dart';
import 'package:boox_mobile/screens/login.dart';
import 'package:boox_mobile/screens/homepage.dart';
import 'package:boox_mobile/screens/editprofilepage.dart';
import 'package:boox_mobile/widgets/bottom_nav.dart';
import 'package:boox_mobile/models/profile.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:boox_mobile/models/user.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late List<Product> displayedProducts = []; // Using Product as a placeholder
  int _selectedIndex = 1; // Index for the selected tab

  @override
  void initState() {
    super.initState();

    // Fetch user profile data initially
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    var url = Uri.parse("https://boox-b09-tk.pbp.cs.ui.ac.id/profile/json/${User.id}/");
    var response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(utf8.decode(response.bodyBytes));
      print('Response body: ${response.body}');

      List<Product> userProfiles = []; // Change Product to your model class
      for (var userData in data) {
        if (userData != null) {
          Product userProfile = Product.fromJson(userData); // Use your model's fromJson method
          userProfiles.add(userProfile);
        }
      }

      setState(() {
        displayedProducts = userProfiles;
      });
    } else {
      // Handle error when fetching data
      print('Failed to fetch user profile data');
    }
  }

  void onBottomNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfilePage(),
          ),
        );
        break;
      case 2:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ReadersFavorite(),
            ),
          );
        break;
      case 3:
        Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => CommentSection(),
              ),
            );
        break;
      case 4:
        _handleLogout();
        break;
      // Add cases for additional screens if needed
      }
    }

  Future<void> _handleLogout() async {
    final request = context.read<CookieRequest>();
    final response = await request.logout("https://boox-b09-tk.pbp.cs.ui.ac.id/auth/flutter_logout/");
    String message = response["message"];

    if (response['status']) {
      User.username = "";
      String uname = response["username"];
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text("Successfully logged out. See you soon, $uname.")),
        );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$message"),
        ),
      );
    }
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
      // drawer: const LeftDrawer(), // drawer
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: onBottomNavTapped,
      ),
      backgroundColor: Colors.black87,
      body: FutureBuilder(
        future: Future.value(displayedProducts),
        builder: (context, AsyncSnapshot<List<Product>> snapshot) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
            const SizedBox(height: 16),
            displayedProducts.isNotEmpty
                ? Column(
                    children: displayedProducts
                        .map((profile) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                              child: Card(
                                color: Colors.black87,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(color: Colors.white, width: 1),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Image.asset(
                                            'images/defaultprofile.jpg',
                                            width: 200.0,
                                            height: 200.0,
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 16),
                                      ListTile(
                                        title: Text(
                                          '${profile.fields.name}',
                                          style: TextStyle(
                                            fontSize: 22,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        subtitle: Text(
                                          '@${User.username}',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Divider(color: Colors.white),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          _buildProfileStat('Description', '${profile.fields.description}'),
                                          _buildProfileStat('Favorite Books', '${profile.fields.favoriteBooks}'),
                                          _buildProfileStat('Favorite Author', '${profile.fields.favoriteAuthor}'),
                                          _buildProfileStat('Joined Since', '${DateFormat('yyyy-MM-dd').format(profile.fields.dateJoined)}'),
                                        ],
                                      ),
                                      SizedBox(height: 16),
                                      // Add an "Edit Profile" button
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => UserProfileForm(),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          'Edit Profile',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          primary: Colors.white,
                                          padding: EdgeInsets.symmetric(vertical: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  )
                : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'No user profile data available.',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          // Redirect to a different page (e.g., Homepage) when no profile data available
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => NewUserProfileForm()),
                          );
                        },
                        child: Text('Create Profile'),
                      ),
                    ],
                  ),
                ),
            ],
            ),
          );
      },
    ),
  );
}

  Widget _buildProfileStat(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
        Divider(color: Colors.white),
      ],
    );
  }
}