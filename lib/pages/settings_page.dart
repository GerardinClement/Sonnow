import 'package:flutter/material.dart';
import 'package:sonnow/services/auth_service.dart';
import 'package:sonnow/models/user.dart';
import 'package:sonnow/pages/manage_account_page.dart';
import 'package:sonnow/app.dart';

class SettingsPage extends StatefulWidget {
  final User user;
  const SettingsPage({
    super.key,
    required this.user,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AuthService authService = AuthService();

  Future<void> _logout() async {
    try {
      await authService.logout();

      if (!mounted) return;

      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const App()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la déconnexion: $e")),
      );
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Settings')),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ManageAccountPage(user: widget.user),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              child: const Text("Edit account"),
            ),
          ),
          const SizedBox(height: 16), // Espace entre les boutons
          ElevatedButton(
            onPressed: _logout,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              child: const Text("Logout"),
            ),
          ),
        ],
      ),
    ),
  );
}
}
