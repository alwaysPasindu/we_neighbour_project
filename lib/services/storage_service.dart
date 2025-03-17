import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload avatar image
  Future<String> uploadAvatar(String userId, File file) async {
    try {
      final fileExtension = file.path.split('.').last;
      final fileName = '$userId-${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      final storageRef = _storage.ref().child('avatars/$fileName');
      
      final uploadTask = await storageRef.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      rethrow;
    }
  }
}

