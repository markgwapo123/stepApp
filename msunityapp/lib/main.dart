import 'package:flutter/material.dart';
import 'screens/events_screen.dart';
import 'services/api_service.dart';  // Import the ApiService

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ApiService apiService = ApiService();  // Initialize ApiService

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: EventsScreen(apiService: apiService),  // Pass the ApiService
    );
  }
}
