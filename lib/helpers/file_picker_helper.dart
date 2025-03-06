import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

// If running on mobile, import 'dart:io' to use `File`
import 'dart:io' if (dart.library.html) 'dart:typed_data';

class FilePickerHelper {
  static Future<dynamic> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        // Web: Return Uint8List
        final bytes = await pickedFile.readAsBytes();
        return {
          "webImage": bytes,
          "webImageName": pickedFile.name,
        };
      } else {
        // Mobile: Return File
        return {
          "file": File(pickedFile.path),
        };
      }
    }
    return null;
  }
}
