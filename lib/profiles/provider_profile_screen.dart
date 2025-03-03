import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:we_neighbour/settings/settings_screen.dart';
import 'dart:io';
import '../constants/colors.dart';

class CompanyProfileScreen extends StatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  _CompanyProfileScreenState createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  String? _profileImagePath;

  // Controllers for editing
  final _nameController = TextEditingController(text: 'Company Name');
  final _usernameController = TextEditingController(text: '@companyusername');
  final _descriptionController = TextEditingController(
    text: 'Company Description goes here. This is a brief description of what the company does and what services they provide to their customers.',
  );
  final _emailController = TextEditingController(text: 'company@email.com');
  final _phoneController = TextEditingController(text: '+94 234 567 890');
  final _addressController = TextEditingController(text: '123 Business Street, City, Country');

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _loadProfileImage();
  }

  Future<void> _loadProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _nameController.text = prefs.getString('userName') ?? 'Company Name';
        _emailController.text = prefs.getString('userEmail') ?? 'company@email.com';
        _phoneController.text = prefs.getString('userPhone') ?? '+94 234 567 890';
        _addressController.text = prefs.getString('userAddress') ?? '123 Business Street';
        _descriptionController.text = prefs.getString('userDescription') ?? 'Company Description';
        _usernameController.text = prefs.getString('username') ?? '@companyusername';
      });
    } catch (e) {
      print('Error loading profile data: $e');
    }
  }

  Future<void> _loadProfileImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final imagePath = prefs.getString('profile_image');
      if (imagePath != null) {
        setState(() {
          _profileImagePath = imagePath;
        });
      }
    } catch (e) {
      print('Error loading profile image: $e');
    }
  }

  Future<void> _saveProfileImage(String imagePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image', imagePath);
    } catch (e) {
      print('Error saving profile image: $e');
    }
  }

  Future<void> _pickAndSaveProfileImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (image != null) {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}';
        final savedImage = File('${directory.path}/$fileName');

        // Copy the picked image to app directory
        await savedImage.writeAsBytes(await image.readAsBytes());

        // Delete old profile image if it exists
        if (_profileImagePath != null) {
          final oldImage = File(_profileImagePath!);
          if (await oldImage.exists()) {
            await oldImage.delete();
          }
        }

        setState(() {
          _profileImagePath = savedImage.path;
        });
        await _saveProfileImage(savedImage.path);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile photo updated successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile photo: $e')),
        );
      }
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
        // Save changes
        if (_formKey.currentState?.validate() ?? false) {
          _saveProfileData();
          _isEditing = false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
        }
      } else {
        _isEditing = true;
      }
    });
  }

  Future<void> _saveProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', _nameController.text);
      await prefs.setString('userEmail', _emailController.text);
      await prefs.setString('userPhone', _phoneController.text);
      await prefs.setString('userAddress', _addressController.text);
      await prefs.setString('userDescription', _descriptionController.text);
      await prefs.setString('username', _usernameController.text);
    } catch (e) {
      print('Error saving profile data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error saving profile data')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.darkBackground : AppColors.primary,
              ),
            ),
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
              Text(
                'Profile',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _isEditing ? Icons.save : Icons.edit,
                      color: Colors.white,
                    ),
                    onPressed: _toggleEdit,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.settings,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          left: 20,
          top: 100,
          child: _buildProfileImage(),
        ),
      ],
    );
  }

  Widget _buildProfileImage() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white,
              width: 4,
            ),
            borderRadius: BorderRadius.circular(60),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(60),
            child: _profileImagePath != null
                ? Image.file(
                    File(_profileImagePath!),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print('Error loading profile image: $error');
                      return _buildPlaceholderImage();
                    },
                  )
                : Image.asset(
                    'assets/profile_placeholder.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholderImage();
                    },
                  ),
          ),
        ),
        if (_isEditing)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF4B7DFF),
                borderRadius: BorderRadius.circular(15),
              ),
              child: IconButton(
                icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                onPressed: _pickAndSaveProfileImage,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
                padding: const EdgeInsets.all(6),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 100,
      height: 100,
      color: Colors.grey[300],
      child: const Icon(
        Icons.person,
        size: 50,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildProfileDetails(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _isEditing
              ? TextFormField(
                  controller: _nameController,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Company Name',
                    labelStyle: TextStyle(
                      color: isDarkMode ? Colors.grey[400] : AppColors.textSecondary,
                    ),
                  ),
                  autocorrect: false,
                  textCapitalization: TextCapitalization.none,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Company name is required';
                    }
                    return null;
                  },
                )
              : Text(
                  _nameController.text,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : AppColors.textPrimary,
                  ),
                ),
          const SizedBox(height: 8),
          _isEditing
              ? TextFormField(
                  controller: _usernameController,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.grey[400] : AppColors.textSecondary,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Username',
                    labelStyle: TextStyle(
                      color: isDarkMode ? Colors.grey[400] : AppColors.textSecondary,
                    ),
                  ),
                  autocorrect: false,
                  textCapitalization: TextCapitalization.none,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Username is required';
                    }
                    return null;
                  },
                )
              : Text(
                  _usernameController.text,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.grey[400] : AppColors.textSecondary,
                  ),
                ),
          const SizedBox(height: 16),
          _isEditing
              ? TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.white : AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(
                      color: isDarkMode ? Colors.grey[400] : AppColors.textSecondary,
                    ),
                  ),
                  autocorrect: false,
                  textCapitalization: TextCapitalization.none,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Description is required';
                    }
                    return null;
                  },
                )
              : Text(
                  _descriptionController.text,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.white : AppColors.textPrimary,
                  ),
                ),
          const SizedBox(height: 24),
          _buildStatistics(),
          const SizedBox(height: 24),
          _buildContactInfo(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem('Services', '3'),
        _buildStatItem('Reviews', '150'),
        _buildStatItem('Rating', '4.8'),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfo(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : AppColors.textPrimary,
          ),
        ),
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
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.white : AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      labelText: label,
                      labelStyle: TextStyle(
                        color: isDarkMode ? Colors.grey[400] : AppColors.textSecondary,
                      ),
                    ),
                    autocorrect: false,
                    textCapitalization: TextCapitalization.none,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return '$label is required';
                      }
                      return null;
                    },
                  )
                : Text(
                    controller.text,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

