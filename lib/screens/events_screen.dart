import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'create_event_screen.dart';

/// Base URL of your Laravel server
const String baseUrl = "http://192.168.1.11:8000";

class EventsScreen extends StatefulWidget {
  final ApiService apiService;
  final String token;

  const EventsScreen({super.key, required this.apiService, required this.token});

  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  late Future<List<dynamic>> _eventsFuture;
  String selectedFilter = "Today";

  @override
  void initState() {
    super.initState();
    _refreshEvents();
  }

  void _refreshEvents() {
    setState(() {
      _eventsFuture = widget.apiService.fetchEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Events",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.grid_view, color: Colors.black), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.black),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateEventScreen(apiService: widget.apiService, token: widget.token),
                ),
              );
              if (result == true) _refreshEvents();
            },
          ),
          IconButton(icon: const Icon(Icons.search, color: Colors.black), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Tab Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ["Today", "This Week", "This Month"].map((filter) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedFilter = filter;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: selectedFilter == filter ? Colors.blue.shade100 : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: selectedFilter == filter ? Colors.blue : Colors.black,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _eventsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text("⚠️ Error loading events. Please try again!", style: TextStyle(color: Colors.red)),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("📅 No events available."));
                }

                final events = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.all(12.0),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    final eventImage = event['image'] ?? '';
                    final eventImageUrl = eventImage.isNotEmpty
                        ? "$baseUrl/storage/event_images/${eventImage.split('/').last}"
                        : "$baseUrl/storage/default_event_image.png";

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            child: Image.network(
                              eventImageUrl,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/default_event_image.png',
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event['title'],
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text("📍 ${event['location']}", style: const TextStyle(color: Colors.grey)),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[200],
                                    minimumSize: const Size(double.infinity, 40),
                                  ),
                                  icon: const Icon(Icons.star_border, color: Colors.black),
                                  label: const Text("Interested", style: TextStyle(color: Colors.black)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
