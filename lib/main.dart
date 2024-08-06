import 'package:event_app/firebase_options.dart';
import 'package:event_app/view/event_list_view.dart';
import 'package:event_app/view/login_view.dart';
import 'package:event_app/view_models/auth_view_model.dart';
import 'package:event_app/view_models/event_view_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => EventViewModel()),
      ],
      child: MaterialApp(
        title: 'Event Management App',
        home: Consumer<AuthViewModel>(
          builder: (context, authViewModel, child) {
            if (authViewModel.user != null) {
              return const EventListView();
            } else {
              return const LoginView();
            }
          },
        ),
      ),
    );
  }
}
