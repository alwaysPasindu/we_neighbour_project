import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:we_neighbour/features/maintenance/maintenance_screen.dart';
import 'dart:convert';


class ManagerMaintenanceScreen extends StatefulWidget {
  final String authToken;

  const ManagerMaintenanceScreen({Key? key, required this.authToken}) : super(key: key);

  @override
  State<ManagerMaintenanceScreen> createState() => _ManagerMaintenanceScreenState();
}

class _ManagerMaintenanceScreenState extends State<ManagerMaintenanceScreen> {
  List<MaintenanceCard> _pendingRequests = [];
  bool _isLoading = true;
  static const String baseUrl = 'http://172.20.10.3:3000'; // Match with main.dart

  @override
  void initState() {
    super.initState();
    _fetchPendingRequests();
  }

  Future<void> _fetchPendingRequests() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/maintenance/get-pending-request'),
        headers: {
          'Authorization': 'Bearer ${widget.authToken}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _pendingRequests = data.map((r) => MaintenanceCard.fromJson(r)).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load pending requests');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _markAsDone(String id) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/maintenance/mark-request/$id/done'),
        headers: {
          'Authorization': 'Bearer ${widget.authToken}',
        },
      );

      if (response.statusCode == 200) {
        _fetchPendingRequests();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request marked as done')),
        );
      } else {
        throw Exception('Failed to mark request as done');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0A1A3B) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF0A1A3B) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pending Maintenance Requests',
          style: TextStyle(
            color: isDarkMode ? const Color.fromARGB(255, 255, 255, 255) : Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingRequests.isEmpty
              ? const Center(child: Text('No pending requests'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _pendingRequests.length,
                  itemBuilder: (context, index) {
                    final request = _pendingRequests[index];
                    return Card(
                      color: isDarkMode ? Colors.grey[800] : Colors.white,
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(
                          request.title,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        subtitle: Text(
                          request.description,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        trailing: ElevatedButton(
                          onPressed: () => _markAsDone(request.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4080FF),
                          ),
                          child: const Text('Mark Done'),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}