import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class EditEventScreen extends StatefulWidget {
  final ApiService apiService;
  final Map<String, dynamic> event;

  const EditEventScreen({Key? key, required this.apiService, required this.event}) : super(key: key);

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController locationController;
  late TextEditingController dateController;
  late TextEditingController timeController;
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.event['title']);
    descriptionController = TextEditingController(text: widget.event['description']);
    locationController = TextEditingController(text: widget.event['location']);
    dateController = TextEditingController(text: widget.event['date']);
    timeController = TextEditingController(text: widget.event['time']);
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null && !kIsWeb) {
      setState(() {
        selectedImage = File(picked.path);
      });
    }
  }

  Future<void> saveChanges() async {
    if (_formKey.currentState!.validate()) {
      try {
        final result = await widget.apiService.updateEvent(
          eventId: widget.event['id'],
          title: titleController.text,
          description: descriptionController.text,
          location: locationController.text,
          date: dateController.text,
          time: timeController.text,
          image: selectedImage, // Can be null
        );
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
        Navigator.pop(context, true); // Return success
      } catch (e) {
        print('Update error: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Event'), backgroundColor: Colors.deepPurple),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: titleController, decoration: InputDecoration(labelText: 'Title'), validator: (v) => v!.isEmpty ? 'Required' : null),
              TextFormField(controller: descriptionController, decoration: InputDecoration(labelText: 'Description'), maxLines: 3),
              TextFormField(controller: locationController, decoration: InputDecoration(labelText: 'Location')),
              TextFormField(controller: dateController, decoration: InputDecoration(labelText: 'Date')),
              TextFormField(controller: timeController, decoration: InputDecoration(labelText: 'Time')),

              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: pickImage,
                icon: Icon(Icons.image),
                label: Text('Select Image'),
              ),

              if (selectedImage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: kIsWeb
                      ? const Text("Image preview not supported on Web.")
                      : Image.file(selectedImage!, height: 150),
                ),

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveChanges,
                child: Text('Save'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
