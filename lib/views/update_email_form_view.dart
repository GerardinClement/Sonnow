import 'package:flutter/material.dart';
import 'package:sonnow/services/auth_service.dart';

class UpdateEmailForm extends StatefulWidget {
  final TextEditingController emailController;
  final Function onUpdateSuccess;

  const UpdateEmailForm({
    super.key,
    required this.emailController,
    required this.onUpdateSuccess,
  });

  @override
  UpdateEmailFormState createState() => UpdateEmailFormState();
}

class UpdateEmailFormState extends State<UpdateEmailForm> {
  final AuthService authService = AuthService();
  String? _errorMessage;

  void _onUpdateSuccess(BuildContext context) {
    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email updated successfully!'),
        ),
      );
      widget.onUpdateSuccess();
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: widget.emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your new email address',
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final Map<String, String> credentials = {
                "email": widget.emailController.text,
              };
              await authService.updateUserAccount(
                credentials,
                    () => _onUpdateSuccess(context),
                _onUpdateError,
              );
            },
            child: const Text('Save'),
          ),
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