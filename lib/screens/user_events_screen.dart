import 'package:flutter/material.dart';
import '../services/api_service.dart';

class UserEventsScreen extends StatefulWidget {
  final ApiService apiService;
  final int userId;
  final String userName;

  const UserEventsScreen({
    Key? key,
    required this.apiService,
    required this.userId,
    required this.userName,
  }) : super(key: key);

  @override
  _UserEventsScreenState createState() => _UserEventsScreenState();
}

class _UserEventsScreenState extends State<UserEventsScreen> {
  List<dynamic> events = [];

  @override
  void initState() {
    super.initState();
    fetchUserEvents();
  }

Future<void> fetchUserEvents() async {
  try {
    final fetchedEvents = await widget.apiService.getEventsByUser(widget.userId);
    print('Fetched events: $fetchedEvents'); // Debug print
    setState(() {
      events = fetchedEvents;
    });
  } catch (e) {
    print('Error fetching events: $e'); // Debug print
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to load events')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.userName}\'s Events'),
        backgroundColor: Colors.deepPurple,
      ),
      body: events.isEmpty
          ? Center(child: Text('No events created by this user.'))
          : ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(event['title'] ?? 'Untitled'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(event['description'] ?? ''),
                        Text('Location: ${event['location'] ?? ''}'),
                        Text('Date: ${event['date'] ?? ''}'),
                        Text('Time: ${event['time'] ?? ''}'),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
