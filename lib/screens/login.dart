import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:boox_mobile/screens/register.dart';
import 'package:boox_mobile/models/user.dart';
import 'package:boox_mobile/screens/homepage.dart';

void main() {
    runApp(const LoginApp());
}

class LoginApp extends StatelessWidget {
  const LoginApp({super.key});
  
  @override
  Widget build(BuildContext context) {
      return MaterialApp(
          title: 'Login',
          theme: ThemeData(
              primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
      );
      }
}

class LoginPage extends StatefulWidget {
    const LoginPage({super.key});
    static String uname = "";

    @override
    _LoginPageState createState() => _LoginPageState();
}


class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FlutterLogo(
                  size: 100.0,
                ),
                SizedBox(height: 16.0),
                Text(
                  'Welcome to BOOX',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  keyboardType: TextInputType.name,
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    hintText: 'Enter your username',
                    border: OutlineInputBorder(),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 12.0),
                TextFormField(
                  obscureText: true,
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    border: OutlineInputBorder(),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () async {
                    // TODO: Perform login logic
                    final response = await request.login("https://boox-b09-tk.pbp.cs.ui.ac.id/auth/flutter_login/", {
                      'username': _usernameController.text,
                      'password': _passwordController.text,
                    });

                    if (request.loggedIn && User.username == "") {
                      // Navigate to the home screen
                      User.username = _usernameController.text;
                      String uname = User.username;

                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                            SnackBar(content: Text("Successfully logged in. Welcome, $uname.")));

                      Navigator.pushReplacement(
                        context, 
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                    } else {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                              title: const Text('Failed to Login'),
                              content:
                                  Text(response['message']),
                              actions: [
                                  TextButton(
                                      child: const Text('OK'),
                                      onPressed: () {
                                          Navigator.pop(context);
                                      },
                                  ),
                              ],
                          ),
                      );
                    }
                  },
                  child: Text('Login'),
                ),
                SizedBox(height: 12.0),
                TextButton(
                  onPressed: () {
                    // Navigate to the registration screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterPage()),
                    );
                  },
                  child: Text('Don\'t have an account? Register here'),
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
