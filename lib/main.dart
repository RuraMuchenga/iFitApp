import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_signin/screens/signin_screen.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Colors.blue[100], // Set accent color to a slightly darker shade of blue
        scaffoldBackgroundColor: Colors.blue[50], colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.blue[200]), // Set scaffold background color to a very light shade of blue
        // Other theme properties...
      ),
      home: const SignInScreen(),
    );
  }
}


