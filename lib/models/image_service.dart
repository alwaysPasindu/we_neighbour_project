import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_neighbour/main.dart'; // Ensure this provides `baseUrl`
import 'package:logger/logger.dart';

class ImageService {
  static final ImagePicker _picker = ImagePicker();
  static final Logger logger = Logger();

  /// Pick multiple images from gallery
  static Future<List<XFile>> pickMultipleImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(imageQuality: 80);
      if (images.isEmpty) {
        logger.d('No images selected');
      }
      return images;
    } catch (e) {
      logger.e('Error picking multiple images: $e'); // Use error level for exceptions
      return [];
    }
  }

  /// Pick single image from gallery or camera
  static Future<XFile?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? image = await _picker.pickImage(source: source, imageQuality: 80);
      if (image == null) {
        logger.d('No image selected');
      }
      return image;
    } catch (e) {
      logger.e('Error picking image: $e'); // Use error level for exceptions
      return null;
    }
  }

  /// Upload image to server and return the URL
  static Future<String?> uploadImage(XFile image) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        logger.w('No auth token available. Please log in.'); // Warning level for auth issues
        return null;
      }

      final String uploadUrl = baseUrl.isNotEmpty ? '$baseUrl/api/upload' : '';
      if (uploadUrl.isEmpty) {
        logger.e('Base URL is empty. Cannot upload image.');
        return null;
      }
      final uri = Uri.parse(uploadUrl);

      final request = http.MultipartRequest('POST', uri)
        ..headers['x-auth-token'] = token
        ..files.add(await http.MultipartFile.fromPath(
          'image',
          image.path,
          filename: path.basename(image.path),
        ));

      final response = await request.send().timeout(const Duration(seconds: 30));
      logger.d('Upload response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        logger.d('Response body: $responseBody');
        final json = jsonDecode(responseBody);
        final imageUrl = json['imageUrl'] as String?;
        if (imageUrl != null) {
          return imageUrl;
        } else {
          logger.w('Invalid response format: missing imageUrl');
          return null;
        }
      } else {
        final errorBody = await response.stream.bytesToString();
        logger.w('Failed to upload image: ${response.statusCode} - $errorBody');
        return null;
      }
    } catch (e) {
      logger.e('Error uploading image: $e');
      return null;
    }
  }

  /// Upload multiple images and return a list of URLs
  static Future<List<String>> uploadMultipleImages(List<XFile> images) async {
    final List<String> uploadedUrls = [];
    for (final image in images) {
      final url = await uploadImage(image);
      if (url != null) {
        uploadedUrls.add(url);
      } else {
        logger.w('Failed to upload one of the images');
      }
    }
    return uploadedUrls;
  }

  /// Save image to app directory (for local caching or fallback)
  static Future<String?> saveImageToAppDirectory(XFile file) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}';
      final savedImage = File('${appDir.path}/$fileName');
      await file.saveTo(savedImage.path);
      if (await savedImage.exists()) {
        logger.d('Image saved locally: ${savedImage.path}');
        return savedImage.path;
      } else {
        throw Exception('Failed to save image to ${savedImage.path}');
      }
    } catch (e) {
      logger.e('Error saving image: $e');
      return null;
    }
  }

  /// Delete image from app directory
  static Future<bool> deleteImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        logger.d('Image deleted: $imagePath');
        return true;
      }
      logger.w('Image not found: $imagePath');
      return false;
    } catch (e) {
      logger.e('Error deleting image: $e');
      return false;
    }
  }

  /// Show image picker dialog with mounted check
  static Future<XFile?> showImagePickerDialog(BuildContext context) async {
    XFile? pickedFile;
    if (!context.mounted) return null; // Early return if context is not mounted
    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
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
                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Camera'),
                  onTap: () async {
                    pickedFile = await pickImage(source: ImageSource.camera);
                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
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

  /// Check if file exists
  static Future<bool> checkImageExists(String imagePath) async {
    try {
      final file = File(imagePath);
      final exists = await file.exists();
      logger.d('Image exists check: $imagePath - $exists');
      return exists;
    } catch (e) {
      logger.e('Error checking image existence: $e');
      return false;
    }
  }

  /// Get file size in MB
  static Future<double> getImageSize(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        final bytes = await file.length();
        final sizeInMb = bytes / (1024 * 1024);
        logger.d('Image size: $sizeInMb MB for $imagePath');
        return sizeInMb;
      }
      logger.w('Image not found for size check: $imagePath');
      return 0.0;
    } catch (e) {
      logger.e('Error getting image size: $e');
      return 0.0;
    }
  }
}