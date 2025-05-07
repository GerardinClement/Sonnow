// Dans register_form_view.dart
import 'package:flutter/material.dart';
import 'package:sonnow/services/auth_service.dart';

class RegisterForm extends StatefulWidget {
  final Function onRegisterSuccess;

  const RegisterForm({super.key, required this.onRegisterSuccess});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  var _obscureText = true;
  String? _errorMessage;
  String? _successMessage;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final AuthService authService = AuthService();

  dynamic onRegisterError(dynamic error) {
    setState(() {
      if (error is List) {
        _errorMessage = error.map((e) => e.toString()).join('\n');
      } else if (error.toString().startsWith('[') &&
          error.toString().endsWith(']')) {
        String content = error.toString().substring(
          1,
          error.toString().length - 1,
        );
        _errorMessage = content.split(',').map((e) => e.trim()).join('\n');
      } else {
        _errorMessage = error.toString();
      }
      _successMessage = null;
    });
  }

  Future<void> register() async {
    Map<String, String> credentials = {
      "username": usernameController.text,
      "email": emailController.text,
      "password": passwordController.text,
    };

    await authService.register(
      credentials,
      widget.onRegisterSuccess,
      onRegisterError,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                hintText: 'Choose a username',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
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
            const SizedBox(height: 24.0),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            if (_successMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _successMessage!,
                  style: const TextStyle(color: Colors.green),
                ),
              ),
            const SizedBox(height: 24.0),
            SizedBox(
              width: double.infinity,
              height: 48.0,
              child: ElevatedButton(
                onPressed: register,
                child: const Text('Register'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}