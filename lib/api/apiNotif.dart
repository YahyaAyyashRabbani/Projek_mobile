import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationApi {
  static const String baseUrl = 'https://be-995193249744.us-central1.run.app/'; // Isi nanti sesuai endpoint backend kamu

  static Future<List<Map<String, dynamic>>> fetchNotifications() async {
    final url = Uri.parse('$baseUrl/notif');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  static Future<bool> createNotification(Map<String, dynamic> notifData) async {
    final url = Uri.parse('$baseUrl/add-notif');
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(notifData));

    return response.statusCode == 201;
  }

  static Future<bool> updateNotification(String id, Map<String, dynamic> notifData) async {
    final url = Uri.parse('$baseUrl/notif/$id');
    final response = await http.put(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(notifData));

    return response.statusCode == 200;
  }

  static Future<bool> deleteNotification(String id) async {
    final url = Uri.parse('$baseUrl/notif/$id');
    final response = await http.delete(url);

    return response.statusCode == 200;
  }
}
