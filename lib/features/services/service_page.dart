import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:we_neighbour/constants/colors.dart';
import 'package:we_neighbour/features/services/service_detailsPage.dart';
import 'package:we_neighbour/features/services/location_picker.dart';
import 'package:we_neighbour/main.dart';
import 'package:we_neighbour/models/service.dart';
import 'package:we_neighbour/providers/theme_provider.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

class ServicesPage extends StatefulWidget {
  final UserType userType;

  const ServicesPage({
    super.key,
    required this.userType,
  });

  @override
  _ServicesPageState createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  List<Service> _allServices = [];
  List<Service> _filteredServices = [];
  final ScrollController _scrollController = ScrollController();
  String _currentUserId = '';
  bool _isLoading = false;
  String? _token;
  double? _userLatitude;
  double? _userLongitude;
  String _locationAddress = 'Unknown Location';

  @override
  void initState() {
    super.initState();
    _initializeData();
    _getCurrentLocation();
  }

  Future<void> _initializeData() async {
    await _loadUserData();
    await _loadServices();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _userLatitude = 6.9271;
      _userLongitude = 79.8612;
    });
    await _fetchLocationAddress(_userLatitude!, _userLongitude!);
  }

  Future<void> _fetchLocationAddress(double latitude, double longitude) async {
    try {
      final placemarks = await geocoding.placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        setState(() {
          _locationAddress = '${placemark.street}, ${placemark.locality}, ${placemark.country}' ?? 'Unknown Location';
        });
      }
    } catch (e) {
      print('Error fetching location address: $e');
      setState(() {
        _locationAddress = 'Unknown Location';
      });
    }
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _currentUserId = prefs.getString('userId') ?? '';
        _token = prefs.getString('token');
      });
      print('Token loaded: $_token');
      if (_token == null || _token!.isEmpty) {
        print('No token found in SharedPreferences');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in again')));
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading user data: $e')));
      }
    }
  }

  Future<void> _loadServices() async {
    if (_token == null) {
      print('No authentication token found');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final queryParams = {
        'latitude': _userLatitude?.toString() ?? '',
        'longitude': _userLongitude?.toString() ?? '',
      };

      final uri = Uri.parse('$baseUrl/api/services').replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('Load services response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> servicesJson = jsonDecode(response.body) as List<dynamic>;
        final services = servicesJson.map((json) => Service.fromJson(json as Map<String, dynamic>)).toList();
        setState(() {
          _allServices = services;
          _filteredServices = List.from(_allServices);
        });
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('services', jsonEncode(services.map((s) => s.toJson()).toList()));
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Invalid or expired token');
      } else {
        throw Exception('Failed to load services: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error loading services: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading services: $e')));
        if (e.toString().contains('Unauthorized')) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteService(Service service) async {
    if (_token == null) {
      print('No authentication token found');
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/services/${service.id}'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );

      print('Delete service response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          _allServices.removeWhere((s) => s.id == service.id);
          _filteredServices = List.from(_allServices);
        });
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('services', jsonEncode(_allServices.map((s) => s.toJson()).toList()));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Service deleted successfully')));
          // Notify ProviderHomePage to refresh
          if (ModalRoute.of(context)?.settings.name == '/provider-home') {
            _loadServices(); // Refresh ProviderHomePage if it's the current page
          }
        }
      } else {
        throw Exception('Failed to delete service: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error deleting service: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting service: $e')));
      }
    }
  }

  void _showDeleteDialog(Service service) {
    final isDarkMode = Provider.of<ThemeProvider>(context, listen: false).themeMode == ThemeMode.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
          title: Text('Delete Service', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
          content: Text('Are you sure you want to delete this service?', style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87)),
          actions: [
            TextButton(
              child: Text('Cancel', style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600])),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('Delete'),
              onPressed: () {
                Navigator.pop(context);
                _deleteService(service);
              },
            ),
          ],
        );
      },
    );
  }

  void _editService(Service service) {
    String title = service.title;
    String description = service.description;
    String address = service.location.address;
    String availableHours = service.availableHours;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      decoration: const InputDecoration(labelText: 'Title'),
                      controller: TextEditingController(text: title),
                      onChanged: (value) => title = value,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(labelText: 'Description'),
                      controller: TextEditingController(text: description),
                      maxLines: 3,
                      onChanged: (value) => description = value,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(labelText: 'Address'),
                      controller: TextEditingController(text: address),
                      onChanged: (value) => address = value,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(labelText: 'Available Hours'),
                      controller: TextEditingController(text: availableHours),
                      onChanged: (value) => availableHours = value,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          final response = await http.put(
                            Uri.parse('$baseUrl/api/services/${service.id}'),
                            headers: {
                              'Authorization': 'Bearer $_token',
                              'Content-Type': 'application/json',
                            },
                            body: jsonEncode({
                              'title': title,
                              'description': description,
                              'location': {
                                'type': 'Point',
                                'coordinates': [service.location.coordinates[0], service.location.coordinates[1]],
                                'address': address,
                              },
                              'availableHours': availableHours,
                            }),
                          );

                          if (response.statusCode == 200) {
                            Navigator.pop(context);
                            await _loadServices();
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setString('services', jsonEncode(_allServices.map((s) => s.toJson()).toList()));
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Service updated successfully')));
                            // Notify ProviderHomePage to refresh
                            if (ModalRoute.of(context)?.settings.name == '/provider-home') {
                              _loadServices(); // Refresh ProviderHomePage if it's the current page
                            }
                          } else {
                            throw Exception('Failed to update service: ${response.statusCode}');
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<bool> _checkServerConnection() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'), headers: {'Content-Type': 'application/json'}).timeout(const Duration(seconds: 5));
      print('Server health check: ${response.statusCode} - ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('Server health check failed: $e');
      return false;
    }
  }

  void _addNewService() {
    final isDarkMode = Provider.of<ThemeProvider>(context, listen: false).themeMode == ThemeMode.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        String title = '';
        String description = '';
        double latitude = _userLatitude ?? 0.0;
        double longitude = _userLongitude ?? 0.0;
        String availableHours = '';
        List<XFile> imageFiles = [];
        bool _isLoading = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Add New Service', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
                      const SizedBox(height: 24),
                      TextField(
                        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Title',
                          labelStyle: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                          filled: true,
                          fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        onChanged: (value) => title = value,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Description',
                          labelStyle: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                          filled: true,
                          fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        maxLines: 3,
                        onChanged: (value) => description = value,
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () async {
                          final gmaps.LatLng? selectedLocation = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LocationPicker(initialLatitude: latitude, initialLongitude: longitude)),
                          );
                          if (selectedLocation != null) {
                            setDialogState(() {
                              latitude = selectedLocation.latitude;
                              longitude = selectedLocation.longitude;
                            });
                            await _fetchLocationAddress(latitude, longitude);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: isDarkMode ? Colors.grey[800] : Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Lat: ${latitude.toStringAsFixed(4)}, Lng: ${longitude.toStringAsFixed(4)}', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
                              Icon(Icons.map, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Location Address: $_locationAddress',
                        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () async {
                          final TimeOfDay? pickedStart = await showTimePicker(context: context, initialTime: TimeOfDay.now(), builder: (context, child) => Theme(data: isDarkMode ? ThemeData.dark() : ThemeData.light(), child: child!));
                          if (pickedStart != null) {
                            final TimeOfDay? pickedEnd = await showTimePicker(context: context, initialTime: pickedStart, builder: (context, child) => Theme(data: isDarkMode ? ThemeData.dark() : ThemeData.light(), child: child!));
                            if (pickedEnd != null) {
                              setDialogState(() {
                                availableHours = '${pickedStart.format(context)} - ${pickedEnd.format(context)}';
                              });
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: isDarkMode ? Colors.grey[800] : Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(availableHours.isEmpty ? 'Select Available Hours' : availableHours, style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
                              Icon(Icons.access_time, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text('Service Images', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
                      const SizedBox(height: 8),
                      Container(
                        height: 120,
                        decoration: BoxDecoration(color: isDarkMode ? Colors.grey[800] : Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                        child: Stack(
                          children: [
                            if (imageFiles.isEmpty)
                              Center(
                                child: IconButton(
                                  icon: Icon(Icons.add_photo_alternate, size: 40, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                                  onPressed: () async {
                                    final picker = ImagePicker();
                                    final pickedFiles = await picker.pickMultiImage();
                                    if (pickedFiles != null) {
                                      setDialogState(() {
                                        imageFiles.addAll(pickedFiles);
                                      });
                                    }
                                  },
                                ),
                              )
                            else
                              ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: imageFiles.length + 1,
                                itemBuilder: (context, index) {
                                  if (index == imageFiles.length) {
                                    return Center(
                                      child: IconButton(
                                        icon: Icon(Icons.add_photo_alternate, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                                        onPressed: () async {
                                          final picker = ImagePicker();
                                          final pickedFiles = await picker.pickMultiImage();
                                          if (pickedFiles != null) {
                                            setDialogState(() {
                                              imageFiles.addAll(pickedFiles);
                                            });
                                          }
                                        },
                                      ),
                                    );
                                  }
                                  return Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(imageFiles[index].path), height: 112, width: 112, fit: BoxFit.cover)),
                                      ),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: IconButton(
                                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                                          onPressed: () {
                                            setDialogState(() {
                                              imageFiles.removeAt(index);
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            child: Text('Cancel', style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600])),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () async {
                              if (_token == null) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not authenticated')));
                                  Navigator.pushReplacementNamed(context, '/login');
                                }
                                return;
                              }

                              if (title.isEmpty || description.isEmpty || imageFiles.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields')));
                                return;
                              }

                              setDialogState(() {
                                _isLoading = true;
                              });

                              try {
                                final isServerConnected = await _checkServerConnection();
                                if (!isServerConnected) {
                                  throw Exception('Server is not reachable. Please check your network or server status.');
                                }

                                List<String> imagePaths = [];
                                for (var file in imageFiles) {
                                  final String savedPath = await _saveImageToAppDirectory(file);
                                  imagePaths.add(savedPath);
                                }

                                final companyName = await _getCompanyName();

                                final requestBody = {
                                  'title': title,
                                  'description': description,
                                  'images': imagePaths,
                                  'location': {
                                    'type': 'Point',
                                    'coordinates': [longitude, latitude],
                                    'address': _locationAddress,
                                  },
                                  'serviceProviderName': companyName,
                                  'availableHours': availableHours,
                                };

                                print('Adding service with body: $requestBody');
                                print('Using token: $_token');

                                final response = await http.post(
                                  Uri.parse('$baseUrl/api/services'),
                                  headers: {
                                    'Authorization': 'Bearer $_token',
                                    'Content-Type': 'application/json',
                                  },
                                  body: jsonEncode(requestBody),
                                ).timeout(const Duration(seconds: 15));

                                print('Add service response: ${response.statusCode} - ${response.body}');

                                if (response.statusCode == 201) {
                                  await _loadServices();
                                  final prefs = await SharedPreferences.getInstance();
                                  await prefs.setString('services', jsonEncode(_allServices.map((s) => s.toJson()).toList()));
                                  if (mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Service added successfully')));
                                    // Notify ProviderHomePage to refresh
                                    if (ModalRoute.of(context)?.settings.name == '/provider-home') {
                                      _loadServices(); // Refresh ProviderHomePage if it's the current page
                                    }
                                  }
                                } else {
                                  try {
                                    final errorData = jsonDecode(response.body);
                                    throw Exception(errorData['message'] ?? 'Failed to add service: ${response.statusCode}');
                                  } catch (e) {
                                    throw Exception('Failed to add service: ${response.statusCode} - ${response.body}');
                                  }
                                }
                              } catch (e) {
                                print('Error adding service: $e');
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                                }
                              } finally {
                                if (mounted) {
                                  setDialogState(() {
                                    _isLoading = false;
                                  });
                                }
                              }
                            },
                            child: _isLoading
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white), strokeWidth: 2))
                                : const Text('Add Service'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<String> _saveImageToAppDirectory(XFile imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = path.basename(imageFile.path);
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(await imageFile.readAsBytes());
    return file.path;
  }

  Future<String> _getCompanyName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName') ?? 'Company Name';
  }

  Widget _buildServiceCard(Service service, bool isDarkMode) {
    final bool isOwnService = service.serviceProviderId == _currentUserId;
    final bool canManageService = widget.userType == UserType.serviceProvider && isOwnService;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ServiceDetailsPage(service: service, isOwnService: isOwnService, userType: widget.userType)));
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.file(File(service.imagePaths.first), fit: BoxFit.cover),
                  ),
                ),
                if (canManageService)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        children: [
                          IconButton(icon: const Icon(Icons.edit, color: Colors.white, size: 20), onPressed: () => _editService(service)),
                          IconButton(icon: const Icon(Icons.delete, color: Colors.white, size: 20), onPressed: () => _showDeleteDialog(service)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(service.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
                  const SizedBox(height: 8),
                  Text(service.description, style: TextStyle(fontSize: 14, color: isDarkMode ? Colors.grey[300] : Colors.grey[600]), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(child: Text(service.location.address, style: TextStyle(fontSize: 12, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(service.availableHours, style: TextStyle(fontSize: 12, color: isDarkMode ? Colors.grey[400] : Colors.grey[600])),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (widget.userType == UserType.serviceProvider) {
              Navigator.pushReplacementNamed(context, '/provider-home');
            } else {
              Navigator.pushReplacementNamed(context, '/home', arguments: widget.userType);
            }
          },
        ),
        title: const Text('Services'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadServices)],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadServices,
              child: _allServices.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.business_center_outlined, size: 64, color: isDarkMode ? Colors.grey[600] : Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text('No services available', style: TextStyle(fontSize: 18, color: isDarkMode ? Colors.grey[400] : Colors.grey[600])),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: _allServices.length,
                      itemBuilder: (context, index) => _buildServiceCard(_allServices[index], isDarkMode),
                    ),
            ),
      floatingActionButton: widget.userType == UserType.serviceProvider
          ? FloatingActionButton.extended(
              onPressed: _addNewService,
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Add Service', style: TextStyle(color: Colors.white)),
            )
          : null,
    );
  }
}