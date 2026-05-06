import 'package:flutter/material.dart';
import 'data.dart';
import 'models.dart';
import 'services/firebase_service.dart';
import 'package:flutter_tts/flutter_tts.dart';

class LearningProvider extends ChangeNotifier {
  int _xp = 0;
  int _streak = 0;
  int _quizScore = 0;
  int _totalQuizAttempts = 0;
  Set<int> _learnedVocab = {};
  Set<int> _learnedGrammar = {};
  List<String> _badges = [];
  bool _isDarkMode = true;
  
  // SRS / Recommendation Logic
  Map<String, dynamic> _wordErrorRates = {}; 
  Map<String, dynamic> _lastReviewedWord = {};
  
  // Mastery Update Features
  int _dailyXP = 0;
  int _dailyGoal = 50;
  Set<int> _favorites = {};
  List<Map<String, dynamic>> _leaderboard = [
    {'name': 'You', 'xp': 0, 'isMe': true},
    {'name': 'Carlos', 'xp': 850, 'isMe': false},
    {'name': 'Elena', 'xp': 620, 'isMe': false},
    {'name': 'Sofia', 'xp': 430, 'isMe': false},
  ];

  // Dynamic Content
  List<VocabularyWord> _words = [];
  List<GrammarRule> _grammarRules = [];
  List<PronunciationGuide> _pronunciationGuides = [];
  List<QuizQuestion> _quizQuestions = [];
  bool _isLoadingContent = false;
  final FlutterTts _tts = FlutterTts();

  LearningProvider() {
    _initTTS();
  }

