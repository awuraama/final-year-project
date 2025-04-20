import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'starter_page.dart';
import 'sign_in_page.dart';
import 'sign_up_page.dart';
import 'reset_password_page.dart';
import 'home_page.dart';
import 'personal_page.dart';
import 'group_page.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure Flutter is initialized first
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ); // Initialize Firebase
    print(
        "Firebase has been initialized successfully!"); // Success message in the console
  } catch (e) {
    print(
        "Error initializing Firebase: $e"); // Error message in case initialization fails
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Planner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/', // Set the initial route
      routes: {
        '/': (context) => starter_page(),
        // Starter page as the default route
        '/signin': (context) => sign_in_page(),
        // Sign-in page route
        '/signup': (context) => sign_up_page(),
        // Sign-up page route
        '/reset_password': (context) => reset_password_page(),
        // Reset password page route
        '/home': (context) => home_page(),
        // Add the HomePage route
        '/personal': (context) => personal_page(),
        '/group': (context) => group_page(),
      },
    );
  }
}
