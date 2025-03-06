import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'create_event_screen.dart';

/// Base URL of your Laravel server
const String baseUrl = "http://192.168.1.26:8000";

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
    _refreshEvents();
  }

  /// Fetch events and refresh UI
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
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "⚠️ Error loading events. Please try again!",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("📅 No events available."),
              ),
            );
          }

          final events = snapshot.data!;
          return ListView.builder(
            itemCount: events.length,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemBuilder: (context, index) {
              final event = events[index];
              final creator = event['user'];
              final creatorName = creator?['name'] ?? 'Unknown User';

              // Handle Profile Picture
              final creatorProfilePicture = creator?['profile_picture'];
              final profilePictureUrl = (creatorProfilePicture != null && creatorProfilePicture.isNotEmpty)
                  ? (creatorProfilePicture.startsWith('http')
                      ? creatorProfilePicture
                      : "$baseUrl/storage/${creatorProfilePicture}")
                  : "$baseUrl/storage/default_avatar.png";

              // Handle Event Image
             final eventImage = event['image'];
final eventImageUrl = (eventImage != null && eventImage.isNotEmpty)
    ? "$baseUrl/storage/event_images/${eventImage.split('/').last}"
    : "$baseUrl/storage/default_event_image.png";
               debugPrint("Event Image URL: $eventImageUrl"); // Debugging the image URL
              print("Event Image URL: $eventImageUrl"); // Debugging

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event Creator Info
                    ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(profilePictureUrl),
                        onBackgroundImageError: (_, __) => const Icon(Icons.person),
                      ),
                      title: Text(creatorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text("Event Creator"),
                    ),

                    // Event Image (If available)
                    
                    ClipRRect(
  borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
  
  child: Image.network(
  eventImageUrl,
  height: 200,
  width: double.infinity,
  fit: BoxFit.cover,
  loadingBuilder: (context, child, loadingProgress) {
    if (loadingProgress == null) return child;
    return const Center(child: CircularProgressIndicator());
  },
  errorBuilder: (context, error, stackTrace) {
    debugPrint("⚠️ Error loading image: $eventImageUrl");
    debugPrint("Error: $error");
    return Image.asset( // Ensure you have this fallback image in your assets folder
      'assets/default_event_image.png',
      height: 200,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  },
)

),


                    // Event Details
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(event['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          "${event['date']} at ${event['time']}\n📍 ${event['location']}",
                        ),
                        isThreeLine: true,
                      ),
                    ),
                  ],
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
            _refreshEvents();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
