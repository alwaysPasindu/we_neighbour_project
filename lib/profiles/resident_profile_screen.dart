import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../constants/colors.dart';

class ResidentProfileScreen extends StatefulWidget {
  const ResidentProfileScreen({super.key});

  @override
  State<ResidentProfileScreen> createState() => _ResidentProfileScreenState();
}

class _ResidentProfileScreenState extends State<ResidentProfileScreen> {
  File? _profileImage;
  final TextEditingController _nameController = TextEditingController(text: 'John Doe');
  final TextEditingController _emailController = TextEditingController(text: 'johndoe@gmail.com');
  final TextEditingController _phoneController = TextEditingController(text: '+94 71 234 3465');
  final TextEditingController _apartmentController = TextEditingController(text: '2/3 Lotus Residence Colombo 03');
  bool _isEditing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _apartmentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: const Text('Failed to pick image. Please try again.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: _toggleEdit,
            icon: Icon(
              _isEditing ? Icons.check : Icons.edit,
              color: AppColors.primary,
            ),
            label: Text(
              _isEditing ? 'Save' : 'Edit',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                _buildProfileImage(isDarkMode),
                const SizedBox(height: 16),
                _isEditing
                    ? _buildEditableField(_nameController, 'Name', isDarkMode)
                    : Text(
                        _nameController.text,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? const Color.fromARGB(255, 27, 18, 18) : AppColors.textPrimary,
                        ),
                      ),
                const SizedBox(height: 32),
                _isEditing
                    ? _buildEditableField(_emailController, 'Email', isDarkMode)
                    : _buildInfoField('Email', _emailController.text, isDarkMode),
                _isEditing
                    ? _buildEditableField(_phoneController, 'Phone Number', isDarkMode)
                    : _buildInfoField('Phone Number', _phoneController.text, isDarkMode),
                _isEditing
                    ? _buildEditableField(_apartmentController, 'Apartment', isDarkMode)
                    : _buildInfoField('Apartment', _apartmentController.text, isDarkMode),
                const SizedBox(height: 40),
                _buildOption('Event Participation', Icons.event, isDarkMode),
                const SizedBox(height: 16),
                _buildOption('Maintenance Requests', Icons.build, isDarkMode),
                const SizedBox(height: 16),
                _buildOption(
                  'Settings',
                  Icons.settings,
                  isDarkMode,
                  onTap: () {
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage(bool isDarkMode) {
    return Stack(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: CircleAvatar(
            radius: 50,
            backgroundColor: isDarkMode ? AppColors.darkCardBackground : AppColors.cardBackground,
            child: _profileImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.file(
                      _profileImage!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(
                    Icons.person,
                    size: 50,
                    color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditableField(TextEditingController controller, String label, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        style: TextStyle(
          color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoField(String label, String value, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label, 
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value, 
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Divider(
            color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildOption(String title, IconData icon, bool isDarkMode, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(
              title, 
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios, 
              color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}