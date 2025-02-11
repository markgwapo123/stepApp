import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'create_event_screen.dart';

/// EventsScreen - Fetches and displays the list of events.
class EventsScreen extends StatefulWidget {
  final ApiService apiService;
  final String token;

  const EventsScreen({super.key, required this.apiService, required this.token});

  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  late Future<List<dynamic>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _eventsFuture = widget.apiService.fetchEvents();
  }

  /// Refreshes the event list after creating a new event.
  void _refreshEvents() {
    setState(() {
      _eventsFuture = widget.apiService.fetchEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Events")),
      body: FutureBuilder<List<dynamic>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Loading spinner
          } else if (snapshot.hasError) {
            return Center(
              child: Text("⚠️ Error: ${snapshot.error}"),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("📅 No events available."),
            );
          }

          // Display list of events
          final events = snapshot.data!;
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(event['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${event['date']} at ${event['time']}\n${event['location']}"),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateEventScreen(apiService: widget.apiService, token: widget.token),
            ),
          );

          if (result == true) {
            _refreshEvents(); // Refresh event list if an event was created
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
