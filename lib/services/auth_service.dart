import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sonnow/services/user_library_service.dart';

import 'package:sonnow/pages/login_page.dart';

class AuthService {
  static const String baseUrl = "http://10.0.2.2:8000/";

  Future<String> getCsrfToken() async {
    final response = await http.get(Uri.parse("${baseUrl}user/csrf/"));

    if (response.statusCode == 200) {
      final cookieHeader = response.headers['set-cookie'];
      final csrfTokenMatch = RegExp(r'csrftoken=([^;]+)').firstMatch(cookieHeader!);
      return csrfTokenMatch?.group(1) ?? '';
    } else {
      throw Exception("Error getting CSRF token");
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

    return response.statusCode == 201;
  }

  Future<bool> login(String username, String password) async {
    final url = "${baseUrl}user/token/";
    final csrfToken = await getCsrfToken();

    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "X-CSRFToken": csrfToken,
        "Referer": baseUrl,
        "Cookie": "csrftoken=$csrfToken",
      },
      body: jsonEncode({"username": username, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      await saveAuthToken(data);
      return true;
    } else {
      return false;
    }
  }

  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove("access_token");
    await prefs.remove("refresh_token");

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
          (Route<dynamic> route) => false,
    );
  }

  Future saveAuthToken(data) async {
    final accessToken = data['access'];
    final refreshToken = data['refresh'];

    await saveToken("access_token", accessToken);
    await saveToken("refresh_token", refreshToken);
  }

  Future<bool> isTokenValid(String key) async {
    final token = await getToken(key);

    if (token == null) return false;

    final response = await http.post(
      Uri.parse("${baseUrl}user/token/verify/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"token": token}),
    );

    return response.statusCode == 200;
  }

  Future refreshAccessToken() async {
    final refreshToken = await getToken("refresh_token");
    final response = await http.post(
      Uri.parse('${baseUrl}user/token/refresh/'),
      body: jsonEncode({'refresh': refreshToken}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) return;

    final data = jsonDecode(response.body);
    saveAuthToken(data);
  }

  Future<void> saveToken(String key, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, token);
  }

  Future<String?> getToken(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<bool> checkIfLoggedIn() async {
    if (await isTokenValid("access_token")) {
      return true;
    }
    if (await isTokenValid("refresh_token")) {
      await refreshAccessToken();
      return true;
    }
    return false;
  }



  Future<Map<String, dynamic>?> getUserInfo() async {
    if (!await checkIfLoggedIn()) return null;

    final csrfToken = await getCsrfToken();
    final token = await getToken("access_token");

    if (token == null) return null; // TODO: Handle this case

    final response = await http.get(
      Uri.parse("${baseUrl}user/info/"),
      headers: {
        "Authorization": "Bearer $token",
        "X-CSRFToken": csrfToken,
        "Referer": baseUrl,
        "Cookie": "csrftoken=$csrfToken",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }

}
