import 'package:flutter/material.dart';
import 'package:sonnow/models/user.dart';
import 'package:sonnow/services/auth_service.dart';
import 'package:sonnow/views/update_username_form_view.dart';
import 'package:sonnow/views/update_password_form_view.dart';
import 'package:sonnow/views/update_email_form_view.dart';
import 'package:sonnow/views/delete_account_dialog_view.dart';
import 'package:sonnow/app.dart';

class ManageAccountPage extends StatefulWidget {
  final User user;

  const ManageAccountPage({super.key, required this.user});

  @override
  State<ManageAccountPage> createState() => _ManageAccountPageState();
}

class _ManageAccountPageState extends State<ManageAccountPage> {
  final AuthService authService = AuthService();
  late User user;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final bool _obscureText = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    user = widget.user;
    _fetchUserAccount();
  }

  Future<void> _fetchUserAccount() async {
    try {
      final Map<String, dynamic>? res = await authService.getUserAccountInfo();
      if (res != null) user.setAccountInfo(res);
      setState(() {
        _usernameController.text = user.username;
        _emailController.text = user.email;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching user account data: $e")),
      );
    }
  }

  void _updatePassword() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return UpdatePasswordForm();
      },
    );
  }

  void _updateUsername() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return UpdateUsernameForm(
          usernameController: _usernameController,
          onUpdateSuccess: _fetchUserAccount,
        );
      },
    );
  }

  void _updateEmail() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return UpdateEmailForm(
          emailController: _emailController,
          onUpdateSuccess: _fetchUserAccount,
        );
      },
    );
  }

  void _deleteAccount() {
    showDialog(context: context,
        builder: (context) {
          return DeleteAccountDialog(
            onSuccessDelete: () async {
              await authService.logout(context, () {
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const App()),
                      (route) => false,
                );
              });
            },
          );
        });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Username"),
                    ElevatedButton(
                      onPressed: () {},
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(user.username),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: _updateUsername,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16,),
                    Text("Email"),
                    ElevatedButton(
                      onPressed: () {},
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(user.email),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: _updateEmail,
                            ),
                          ],
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _updatePassword,
                      child: Text("Change Password"),
                    ),
                    const SizedBox(height: 20),
                    Spacer(),
                    ElevatedButton(
                        onPressed: () {
                          _deleteAccount();
                        },
                        child: const Text(
                            "Delete Account",
                            style: TextStyle(
                              color: Colors.red,
                            )
                        )
                    )
                  ],
                ),
              ),
    );
  }
}
