import 'package:flutter/material.dart';
import 'package:sonnow/services/auth_service.dart';
import 'package:sonnow/pages/library_page.dart';
import 'package:sonnow/pages/login_page.dart';
import 'package:sonnow/app.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<Map<String, dynamic>?> _fetchUserInfo() async {
    return await AuthService().getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchUserInfo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData) {
          return Center(child: Text("No user data available."));
        } else {
          var userData = snapshot.data;
          return Scaffold(
            appBar: AppBar(title: Text("Profile")),
            body: Column(
              children: [
                Text(
                  'Email: ${userData?['email']}',
                  style: TextStyle(fontSize: 18),
                ),
                ElevatedButton(
                  onPressed: () {
                    AuthService().logout(context, () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => App(),
                        ),
                      );
                    });
                  },
                  child: Text("Logout"),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
