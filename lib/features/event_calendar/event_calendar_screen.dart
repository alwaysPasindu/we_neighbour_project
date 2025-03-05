import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:we_neighbour/widgets/calendar_feature_column.dart';
import 'package:we_neighbour/widgets/calendar_custom_button.dart';
import 'package:we_neighbour/features/event_calendar/firebase_service.dart';

class EventCalendarScreen extends StatefulWidget {
  const EventCalendarScreen({super.key});

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
              });
            } else {
              newEvents[normalizedDate] = [
                {
                  'id': doc.id,
                  'title': data['title'],
                  'date': date,
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
    return _events[normalizedDate] ?? [];
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

        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Add New Event'),
          content: Column(
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
            ],
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

                  try {
                    await _firebaseService.addEvent(
                        newEventTitle, eventDateTime);

                    // After adding the event, refresh the calendar view
                    setState(() {
                      _selectedDay = selectedDate;
                      _focusedDay = selectedDate;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Event added successfully')),
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
      },
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
                      'assets/images/logo.png',
                      height: 90,
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
    return Container(
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
                CalendarFeatureColumn(
                  iconPath: 'assets/images/calendar_icon.png',
                  label: 'Google\nCalendar',
                  onTap: _openGoogleCalendar,
                ),
                CalendarFeatureColumn(
                  iconPath: 'assets/images/amenities_icon.png',
                  label: 'Book\nAmenities',
                  onTap: () {
                    // Handle Book Amenities tap
                  },
                ),
                CalendarFeatureColumn(
                  iconPath: 'assets/images/health_icon.png',
                  label: 'Health &\nWellness',
                  onTap: () {
                    // Handle Health & Wellness tap
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),
            CalendarCustomButton(
              text: 'Add Event',
              onPressed: () => _addEvent(context),
              backgroundColor: const Color(0xFF0A1A3B),
            ),
            const SizedBox(height: 16),
            CalendarCustomButton(
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

        final events = snapshot.data?.docs ?? [];

        if (events.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text('No upcoming events'),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: events.length > 5
              ? 5
              : events.length, // Show only 5 upcoming events
          itemBuilder: (context, index) {
            final data = events[index].data() as Map<String, dynamic>;
            final DateTime date = (data['date'] as Timestamp).toDate();

            return Card(
              margin: const EdgeInsets.only(bottom: 8.0),
              child: ListTile(
                title: Text(
                  data['title'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(DateFormat('MMM d, yyyy - h:mm a').format(date)),
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A1A3B),
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