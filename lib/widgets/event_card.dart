import 'package:flutter/material.dart';
import '../services/api_service.dart';

class EventCard extends StatefulWidget {
  final int eventId;
  final String title;
  final String description;
  final String dateTime;
  final int initialLikes;
  final int commentsCount;
  final bool userLiked; // ✅ Track if the user already liked the event
  final VoidCallback onLike;
  final VoidCallback onComment;

  const EventCard({
    super.key,
    required this.eventId,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.initialLikes,
    required this.commentsCount,
    required this.userLiked,
    required this.onLike,
    required this.onComment,
  });

  @override
  _EventCardState createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  late int likesCount;
  late bool hasLiked; // ✅ Tracks if user has liked the event
  bool isLiking = false;
  late ApiService apiService;

  @override
  void initState() {
    super.initState();
    likesCount = widget.initialLikes;
    hasLiked = widget.userLiked; // ✅ Initialize from widget
    apiService = ApiService();
  }

  Future<void> likeEvent() async {
    if (isLiking) return;

    setState(() => isLiking = true);

    try {
      await apiService.likeEvent(widget.eventId);

      // ✅ Toggle like state
      setState(() {
        hasLiked = !hasLiked;
        likesCount += hasLiked ? 1 : -1; // ✅ Increase or decrease likes
      });

      widget.onLike(); // ✅ Refresh parent UI if needed
    } catch (e) {
      _showError("Something went wrong. Please try again.");
    } finally {
      setState(() => isLiking = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Title & Date
            Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(widget.dateTime, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 5),
            Text(widget.description),
            const SizedBox(height: 10),

            // Like & Comment Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Like Button
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.thumb_up,
                        color: hasLiked ? Colors.blue : Colors.black, // ✅ Reflects user like status
                      ),
                      onPressed: likeEvent,
                    ),
                    Text("$likesCount Likes"),
                  ],
                ),
                // Comment Button
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.comment),
                      onPressed: widget.onComment,
                    ),
                    Text("${widget.commentsCount} Comments"),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
