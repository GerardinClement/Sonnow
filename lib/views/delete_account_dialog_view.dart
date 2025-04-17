import 'package:flutter/material.dart';
import 'package:sonnow/services/auth_service.dart';

class DeleteAccountDialog extends StatefulWidget {
  final Function onSuccessDelete;

  const DeleteAccountDialog({super.key, required this.onSuccessDelete});

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  final AuthService authService = AuthService();
  String? _errorMessage;
  final TextEditingController _passwordController = TextEditingController();

  void _onSuccess(BuildContext context) {
    showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: const Text("Account Deleted"),
        content: const Text("Your account has been successfully deleted."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onSuccessDelete();
            },
            child: const Text("OK"),
          ),
        ],
      );
    });
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

  void deleteAccount() async {
    authService.deleteUserAccount(
      _passwordController.text,
      () => _onSuccess(context),
      _onUpdateError,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Delete Account"),
      content: const Text(
        "For security reasons, please enter your password to confirm the deletion of your account.",
      ),
      actions: [
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: "Password",
            errorText: _errorMessage,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: deleteAccount,
          child: const Text("Delete"),
        ),
      ],
    );
  }
}
