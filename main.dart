import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'learnit/provider.dart';
import 'learnit/home_screen.dart';
import 'learnit/auth_screen.dart';
import 'firebase_options.dart';

bool _isFirebaseInitialized = false;
String _firebaseError = '';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
    _isFirebaseInitialized = true;
  } catch (e) {
    _firebaseError = e.toString();
    debugPrint("Firebase init error (Did you run flutterfire configure?): $e");
  }

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
    final p = context.watch<LearningProvider>();
    
    return MaterialApp(
      title: 'LearnIt — Language Learning',
      debugShowCheckedModeBanner: false,
      themeMode: p.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF0F0E17)),
          titleTextStyle: TextStyle(color: Color(0xFF0F0E17), fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0F0E17),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      home: _isFirebaseInitialized ? const AuthWrapper() : _buildFirebaseWarning(),
    );
  }

  Widget _buildFirebaseWarning() {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFFF6B6B), size: 64),
              const SizedBox(height: 24),
              const Text('Firebase Not Configured', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('To see the app in action, please run `flutterfire configure` in your terminal to connect this app to your Firebase project.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF9E9DB5), fontSize: 16)),
              const SizedBox(height: 32),
              Text('Error details:\n$_firebaseError', style: const TextStyle(color: Colors.white38, fontSize: 12), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0F0E17),
            body: Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF))),
          );
        }
        
        if (snapshot.hasData) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<LearningProvider>().loadUserData();
          });
          return const LearnItHome();
        }
        
        return const AuthScreen();
      },
    );
  }
}
