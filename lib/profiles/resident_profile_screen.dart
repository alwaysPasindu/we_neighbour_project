import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:we_neighbour/main.dart';
import 'dart:io';
import '../constants/colors.dart';
import '../utils/auth_utils.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ResidentProfileScreen extends StatefulWidget {
  const ResidentProfileScreen({super.key});

  @override
  State<ResidentProfileScreen> createState() => _ResidentProfileScreenState();
}

class _ResidentProfileScreenState extends State<ResidentProfileScreen> {
  File? _profileImage;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _apartmentCodeController = TextEditingController(); // Renamed for consistency
  bool _isEditing = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _loadProfileImage();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _apartmentCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    try {
      final profileData = await AuthUtils.getUserProfileData();
      
      setState(() {
        _nameController.text = profileData['name'] ?? '';
        _emailController.text = profileData['email'] ?? '';
        _phoneController.text = profileData['phone'] ?? '';
        _apartmentCodeController.text = profileData['apartmentCode'] ?? ''; // Use apartmentCode
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading profile data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadProfileImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final imagePath = prefs.getString('resident_profile_image');
      if (imagePath != null) {
        final file = File(imagePath);
        if (await file.exists()) {
          setState(() {
            _profileImage = file;
          });
        }
      }
    } catch (e) {
      print('Error loading profile image: $e');
    }
  }

  Future<void> _saveProfileData() async {
    try {
      await AuthUtils.saveUserProfileData(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        apartment: _apartmentCodeController.text.trim(), // Use apartmentCode
      );
    } catch (e) {
      print('Error saving profile data: $e');
      throw e;
    }
  }

  Future<void> _pickImage() async {
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
        final fileName = 'resident_profile_${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}';
        final savedImage = File('${directory.path}/$fileName');

        await savedImage.writeAsBytes(await image.readAsBytes());

        if (_profileImage != null && await _profileImage!.exists()) {
          await _profileImage!.delete();
        }

        setState(() {
          _profileImage = savedImage;
        });

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('resident_profile_image', savedImage.path);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile photo updated successfully')),
          );
        }
      }
    } catch (e) {
      print('Error picking image: $e');
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

  Future<void> _updateProfileOnServer() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
    
      if (token == null) {
        throw 'No authentication token found';
      }

      final response = await http.put(
        Uri.parse('$baseUrl/api/residents/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'apartmentComplexName': _apartmentCodeController.text.trim(), // Use apartmentCode
        }),
      );

      if (response.statusCode == 200) {
        await _saveProfileData();
        // Force a refresh of profile data after update
        await _loadProfileData();
      } else {
        throw 'Failed to update profile: ${response.statusCode}';
      }
    } catch (e) {
      print('Error updating profile on server: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
      throw e;
    }
  }

  void _toggleEdit() {
    setState(() {
      if (_isEditing) {
        if (_validateFields()) {
          _updateProfileOnServer().then((_) {
            setState(() {
              _isEditing = false;
            });
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated successfully')),
              );
            }
          }).catchError((error) {
            setState(() {
              _isEditing = true;
            });
          });
        }
      } else {
        _isEditing = true;
      }
    });
  }

  bool _validateFields() {
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return false;
    }

    if (!_isValidPhoneNumber(_phoneController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number')),
      );
      return false;
    }

    if (_apartmentCodeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your Apartment Code')),
      );
      return false;
    }

    return true;
  }

  bool _isValidPhoneNumber(String phone) {
    return RegExp(r'^(?:\+94|0)?[0-9]{9}$').hasMatch(phone);
  }

  TextInputType _getKeyboardType(String label) {
    switch (label) {
      case 'Phone Number':
        return TextInputType.phone;
      case 'Email':
        return TextInputType.emailAddress;
      case 'Apartment Code': // Updated label for consistency
        return TextInputType.text;
      default:
        return TextInputType.text;
    }
  }

  List<TextInputFormatter>? _getInputFormatters(String label) {
    switch (label) {
      case 'Phone Number':
        return [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9\+]')),
          LengthLimitingTextInputFormatter(12),
        ];
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? Colors.white : AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
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
                          color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
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
                    ? _buildEditableField(_apartmentCodeController, 'Apartment Code', isDarkMode) // Updated label
                    : _buildInfoField('Apartment Code', _apartmentCodeController.text, isDarkMode), // Updated label
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
          onTap: _isEditing ? _pickImage : null,
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
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading profile image: $error');
                        return Icon(
                          Icons.person,
                          size: 50,
                          color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        );
                      },
                    ),
                  )
                : Icon(
                    Icons.person,
                    size: 50,
                    color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
          ),
        ),
        if (_isEditing)
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
        autocorrect: false,
        textCapitalization: label == 'Name' ? TextCapitalization.words : TextCapitalization.none,
        textInputAction: TextInputAction.next,
        keyboardType: _getKeyboardType(label),
        inputFormatters: _getInputFormatters(label),
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