import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:we_neighbour/main.dart';
import 'package:we_neighbour/settings/settings_screen.dart';
import 'dart:io';
import '../constants/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CompanyProfileScreen extends StatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  _CompanyProfileScreenState createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  String? _profileImagePath;
  String? _token;
  bool _isLoading = true;

  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _loadProfileImage();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    if (_token == null) {
      print('No token found, navigating to login');
      if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      return;
    }

    setState(() {
      _nameController.text = prefs.getString('userName') ?? 'Company Name';
      _emailController.text = prefs.getString('userEmail') ?? 'company@email.com';
      _phoneController.text = prefs.getString('userPhone') ?? '+94 234 567 890';
      _addressController.text = prefs.getString('userAddress') ?? '123 Business Street';
      _descriptionController.text = prefs.getString('userDescription') ?? 'Company Description';
      _usernameController.text = prefs.getString('username') ?? '@companyusername';
      _isLoading = false;
    });
  }

  Future<void> _loadProfileImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final imagePath = prefs.getString('profile_image');
      if (imagePath != null && await File(imagePath).exists()) {
        setState(() => _profileImagePath = imagePath);
      }
    } catch (e) {
      print('Error loading profile image: $e');
    }
  }

  Future<void> _pickAndSaveProfileImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1000, maxHeight: 1000, imageQuality: 85);
      if (image != null) {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}';
        final savedImage = File('${directory.path}/$fileName');
        await savedImage.writeAsBytes(await image.readAsBytes());

        if (_profileImagePath != null && await File(_profileImagePath!).exists()) {
          await File(_profileImagePath!).delete();
        }

        setState(() => _profileImagePath = savedImage.path);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_image', savedImage.path);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile photo updated')));
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _saveProfileData() async {
    if (_token == null) return;

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/service-providers/profile'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_token'},
        body: jsonEncode({
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'address': _addressController.text,
          'description': _descriptionController.text,
          'username': _usernameController.text,
        }),
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userName', _nameController.text);
        await prefs.setString('userEmail', _emailController.text);
        await prefs.setString('userPhone', _phoneController.text);
        await prefs.setString('userAddress', _addressController.text);
        await prefs.setString('userDescription', _descriptionController.text);
        await prefs.setString('username', _usernameController.text);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully')));
      } else {
        print('Failed to update profile: ${response.statusCode} - ${response.body}');
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update profile on server')));
      }
    } catch (e) {
      print('Error saving profile data: $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _descriptionController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      if (_isEditing) {
        if (_formKey.currentState?.validate() ?? false) {
          _saveProfileData().then((_) => setState(() => _isEditing = false));
        }
      } else {
        _isEditing = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildProfileHeader(context, isDarkMode),
                const SizedBox(height: 20),
                _buildProfileDetails(isDarkMode),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, bool isDarkMode) {
    return Stack(
      children: [
        Column(
          children: [
            Container(height: 150, width: double.infinity, decoration: BoxDecoration(color: isDarkMode ? AppColors.darkBackground : AppColors.primary)),
            const SizedBox(height: 60),
          ],
        ),
        Positioned(
          top: 20,
          left: 20,
          right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Profile', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  IconButton(icon: Icon(_isEditing ? Icons.save : Icons.edit, color: Colors.white), onPressed: _toggleEdit),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(left: 20, top: 100, child: _buildProfileImage()),
      ],
    );
  }

  Widget _buildProfileImage() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 4), borderRadius: BorderRadius.circular(60)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(60),
            child: _profileImagePath != null
                ? Image.file(File(_profileImagePath!), width: 100, height: 100, fit: BoxFit.cover, errorBuilder: (_, e, __) => _buildPlaceholderImage())
                : Image.asset('assets/profile_placeholder.png', width: 100, height: 100, fit: BoxFit.cover, errorBuilder: (_, e, __) => _buildPlaceholderImage()),
          ),
        ),
        if (_isEditing)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(color: const Color(0xFF4B7DFF), borderRadius: BorderRadius.circular(15)),
              child: IconButton(
                icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                onPressed: _pickAndSaveProfileImage,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: const EdgeInsets.all(6),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholderImage() => Container(width: 100, height: 100, color: Colors.grey[300], child: const Icon(Icons.person, size: 50, color: Colors.grey));

  Widget _buildProfileDetails(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _isEditing
              ? TextFormField(
                  controller: _nameController,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : AppColors.textPrimary),
                  decoration: InputDecoration(labelText: 'Company Name', labelStyle: TextStyle(color: isDarkMode ? Colors.grey[400] : AppColors.textSecondary)),
                  validator: (value) => value?.isEmpty ?? true ? 'Company name is required' : null,
                )
              : Text(_nameController.text, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : AppColors.textPrimary)),
          const SizedBox(height: 8),
          _isEditing
              ? TextFormField(
                  controller: _usernameController,
                  style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.grey[400] : AppColors.textSecondary),
                  decoration: InputDecoration(labelText: 'Username', labelStyle: TextStyle(color: isDarkMode ? Colors.grey[400] : AppColors.textSecondary)),
                  validator: (value) => value?.isEmpty ?? true ? 'Username is required' : null,
                )
              : Text(_usernameController.text, style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.grey[400] : AppColors.textSecondary)),
          const SizedBox(height: 16),
          _isEditing
              ? TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.white : AppColors.textPrimary),
                  decoration: InputDecoration(labelText: 'Description', labelStyle: TextStyle(color: isDarkMode ? Colors.grey[400] : AppColors.textSecondary)),
                  validator: (value) => value?.isEmpty ?? true ? 'Description is required' : null,
                )
              : Text(_descriptionController.text, style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.white : AppColors.textPrimary)),
          const SizedBox(height: 24),
          // _buildStatistics(),
          const SizedBox(height: 24),
          _buildContactInfo(isDarkMode),
        ],
      ),
    );
  }

  // Widget _buildStatistics() {
    // return Row(
    //   mainAxisAlignment: MainAxisAlignment.spaceAround,
    //   children: [
    //     _buildStatItem('Services', '3'),
    //     _buildStatItem('Reviews', '150'),
    //     _buildStatItem('Rating', '4.8'),
    //   ],
    // );
  // }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  Widget _buildContactInfo(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Contact Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : AppColors.textPrimary)),
        const SizedBox(height: 12),
        _buildContactItem(Icons.email, _emailController, 'Email', isDarkMode),
        _buildContactItem(Icons.phone, _phoneController, 'Phone', isDarkMode),
        _buildContactItem(Icons.location_on, _addressController, 'Address', isDarkMode),
      ],
    );
  }

  Widget _buildContactItem(IconData icon, TextEditingController controller, String label, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: isDarkMode ? Colors.white : AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: _isEditing
                ? TextFormField(
                    controller: controller,
                    style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.white : AppColors.textPrimary),
                    decoration: InputDecoration(labelText: label, labelStyle: TextStyle(color: isDarkMode ? Colors.grey[400] : AppColors.textSecondary)),
                    validator: (value) => value?.isEmpty ?? true ? '$label is required' : null,
                  )
                : Text(controller.text, style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.white : AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}