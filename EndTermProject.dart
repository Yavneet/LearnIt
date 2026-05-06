import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'learnit/provider.dart';
import 'learnit/home_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => LearningProvider(),
      child: const LearnItApp(),
    ),
  );
}

class LearnItApp extends StatelessWidget {
  const LearnItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LearnIt — Language Learning',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'sans-serif',
        scaffoldBackgroundColor: const Color(0xFF0F0E17),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      home: const LearnItHome(),
    );
  }
}
