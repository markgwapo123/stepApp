import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mime/mime.dart';
import 'package:image_picker/image_picker.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal(); // Singleton Pattern
  factory ApiService() => _instance;
  ApiService._internal();

  final String baseUrl = "http://192.168.1.11:8000/api"; // Change to your API URL

  // ✅ REGISTER USER
  Future<String> registerUser(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name, "email": email, "password": password}),
      );

      final data = jsonDecode(response.body);
      debugPrint("🔹 Register Response: ${response.body}");

      return (response.statusCode == 201 || response.statusCode == 200)
          ? data["message"] ?? "User registered successfully!"
          : data["error"] ?? "Registration failed!";
    } catch (e) {
      debugPrint("❌ Registration Error: $e");
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
      debugPrint("🔹 Login Response: ${response.body}");

      if (response.statusCode == 200 && data['token'] != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", data['token']);
        return data['token'];
      } else {
        return data["error"] ?? "Login failed!";
      }
    } catch (e) {
      debugPrint("❌ Login Error: $e");
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
        headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
      );

      debugPrint("🔹 Fetch Events Response: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to fetch events. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Fetch Events Error: $e");
      return [];
    }
  }


  // ✅ Get Token


  // ✅ Pick Image from Gallery
 Future<File?> pickImage() async {
  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
  return pickedFile != null ? File(pickedFile.path) : null;
}

  // ✅ Create Event (with Image Upload)

Future<String> createEvent({
  required String title,
  required String description,
  required String location,
  required String date,
  required String time,
  File? image,
  String? imageBase64,
}) async {
  try {
    String? token = await getToken();
    if (token == null) return "❌ No token found. Please log in again.";

    var uri = Uri.parse('$baseUrl/events');
    var request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['title'] = title
      ..fields['description'] = description
      ..fields['location'] = location
      ..fields['date'] = date
      ..fields['time'] = time;

    // ✅ Attach Image if Available (Image File)
    if (image != null && await image.exists()) {
      String mimeType = lookupMimeType(image.path) ?? "image/jpeg";
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        image.path,
        contentType: MediaType.parse(mimeType),
      ));
    } 
    // ✅ Attach Image if Available (Base64 Image)
    else if (imageBase64 != null) {
      String base64Str = imageBase64.replaceAll('data:image/png;base64,', '').replaceAll('data:image/jpeg;base64,', '');
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        base64Decode(base64Str),
        filename: 'event_image.jpg',
        contentType: MediaType('image', 'jpeg'),
      ));
    }

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();
    var data = jsonDecode(responseBody);

    if (response.statusCode == 201 || response.statusCode == 200) {
      return data["message"] ?? "✅ Event created successfully!";
    } else {
      return "❌ Failed to create event. Status: ${response.statusCode}, Message: ${data['message'] ?? responseBody}";
    }
  } catch (e) {
    return "❌ Create Event Error: $e";
  }
}

  // ✅ Update Event (with Image Upload)
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
      String? token = await getToken();
      if (token == null) return "❌ No token found. Please log in again.";

      var uri = Uri.parse('$baseUrl/events/$eventId');

      var request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['title'] = title
        ..fields['description'] = description
        ..fields['location'] = location
        ..fields['date'] = date
        ..fields['time'] = time.substring(0, 5)
        ..fields['_method'] = 'PUT'; // Laravel needs this for multipart PUT

      if (image != null && await image.exists()) {
        String? mimeType = lookupMimeType(image.path) ?? "image/jpeg";
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          image.path,
          contentType: MediaType.parse(mimeType),
        ));
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var data = jsonDecode(responseBody);

      return response.statusCode == 200
          ? data["message"] ?? "✅ Event updated successfully!"
          : "❌ Failed to update event. Status: ${response.statusCode}, Message: ${data['message'] ?? responseBody}";
    } catch (e) {
      return "❌ Update Event Error: $e";
    }
  }

  // ✅ Delete Event
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

      if (response.statusCode == 200) {
        return "✅ Event deleted successfully!";
      } else {
        var data = json.decode(response.body);
        return "❌ Failed to delete event. Status: ${response.statusCode}, Message: ${data['message'] ?? 'Unknown error'}";
      }
    } catch (e) {
      return "❌ Delete Event Error: $e";
    }
  }
}
