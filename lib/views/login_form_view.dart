import 'package:flutter/material.dart';
import 'package:sonnow/services/auth_service.dart';
import 'package:sonnow/views/register_form_view.dart';

class LoginForm extends StatefulWidget {
  final Function onLoginSuccess;

  const LoginForm({super.key, required this.onLoginSuccess});

  @override
  State<LoginForm> createState() => _LoginFormState();
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

    authService
        .login(email, password)
        .then((success) {
          if (success) {
            widget.onLoginSuccess();
          } else {
            setState(() {
              _errorMessage = "Login failed. Please check your credentials.";
            });
          }
        })
        .catchError((error) {
          setState(() {
            _errorMessage = "An error occurred: ${error.toString()}";
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                hintText: 'Enter your username',
              ),
            ),
            const SizedBox(height: 16.0),
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
                  icon: const Icon(Icons.visibility, color: Colors.black),
                ),
              ),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            Spacer(),
            Text(
              "Don't have an account?",
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (context) => RegisterForm(
                          onRegisterSuccess: widget.onLoginSuccess,
                        ),
                  ),
                );
              },
              child: const Text(
                "Create an account",
                style: TextStyle(color: Colors.black),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 48.0,
              child: ElevatedButton(
                onPressed: login,
                child: const Text('Login'),
              ),
            ),
            const SizedBox(height: 20.0), // Espace sous le bouton
          ],
        ),
      ),
    );
  }
}
