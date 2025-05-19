import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'create_event_screen.dart';

const String baseUrl = "http://192.168.1.6:8000";

class EventsScreen extends StatefulWidget {
  final ApiService apiService;
  final String token;

  const EventsScreen({super.key, required this.apiService, required this.token});

  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  late Future<List<dynamic>> _eventsFuture;
  int selectedNavIndex = 0;
  bool _yourEventsExpanded = true;

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

  int _getGridCount(double width) {
    if (width >= 1000) return 3;
    if (width >= 600) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      drawer: isMobile ? _buildDrawer() : null,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Events", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: Row(
        children: [
          if (!isMobile) SizedBox(width: 280, child: _buildDrawer()),
          Expanded(
            child: Column(
              children: [
                _buildHeaderFilters(),
                Expanded(
                  child: FutureBuilder<List<dynamic>>(
                    future: _eventsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(child: Text("⚠️ Error loading events."));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text("📅 No events found."));
                      }

                      final events = snapshot.data!;
                      return GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _getGridCount(width),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.72,
                        ),
                        itemCount: events.length,
                        itemBuilder: (context, index) => _buildEventCard(events[index]),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: isMobile
          ? FloatingActionButton(
              backgroundColor: Colors.blue,
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateEventScreen(
                      apiService: widget.apiService,
                      token: widget.token,
                    ),
                  ),
                );
                if (result == true) _refreshEvents();
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.grey[900],
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text("Events",
                style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 15),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.white),
            title: const Text("Home", style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),
          ExpansionTile(
            initiallyExpanded: _yourEventsExpanded,
            onExpansionChanged: (expanded) {
              setState(() {
                _yourEventsExpanded = expanded;
              });
            },
            leading: const Icon(Icons.person, color: Colors.white),
            title: const Text("Your Events", style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.grey[850],
            collapsedIconColor: Colors.white,
            iconColor: Colors.white,
            childrenPadding: const EdgeInsets.only(left: 32),
            children: [
              _subDrawerItem(Icons.check_circle, "Going", () {}),
              _subDrawerItem(Icons.mail, "Invites", () {}),
              _subDrawerItem(Icons.star, "Interested", () {}),
              _subDrawerItem(Icons.home_work, "Hosting", () {}),
              _subDrawerItem(Icons.history, "Past events", () {}),
            ],
          ),
          ListTile(
            leading: const Icon(Icons.notifications, color: Colors.white),
            title: const Text("Notifications", style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CreateEventScreen(apiService: widget.apiService, token: widget.token),
                  ),
                );
                if (result == true) _refreshEvents();
              },
              icon: const Icon(Icons.add),
              label: const Text("Create new event"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _subDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70, size: 20),
      title: Text(title, style: const TextStyle(color: Colors.white70)),
      onTap: onTap,
    );
  }

  Widget _buildHeaderFilters() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _filterChip(Icons.location_on, "My location"),
          _filterChip(Icons.date_range, "Any date"),
          _filterChip(Icons.trending_up, "Top", selected: true),
          _filterChip(Icons.people, "Friends"),
          _filterChip(Icons.person_add, "Following"),
        ],
      ),
    );
  }

  Widget _filterChip(IconData icon, String label, {bool selected = false}) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: selected,
      onSelected: (_) {},
      backgroundColor: Colors.grey[300],
      selectedColor: Colors.blue[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildEventCard(dynamic event) {
    final image = event['image'] ?? '';
    final imageUrl = image.isNotEmpty
        ? "$baseUrl/storage/event_images/${image.split('/').last}"
        : "$baseUrl/storage/default_event_image.png";

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.network(
                imageUrl,
                height: 230,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 6,
                right: 6,
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: Icon(Icons.more_horiz, color: Colors.white),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("📍 ${event['location']}", style: const TextStyle(color: Colors.black87)),
                const SizedBox(height: 5),
                Text(event['title'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text("319 interested · 24 going",
                    style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          

                          _refreshEvents();
                        },
                        icon: const Icon(Icons.star_border),
                        label: const Text("Interested"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () {},
                      tooltip: "Share",
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
