import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  String id;
  String title;
  String description;
  DateTime date;
  String location;
  String creatorId;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.creatorId,
  });

  factory Event.fromMap(Map<String, dynamic> data) {
    return Event(
      id: data['id'],
      title: data['title'],
      description: data['description'],
      date: (data['date'] as Timestamp).toDate(),
      location: data['location'],
      creatorId: data['creatorId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date,
      'location': location,
      'creatorId': creatorId,
    };
  }
}
