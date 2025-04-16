import 'package:flutter/material.dart';
import 'package:sonnow/services/auth_service.dart';

class UpdateUsernameForm extends StatefulWidget {
    final TextEditingController usernameController;
    final Function onUpdateSuccess;

    const UpdateUsernameForm({
      super.key,
      required this.usernameController,
      required this.onUpdateSuccess,
    });

    @override
    _UpdateUsernameFormState createState() => _UpdateUsernameFormState();
  }

  class _UpdateUsernameFormState extends State<UpdateUsernameForm> {
    final AuthService authService = AuthService();
    String? _errorMessage;

    void _onUpdateSuccess(BuildContext context) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Username updated successfully!'),
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
              controller: widget.usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                hintText: 'Enter your new username',
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final Map<String, String> credentials = {
                  "username": widget.usernameController.text,
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