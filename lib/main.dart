import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sonnow/services/auth_service.dart';
import 'package:sonnow/views/welcome_page.dart';
import 'package:sonnow/views/profile_page.dart'; // Import de la page de profil
import 'package:sonnow/views/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget _homePage = Center(child: CircularProgressIndicator());

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLogin = await AuthService().checkIfLoggedIn();

    setState(() {
      _homePage = isLogin ? HomePage() : WelcomePage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
        appBar: AppBar(title: Text('Flutter Demo')),
        body: _homePage,
      ),
    );
  }
}
