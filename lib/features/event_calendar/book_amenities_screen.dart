import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:we_neighbour/features/event_calendar/firebase_service.dart';
import 'package:logger/logger.dart';

class BookAmenitiesScreen extends StatefulWidget {
  const BookAmenitiesScreen({super.key});

  @override
  State<BookAmenitiesScreen> createState() => _BookAmenitiesScreenState(); // Made public by using State<BookAmenitiesScreen>
}

class _BookAmenitiesScreenState extends State<BookAmenitiesScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final Logger logger = Logger();
  final List<Map<String, dynamic>> _amenities = [
    {'name': 'Gym', 'icon': Icons.fitness_center},
    {'name': 'Ground', 'icon': Icons.sports_soccer},
    {'name': 'Rooftop', 'icon': Icons.deck},
    {'name': 'Pool', 'icon': Icons.pool},
    {'name': 'Tennis Court', 'icon': Icons.sports_tennis},
    {'name': 'Basketball Court', 'icon': Icons.sports_basketball},
    {'name': 'Party Hall', 'icon': Icons.celebration},
    {'name': 'Other', 'icon': Icons.add_circle_outline},
  ];

  void _bookAmenity(BuildContext context, String amenityName) {
    DateTime selectedDate = DateTime.now();
    TimeOfDay startTime = TimeOfDay.now();
    TimeOfDay endTime = TimeOfDay(
      hour: startTime.hour + 1,
      minute: startTime.minute,
    );
    String notes = "";
    String customAmenity = "";

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) { // Renamed context to dialogContext for clarity
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                  'Book ${amenityName == 'Other' ? 'Custom Amenity' : amenityName}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (amenityName == 'Other')
                      TextField(
                        onChanged: (value) {
                          customAmenity = value;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Amenity Name',
                          hintText: 'Enter custom amenity name',
                        ),
                      ),
                    const SizedBox(height: 16),
                    const Text('Select Date:'),
                    OutlinedButton(
                      child: Text(
                        DateFormat('EEEE, MMMM d, yyyy').format(selectedDate),
                        style: const TextStyle(fontSize: 16),
                      ),
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null && picked != selectedDate) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Start Time:'),
                              OutlinedButton(
                                child: Text(
                                  startTime.format(context),
                                  style: const TextStyle(fontSize: 16),
                                ),
                                onPressed: () async {
                                  final TimeOfDay? picked =
                                      await showTimePicker(
                                    context: context,
                                    initialTime: startTime,
                                  );
                                  if (picked != null && picked != startTime) {
                                    setState(() {
                                      startTime = picked;
                                      // Ensure end time is after start time
                                      if (_timeToDouble(endTime) <=
                                          _timeToDouble(startTime)) {
                                        endTime = TimeOfDay(
                                          hour: startTime.hour + 1,
                                          minute: startTime.minute,
                                        );
                                      }
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('End Time:'),
                              OutlinedButton(
                                child: Text(
                                  endTime.format(context),
                                  style: const TextStyle(fontSize: 16),
                                ),
                                onPressed: () async {
                                  final TimeOfDay? picked =
                                      await showTimePicker(
                                    context: context,
                                    initialTime: endTime,
                                  );
                                  if (picked != null && picked != endTime) {
                                    setState(() {
                                      if (_timeToDouble(picked) >
                                          _timeToDouble(startTime)) {
                                        endTime = picked;
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'End time must be after start time'),
                                          ),
                                        );
                                      }
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      onChanged: (value) {
                        notes = value;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Notes (Optional)',
                        hintText: 'Add any special requests or notes',
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
                TextButton(
                  child: const Text('Book'),
                  onPressed: () async {
                    final String finalAmenityName =
                        amenityName == 'Other' ? customAmenity : amenityName;

                    if (amenityName == 'Other' && customAmenity.isEmpty) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Please enter a custom amenity name')),
                      );
                      return;
                    }

                    // Create start and end DateTime objects
                    final DateTime startDateTime = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      startTime.hour,
                      startTime.minute,
                    );

                    final DateTime endDateTime = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      endTime.hour,
                      endTime.minute,
                    );

                    try {
                      await _firebaseService.bookAmenity(
                        finalAmenityName,
                        startDateTime,
                        endDateTime,
                        notes,
                      );

                      if (!dialogContext.mounted) return; // Check if dialog is still mounted
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                            content:
                                Text('$finalAmenityName booked successfully')),
                      );
                      Navigator.of(dialogContext).pop();
                      if (!mounted) return; // Check if widget is still mounted
                      Navigator.of(context).pop(); // Go back to calendar screen
                    } catch (e) {
                      logger.d('Error booking amenity: $e');
                      if (!dialogContext.mounted) return; // Check if dialog is still mounted
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(content: Text('Failed to book amenity: $e')),
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

  // Helper method to convert TimeOfDay to double for comparison
  double _timeToDouble(TimeOfDay time) {
    return time.hour + time.minute / 60.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Amenities'),
        backgroundColor: const Color(0xFF0A1A3B),
      ),
      body: Container(
        color: const Color(0xFF0A1A3B),
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Select an Amenity to Book',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: _amenities.length,
                  itemBuilder: (context, index) {
                    return _buildAmenityCard(
                      _amenities[index]['name'],
                      _amenities[index]['icon'],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmenityCard(String name, IconData icon) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: InkWell(
        onTap: () => _bookAmenity(context, name),
        borderRadius: BorderRadius.circular(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48.0,
              color: const Color(0xFF0A1A3B),
            ),
            const SizedBox(height: 12.0),
            Text(
              name,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}