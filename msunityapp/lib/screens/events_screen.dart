import 'package:flutter/material.dart';
import '../services/api_service.dart';  // Import ApiService

class EventsScreen extends StatefulWidget {
  final ApiService apiService;
  final String token;

  EventsScreen({required this.apiService, required this.token});  // Constructor

  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  List events = [];

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
  try {
    List<dynamic> fetchedEvents = await widget.apiService.fetchEvents(); 

    setState(() {
      events = fetchedEvents;
    });
  } catch (e) {
    print('Error fetching events: $e');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Events")),
      body: events.isEmpty
          ? Center(child: CircularProgressIndicator()) // Show a loading spinner
          : ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(events[index]['title']),
                  subtitle: Text(events[index]['description']),
                );
              },
            ),
    );
  }
}
