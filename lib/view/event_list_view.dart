// ignore_for_file: use_build_context_synchronously

import 'package:carousel_slider/carousel_slider.dart';
import 'package:event_app/service/auth_service.dart';
import 'package:event_app/service/unsplash_service.dart';
import 'package:event_app/view/event_create_view.dart';
import 'package:event_app/view/login_view.dart';
import 'package:event_app/view_models/event_view_model.dart';
import 'package:event_app/widgets/event_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EventListView extends StatefulWidget {
  const EventListView({super.key});

  @override
  State<EventListView> createState() => _EventListViewState();
}

class _EventListViewState extends State<EventListView> {
  final UnsplashService _unsplashService = UnsplashService();
  Future<List<String>>? _photosFuture;
  late AuthService _authService;

  @override
  void initState() {
    super.initState();
    _photosFuture = _unsplashService.fetchRandomPhotos();
    _authService = AuthService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Events'),
        backgroundColor: Colors.teal,
        actions: [
          OutlinedButton(
            onPressed: () async {
              await _authService.signOut();

              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginView(),
                  ));
            },
            child: const Text(
              "Logout",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Consumer<EventViewModel>(
        builder: (context, eventViewModel, child) {
          final now = DateTime.now();

          final upcomingEvents = eventViewModel.events
              .where((event) => event.date.isAfter(now))
              .toList()
            ..sort((a, b) => a.date.compareTo(b.date));

          final upcomingEvents24Hours = upcomingEvents
              .where((event) =>
                  event.date.isBefore(now.add(const Duration(hours: 24))))
              .toList();

          final upcomingEventsBeyond24Hours = upcomingEvents
              .where((event) =>
                  event.date.isAfter(now.add(const Duration(hours: 24))))
              .toList();

          final List<Widget> carouselWidgets = upcomingEvents24Hours.isNotEmpty
              ? [
                  CarouselSlider.builder(
                    itemCount: upcomingEvents24Hours.length,
                    itemBuilder: (context, index, realIndex) {
                      final event = upcomingEvents24Hours[index];
                      return EventCard(event: event);
                    },
                    options: CarouselOptions(
                      autoPlay: true,
                      enlargeCenterPage: true,
                      aspectRatio: 2.0,
                      viewportFraction: 0.9,
                    ),
                  ),
                ]
              : [];

          final List<Widget> listWidgets =
              upcomingEventsBeyond24Hours.isNotEmpty
                  ? [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Upcoming Events',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.white),
                        ),
                      ),
                      ...upcomingEventsBeyond24Hours
                          .map((event) => EventCard(event: event)),
                    ]
                  : [];

          return FutureBuilder<List<String>>(
            future: _photosFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                final photos = snapshot.data!;
                return ListView(
                  children: [
                    if (photos.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: CarouselSlider.builder(
                          itemCount: photos.length,
                          itemBuilder: (context, index, realIndex) {
                            return Image.network(
                              photos[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                            );
                          },
                          options: CarouselOptions(
                            autoPlay: true,
                            enlargeCenterPage: true,
                            aspectRatio: 2.0,
                            viewportFraction: 1.0,
                          ),
                        ),
                      ),
                    ],
                    ...carouselWidgets,
                    ...listWidgets,
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const EventCreateView()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Create Event'),
                      ),
                    ),
                  ],
                );
              } else {
                return const Center(
                    child: Text('No photos available.',
                        style: TextStyle(color: Colors.white)));
              }
            },
          );
        },
      ),
    );
  }
}
