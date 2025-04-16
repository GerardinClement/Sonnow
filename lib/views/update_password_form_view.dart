import 'package:flutter/material.dart';
import 'package:sonnow/services/auth_service.dart';

class UpdatePasswordForm extends StatefulWidget {
  const UpdatePasswordForm({super.key});

  @override
  _UpdatePasswordFormState createState() => _UpdatePasswordFormState();
}

class _UpdatePasswordFormState extends State<UpdatePasswordForm> {
  var _obscureText = true;
  String? _errorMessage;
  String? _passwordMatchError;
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    newPasswordController.addListener(_validatePasswords);
    confirmPasswordController.addListener(_validatePasswords);
  }

  void _validatePasswords() {
    if (newPasswordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty &&
        newPasswordController.text != confirmPasswordController.text) {
      setState(() {
        _passwordMatchError = "Passwords do not match.";
      });
    } else {
      setState(() {
        _passwordMatchError = null;
      });
    }
  }

  void _onUpdateError(dynamic error) {
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
    });
  }

  void _onUpdateSuccess(BuildContext context) {
    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully!')),
      );
    }
  }

  Future<void> updatePassword() async {
    if (newPasswordController.text != confirmPasswordController.text) {
      setState(() {
        _errorMessage = "Passwords do not match.";
      });
      return;
    }

    Map<String, String> credentials = {
      "old_password": oldPasswordController.text,
      "new_password": newPasswordController.text,
    };

    await authService.updateUserAccount(
      credentials,
      () => _onUpdateSuccess(context),
      _onUpdateError,
    );
  }

  @override
  void dispose() {
    newPasswordController.removeListener(_validatePasswords);
    confirmPasswordController.removeListener(_validatePasswords);
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: oldPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Current Password',
              hintText: 'Enter your current password',
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: newPasswordController,
            obscureText: _obscureText,
            decoration: InputDecoration(
              labelText: 'New Password',
              hintText: 'Enter your new password',
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
          const SizedBox(height: 10),
          TextField(
            controller: confirmPasswordController,
            obscureText: _obscureText,
            decoration: InputDecoration(
              labelText: 'Confirm New Password',
              hintText: 'Enter your new password again',
              errorText: _passwordMatchError,
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
          const SizedBox(height: 20),
          ElevatedButton(onPressed: updatePassword, child: const Text('Save')),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }
}
