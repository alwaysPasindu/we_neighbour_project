import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/auth_io.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class GoogleCalendarService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/calendar',
    ],
  );
  
  static final _storage = FlutterSecureStorage();
  static calendar.CalendarApi? _calendarApi;
  
  // Sign in with Google and get calendar access
  static Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return false;
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Store access token securely
      await _storage.write(key: 'google_access_token', value: googleAuth.accessToken);
      
      // Create calendar API client
      final authClient = AuthClient(
        http.Client(),
        AccessCredentials(
          AccessToken(
            'Bearer',
            googleAuth.accessToken!,
            DateTime.now().add(const Duration(hours: 1)),
          ),
          null,
          ['https://www.googleapis.com/auth/calendar'],
        ),
      );
      
      _calendarApi = calendar.CalendarApi(authClient);
      return true;
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      return false;
    }
  }
  
  // Check if user is signed in
  static Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }
  
  // Sign out
  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _storage.delete(key: 'google_access_token');
    _calendarApi = null;
  }
  
  // Get calendar events
  static Future<List<calendar.Event>> getEvents({
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    if (_calendarApi == null) {
      final signedIn = await signInWithGoogle();
      if (!signedIn) throw Exception('Not signed in with Google');
    }
    
    final now = DateTime.now();
    startTime ??= DateTime(now.year, now.month, now.day);
    endTime ??= startTime.add(const Duration(days: 30));
    
    try {
      final events = await _calendarApi!.events.list(
        'primary',
        timeMin: startTime,
        timeMax: endTime,
        singleEvents: true,
        orderBy: 'startTime',
      );
      
      return events.items ?? [];
    } catch (e) {
      debugPrint('Error getting events: $e');
      // If token expired, try to refresh
      if (e.toString().contains('401')) {
        await signInWithGoogle();
        return getEvents(startTime: startTime, endTime: endTime);
      }
      return [];
    }
  }
  
  // Create a new event
  static Future<calendar.Event?> createEvent({
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    String? location,
    List<String>? attendeeEmails,
  }) async {
    if (_calendarApi == null) {
      final signedIn = await signInWithGoogle();
      if (!signedIn) throw Exception('Not signed in with Google');
    }
    
    try {
      final event = calendar.Event()
        ..summary = title
        ..description = description
        ..start = (calendar.EventDateTime()
          ..dateTime = startTime
          ..timeZone = startTime.timeZoneName)
        ..end = (calendar.EventDateTime()
          ..dateTime = endTime
          ..timeZone = endTime.timeZoneName);
      
      if (location != null) {
        event.location = location;
      }
      
      if (attendeeEmails != null && attendeeEmails.isNotEmpty) {
        event.attendees = attendeeEmails.map((email) => 
          calendar.EventAttendee()..email = email
        ).toList();
      }
      
      final createdEvent = await _calendarApi!.events.insert(event, 'primary');
      
      // Store event in Firestore for community events
      await _saveEventToFirestore(createdEvent);
      
      return createdEvent;
    } catch (e) {
      debugPrint('Error creating event: $e');
      if (e.toString().contains('401')) {
        await signInWithGoogle();
        return createEvent(
          title: title,
          description: description,
          startTime: startTime,
          endTime: endTime,
          location: location,
          attendeeEmails: attendeeEmails,
        );
      }
      return null;
    }
  }
  
  // Save event to Firestore for community events
  static Future<void> _saveEventToFirestore(calendar.Event event) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      
      final startTime = event.start?.dateTime;
      final endTime = event.end?.dateTime;
      
      if (startTime == null || endTime == null) return;
      
      await FirebaseFirestore.instance.collection('community_events').add({
        'title': event.summary,
        'description': event.description,
        'location': event.location,
        'startTime': Timestamp.fromDate(startTime),
        'endTime': Timestamp.fromDate(endTime),
        'createdBy': user.uid,
        'createdByEmail': user.email,
        'createdAt': FieldValue.serverTimestamp(),
        'googleEventId': event.id,
      });
    } catch (e) {
      debugPrint('Error saving event to Firestore: $e');
    }
  }
  
  // Open Google Calendar in browser or app
  static Future<void> openGoogleCalendar() async {
    const url = 'https://calendar.google.com/';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
  
  // Format date for display
  static String formatEventDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('EEE, MMM d, yyyy • h:mm a').format(date.toLocal());
  }
}

// Custom AuthClient for Google APIs
class AuthClient extends http.BaseClient {
  final http.Client _client;
  final AccessCredentials _credentials;

  AuthClient(this._client, this._credentials);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = 'Bearer ${_credentials.accessToken.data}';
    return _client.send(request);
  }
}

