import 'package:flutter/material.dart';
import 'package:sonnow/services/auth_service.dart';

class RegisterForm extends StatefulWidget {
  final Function onRegisterSuccess;
  const RegisterForm({
    super.key,
    required this.onRegisterSuccess,
  });

  @override
  _RegisterFormState createState() => _RegisterFormState();
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
      _errorMessage =
          "An error occurred during registration. Please check your information and try again.";
      _successMessage = null;
    });
  }

  Future<void> register() async{
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
    return Column(
      children: [
        TextField(
          controller: usernameController,
          decoration: InputDecoration(
            labelText: 'Username',
            hintText: 'Choose a username',
          ),
        ),
        TextField(
          controller: emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'Enter your email',
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
        ElevatedButton(onPressed: register, child: Text('Register')),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(_errorMessage!, style: TextStyle(color: Colors.red)),
          ),
        if (_successMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _successMessage!,
              style: TextStyle(color: Colors.green),
            ),
          ),
      ],
    );
  }
}
