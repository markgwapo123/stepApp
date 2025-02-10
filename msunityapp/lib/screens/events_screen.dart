import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';  // Import the ApiService

class EventsScreen extends StatefulWidget {
  final ApiService apiService;
  EventsScreen({required this.apiService});  // Accept ApiService

  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  List events = [];
  String token = "1r1y8Aogv6fg9ols86DwTtVF4wBkDFHe0ExG1vrddcc0e80e"; // Replace with actual token from login

  Future<void> fetchEvents() async {
    try {
      List<dynamic> data = await widget.apiService.fetchEvents(token);
      setState(() {
        events = data;
      });
    } catch (e) {
      print('Failed to load events: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Events')),
      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(events[index]['title']),
            subtitle: Text(events[index]['location']),
          );
        },
      ),
    );
  }
}
