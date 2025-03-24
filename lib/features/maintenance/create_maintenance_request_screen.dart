import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:we_neighbour/main.dart';
import 'dart:convert';
import 'package:logger/logger.dart';

class CreateMaintenanceRequestScreen extends StatefulWidget {
  final String authToken;

  const CreateMaintenanceRequestScreen({
    super.key,
    required this.authToken,
  });

  @override
  State<CreateMaintenanceRequestScreen> createState() =>
      _CreateMaintenanceRequestScreenState();
}

class _CreateMaintenanceRequestScreenState
    extends State<CreateMaintenanceRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;
  final Logger logger = Logger();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final headers = {
          'Content-Type': 'application/json',
          'x-auth-token': widget.authToken,
        };
        final body = jsonEncode({
          'title': _titleController.text,
          'description': _descriptionController.text,
          'status': 'pending',
        });
        logger.d('Submitting request with headers: $headers');
        logger.d('Request body: $body');
        final response = await http
            .post(
              Uri.parse('$baseUrl/api/maintenance/create-request'),
              headers: headers,
              body: body,
            )
            .timeout(const Duration(seconds: 15));

        logger.d('Create response: ${response.statusCode} - ${response.body}');

        if (response.statusCode == 201) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Maintenance request submitted successfully',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.green.shade700,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                duration: const Duration(seconds: 3),
              ),
            );
            Navigator.pop(context, true);
          }
        } else {
          final data = jsonDecode(response.body);
          throw Exception(data['message'] ?? 'Failed to create request');
        }
      } on TimeoutException {
        logger.d('Create request timed out');
        throw Exception('Request timed out. Please check your network.');
      } catch (e) {
        logger.d('Error creating request: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Error: ${e.toString()}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = const Color(0xFF4080FF);

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0A1A3B) : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF0A1A3B) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDarkMode ? Colors.white : Colors.black87,
            size: 22,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'New Maintenance Request',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF0F2445) : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.home_repair_service_rounded,
                          color: primaryColor,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Submit a new request',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please provide detailed information about your maintenance issue',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Request Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildLabel('Title'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleController,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              'Enter the title of your maintenance request',
                          hintStyle: TextStyle(
                            color: isDarkMode ? Colors.white60 : Colors.black45,
                            fontSize: 15,
                          ),
                          filled: true,
                          fillColor: isDarkMode
                              ? Colors.grey[800]!.withOpacity(0.5)
                              : Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: primaryColor,
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.red.shade400,
                              width: 1.5,
                            ),
                          ),
                          prefixIcon: Icon(
                            Icons.title_rounded,
                            color:
                                isDarkMode ? Colors.white70 : Colors.grey[600],
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildLabel('Description'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontSize: 16,
                        ),
                        maxLines: 6,
                        decoration: InputDecoration(
                          hintText: 'Describe your maintenance issue in detail',
                          hintStyle: TextStyle(
                            color: isDarkMode ? Colors.white60 : Colors.black45,
                            fontSize: 15,
                          ),
                          filled: true,
                          fillColor: isDarkMode
                              ? Colors.grey[800]!.withOpacity(0.5)
                              : Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: primaryColor,
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.red.shade400,
                              width: 1.5,
                            ),
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(bottom: 80),
                            child: Icon(
                              Icons.description_rounded,
                              color: isDarkMode
                                  ? Colors.white70
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 36),
                      Container(
                        width: double.infinity,
                        height: 56,
                        margin: const EdgeInsets.only(bottom: 24),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitRequest,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.send_rounded, size: 20),
                                    const SizedBox(width: 10),
                                    const Text('Submit Request'),
                                  ],
                                ),
                        ),
                      ),
                      if (!isDarkMode)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.blue.shade100,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: Colors.blue.shade700,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Our maintenance team typically responds within 24-48 hours of submission.',
                                  style: TextStyle(
                                    color: Colors.blue.shade800,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDarkMode ? Colors.white70 : Colors.black87,
        ),
      ),
    );
  }
}
