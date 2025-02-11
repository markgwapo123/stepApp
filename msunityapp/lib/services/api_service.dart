import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl = "http://192.168.1.13:8000/api"; // Change to your API's IP

  // ✅ REGISTER USER
  Future<String> registerUser(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name, "email": email, "password": password}),
      );

      print("🔹 Register Response: ${response.statusCode} - ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return data["message"] ?? "User registered successfully!";
      } else {
        return data["error"] ?? "Registration failed!";
      }
    } catch (e) {
      print("❌ Registration Error: $e");
      return "Something went wrong. Please try again!";
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

      print("🔹 Login Response: ${response.statusCode} - ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", data['token']); // Save token
        return data['token'];
      } else {
        return data["error"] ?? "Login failed!";
      }
    } catch (e) {
      print("❌ Login Error: $e");
      return "Something went wrong. Please try again!";
    }
  }

  // ✅ LOGOUT USER (Clears token)
  Future<void> logoutUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("token"); // Remove stored token
    print("🔹 User logged out.");
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

      print("🔹 Fetch Events Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("❌ Failed to fetch events: ${response.body}");
        return [];
      }
    } catch (e) {
      print("❌ Fetch Events Error: $e");
      return [];
    }
  }

  // ✅ CREATE EVENT (WITH TOKEN)
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

      print("🔹 Create Event Response: ${response.statusCode} - ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return data["message"] ?? "Event created successfully!";
      } else {
        return data["error"] ?? "Failed to create event.";
      }
    } catch (e) {
      print("❌ Create Event Error: $e");
      return "Something went wrong. Please try again!";
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

      print("🔹 Delete Event Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200) {
        return "✅ Event deleted successfully!";
      } else {
        return "❌ Failed to delete event.";
      }
    } catch (e) {
      print("❌ Delete Event Error: $e");
      return "Something went wrong. Please try again!";
    }
  }
}
