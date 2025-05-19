import 'package:flutter/material.dart';
import '../services/api_service.dart';

class UserEventsScreen extends StatefulWidget {
  final ApiService apiService;
  final String token;

  const UserEventsScreen({super.key, required this.apiService, required this.token});

  @override
  _UserEventsScreenState createState() => _UserEventsScreenState();
}

class _UserEventsScreenState extends State<UserEventsScreen> {
  late Future<List<dynamic>> _userEventsFuture;

  @override
  void initState() {
    super.initState();
    _fetchUserEvents();
  }

  void _fetchUserEvents() {
    setState(() {
      _userEventsFuture = widget.apiService.fetchUserEvents(widget.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Events"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _userEventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("⚠️ Failed to load your events."));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("📅 You haven't created any events yet."));
          }

          final events = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(event['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("📍 ${event['location']}"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navigate to Event Details
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
