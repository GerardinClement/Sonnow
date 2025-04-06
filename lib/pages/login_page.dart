import 'package:flutter/material.dart';
import 'package:sonnow/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  final Function onLoginSuccess;
  const LoginPage({super.key , required this.onLoginSuccess});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
    final loginPage = context.findAncestorWidgetOfExactType<LoginPage>();

    return Scaffold(
      appBar: AppBar(
        title: Text(isLogin ? 'Login Page' : 'Register Page'),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 100, horizontal: 40),
          child: Column(
            children: [
              isLogin ? LoginForm(onLoginSuccess: onLoginSuccess,) : RegisterForm(),
              SizedBox(height: 20),
              TextButton(
                onPressed: toggleForm,
                child: Text(
                  isLogin ? "Pas encore de compte ? Inscris-toi !" : "Déjà un compte ? Connecte-toi !",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
          onPressed: () async {
            String email = usernameController.text;
            String password = passwordController.text;

            try {
              bool success = await authService.login(email, password);

              if (context.mounted) {
                if (success) {
                  widget.onLoginSuccess();
                } else {
                  setState(() {
                    _errorMessage = "Login failed. Please check your credentials.";
                  });
                }
              }
            } catch (e) {
              if (context.mounted) {
                setState(() {
                  _errorMessage = "An error occurred: ${e.toString()}";
                });
              }
            }

          },
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

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

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
        ElevatedButton(
          onPressed: () async {
            String username = usernameController.text;
            String email = emailController.text;
            String password = passwordController.text;

            bool success = await authService.register(username, email, password);

            if (success) {
              _successMessage = "Registration successful! You can now log in.";
            } else {
              _errorMessage = "An error occurred during registration. Please check your information and try again.";
            }
          },
          child: Text('Register'),
        ),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red),
            ),
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
