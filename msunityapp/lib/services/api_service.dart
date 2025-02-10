import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "http://192.168.1.13:8000/api";  // Change to your backend IP

Future<List<dynamic>> fetchEvents(String token) async {
  final response = await http.get(
    Uri.parse('http://192.168.1.13:8000/api/events'),
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    },
  );

  print('Response Code: ${response.statusCode}');
  print('Response Body: ${response.body}'); // Debugging output

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load events');
  }
}

}
