import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_carousel_slider/carousel_slider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import '../models/service.dart';
import '../providers/theme_provider.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({Key? key}) : super(key: key);

  @override
  _ServicesPageState createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  List<Service> _allServices = [];
  List<Service> _filteredServices = [];
  final ScrollController _scrollController = ScrollController();
  final String currentUserId = 'user123';

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? servicesJson = prefs.getString('services');
      if (servicesJson != null) {
        final List<dynamic> decodedServices = jsonDecode(servicesJson);
        setState(() {
          _allServices = decodedServices.map((service) => Service.fromJson(service)).toList();
          _filteredServices = List.from(_allServices);
        });
      }
    } catch (e) {
      print('Error loading services: $e');
    }
  }

  Future<void> _saveServices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String servicesJson = jsonEncode(_allServices.map((service) => service.toJson()).toList());
      await prefs.setString('services', servicesJson);
    } catch (e) {
      print('Error saving services: $e');
    }
  }

  Future<String> _saveImageToAppDirectory(XFile file) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}';
      final savedImage = File('${appDir.path}/$fileName');
      
      await file.saveTo(savedImage.path);
      
      return savedImage.path;
    } catch (e) {
      print('Error saving image: $e');
      throw Exception('Failed to save image');
    }
  }

  Widget _buildServiceImage(String imagePath) {
    return FutureBuilder<bool>(
      future: File(imagePath).exists(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data == true) {
            return Image.file(
              File(imagePath),
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print('Error loading image: $error');
                return _buildPlaceholderImage();
              },
            );
          } else {
            print('Image file does not exist: $imagePath');
            return _buildPlaceholderImage();
          }
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  Widget _buildPlaceholderImage() {
    final isDarkMode = Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark;
    return Container(
      height: 120,
      width: double.infinity,
      color: isDarkMode ? const Color(0xFF404040) : const Color(0xFFD7D7D7),
      child: Icon(
        Icons.image_not_supported,
        size: 40,
        color: isDarkMode ? Colors.grey[400] : const Color(0xFF202020),
      ),
    );
  }

  void _addNewService() {
    final isDarkMode = Provider.of<ThemeProvider>(context, listen: false).themeMode == ThemeMode.dark;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String title = '';
        String description = '';
        String companyName = '';
        List<XFile> imageFiles = [];

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
              title: Text(
                'Add New Service',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Title',
                        labelStyle: TextStyle(
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                          ),
                        ),
                      ),
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      onChanged: (value) => title = value,
                    ),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: TextStyle(
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                          ),
                        ),
                      ),
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      onChanged: (value) => description = value,
                    ),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Company Name',
                        labelStyle: TextStyle(
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                          ),
                        ),
                      ),
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      onChanged: (value) => companyName = value,
                    ),
                    const SizedBox(height: 16),
                    if (imageFiles.isNotEmpty)
                      Container(
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: imageFiles.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(imageFiles[index].path),
                                      height: 80,
                                      width: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: IconButton(
                                    icon: const Icon(Icons.close, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        imageFiles.removeAt(index);
                                      });
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'No images selected',
                          style: TextStyle(
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDarkMode ? const Color(0xFF004CFF) : const Color(0xFF0C78F8),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: imageFiles.length >= 5 
                          ? null 
                          : () async {
                              final ImagePicker picker = ImagePicker();
                              try {
                                final List<XFile> pickedFiles = await picker.pickMultiImage();
                                if (pickedFiles.isNotEmpty) {
                                  final int remainingSlots = 5 - imageFiles.length;
                                  final List<XFile> limitedFiles = pickedFiles.take(remainingSlots).toList();
                                  
                                  setState(() {
                                    imageFiles.addAll(limitedFiles);
                                  });

                                  if (pickedFiles.length > remainingSlots) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Maximum 5 images allowed')),
                                    );
                                  }
                                }
                              } catch (e) {
                                print('Error picking images: $e');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Error selecting images')),
                                );
                              }
                            },
                      icon: const Icon(Icons.add_photo_alternate),
                      label: Text(
                        imageFiles.length >= 5 
                            ? 'Maximum images reached' 
                            : 'Select Images (${imageFiles.length}/5)'
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: Text(
                    'Add',
                    style: TextStyle(
                      color: isDarkMode ? const Color(0xFF004CFF) : const Color(0xFF0C78F8),
                    ),
                  ),
                  onPressed: () async {
                    if (title.isNotEmpty && description.isNotEmpty && imageFiles.isNotEmpty && companyName.isNotEmpty) {
                      try {
                        List<String> imagePaths = [];
                        for (var file in imageFiles) {
                          final String savedPath = await _saveImageToAppDirectory(file);
                          imagePaths.add(savedPath);
                        }
                        
                        final newService = Service(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: title,
                          description: description,
                          imagePaths: imagePaths,
                          userId: currentUserId,
                          companyName: companyName,
                        );

                        setState(() {
                          _allServices.insert(0, newService);
                          _filteredServices = List.from(_allServices);
                        });
                        await _saveServices();
                        Navigator.of(context).pop();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error saving service: $e')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all fields and select at least one image')),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Services',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFF4B7DFF),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search services...',
                hintStyle: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFFCF9F9),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                  ),
                ),
              ),
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              onChanged: (query) {
                setState(() {
                  _filteredServices = _allServices
                      .where((service) =>
                          service.title.toLowerCase().contains(query.toLowerCase()) ||
                          service.description.toLowerCase().contains(query.toLowerCase()))
                      .toList();
                });
              },
            ),
          ),
          Expanded(
            child: GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: _filteredServices.length,
              itemBuilder: (context, index) {
                final service = _filteredServices[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ServiceDetailsPage(service: service),
                      ),
                    );
                  },
                  child: Card(
                    color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: _buildServiceImage(service.imagePaths.first),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isDarkMode ? Colors.white : const Color(0xFF202020),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                service.description,
                                style: TextStyle(
                                  color: isDarkMode ? Colors.grey[400] : const Color(0xFF1E1E1E),
                                  fontSize: 12,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewService,
        backgroundColor: isDarkMode ? const Color(0xFF004CFF) : const Color(0xFF0C78F8),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class ServiceDetailsPage extends StatelessWidget {
  final Service service;

  const ServiceDetailsPage({
    super.key,
    required this.service,
  });

  Widget _buildServiceImage(String imagePath) {
    return FutureBuilder<bool>(
      future: File(imagePath).exists(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data == true) {
            return Image.file(
              File(imagePath),
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                print('Error loading image: $error');
                return _buildPlaceholderImage(context);
              },
            );
          } else {
            print('Image file does not exist: $imagePath');
            return _buildPlaceholderImage(context);
          }
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  Widget _buildPlaceholderImage(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark;
    return Container(
      color: isDarkMode ? const Color(0xFF404040) : const Color(0xFFD7D7D7),
      child: Icon(
        Icons.image_not_supported,
        size: 40,
        color: isDarkMode ? Colors.grey[400] : const Color(0xFF202020),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          service.title,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFF004CFF),
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 200,
              child: CarouselSlider(
                slideTransform: const CubeTransform(),
                slideIndicator: CircularSlideIndicator(
                  padding: const EdgeInsets.only(bottom: 32),
                  indicatorBackgroundColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                  currentIndicatorColor: isDarkMode ? Colors.white : const Color(0xFF004CFF),
                ),
                unlimitedMode: true,
                children: service.imagePaths.map((imagePath) {
                  return Builder(
                    builder: (BuildContext context) {
                      return _buildServiceImage(imagePath);
                    },
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : const Color(0xFF202020),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    service.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.grey[400] : const Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Provided by: ${service.companyName}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : const Color(0xFF202020),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}