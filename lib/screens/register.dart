import 'package:flutter/material.dart';
import 'package:boox_mobile/screens/login.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'dart:convert' as convert;

void main() {
    runApp(const RegisterApp());
}

class RegisterApp extends StatelessWidget {
const RegisterApp({super.key});

@override
Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Register Account',
        theme: ThemeData(
            primarySwatch: Colors.blue,
    ),
    home: const RegisterPage(),
    );
    }
}

class RegisterPage extends StatefulWidget {
    const RegisterPage({super.key});

    @override
    _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmationController = TextEditingController();

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
                  'Create new Account',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 16.0),
                TextFormField(
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
                SizedBox(height: 12.0),
                TextFormField(
                  obscureText: true,
                  controller: _passwordConfirmationController,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    hintText: 'Re-enter your password',
                    border: OutlineInputBorder(),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () async {
                    // TODO: Perform registration logic
                    // TODO: Ubah link nanti
                    final response = await request.postJson(
                      'https://boox-b09-tk.pbp.cs.ui.ac.id/auth/flutter_register/',
                      convert.jsonEncode(<String, String> {
                        'username': _usernameController.text,
                        'password1': _passwordController.text,
                        'password2': _passwordConfirmationController.text,
                      }),
                    );

                    if (response["status"] == "success") {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(
                        content: Text(
                            "Account has been successfully registered!"),
                      ));

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${response["message"]}')),
                      );
                    }
                  },
                  child: Text('Register'),
                ),
                SizedBox(height: 12.0),
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to the login screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: Text('Already have an account? Login here'),
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
