import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'EditEventScreen.dart';

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
      setState(() {
        events = fetchedEvents;
      });
    } catch (e) {
      print('Error fetching events: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load events')),
      );
    }
  }

  Future<void> deleteEvent(int eventId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Event'),
        content: Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Delete')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await widget.apiService.deleteEvent(eventId);
        fetchUserEvents(); // Refresh list
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Event deleted')),
        );
      } catch (e) {
        print('Delete failed: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete event')),
        );
      }
    }
  }

  void editEvent(Map<String, dynamic> event) async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => EditEventScreen(apiService: widget.apiService, event: event),
    ),
  );

  if (result == true) {
    fetchUserEvents(); // Refresh if changes were saved
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
                  margin: EdgeInsets.all(10),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (event['image'] != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  event['image'],
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              )
                            else
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.image_not_supported, size: 40),
                              ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event['title'] ?? 'Untitled',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 6),
                                  if (event['description'] != null)
                                    Text(
                                      event['description'],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  SizedBox(height: 6),
                                  Text('📍 ${event['location'] ?? 'No location'}'),
                                  Text('📅 ${event['date'] ?? 'No date'}'),
                                  Text('⏰ ${event['time'] ?? 'No time'}'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () => editEvent(event),
                              icon: Icon(Icons.edit, color: Colors.blue),
                              label: Text('Edit', style: TextStyle(color: Colors.blue)),
                            ),
                            SizedBox(width: 10),
                            TextButton.icon(
                              onPressed: () => deleteEvent(event['id']),
                              icon: Icon(Icons.delete, color: Colors.red),
                              label: Text('Delete', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
