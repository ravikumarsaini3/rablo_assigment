import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:new_assigment/screen/chat_screen/chat_user_screen.dart';
import 'package:new_assigment/screen/signup_screen/signup_screen.dart';
import 'package:new_assigment/screen/splash_screen.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'rablo assignment',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
      ),
      home: SplashScreen()
    );
  }
}
