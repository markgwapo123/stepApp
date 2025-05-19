import 'package:flutter/material.dart';
import '../services/api_service.dart';

  class AdminDashboardScreen extends StatefulWidget {
  final ApiService apiService;
  final String token;

  const AdminDashboardScreen({Key? key, required this.apiService, required this.token}) : super(key: key);

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
  final response = await widget.apiService.fetchAllUsers();
  setState(() {
    users = response;
  });
}


 Future<void> deleteUser(int id) async {
  bool success = await widget.apiService.deleteUser(id);
  if (success) {
    fetchUsers();
  }
}


  void showEditDialog(Map user) {
  final nameController = TextEditingController(text: user['name']);
  final emailController = TextEditingController(text: user['email']);

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('Edit User'),
      content: Column(
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
      actions: [
        TextButton(
            onPressed: () async {
            String result = await ApiService().updateUser(
            user['id'],
            nameController.text,
            emailController.text,
            );
          Navigator.pop(context);
          if (result == 'success') { // Check based on returned string
          fetchUsers();
          } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
          }
          },

          child: Text('Save'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
      ],
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Dashboard')),
      body: users.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  title: Text(user['name']),
                  subtitle: Text(user['email']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: Icon(Icons.edit), onPressed: () => showEditDialog(user)),
                      IconButton(icon: Icon(Icons.delete), onPressed: () => deleteUser(user['id'])),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
