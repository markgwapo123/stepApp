import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'user_events_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final ApiService apiService;
  final String token;

  const AdminDashboardScreen({
    Key? key,
    required this.apiService,
    required this.token,
  }) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List<dynamic> users = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final response = await widget.apiService.fetchAllUsers();
      setState(() {
        users = response;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load users')),
      );
    }
  }

  Future<void> deleteUser(int id) async {
    bool confirmed = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(child: Text('Cancel'), onPressed: () => Navigator.pop(context, false)),
          ElevatedButton(child: Text('Delete'), onPressed: () => Navigator.pop(context, true)),
        ],
      ),
    );

    if (confirmed == true) {
      bool success = await widget.apiService.deleteUser(id);
      if (success) {
        fetchUsers();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User deleted')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete user')),
        );
      }
    }
  }

  void showEditDialog(Map user) {
    final nameController = TextEditingController(text: user['name']);
    final emailController = TextEditingController(text: user['email']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit User'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              String result = await widget.apiService.updateUser(
                user['id'],
                nameController.text,
                emailController.text,
              );
              Navigator.pop(context);
              if (result == 'success') {
                fetchUsers();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('User updated successfully')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result)),
                );
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void viewUserEvents(Map user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserEventsScreen(
          apiService: widget.apiService,
          userId: user['id'],
          userName: user['name'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        backgroundColor: Colors.deepPurple,
      ),
      body: users.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      leading: CircleAvatar(
                        backgroundColor: Colors.deepPurple,
                        child: Text(
                          user['name'][0].toUpperCase(),
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(user['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user['email']),
                          SizedBox(height: 4),
                          Text('Events Created: ${user['event_count'] ?? 0}'),
                        ],
                      ),
                      trailing: Wrap(
                        spacing: 10,
                        children: [
                        IconButton(
                          icon: Icon(Icons.remove_red_eye, color: Colors.blue),
                          tooltip: 'View Events',
                          onPressed: () => viewUserEvents(user),
                        ),

                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.orange),
                            tooltip: 'Edit User',
                            onPressed: () => showEditDialog(user),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Delete User',
                            onPressed: () => deleteUser(user['id']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
