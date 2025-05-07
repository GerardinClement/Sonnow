// Dans auth_page.dart
import 'package:flutter/material.dart';
import 'package:sonnow/views/register_form_view.dart';
import 'package:sonnow/views/login_form_view.dart';

class AuthPage extends StatefulWidget {
  final Function onLoginSuccess;

  const AuthPage({super.key, required this.onLoginSuccess});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;

  void toggleForm() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  void onLoginSuccess() {
    widget.onLoginSuccess();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isLogin ? 'Login' : 'Register'),
        actions: [
          TextButton(
            onPressed: toggleForm,
            child: Text(isLogin ? 'Register' : 'Login'),
          ),
        ],
      ),
      body: SafeArea(
        child: isLogin
            ? LoginForm(onLoginSuccess: onLoginSuccess)
            : RegisterForm(onRegisterSuccess: onLoginSuccess),
      ),
    );
  }
}