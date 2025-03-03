import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:intl/intl.dart';
import '../../services/google_calendar_service.dart';
import '../../constants/colors.dart';
import 'create_event_screen.dart';

class EventCalendarScreen extends StatefulWidget {
  const EventCalendarScreen({Key? key}) : super(key: key);

  @override
  State<EventCalendarScreen> createState() => _EventCalendarScreenState();
}

class _EventCalendarScreenState extends State<EventCalendarScreen> {
  bool _isLoading = true;
  bool _isSignedIn = false;
  List<calendar.Event> _events = [];
  DateTime _selectedDate = DateTime.now();
  
  @override
  void initState() {
    super.initState();
    _checkSignInStatus();
  }
  
  Future<void> _checkSignInStatus() async {
    setState(() => _isLoading = true);
    final isSignedIn = await GoogleCalendarService.isSignedIn();
    setState(() => _isSignedIn = isSignedIn);
    
    if (isSignedIn) {
      await _loadEvents();
    } else {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _signIn() async {
    setState(() => _isLoading = true);
    final success = await GoogleCalendarService.signInWithGoogle();
    setState(() => _isSignedIn = success);
    
    if (success) {
      await _loadEvents();
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to sign in with Google')),
        );
      }
    }
  }
  
  Future<void> _loadEvents() async {
    try {
      final startDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
      final endDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
      
      final events = await GoogleCalendarService.getEvents(
        startTime: startDate,
        endTime: endDate,
      );
      
      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading events: ${e.toString()}')),
        );
      }
    }
  }
  
  Future<void> _openGoogleCalendar() async {
    try {
      await GoogleCalendarService.openGoogleCalendar();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening Google Calendar: ${e.toString()}')),
        );
      }
    }
  }
  
  Future<void> _navigateToCreateEvent() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateEventScreen()),
    );
    
    if (result == true) {
      await _loadEvents();
    }
  }
  
  void _changeMonth(int monthsToAdd) {
    setState(() {
      _selectedDate = DateTime(
        _selectedDate.year,
        _selectedDate.month + monthsToAdd,
        _selectedDate.day,
      );
      _isLoading = true;
    });
    _loadEvents();
  }
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Calendar'),
        actions: [
          if (_isSignedIn)
            IconButton(
              icon: const Icon(Icons.open_in_new),
              onPressed: _openGoogleCalendar,
              tooltip: 'Open in Google Calendar',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !_isSignedIn
              ? _buildSignInPrompt(isDarkMode)
              : _buildCalendarView(isDarkMode),
      floatingActionButton: _isSignedIn
          ? FloatingActionButton(
              onPressed: _navigateToCreateEvent,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
  
  Widget _buildSignInPrompt(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/icons/calendar.png',
            height: 100,
            width: 100,
          ),
          const SizedBox(height: 24),
          Text(
            'Connect with Google Calendar',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Sign in with your Google account to view and manage your events',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _signIn,
            icon: Image.asset(
              'assets/images/google.png',
              height: 24,
              width: 24,
            ),
            label: const Text('Sign in with Google'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCalendarView(bool isDarkMode) {
    return Column(
      children: [
        _buildMonthSelector(isDarkMode),
        Expanded(
          child: _events.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_available,
                        size: 64,
                        color: isDarkMode ? Colors.white38 : Colors.black26,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No events this month',
                        style: TextStyle(
                          fontSize: 18,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _navigateToCreateEvent,
                        child: const Text('Create an event'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _events.length,
                  itemBuilder: (context, index) {
                    final event = _events[index];
                    return _buildEventCard(event, isDarkMode);
                  },
                ),
        ),
      ],
    );
  }
  
  Widget _buildMonthSelector(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkCardBackground : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _changeMonth(-1),
          ),
          GestureDetector(
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (picked != null && picked != _selectedDate) {
                setState(() {
                  _selectedDate = picked;
                  _isLoading = true;
                });
                _loadEvents();
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                DateFormat('MMMM yyyy').format(_selectedDate),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _changeMonth(1),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEventCard(calendar.Event event, bool isDarkMode) {
    final startTime = event.start?.dateTime;
    final endTime = event.end?.dateTime;
    final isAllDay = startTime == null;
    
    final formattedDate = isAllDay
        ? 'All day'
        : GoogleCalendarService.formatEventDate(startTime);
    
    final colorHex = event.colorId != null 
        ? _getEventColor(event.colorId!) 
        : AppColors.primary.value.toRadixString(16);
    
    final eventColor = Color(int.parse('0xFF$colorHex'));
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: isDarkMode ? AppColors.darkCardBackground : Colors.white,
      child: InkWell(
        onTap: () => _showEventDetails(event),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  color: eventColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.summary ?? 'Untitled Event',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    if (event.location != null && event.location!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: isDarkMode ? Colors.white54 : Colors.black45,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.location!,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDarkMode ? Colors.white54 : Colors.black45,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showEventDetails(calendar.Event event) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final startTime = event.start?.dateTime;
    final endTime = event.end?.dateTime;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.darkCardBackground : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.summary ?? 'Untitled Event',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow(
                Icons.access_time,
                startTime == null
                    ? 'All day'
                    : '${GoogleCalendarService.formatEventDate(startTime)} - ${DateFormat('h:mm a').format(endTime!.toLocal())}',
                isDarkMode,
              ),
              if (event.location != null && event.location!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildDetailRow(
                  Icons.location_on,
                  event.location!,
                  isDarkMode,
                ),
              ],
              if (event.description != null && event.description!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  event.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    label: const Text('Close'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _openGoogleCalendar(),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open in Calendar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildDetailRow(IconData icon, String text, bool isDarkMode) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: isDarkMode ? Colors.white70 : Colors.black54,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
  
  String _getEventColor(String colorId) {
    // Google Calendar color IDs
    final colorMap = {
      '1': '7986CB', // Lavender
      '2': '33B679', // Sage
      '3': '8E24AA', // Grape
      '4': 'E67C73', // Flamingo
      '5': 'F6BF26', // Banana
      '6': 'F4511E', // Tangerine
      '7': '039BE5', // Peacock
      '8': '616161', // Graphite
      '9': '3F51B5', // Blueberry
      '10': '0B8043', // Basil
      '11': 'D50000', // Tomato
    };
    
    return colorMap[colorId] ?? '4285F4'; // Default blue
  }
}

