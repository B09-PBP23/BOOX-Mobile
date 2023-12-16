import 'package:boox_mobile/screens/comment_section.dart';
import 'package:boox_mobile/screens/homepage.dart';
import 'package:boox_mobile/screens/login.dart';
import 'package:boox_mobile/screens/readers_favorite.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:boox_mobile/models/user.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Drawer(
      backgroundColor: Colors.black,
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.pink,
            ),
            child: Column(
              children: [
                Text(
                  'BOOX',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Padding(padding: EdgeInsets.all(10)),
                Text("Explore the world of books!",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                    )),
              ],
            ),
          ),

          // TODO: Bagian routing
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home', style: TextStyle(color: Colors.white)),
            // Bagian redirection ke MyHomePage
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(),
                  ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_outlined),
            title:
                const Text('My Profle', style: TextStyle(color: Colors.white)),
            onTap: () {
              // TODO:
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_basket),
            title: const Text('Readers Favorite',
                style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReadersFavorite(),
                  ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_basket),
            title: const Text('Comment Section',
                style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CommentSection(),
                  ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.question_mark_outlined),
            title: const Text('Help', style: TextStyle(color: Colors.white)),
            onTap: () {
              // TODO:
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout_outlined),
            title: const Text('Logout', style: TextStyle(color: Colors.white)),
            onTap: () async {
              // TODO:
              final response = await request.logout(
                  "https://boox-b09-tk.pbp.cs.ui.ac.id/auth/flutter_logout/");
              String message = response["message"];
              if (response['status']) {
                User.username = "";
                String uname = response["username"];
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(
                      content: Text(
                          "Successfully logged out. See you soon, $uname.")));

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("$message"),
                ));
              }
            },
          ),
        ],
      ),
    );
  }
}
