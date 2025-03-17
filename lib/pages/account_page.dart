import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

// Use relative imports
import '../components/avatar.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import 'login_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _usernameController = TextEditingController();
  final _websiteController = TextEditingController();

  String? _avatarUrl;
  var _loading = true;

  @override
  void initState() {
    super.initState();
    _getProfile();
  }

  Future<void> _getProfile() async {
    setState(() {
      _loading = true;
    });

    try {
      final firestoreService = Provider.of<FirestoreService>(context, listen: false);
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final profile = await firestoreService.getUserProfile(userId);
      
      if (profile != null) {
        _usernameController.text = profile.username;
        _websiteController.text = profile.website ?? '';
        _avatarUrl = profile.avatarUrl;
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error loading profile'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    setState(() {
      _loading = true;
    });
    
    try {
      final firestoreService = Provider.of<FirestoreService>(context, listen: false);
      final userId = FirebaseAuth.instance.currentUser!.uid;
      
      await firestoreService.createOrUpdateUserProfile(
        userId: userId,
        username: _usernameController.text.trim(),
        website: _websiteController.text.trim(),
        avatarUrl: _avatarUrl,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully updated profile!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error updating profile'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signOut();
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error signing out'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadAvatar() async {
    final picker = ImagePicker();
    final imageFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 300,
      maxHeight: 300,
    );
    
    if (imageFile == null) {
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final storageService = Provider.of<StorageService>(context, listen: false);
      final firestoreService = Provider.of<FirestoreService>(context, listen: false);
      final userId = FirebaseAuth.instance.currentUser!.uid;
      
      final downloadUrl = await storageService.uploadAvatar(
        userId,
        File(imageFile.path),
      );
      
      await firestoreService.createOrUpdateUserProfile(
        userId: userId,
        username: _usernameController.text.trim(),
        website: _websiteController.text.trim(),
        avatarUrl: downloadUrl,
      );
      
      setState(() {
        _avatarUrl = downloadUrl;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Updated your profile image!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error uploading image'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
              children: [
                GestureDetector(
                  onTap: _uploadAvatar,
                  child: Avatar(
                    imageUrl: _avatarUrl,
                    radius: 50,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: _uploadAvatar,
                    child: const Text('Change Avatar'),
                  ),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'User Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _websiteController,
                  decoration: const InputDecoration(
                    labelText: 'Website',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: _loading ? null : _updateProfile,
                  child: Text(_loading ? 'Saving...' : 'Update'),
                ),
                const SizedBox(height: 18),
                TextButton(
                  onPressed: _signOut,
                  child: const Text('Sign Out'),
                ),
              ],
            ),
    );
  }
}

