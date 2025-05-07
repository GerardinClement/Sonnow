import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sonnow/globals.dart';

class SonnowService {
  static const String releaseEndpoint = "release";

  static Future<int> getReleaseNumberOfLikes(String releaseId) async {
    final response = await http.get(Uri.parse('$baseUrl/$releaseEndpoint/$releaseId/likes/'));

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData['number_of_likes'];
    } else if (response.statusCode == 404) {
      return 0;
    } else {
      throw Exception("Error getting number of likes for release $releaseId");
    }
  }

}