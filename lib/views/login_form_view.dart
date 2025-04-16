import 'package:flutter/material.dart';
import 'package:sonnow/services/auth_service.dart';


class LoginForm extends StatefulWidget {
  final Function onLoginSuccess;
  const LoginForm({super.key, required this.onLoginSuccess});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  var _obscureText = true;
  String? _errorMessage;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService authService = AuthService();

  Future<void> login() async {
    String email = usernameController.text;
    String password = passwordController.text;

    authService.login(email, password).then((success) {
      if (success) {
        widget.onLoginSuccess();
      } else {
        setState(() {
          _errorMessage = "Login failed. Please check your credentials.";
        });
      }
    }).catchError((error) {
      setState(() {
        _errorMessage = "An error occurred: ${error.toString()}";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: usernameController,
          decoration: InputDecoration(
            labelText: 'Username',
            hintText: 'Enter your username',
          ),
        ),
        TextField(
          controller: passwordController,
          obscureText: _obscureText,
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'Enter your password',
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
              icon: Icon(Icons.visibility, color: Colors.black),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: login,
          child: Text('Login'),
        ),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }
}