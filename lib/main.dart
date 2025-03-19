import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:irc_ride_partner/HomeScreen/HomeScreen.dart';
import 'package:irc_ride_partner/LoginScreen/LoginScreen.dart';

import 'WelcomeScreen/WelcomeScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IRC Ride Partner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white, primary: Colors.black, secondary: Colors.orange),
        useMaterial3: true,
      ),
      home: AuthStateWrapper(),
      routes: {
        '/home': (context) => Homescreen(),
        '/login': (context) => Loginscreen(),
        '/auth': (context) => AuthStateWrapper(),
      },
    );
  }
}

class AuthStateWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show loading indicator
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasData) {
          // User is logged in
          return Homescreen();
        } else {
          // User is not logged in
          return WelcomeScreen();
        }
      },
    );
  }
}


