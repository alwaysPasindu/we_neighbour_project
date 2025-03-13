import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../widgets/feature_column.dart';
import '../widgets/custom_button.dart';
import '../services/firebase_service.dart';
// Import screens
import '../screens/book_amenities_screen.dart';
import '../screens/health_wellness_screen.dart';

class EventCalendarScreen extends StatefulWidget {
  const EventCalendarScreen({Key? key}) : super(key: key);

  @override
  _EventCalendarScreenState createState() => _EventCalendarScreenState();
}

class _EventCalendarScreenState extends State<EventCalendarScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  String _activeView = 'calendar'; // 'calendar' or 'list'
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  Map<DateTime, List<dynamic>> _events = {};
  bool _isLoading = true;
  StreamSubscription<QuerySnapshot>? _eventsSubscription;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadEvents();
  }

  @override
  void dispose() {
    _eventsSubscription?.cancel();
    super.dispose();
  }

  void _loadEvents() {
    setState(() {
      _isLoading = true;
    });

    try {
      _eventsSubscription = _firebaseService.getEvents().listen(
        (QuerySnapshot snapshot) {
          final Map<DateTime, List<dynamic>> newEvents = {};

          print('Received ${snapshot.docs.length} events from Firestore');

          for (var doc in snapshot.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final DateTime date = (data['date'] as Timestamp).toDate();
            // Normalize date to remove time component for proper comparison
            final DateTime normalizedDate =
                DateTime(date.year, date.month, date.day);

            if (newEvents[normalizedDate] != null) {
              newEvents[normalizedDate]!.add({
                'id': doc.id,
                'title': data['title'],
                'date': date,
                'type': data['type'] ?? 'event', // Add event type with default
                'endTime': data['endTime'] != null
                    ? (data['endTime'] as Timestamp).toDate()
                    : null, // Add endTime
                'notes': data['notes'], // Add notes
              });
            } else {
              newEvents[normalizedDate] = [
                {
                  'id': doc.id,
                  'title': data['title'],
                  'date': date,
                  'type':
                      data['type'] ?? 'event', // Add event type with default
                  'endTime': data['endTime'] != null
                      ? (data['endTime'] as Timestamp).toDate()
                      : null, // Add endTime
                  'notes': data['notes'], // Add notes
                }
              ];
            }
          }

          if (mounted) {
            setState(() {
              _events = newEvents;
              _isLoading = false;
            });
          }
        },
        onError: (error) {
          print('Error loading events: $error');
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        },
      );
    } catch (e) {
      print('Exception in _loadEvents: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    // Normalize date to remove time component
    final normalizedDate = DateTime(day.year, day.month, day.day);

    // Get events for this day
    final eventsForDay = _events[normalizedDate] ?? [];

    // If the day is today or in the future, return all events
    // If the day is in the past, only return events for display purposes (not for "upcoming")
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (normalizedDate.isBefore(today)) {
      // For past days in the calendar, we still show the events (just with markers)
      return eventsForDay;
    } else if (normalizedDate.isAtSameMomentAs(today)) {
      // For today, filter out events that have already passed
      return eventsForDay.where((event) {
        final eventTime = event['date'] as DateTime;
        return eventTime.isAfter(now);
      }).toList();
    } else {
      // For future days, show all events
      return eventsForDay;
    }
  }

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
        TimeOfDay selectedTime = TimeOfDay.now();
        TimeOfDay? selectedEndTime; // Added for endTime
        String? eventNotes; // Added for notes

        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: const Text('Add New Event'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    onChanged: (value) {
                      newEventTitle = value;
                    },
                    decoration: const InputDecoration(hintText: "Event Title"),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        child: const Text("Select Date"),
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
                      ElevatedButton(
                        child: const Text("Select Time"),
                        onPressed: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                          );
                          if (picked != null && picked != selectedTime) {
                            setState(() {
                              selectedTime = picked;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    child: const Text("Select End Time (Optional)"),
                    onPressed: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          selectedEndTime = picked;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    onChanged: (value) {
                      eventNotes = value;
                    },
                    decoration:
                        const InputDecoration(hintText: "Notes (Optional)"),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Add'),
                onPressed: () async {
                  if (newEventTitle.isNotEmpty) {
                    final DateTime eventDateTime = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      selectedTime.hour,
                      selectedTime.minute,
                    );

                    // Create eventEndTime only if selectedEndTime is not null
                    DateTime? eventEndTime;
                    if (selectedEndTime != null) {
                      eventEndTime = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                      );
                    }

                    try {
                      await _firebaseService.addEvent(newEventTitle,
                          eventDateTime, eventEndTime, eventNotes, 'event');

                      // After adding the event, refresh the calendar view
                      setState(() {
                        _selectedDay = selectedDate;
                        _focusedDay = selectedDate;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Event added successfully')),
                      );
                    } catch (e) {
                      print('Error adding event: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to add event: $e')),
                      );
                    }

                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          );
        });
      },
    );
  }

  void _deleteEvent(BuildContext context, String eventId, String eventTitle) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Event'),
          content: Text('Are you sure you want to delete "$eventTitle"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
              onPressed: () async {
                try {
                  await _firebaseService.deleteEvent(eventId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Event deleted successfully')),
                  );
                } catch (e) {
                  print('Error deleting event: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete event: $e')),
                  );
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showEventDetails(BuildContext context, Map<String, dynamic> event) {
    final String eventType = event['type'] ?? 'event';
    final bool isAmenity = eventType == 'amenity';
    final bool isHealth = eventType == 'health';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      event['title'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      Navigator.pop(context); // Close the bottom sheet
                      _deleteEvent(context, event['id'], event['title']);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Date: ${DateFormat('EEEE, MMMM d, yyyy').format(event['date'])}',
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                'Time: ${DateFormat('h:mm a').format(event['date'])}',
                style: const TextStyle(fontSize: 16),
              ),

              // Show additional details for amenity or health bookings
              if ((isAmenity || isHealth) && event['endTime'] != null) ...[
                Text(
                  'End Time: ${DateFormat('h:mm a').format(event['endTime'])}',
                  style: const TextStyle(fontSize: 16),
                ),
                if (event['notes'] != null &&
                    event['notes'].toString().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Notes:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          event['notes'],
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
              ],

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A1A3B),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Navigate to BookAmenitiesScreen
  void _openAmenitiesBooking() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BookAmenitiesScreen()),
    );
  }

  // Navigate to HealthWellnessScreen
  void _openHealthWellness() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HealthWellnessScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFF0A1A3B),
        child: SafeArea(
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
                    const Spacer(),
                    Image.asset(
                      'assets/we_neighbour_logo.png',
                      height: 40,
                      fit: BoxFit.contain,
                    ),
                    const Spacer(),
                    const SizedBox(width: 48), // Balance for back button
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Event Calendar Text
              const Text(
                'Event Calendar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // Toggle buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildToggleButton('Calendar', 'calendar'),
                        _buildToggleButton('List', 'list'),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Main content
              if (_isLoading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                )
              else
                Expanded(
                  child: _activeView == 'calendar'
                      ? _buildCalendarView()
                      : _buildListView(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarView() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            eventLoader: _getEventsForDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              leftChevronIcon: Icon(Icons.chevron_left, size: 28),
              rightChevronIcon: Icon(Icons.chevron_right, size: 28),
            ),
            calendarStyle: CalendarStyle(
              markersMaxCount: 3,
              markerDecoration: BoxDecoration(
                color: Colors.blue.shade700,
                shape: BoxShape.circle,
              ),
              todayDecoration: const BoxDecoration(
                color: Color(0xFF0A1A3B),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: Color(0xFF0A1A3B),
                shape: BoxShape.circle,
              ),
              outsideDaysVisible: false,
              weekendTextStyle: const TextStyle(color: Colors.black87),
              defaultTextStyle: const TextStyle(color: Colors.black87),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              weekendStyle: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),

        // Show events for selected day
        if (_selectedDay != null && _getEventsForDay(_selectedDay!).isNotEmpty)
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: _getEventsForDay(_selectedDay!).length,
                itemBuilder: (context, index) {
                  final event = _getEventsForDay(_selectedDay!)[index];
                  final String eventType = event['type'] ?? 'event';
                  final bool isAmenity = eventType == 'amenity';
                  final bool isHealth = eventType == 'health';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: ListTile(
                      title: Text(
                        event['title'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text((isAmenity || isHealth) &&
                              event['endTime'] != null
                          ? '${DateFormat('h:mm a').format(event['date'])} - ${DateFormat('h:mm a').format(event['endTime'])}'
                          : DateFormat('h:mm a').format(event['date'])),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isHealth
                              ? Colors.purple.shade700
                              : isAmenity
                                  ? Colors.green.shade700
                                  : Colors.blue.shade700,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isHealth
                              ? Icons.spa
                              : isAmenity
                                  ? Icons.fitness_center
                                  : Icons.event,
                          color: Colors.white,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () =>
                            _deleteEvent(context, event['id'], event['title']),
                      ),
                      onTap: () => _showEventDetails(context, event),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildListView() {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(16),
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
                  onTap: _openAmenitiesBooking,
                ),
                FeatureColumn(
                  iconPath: 'assets/health_icon.png',
                  label: 'Health &\nWellness',
                  onTap: _openHealthWellness, // Updated to use the new method
                ),
              ],
            ),
            const SizedBox(height: 30),
            CustomButton(
              text: 'Add Event',
              onPressed: () => _addEvent(context),
              backgroundColor: const Color(0xFF0A1A3B),
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Manage RSVPs',
              onPressed: () {
                // Handle Manage RSVPs
              },
              backgroundColor: const Color(0xFF0A1A3B),
            ),

            // Show upcoming events in list view
            const SizedBox(height: 30),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Upcoming Events",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildUpcomingEventsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingEventsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firebaseService.getEvents(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final allEvents = snapshot.data?.docs ?? [];

        // Get current date and time
        final now = DateTime.now();

        // Filter to only include future events
        final futureEvents = allEvents.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final DateTime eventDate = (data['date'] as Timestamp).toDate();
          // Only include events that haven't happened yet
          return eventDate.isAfter(now);
        }).toList();

        if (futureEvents.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text('No upcoming events'),
          );
        }

        // Sort events by date (earliest first)
        futureEvents.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final DateTime aDate = (aData['date'] as Timestamp).toDate();
          final DateTime bDate = (bData['date'] as Timestamp).toDate();
          return aDate.compareTo(bDate);
        });

        // Show only the first 5 upcoming events
        final eventsToShow =
            futureEvents.length > 5 ? futureEvents.sublist(0, 5) : futureEvents;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: eventsToShow.length,
          itemBuilder: (context, index) {
            final doc = eventsToShow[index];
            final data = doc.data() as Map<String, dynamic>;
            final DateTime date = (data['date'] as Timestamp).toDate();
            final String eventType = data['type'] ?? 'event';

            return Dismissible(
              key: Key(doc.id),
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20.0),
                child: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
              direction: DismissDirection.endToStart,
              confirmDismiss: (direction) async {
                return await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Confirm"),
                      content: Text(
                          "Are you sure you want to delete ${data['title']}?"),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text("CANCEL"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text("DELETE",
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    );
                  },
                );
              },
              onDismissed: (direction) {
                _firebaseService.deleteEvent(doc.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${data['title']} deleted')),
                );
              },
              child: Card(
                margin: const EdgeInsets.only(bottom: 8.0),
                child: ListTile(
                  title: Text(
                    data['title'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle:
                      Text(DateFormat('MMM d, yyyy - h:mm a').format(date)),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: eventType == 'health'
                          ? Colors.purple.shade700
                          : eventType == 'amenity'
                              ? Colors.green.shade700
                              : const Color(0xFF0A1A3B),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('d').format(date),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          DateFormat('MMM').format(date),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () =>
                        _deleteEvent(context, doc.id, data['title']),
                  ),
                  onTap: () {
                    _showEventDetails(context, {
                      'id': doc.id,
                      'title': data['title'],
                      'date': date,
                      'type': eventType,
                      'endTime': data['endTime'] != null
                          ? (data['endTime'] as Timestamp).toDate()
                          : null,
                      'notes': data['notes'],
                    });
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildToggleButton(String text, String view) {
    final isActive = _activeView == view;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeView = view;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF6750A4) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF6750A4),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
