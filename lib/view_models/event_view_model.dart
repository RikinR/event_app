import 'package:event_app/models/event.dart';
import 'package:event_app/service/event_service.dart';
import 'package:flutter/material.dart';

class EventViewModel extends ChangeNotifier {
  final EventService _eventService = EventService();
  List<Event> _events = [];

  List<Event> get events => _events;

  EventViewModel() {
    _eventService.getEvents().listen((events) {
      _events = events;
      notifyListeners();
    });
  }

  Future<void> createEvent(Event event) async {
    await _eventService.createEvent(event);
  }

  Future<void> updateEvent(Event event) async {
    await _eventService.updateEvent(event);
  }

  Future<void> deleteEvent(String eventId) async {
    await _eventService.deleteEvent(eventId);
  }
}
