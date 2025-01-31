import 'package:flutter/material.dart';
import 'package:kasir/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://izmboylygxxkhanqiwgt.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml6bWJveWx5Z3h4a2hhbnFpd2d0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzYxMzEyMzgsImV4cCI6MjA1MTcwNzIzOH0.66Ja9ZMZRFqwchGP_-zCHzOSK2TTzVkBj7LC3De3Teg',
  );
  runApp(MyApp());
}
          

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
      // home: LoginPage(),
    );
  }
}
