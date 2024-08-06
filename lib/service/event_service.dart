import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/models/event.dart';


class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createEvent(Event event) async {
    await _firestore.collection('events').add(event.toMap());
  }

  Future<void> updateEvent(Event event) async {
    await _firestore.collection('events').doc(event.id).update(event.toMap());
  }

  Future<void> deleteEvent(String eventId) async {
    await _firestore.collection('events').doc(eventId).delete();
  }

  Stream<List<Event>> getEvents() {
    return _firestore.collection('events').snapshots().map((snapshot) => 
      snapshot.docs.map((doc) => Event.fromMap(doc.data())).toList()
    );
  }
}
