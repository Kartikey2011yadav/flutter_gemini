import 'package:flutter/material.dart';
import 'package:flutter_gemini/home_screen.dart';
// Alternative code import
// import 'ChatScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Chat Application',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromRGBO(
            36, 244, 29, 1.0)),
        useMaterial3: true,
          fontFamily: 'Roboto',
      ),
      home: const MyHomePage(title: 'Flutter Gemini Application'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
    // Alternative Approach
    // return const ChatScreen(title: "Chat with Gemini");
  }
}
