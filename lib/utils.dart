import 'package:sonnow/services/auth_service.dart';

final AuthService authService = AuthService();

Future<Map<String, String>> setRequestHeader() async {
  if (!await authService.checkIfLoggedIn()) throw Exception("User not logged in");

  final csrfToken = await authService.getCsrfToken();
  final token = await authService.getToken("access_token");

  if (token == null) throw Exception("Error with access token");

  return {
    "Content-Type": "application/json",
    "X-CSRFToken": csrfToken,
    "Authorization": "Bearer $token",
    "Cookie": "csrftoken=$csrfToken",
  };
}