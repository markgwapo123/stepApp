import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl = "http://192.168.1.5:8000/api"; // Change this to your API's IP

  // ✅ REGISTER USER
  Future<String> registerUser(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name, "email": email, "password": password}),
      );

      final data = jsonDecode(response.body);
      return response.statusCode == 201 || response.statusCode == 200
          ? data["message"] ?? "User registered successfully!"
          : data["error"] ?? "Registration failed!";
    } catch (e) {
      return "❌ Registration Error: $e";
    }
  }

  // ✅ LOGIN USER
  Future<String?> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['token'] != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", data['token']); // Save token
        return data['token'];
      } else {
        return data["error"] ?? "Login failed!";
      }
    } catch (e) {
      return "❌ Login Error: $e";
    }
  }

  // ✅ LOGOUT USER
  Future<void> logoutUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }

  // ✅ GET STORED TOKEN
  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  // ✅ FETCH EVENTS
  Future<List<dynamic>> fetchEvents() async {
    try {
      String? token = await getToken();
      if (token == null) throw Exception("No token found. Please log in again.");

      final response = await http.get(
        Uri.parse('$baseUrl/events'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> events = jsonDecode(response.body);

        // ✅ Ensure event objects contain user details (Fixes possible null errors)
        for (var event in events) {
          event['user'] ??= {"name": "Unknown", "profile_picture": ""};
        }
        return events;
      } else {
        throw Exception("Failed to fetch events. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      return [];
    }
  }

  // ✅ CREATE EVENT
  Future<String> createEvent({
    required String title,
    required String description,
    required String location,
    required String date,
    required String time,
  }) async {
    try {
      String? token = await getToken();
      if (token == null) return "❌ No token found. Please log in again.";

      final response = await http.post(
        Uri.parse('$baseUrl/events'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'title': title,
          'description': description,
          'location': location,
          'date': date,
          'time': time,
        }),
      );

      final data = jsonDecode(response.body);
      return response.statusCode == 201
          ? data["message"] ?? "Event created successfully!"
          : data["error"] ?? "Failed to create event.";
    } catch (e) {
      return "❌ Create Event Error: $e";
    }
  }

  // ✅ UPDATE EVENT
  Future<String> updateEvent({
    required int eventId,
    required String title,
    required String description,
    required String location,
    required String date,
    required String time,
  }) async {
    try {
      String? token = await getToken();
      if (token == null) return "❌ No token found. Please log in again.";

      final response = await http.put(
        Uri.parse('$baseUrl/events/$eventId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'title': title,
          'description': description,
          'location': location,
          'date': date,
          'time': time,
        }),
      );

      final data = jsonDecode(response.body);
      return response.statusCode == 200
          ? data["message"] ?? "Event updated successfully!"
          : data["error"] ?? "Failed to update event.";
    } catch (e) {
      return "❌ Update Event Error: $e";
    }
  }

  // ✅ DELETE EVENT
  Future<String> deleteEvent(int eventId) async {
    try {
      String? token = await getToken();
      if (token == null) return "❌ No token found. Please log in again.";

      final response = await http.delete(
        Uri.parse('$baseUrl/events/$eventId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      return response.statusCode == 200
          ? "✅ Event deleted successfully!"
          : "❌ Failed to delete event.";
    } catch (e) {
      return "❌ Delete Event Error: $e";
    }
  }

  // ✅ LIKE EVENT
  Future<String> likeEvent(int eventId) async {
    try {
      String? token = await getToken();
      if (token == null) return "❌ No token found. Please log in again.";

      final response = await http.post(
        Uri.parse('$baseUrl/events/$eventId/like'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      return response.statusCode == 200
          ? "❤️ Event liked!"
          : "❌ Failed to like event.";
    } catch (e) {
      return "❌ Like Event Error: $e";
    }
  }

  // ✅ COMMENT ON EVENT
  Future<String> commentOnEvent(int eventId, String comment) async {
    try {
      String? token = await getToken();
      if (token == null) return "❌ No token found. Please log in again.";

      final response = await http.post(
        Uri.parse('$baseUrl/events/$eventId/comment'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'comment': comment}),
      );

      return response.statusCode == 201
          ? "💬 Comment added!"
          : "❌ Failed to add comment.";
    } catch (e) {
      return "❌ Comment Error: $e";
    }
  }
}
