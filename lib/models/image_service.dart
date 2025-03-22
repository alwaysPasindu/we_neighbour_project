import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_neighbour/main.dart'; // Ensure this provides `baseUrl`

class ImageService {
  static final ImagePicker _picker = ImagePicker();

  // Pick multiple images from gallery
  static Future<List<XFile>> pickMultipleImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 80, // Added quality to reduce size
      );
      if (images.isEmpty) {
        print('No images selected');
      }
      return images;
    } catch (e) {
      print('Error picking multiple images: $e');
      return [];
    }
  }

  // Pick single image from gallery or camera
  static Future<XFile?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80, // Consistent quality setting
      );
      if (image == null) {
        print('No image selected');
      }
      return image;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  // Upload image to server and return the URL
  static Future<String?> uploadImage(XFile image) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        print('No auth token available. Please log in.');
        return null;
      }

      // Use baseUrl from main.dart
      final String uploadUrl = baseUrl.isNotEmpty ? '$baseUrl/api/upload' : '';
      final uri = Uri.parse(uploadUrl);

      // Prepare multipart request
      final request = http.MultipartRequest('POST', uri)
        ..headers['x-auth-token'] = token
        ..files.add(await http.MultipartFile.fromPath(
          'image', // Field name expected by server
          image.path,
          filename: path.basename(image.path), // Preserve original filename
        ));

      // Send request and handle response
      final response = await request.send().timeout(const Duration(seconds: 30));
      print('Upload response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        print('Response body: $responseBody');
        final json = jsonDecode(responseBody);
        if (json['imageUrl'] != null) {
          return json['imageUrl'] as String;
        } else {
          print('Invalid response format: missing imageUrl');
          return null;
        }
      } else {
        final errorBody = await response.stream.bytesToString();
        print('Failed to upload image: ${response.statusCode} - $errorBody');
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Upload multiple images and return a list of URLs
  static Future<List<String>> uploadMultipleImages(List<XFile> images) async {
    final List<String> uploadedUrls = [];
    for (final image in images) {
      final url = await uploadImage(image);
      if (url != null) {
        uploadedUrls.add(url);
      } else {
        print('Failed to upload one of the images');
      }
    }
    return uploadedUrls;
  }

  // Save image to app directory (for local caching or fallback)
  static Future<String?> saveImageToAppDirectory(XFile file) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}';
      final savedImage = File('${appDir.path}/$fileName');
      await file.saveTo(savedImage.path);
      if (await savedImage.exists()) {
        print('Image saved locally: ${savedImage.path}');
        return savedImage.path;
      } else {
        throw Exception('Failed to save image');
      }
    } catch (e) {
      print('Error saving image: $e');
      return null;
    }
  }

  // Delete image from app directory
  static Future<bool> deleteImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        print('Image deleted: $imagePath');
        return true;
      }
      print('Image not found: $imagePath');
      return false;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  // Show image picker dialog
  static Future<XFile?> showImagePickerDialog(BuildContext context) async {
    XFile? pickedFile;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Gallery'),
                  onTap: () async {
                    pickedFile = await pickImage(source: ImageSource.gallery);
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Camera'),
                  onTap: () async {
                    pickedFile = await pickImage(source: ImageSource.camera);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
    return pickedFile;
  }

  // Check if file exists
  static Future<bool> checkImageExists(String imagePath) async {
    try {
      final file = File(imagePath);
      return await file.exists();
    } catch (e) {
      print('Error checking image existence: $e');
      return false;
    }
  }

  // Get file size in MB
  static Future<double> getImageSize(String imagePath) async {
    try {
      final file = File(imagePath);
      final bytes = await file.length();
      final sizeInMb = bytes / (1024 * 1024);
      print('Image size: $sizeInMb MB');
      return sizeInMb;
    } catch (e) {
      print('Error getting image size: $e');
      return 0.0;
    }
  }
}