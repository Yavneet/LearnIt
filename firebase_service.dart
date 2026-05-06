import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  // Stream for auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current user getter
  User? get currentUser => _auth.currentUser;

  // Sign Up
  Future<UserCredential?> signUpWithEmailAndPassword(String email, String password, String name) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create user document in Firestore
      await _firestore.collection('progress').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'xp': 0,
        'level': 1,
        'streak': 0,
        'quizScore': 0,
        'totalQuizAttempts': 0,
        'learnedVocab': [],
        'learnedGrammar': [],
        'badges': [],
        // Data for SRS logic
        'wordErrorRates': {}, // wordIndex : errorCount
        'lastReviewedWord': {}, // wordIndex : timestamp
        'isDarkMode': true,
        'dailyXP': 0,
        'dailyGoal': 50,
        'favorites': [],
      });

      return userCredential;
    } catch (e) {
      print('Sign Up Error: \$e');
      rethrow;
    }
  }

  // Log In
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Sign In Error: \$e');
      rethrow;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Update user progress
  Future<void> updateUserProgress({
    required int xp,
    required int streak,
    required int quizScore,
    required int totalQuizAttempts,
    required List<int> learnedVocab,
    required List<int> learnedGrammar,
    required List<String> badges,
    required Map<String, dynamic> wordErrorRates,
    required Map<String, dynamic> lastReviewedWord,
    required bool isDarkMode,
    required int dailyXP,
    required int dailyGoal,
    required List<int> favorites,
  }) async {
    if (currentUser == null) return;

    try {
      await _firestore.collection('progress').doc(currentUser!.uid).update({
        'xp': xp,
        'level': (xp / 200).floor() + 1,
        'streak': streak,
        'quizScore': quizScore,
        'totalQuizAttempts': totalQuizAttempts,
        'learnedVocab': learnedVocab,
        'learnedGrammar': learnedGrammar,
        'badges': badges,
        'wordErrorRates': wordErrorRates,
        'lastReviewedWord': lastReviewedWord,
        'isDarkMode': isDarkMode,
        'dailyXP': dailyXP,
        'dailyGoal': dailyGoal,
        'favorites': favorites,
      });
    } catch (e) {
      print('Error updating progress: \$e');
    }
  }

  // Get user data
  Future<Map<String, dynamic>?> getUserData() async {
    if (currentUser == null) return null;

    try {
      DocumentSnapshot doc = await _firestore.collection('progress').doc(currentUser!.uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error getting user data: \$e');
    }
    return null;
  }

  // --- Dynamic Content Fetching ---

  Future<List<Map<String, dynamic>>> fetchCollection(String collection) async {
    try {
      final snapshot = await _firestore.collection(collection).get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching collection $collection: $e');
      return [];
    }
  }

  Future<void> seedCollection(String collection, List<Map<String, dynamic>> items) async {
    final batch = _firestore.batch();
    for (var item in items) {
      final docRef = _firestore.collection(collection).doc();
      batch.set(docRef, item);
    }
    await batch.commit();
  }
}
