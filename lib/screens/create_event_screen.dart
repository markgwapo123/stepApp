import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart'; // ✅ For kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import 'dart:convert'; // ✅ For Base64 encoding (Web)

/// CreateEventScreen - Form to create a new event with image upload.
class CreateEventScreen extends StatefulWidget {
  final ApiService apiService;
  final String token;

  const CreateEventScreen({super.key, required this.apiService, required this.token});

  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  File? _selectedImage; // ✅ Mobile image file
  Uint8List? _webImage; // ✅ Web image bytes
  String? _webImageBase64; // ✅ Web image Base64
  bool isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  /// Pick Image (Handles both Web and Mobile)
Future<void> _pickImage() async {
  final ImagePicker picker = ImagePicker();
  final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

  if (pickedFile != null) {
    if (kIsWeb) {
      // ✅ Convert Web image to Base64
      Uint8List bytes = await pickedFile.readAsBytes();
      setState(() {
        _webImage = bytes;
        _webImageBase64 = base64Encode(bytes);
      });
    } else {
      // ✅ Mobile image selection
      File selectedFile = File(pickedFile.path);

      setState(() {
        _selectedImage = selectedFile;
      });

      // ✅ Debugging: Check if _selectedImage is null before accessing properties
      if (_selectedImage != null && await _selectedImage!.exists()) {
        debugPrint("✅ Image selected successfully: ${_selectedImage!.path}");
      } else {
        debugPrint("❌ Image file does not exist or is null.");
      }
    }
  } else {
    debugPrint("⚠️ No image selected.");
  }
}



  /// Create Event API Call
  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      String responseMessage = await widget.apiService.createEvent(
  title: _titleController.text.trim(),
  description: _descriptionController.text.trim(),
  location: _locationController.text.trim(),
  date: _dateController.text.trim(),
  time: _timeController.text.trim(),
  image: _selectedImage, // ✅ Mobile image file
  imageBase64: _webImageBase64, // ✅ Web Base64 image
);



      if (responseMessage.contains("successfully")) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎉 Event created successfully!')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('⚠️ $responseMessage')),
        );
      }
    } catch (e) {
      debugPrint('❌ Error creating event: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Failed to create event. Try again!')),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  /// Select Date
  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text = pickedDate.toIso8601String().split('T')[0]; // Format YYYY-MM-DD
      });
    }
  }

  /// Select Time
  Future<void> _selectTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      final now = DateTime.now();
      final formattedTime = DateTime(
        now.year,
        now.month,
        now.day,
        pickedTime.hour,
        pickedTime.minute,
      ).toIso8601String().split('T')[1].substring(0, 5);

      setState(() {
        _timeController.text = formattedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Event')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: kIsWeb
                      ? (_webImage != null
                          ? Image.memory(_webImage!, fit: BoxFit.cover) // ✅ Web Image
                          : const Center(child: Text('📷 Tap to select image')))
                      : (_selectedImage != null
                          ? Image.file(File(_selectedImage!.path), fit: BoxFit.cover) // ✅ Mobile Image
                          : const Center(child: Text('📷 Tap to select image'))),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Event Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    (value?.trim().isEmpty ?? true) ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) =>
                    (value?.trim().isEmpty ?? true) ? 'Description is required' : null,
              ),
              const SizedBox(height: 16),

              // Location
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    (value?.trim().isEmpty ?? true) ? 'Location is required' : null,
              ),
              const SizedBox(height: 16),

              // Date Picker
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Date',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _selectDate,
                  ),
                ),
                validator: (value) =>
                    (value?.trim().isEmpty ?? true) ? 'Date is required' : null,
              ),
              const SizedBox(height: 16),

              // Time Picker
              TextFormField(
                controller: _timeController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Time',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.access_time),
                    onPressed: _selectTime,
                  ),
                ),
                validator: (value) =>
                    (value?.trim().isEmpty ?? true) ? 'Time is required' : null,
              ),
              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _createEvent,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Create Event'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
