import 'package:flutter/material.dart';
import 'package:sonnow/services/auth_service.dart';
import 'package:sonnow/app.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AuthService authService = AuthService();

  Future<void> _logout() async {
    await authService.logout(context, () {
      // Naviguer vers la racine et remplacer tout l'arbre de navigation
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const App()),
            (route) => false, // Supprime toutes les routes précédentes
      );
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: ElevatedButton(
            onPressed: _logout, 
            child: Text("Logout")),
      ),
    );
  }
}