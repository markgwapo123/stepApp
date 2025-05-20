import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mime/mime.dart';
import 'package:image_picker/image_picker.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String baseUrl = "http://192.168.1.6:8000/api";

  // Register User
  Future<String> registerUser (String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name, "email": email, "password": password}),
      );

      final data = jsonDecode(response.body);
      debugPrint("🔹 Register Response: ${response.body}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        return data["message"] ?? "User  registered successfully!";
      } else {
        return data["error"] ?? "Registration failed!";
      }
    } catch (e) {
      debugPrint("❌ Registration Error: $e");
      return "❌ Registration Error: $e";
    }
  }



 Future<String?> loginUser(String email, String password, ApiService apiService) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    debugPrint("🔹 Login Response: ${response.body}");

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['token'] != null) {
      // ✅ Set the token in the ApiService instance
      apiService.setToken(data['token']);

      // ✅ Store in SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", data['token']);
      await prefs.setBool("isAdmin", data['user']?['is_admin'] == 1);

      return data['token'];
    } else {
      debugPrint("❌ Login failed: ${data['message']}");
      return null;
    }
  } catch (e) {
    debugPrint("❌ Login Error: $e");
    return null;
  }
}



  // Logout
  Future<void> logoutUser () async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    await prefs.remove("isAdmin");
  }

 Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('isAdmin');

    // Optional: If you want to also notify the backend:
    // await http.post(Uri.parse('$baseUrl/logout'), headers: {
    //   'Authorization': 'Bearer ${prefs.getString('token')}',
    // });

    return;
  }

  // Token
  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  // Fetch User Info
  Future<Map<String, dynamic>> getUserInfo() async {
    try {
      final token = await getToken();
      if (token == null) throw Exception("No token found");

      final response = await http.get(
        Uri.parse('$baseUrl/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to fetch user data");
      }
    } catch (e) {
      debugPrint("❌ Fetch User Info Error: $e");
      throw e; // Rethrow the error for handling in the calling function
    }
  }

  // Admin Check
  Future<bool> isAdmin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool("isAdmin") ?? false;
  }

  // Pick Image
  Future<File?> pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      return pickedFile != null ? File(pickedFile.path) : null;
    } catch (e) {
      debugPrint("❌ Pick Image Error: $e");
      return null;
    }
  }




  // Fetch Events
  Future<List<dynamic>> fetchEvents() async {
    try {
      final token = await getToken();
      if (token == null) throw Exception("No token found");

      final response = await http.get(
        Uri.parse('$baseUrl/events'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      debugPrint("🔹 Fetch Events Response: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception("Failed to fetch events");
      }
    } catch (e) {
      debugPrint("❌ Fetch Events Error: $e");
      return [];
    }
  }

  // Create Event
  Future<String> createEvent({
    required String title,
    required String description,
    required String location,
    required String date,
    required String time,
    File? image,
    String? imageBase64,
  }) async {
      debugPrint("🔹 createEvent called: $title at $date $time"); // add this
    try {
      final token = await getToken();
      if (token == null) return "❌ No token found";

      final uri = Uri.parse('$baseUrl/events');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['title'] = title
        ..fields['description'] = description
        ..fields['location'] = location
        ..fields['date'] = date
        ..fields['time'] = time;

      if (image != null && await image.exists()) {
        final mimeType = lookupMimeType(image.path) ?? 'image/jpeg';
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          image.path,
          contentType: MediaType.parse(mimeType),
        ));
      } else if (imageBase64 != null) {
        final cleaned = imageBase64.replaceAll(RegExp(r'data:image/[^;]+;base64,'), '');
        final bytes = base64Decode(cleaned);
        request.files.add(http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: 'event_image.jpg',
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final data = jsonDecode(responseBody);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return data["message"] ?? "✅ Event created successfully!";
      } else {
        return "❌ Failed to create event. ${data['message'] ?? responseBody}";
      }
    } catch (e) {
      debugPrint("❌ Create Event Error: $e");
      return "❌ Create Event Error: $e";
    }
  }

  // Update Event
  Future<String> updateEvent({
  required int eventId,
  required String title,
  required String description,
  required String location,
  required String date,
  required String time,
  File? image,
}) async {
  try {
    final token = await getToken(); // Replace with your method to get token
    if (token == null) return "❌ No token found";

    final uri = Uri.parse('$baseUrl/events/$eventId');

    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['_method'] = 'PUT'
      ..fields['title'] = title
      ..fields['description'] = description
      ..fields['location'] = location
      ..fields['date'] = date
      ..fields['time'] = time;

    if (image != null && await image.exists()) {
      final mimeType = lookupMimeType(image.path) ?? 'image/jpeg';
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        image.path,
        contentType: MediaType.parse(mimeType),
      ));
    }

    final streamedResponse = await request.send();
    final responseBody = await streamedResponse.stream.bytesToString();
    final data = jsonDecode(responseBody);

    if (streamedResponse.statusCode == 200) {
      return data["message"] ?? "✅ Event updated successfully!";
    } else {
      return "❌ Failed to update event. ${data['message'] ?? responseBody}";
    }
  } catch (e) {
    debugPrint("❌ Update Event Error: $e");
    return "❌ Update Event Error: $e";
  }
}
  // Delete Event
  Future<String> deleteEvent(int eventId) async {
    try {
      final token = await getToken();
      if (token == null) return "❌ No token found";

      final response = await http.delete(
        Uri.parse('$baseUrl/events/$eventId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return "✅ Event deleted successfully!";
      } else {
        return "❌ Failed to delete event. ${data['message'] ?? 'Unknown error'}";
      }
    } catch (e) {
      debugPrint("❌ Delete Event Error: $e");
      return "❌ Delete Event Error: $e";
    }
  }



  // Admin: Fetch All Users
  Future<List<dynamic>> fetchAllUsers() async {
    try {
      final token = await getToken();
      if (token == null) throw Exception("No token found");

      final response = await http.get(
        Uri.parse('$baseUrl/admin/users'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception("Failed to fetch users");
      }
    } catch (e) {
      debugPrint("❌ Fetch Users Error: $e");
      return [];
    }
  }

  // Admin: Update User
  Future<String> updateUser(int userId, String name, String email) async {
    try {
      final token = await getToken();
      if (token == null) return "❌ No token found";

      final response = await http.put(
        Uri.parse('$baseUrl/admin/users/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "name": name,
          "email": email,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['message'] ?? "✅ User updated successfully!";
      } else {
        return "❌ Failed to update user: ${data['message'] ?? 'Unknown error'}";
      }
    } catch (e) {
      debugPrint("❌ Update User Error: $e");
      return "❌ Update User Error: $e";
    }
  }

  // Admin: Delete User
  Future<bool> deleteUser(int userId) async {
  try {
    final token = await getToken();
    if (token == null) return false;

    final response = await http.delete(
      Uri.parse('$baseUrl/admin/users/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    debugPrint("❌ Delete User Error: $e");
    return false;
  }
}



  String token = '';

  // Call this after login or load from storage
  void setToken(String newToken) {
    token = newToken;
  }

Map<String, String> _headers() {
  return {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token', // ✅ Token must be set correctly
  };
}


 
  // Get events by user
  Future<List<dynamic>> getEventsByUser(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/events/by-user/$userId'),
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to load events: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load events');
    }
  }



}