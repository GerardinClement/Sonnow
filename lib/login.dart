import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = "http://10.0.2.2:8000/";

  Future<String> getCsrfToken() async {
    final response = await http.get(Uri.parse("${baseUrl}user/csrf/"));

    if (response.statusCode == 200) {
      final cookieHeader = response.headers['set-cookie'];
      final csrfTokenMatch = RegExp(r'csrftoken=([^;]+)').firstMatch(cookieHeader!);
      return csrfTokenMatch?.group(1) ?? '';
    } else {
      throw Exception("Impossible d'obtenir le token CSRF");
    }
  }


  Future<bool> register(String username, String email, String password) async {
    final url = "${baseUrl}user/register/";
    final csrfToken = await getCsrfToken();

    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "X-CSRFToken": csrfToken,
        "Referer": baseUrl,
        "Cookie": "csrftoken=$csrfToken",
      },
      body: jsonEncode({"username": username, "email": email, "password": password}),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final token = data['access'];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      return true;
    } else {
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    final url = "${baseUrl}user/login/";
    final csrfToken = await getCsrfToken();

    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "X-CSRFToken": csrfToken,
        "Referer": baseUrl,
        "Cookie": "csrftoken=$csrfToken",
      },
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['access'];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      return true;
    } else {
      return false;
    }
  }
}
