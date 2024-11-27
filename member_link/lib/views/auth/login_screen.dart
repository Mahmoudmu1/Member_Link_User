// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:member_link/myconfig.dart';
import 'package:member_link/views/main_screen.dart';
import 'package:member_link/views/auth/register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  bool rememberme = false;
  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    loadPref();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Welcome Back",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Login to your account",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: emailcontroller,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      hintText: "Email",
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      } else if (!RegExp(
                              r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
                          .hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    obscureText: !_passwordVisible,
                    controller: passwordcontroller,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      hintText: "Password",
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      } else if (value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Checkbox(
                        value: rememberme,
                        onChanged: (bool? value) {
                          setState(() {
                            String email = emailcontroller.text;
                            String pass = passwordcontroller.text;
                            if (value!) {
                              if (_formKey.currentState!.validate()) {
                                storeSharedPrefs(value, email, pass);
                              } else {
                                rememberme = false;
                                return;
                              }
                            } else {
                              email = "";
                              pass = "";
                              storeSharedPrefs(value, email, pass);
                            }
                            rememberme = value;
                            setState(() {});
                          });
                        },
                      ),
                      const Text("Remember me")
                    ],
                  ),
                  const SizedBox(height: 20),
                  MaterialButton(
                    elevation: 10,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        onLogin();
                      }
                    },
                    minWidth: double.infinity,
                    height: 50,
                    color: Colors.black,
                    child: const Text(
                      "Login",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      // Forgot password functionality
                    },
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (content) => const RegisterScreen()));
                    },
                    child: const Text(
                      "Create new account?",
                      style: TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void onLogin() {
    String email = emailcontroller.text;
    String password = passwordcontroller.text;

    http.post(Uri.parse("${MyConfig.servername}/memberlink/api/login_user.php"),
        body: {"email": email, "password": password}).then((response) {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == "success") {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Login Success"),
            backgroundColor: Color.fromARGB(255, 12, 12, 12),
          ));
          Navigator.push(context,
              MaterialPageRoute(builder: (content) => const MainScreen()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Incorrect Email or Password, Login Failed"),
            backgroundColor: Colors.red,
          ));
        }
      }
    });
  }

  Future<void> storeSharedPrefs(bool value, String email, String pass) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value) {
      prefs.setString("email", email);
      prefs.setString("password", pass);
      prefs.setBool("rememberme", value);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Preferences Stored"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ));
    } else {
      prefs.setString("email", email);
      prefs.setString("password", pass);
      prefs.setBool("rememberme", value);
      emailcontroller.text = "";
      passwordcontroller.text = "";
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Preferences Removed"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 1),
      ));
    }
  }

  Future<void> loadPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    emailcontroller.text = prefs.getString("email") ?? "";
    passwordcontroller.text = prefs.getString("password") ?? "";
    rememberme = prefs.getBool("rememberme") ?? false;
    setState(() {});
  }
}
