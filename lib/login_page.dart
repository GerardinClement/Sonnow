import 'package:flutter/material.dart';
import 'package:sonnow/auth_service.dart';
import 'package:sonnow/profile_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLogin = true; // true = Login, false = Register

  void toggleForm() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isLogin ? 'Login Page' : 'Register Page'),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 100, horizontal: 40),
          child: Column(
            children: [
              isLogin ? LoginForm() : RegisterForm(),
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
  const LoginForm({super.key});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  var _obscureText = true;
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

            bool success = await authService.login(email, password);

            if (context.mounted) {
              if (success) {
                Navigator.pushReplacement(context, MaterialPageRoute(
                    builder: (context) => const ProfilePage())
                );
              } else {
                print("Erreur de connexion");
              }
            }

          },
          child: Text('Login'),
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
              print("Inscription réussie !");
            } else {
              print("Erreur lors de l'inscription");
            }
          },
          child: Text('Register'),
        ),
      ],
    );
  }
}
