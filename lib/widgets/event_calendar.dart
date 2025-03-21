import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:we_neighbour/features/event_calendar/firebase_service.dart';

class EventCalendar extends StatefulWidget {
  final FirebaseService firebaseService;

  const EventCalendar({
    super.key,
    required this.firebaseService,
  });

  @override
  _EventCalendarState createState() => _EventCalendarState();
}

class _EventCalendarState extends State<EventCalendar> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<dynamic>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadEvents();
  }

  void _loadEvents() {
    widget.firebaseService.getEvents().listen((QuerySnapshot snapshot) {
      final Map<DateTime, List<dynamic>> newEvents = {};

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

      setState(() {
        _events = newEvents;
      });
    });
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    // Normalize date to remove time component
    final normalizedDate = DateTime(day.year, day.month, day.day);
    return _events[normalizedDate] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0A1A3B),
      child: Column(
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
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                }
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarStyle: const CalendarStyle(
                markersMaxCount: 3,
                markerDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Color(0xFF0A1A3B),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Color(0xFF0A1A3B),
                  shape: BoxShape.circle,
                ),
                outsideDaysVisible: false,
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: _buildEventList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEventList() {
    final events = _getEventsForDay(_selectedDay!);

    if (events.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'No events for this day',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return ListTile(
            title: Text(
              event['title'],
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              DateFormat('h:mm a').format(event['date']),
              style: const TextStyle(color: Colors.white70),
            ),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.event,
                color: Colors.white,
              ),
            ),
          );
        },
      ),
    );
  }
}