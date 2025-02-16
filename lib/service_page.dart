import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_carousel_slider/carousel_slider.dart';
import 'models/service.dart';

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
    final prefs = await SharedPreferences.getInstance();
    final String? servicesJson = prefs.getString('services');
    if (servicesJson != null) {
      final List<dynamic> decodedServices = jsonDecode(servicesJson);
      setState(() {
        _allServices = decodedServices.map((service) => Service.fromJson(service)).toList();
        _filteredServices = List.from(_allServices);
      });
    }
  }

  Future<void> _saveServices() async {
    final prefs = await SharedPreferences.getInstance();
    final String servicesJson = jsonEncode(_allServices.map((service) => service.toJson()).toList());
    await prefs.setString('services', servicesJson);
  }

  void _addNewService() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String title = '';
        String description = '';
        String companyName = '';
        List<String> imagePaths = [];

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New Service'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(labelText: 'Title'),
                      onChanged: (value) => title = value,
                    ),
                    TextField(
                      decoration: const InputDecoration(labelText: 'Description'),
                      onChanged: (value) => description = value,
                    ),
                    TextField(
                      decoration: const InputDecoration(labelText: 'Company Name'),
                      onChanged: (value) => companyName = value,
                    ),
                    const SizedBox(height: 16),
                    if (imagePaths.isNotEmpty)
                      Container(
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: imagePaths.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(imagePaths[index]),
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
                                        imagePaths.removeAt(index);
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
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('No images selected'),
                      ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: imagePaths.length >= 5 
                          ? null 
                          : () async {
                              final ImagePicker picker = ImagePicker();
                              try {
                                final List<XFile> pickedFiles = await picker.pickMultiImage();
                                if (pickedFiles.isNotEmpty) {
                                  // Limit the number of images that can be added
                                  final int remainingSlots = 5 - imagePaths.length;
                                  final List<XFile> limitedFiles = pickedFiles.take(remainingSlots).toList();
                                  
                                  setState(() {
                                    imagePaths.addAll(limitedFiles.map((file) => file.path));
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
                                  const SnackBar(content: Text('Error selecting images. Please try again.')),
                                );
                              }
                            },
                      icon: const Icon(Icons.add_photo_alternate),
                      label: Text(
                        imagePaths.length >= 5 
                            ? 'Maximum images reached' 
                            : 'Select Images (${imagePaths.length}/5)'
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('Add'),
                  onPressed: () {
                    if (title.isNotEmpty && description.isNotEmpty && imagePaths.isNotEmpty && companyName.isNotEmpty) {
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
                      _saveServices();
                      Navigator.of(context).pop();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Services'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search services...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: Image.file(
                            File(service.imagePaths.first),
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 120,
                                width: double.infinity,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image_not_supported, size: 40),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                service.description,
                                style: TextStyle(
                                  color: Colors.grey[600],
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
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ServiceDetailsPage extends StatelessWidget {
  final Service service;

  const ServiceDetailsPage({
    Key? key,
    required this.service,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(service.title),
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
                ),
                unlimitedMode: true,
                children: service.imagePaths.map((imagePath) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Image.file(
                        File(imagePath),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.image_not_supported, size: 40),
                          );
                        },
                      );
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
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    service.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Provided by: ${service.companyName}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Booking functionality to be implemented')),
                      );
                    },
                    child: const Text('Book Now'),
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

