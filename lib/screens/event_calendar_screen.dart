import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../widgets/feature_column.dart';
import '../widgets/custom_button.dart';
import '../services/firebase_service.dart';

class EventCalendarScreen extends StatelessWidget {
  EventCalendarScreen({Key? key}) : super(key: key);

  final FirebaseService _firebaseService = FirebaseService();

  Future<void> _openGoogleCalendar() async {
    final Uri url = Uri.parse('https://calendar.google.com/');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  void _addEvent(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newEventTitle = "";
        DateTime selectedDate = DateTime.now();

        return AlertDialog(
          title: Text('Add New Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                onChanged: (value) {
                  newEventTitle = value;
                },
                decoration: InputDecoration(hintText: "Event Title"),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                child: Text("Select Date"),
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null && picked != selectedDate) {
                    selectedDate = picked;
                  }
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                if (newEventTitle.isNotEmpty) {
                  _firebaseService.addEvent(newEventTitle, selectedDate);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Calendar'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Back button and logo
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Expanded(
                    child: Center(
                      child: Image.asset(
                        'assets/we_neighbour_logo.png',
                        width: 100,
                        height: 100, // Adjust this value as needed
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Event Calendar Text
            const Text(
              'Event Calendar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firebaseService.getEvents(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  return ListView(
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;
                      DateTime date = (data['date'] as Timestamp).toDate();
                      return ListTile(
                        title: Text(data['title']),
                        subtitle: Text(DateFormat('yyyy-MM-dd').format(date)),
                      );
                    }).toList(),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icons Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FeatureColumn(
                          iconPath: 'assets/calendar_icon.png',
                          label: 'Google\nCalendar',
                          onTap: _openGoogleCalendar,
                        ),
                        FeatureColumn(
                          iconPath: 'assets/amenities_icon.png',
                          label: 'Book\nAmenities',
                          onTap: () {
                            // Handle Book Amenities tap
                          },
                        ),
                        FeatureColumn(
                          iconPath: 'assets/health_icon.png',
                          label: 'Health &\nWellness',
                          onTap: () {
                            // Handle Health & Wellness tap
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Buttons
                    CustomButton(
                      text: 'Add Event',
                      onPressed: () => _addEvent(context),
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Manage RSVPs',
                      onPressed: () {
                        // Handle Manage RSVPs
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