  Future<void> _initTTS() async {
    await _tts.setLanguage("es-ES"); // Spanish for Spanish learning
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.5); // Slightly slower for learning
  }

  Future<void> speak(String text) async {
    await _tts.speak(text);
  }

  final FirebaseService _firebaseService = FirebaseService();

  // Getters
  int get xp => _xp;
  int get level => (_xp / 200).floor() + 1;
  int get xpToNextLevel => 200 - (_xp % 200);
  double get xpProgress => (_xp % 200) / 200.0;
  int get streak => _streak;
  int get quizScore => _quizScore;
  int get totalQuizAttempts => _totalQuizAttempts;
  Set<int> get learnedVocab => _learnedVocab;
  Set<int> get learnedGrammar => _learnedGrammar;
  List<String> get badges => List.unmodifiable(_badges);
  bool get isDarkMode => _isDarkMode;
  int get vocabTotal => _words.length;
  int get grammarTotal => _grammarRules.length;
  int get dailyXP => _dailyXP;
  int get dailyGoal => _dailyGoal;
  double get dailyProgress => (_dailyXP / _dailyGoal).clamp(0.0, 1.0);
  Set<int> get favorites => _favorites;
  List<Map<String, dynamic>> get leaderboard => _leaderboard;
  
  List<VocabularyWord> get words => _words;
  List<GrammarRule> get grammarRules => _grammarRules;
  List<PronunciationGuide> get pronunciationGuides => _pronunciationGuides;
  List<QuizQuestion> get quizQuestions => _quizQuestions;
  bool get isLoadingContent => _isLoadingContent;

  Future<void> loadUserData() async {
    final data = await _firebaseService.getUserData();
    if (data != null) {
      _xp = data['xp'] ?? 0;
      _streak = data['streak'] ?? 0;
      _quizScore = data['quizScore'] ?? 0;
      _totalQuizAttempts = data['totalQuizAttempts'] ?? 0;
      _learnedVocab = Set<int>.from(data['learnedVocab'] ?? []);
      _learnedGrammar = Set<int>.from(data['learnedGrammar'] ?? []);
      _badges = List<String>.from(data['badges'] ?? []);
      _wordErrorRates = data['wordErrorRates'] ?? {};
      _lastReviewedWord = data['lastReviewedWord'] ?? {};
      _isDarkMode = data['isDarkMode'] ?? true;
      _dailyXP = data['dailyXP'] ?? 0;
      _dailyGoal = data['dailyGoal'] ?? 50;
      _favorites = Set<int>.from(data['favorites'] ?? []);
      _updateLeaderboard();
      notifyListeners();
      await initializeContent();
    }
  }

  Future<void> initializeContent() async {
    _isLoadingContent = true;
    notifyListeners();

    try {
      final vocabData = await _firebaseService.fetchCollection('vocabulary');
      _words = vocabData.map((d) => VocabularyWord(
        word: d['word'], translation: d['translation'], phonetic: d['phonetic'], example: d['example'], category: d['category']
      )).toList();

      final grammarData = await _firebaseService.fetchCollection('grammar');
      _grammarRules = grammarData.map((d) => GrammarRule(
        title: d['title'], explanation: d['explanation'], examples: List<String>.from(d['examples']), tip: d['tip']
      )).toList();

      final pronunData = await _firebaseService.fetchCollection('pronunciation');
      _pronunciationGuides = pronunData.map((d) => PronunciationGuide(
        sound: d['sound'], ipa: d['ipa'], englishLike: d['englishLike'], example: d['example']
      )).toList();

      final quizData = await _firebaseService.fetchCollection('quizzes');
      _quizQuestions = quizData.map((d) => QuizQuestion(
        question: d['question'], options: List<String>.from(d['options']), correctIndex: d['correctIndex'], module: d['module']
      )).toList();
      
      // Fallback to AppData if Firebase is empty (during first run)
      if (_words.isEmpty) {
        _words = List.from(AppData.words);
        _grammarRules = List.from(AppData.grammarRules);
        _pronunciationGuides = List.from(AppData.pronunciationGuides);
        _quizQuestions = List.from(AppData.quizQuestions);
      }
    } catch (e) {
      print('Error initializing content: \$e');
    } finally {
      _isLoadingContent = false;
      notifyListeners();
    }
  }

  Future<void> seedDatabase() async {
    await _firebaseService.seedCollection('vocabulary', AppData.words.map((w) => {
      'word': w.word, 'translation': w.translation, 'phonetic': w.phonetic, 'example': w.example, 'category': w.category
    }).toList());
    await _firebaseService.seedCollection('grammar', AppData.grammarRules.map((g) => {
      'title': g.title, 'explanation': g.explanation, 'examples': g.examples, 'tip': g.tip
    }).toList());
    await _firebaseService.seedCollection('pronunciation', AppData.pronunciationGuides.map((p) => {
      'sound': p.sound, 'ipa': p.ipa, 'englishLike': p.englishLike, 'example': p.example
    }).toList());
    await _firebaseService.seedCollection('quizzes', AppData.quizQuestions.map((q) => {
      'question': q.question, 'options': q.options, 'correctIndex': q.correctIndex, 'module': q.module
    }).toList());
    await initializeContent();
  }

  Future<void> _syncData() async {
    await _firebaseService.updateUserProgress(
      xp: _xp,
      streak: _streak,
      quizScore: _quizScore,
      totalQuizAttempts: _totalQuizAttempts,
      learnedVocab: _learnedVocab.toList(),
      learnedGrammar: _learnedGrammar.toList(),
      badges: _badges,
      wordErrorRates: _wordErrorRates,
      lastReviewedWord: _lastReviewedWord,
      isDarkMode: _isDarkMode,
      dailyXP: _dailyXP,
      dailyGoal: _dailyGoal,
      favorites: _favorites.toList(),
    );
  }

  void _updateLeaderboard() {
    for (var entry in _leaderboard) {
      if (entry['isMe'] == true) entry['xp'] = _xp;
    }
    _leaderboard.sort((a, b) => (b['xp'] as int).compareTo(a['xp'] as int));
  }

  void addXP(int amount) {
    _xp += amount;
    _dailyXP += amount;
    _checkXPBadges();
    _updateLeaderboard();
    _syncData();
    notifyListeners();
  }

  void markVocabLearned(int index) {
    if (_learnedVocab.contains(index)) return;
    _learnedVocab.add(index);
    addXP(10);
    if (_learnedVocab.length == AppData.words.length) {
      _awardBadge('Vocabulary Master 📚');
      addXP(50);
    }
    _syncData();
    notifyListeners();
  }

  void markGrammarLearned(int index) {
    if (_learnedGrammar.contains(index)) return;
    _learnedGrammar.add(index);
    addXP(15);
    if (_learnedGrammar.length == AppData.grammarRules.length) {
      _awardBadge('Grammar Guru 📝');
      addXP(50);
    }
    _syncData();
    notifyListeners();
  }

  void recordQuizAnswer(bool correct, {int? wordIndex}) {
    _totalQuizAttempts++;
    if (correct) {
      _quizScore++;
      addXP(20);
    } else if (wordIndex != null) {
      // Logic for SRS: Track errors
      String key = wordIndex.toString();
      _wordErrorRates[key] = (_wordErrorRates[key] ?? 0) + 1;
    }
    
    if (wordIndex != null) {
      _lastReviewedWord[wordIndex.toString()] = DateTime.now().millisecondsSinceEpoch;
    }

    if (_quizScore >= 5 && !_badges.contains('Quiz Champ 🏆')) {
      _awardBadge('Quiz Champ 🏆');
    }
    _syncData();
    notifyListeners();
  }

  void incrementStreak() {
    _streak++;
    if (_streak == 3) _awardBadge('On Fire! 🔥');
    if (_streak == 7) _awardBadge('Week Warrior ⚔️');
    _syncData();
    notifyListeners();
  }

  void _awardBadge(String badge) {
    if (!_badges.contains(badge)) {
      _badges.add(badge);
    }
  }

  void _checkXPBadges() {
    if (_xp >= 50 && !_badges.contains('XP Earner ⭐')) {
      _awardBadge('XP Earner ⭐');
    }
    if (_xp >= 200 && !_badges.contains('Century Club 💯')) {
      _awardBadge('Century Club 💯');
    }
  }

  // Recommendation Engine Logic
  List<int> getRecommendedVocabIndices() {
    List<MapEntry<String, dynamic>> sortedErrors = _wordErrorRates.entries.toList()
      ..sort((a, b) => (b.value as int).compareTo(a.value as int));
    
    // Top 3 words with highest error rate
    return sortedErrors.take(3).map((e) => int.parse(e.key)).toList();
  }

  Future<void> logout() async {
    await _firebaseService.signOut();
    _xp = 0;
    _streak = 0;
    _quizScore = 0;
    _totalQuizAttempts = 0;
    _learnedVocab = {};
    _learnedGrammar = {};
    _badges = [];
    _wordErrorRates = {};
    _lastReviewedWord = {};
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _syncData();
    notifyListeners();
  }

  void toggleFavorite(int wordIndex) {
    if (_favorites.contains(wordIndex)) {
      _favorites.remove(wordIndex);
    } else {
      _favorites.add(wordIndex);
    }
    _syncData();
    notifyListeners();
  }
}
