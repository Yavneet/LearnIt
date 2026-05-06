import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'provider.dart';
import 'data.dart';

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});
  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isFlipped = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _animation = Tween<double>(begin: 0, end: math.pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  void _flip() {
    _isFlipped ? _controller.reverse() : _controller.forward();
    setState(() => _isFlipped = !_isFlipped);
  }

  void _next(LearningProvider p) {
    p.markVocabLearned(_currentIndex);
    if (_currentIndex < p.words.length - 1) {
      setState(() { _currentIndex++; _isFlipped = false; _controller.reset(); });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('🎉 All flashcards done! Bonus XP awarded!'),
        backgroundColor: Color(0xFF6C63FF),
        behavior: SnackBarBehavior.floating,
      ));
      Navigator.pop(context);
    }
  }

  void _prev() {
    if (_currentIndex > 0) {
      setState(() { _currentIndex--; _isFlipped = false; _controller.reset(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<LearningProvider>();
    
    if (p.isLoadingContent || p.words.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    final word = p.words[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent, foregroundColor: Colors.white,
        title: Row(
          children: [
            Hero(
              tag: 'icon_Vocabulary',
              child: const Icon(Icons.translate_rounded, color: Color(0xFF6C63FF), size: 24),
            ),
            const SizedBox(width: 10),
            const Text('Vocabulary Flashcards', style: TextStyle(fontSize: 18)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: Text('${_currentIndex + 1}/${p.words.length}',
              style: const TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.bold))),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: p.words.isEmpty ? 0 : (_currentIndex + 1) / p.words.length,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Text('${p.learnedVocab.length} learned · Tap card to flip',
              style: const TextStyle(color: Color(0xFF9E9DB5), fontSize: 12)),
          const SizedBox(height: 30),
          Expanded(
            child: GestureDetector(
              onTap: _flip,
              onDoubleTap: () {
                p.toggleFavorite(_currentIndex);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(p.favorites.contains(_currentIndex) ? 'Added to Favorites!' : 'Removed from Favorites'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: AnimatedBuilder(
                animation: _animation,
                builder: (ctx, _) {
                  final firstHalf = _animation.value < math.pi / 2;
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateY(_animation.value),
                    child: firstHalf
                        ? _CardFace(word: word, isFront: true, isFavorite: p.favorites.contains(_currentIndex))
                        : Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()..rotateY(math.pi),
                            child: _CardFace(word: word, isFront: false, isFavorite: p.favorites.contains(_currentIndex)),
                          ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _currentIndex > 0 ? _prev : null,
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Previous'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF0F0E17), 
                  side: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black12),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () => _next(p),
                icon: const Icon(Icons.check_rounded),
                label: Text(_currentIndex == p.words.length - 1 ? 'Finish (+XP)' : 'Got it! (+10 XP)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF), foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 10),
        ]),
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  final dynamic word;
  final bool isFront;
  final bool isFavorite;
  const _CardFace({required this.word, required this.isFront, required this.isFavorite});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? (isFront ? const Color(0xFF6C63FF) : const Color(0xFF1E1D2E)) : Colors.white,
        gradient: isDark && isFront ? const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF3B36CC)]) : null,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0xFF6C63FF).withOpacity(0.3) : Colors.black.withOpacity(0.1), 
            blurRadius: 20, 
            offset: const Offset(0, 8),
          )
        ],
        border: !isDark ? Border.all(color: const Color(0xFF6C63FF).withOpacity(0.2)) : null,
      ),
      child: isFront ? _front(context) : _back(context),
    );
  }

  Widget _front(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final p = context.watch<LearningProvider>();
    final isFav = isFavorite;
    
    return Stack(
      children: [
        Positioned(
          top: 16, right: 16,
          child: Icon(isFav ? Icons.star_rounded : Icons.star_outline_rounded, 
               color: isFav ? Colors.amber : Colors.white30, size: 28),
        ),
        Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : const Color(0xFF6C63FF).withOpacity(0.1), 
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(word.category, style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF6C63FF), fontSize: 12, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 20),
            Text(word.word, style: TextStyle(fontSize: 52, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F0E17))),
            const SizedBox(height: 8),
            Text(word.phonetic, style: TextStyle(fontSize: 18, color: isDark ? Colors.white70 : Colors.black54, fontStyle: FontStyle.italic)),
            const SizedBox(height: 30),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.touch_app_rounded, color: isDark ? Colors.white54 : Colors.black38, size: 16),
              const SizedBox(width: 6),
              const Text('Tap to flip · Double tap to save', style: TextStyle(color: Colors.white54, fontSize: 13)),
            ]),
          ]),
        ),
      ],
    );
  }

  Widget _back(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('Translation', style: TextStyle(color: Color(0xFF9E9DB5), fontSize: 13)),
        const SizedBox(height: 10),
        Text(word.translation, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFF6C63FF))),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFF6C63FF).withOpacity(0.05), 
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: [
            const Text('Example', style: TextStyle(color: Color(0xFF9E9DB5), fontSize: 12)),
            const SizedBox(height: 6),
            Text(word.example, textAlign: TextAlign.center,
                style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F0E17), fontSize: 15, fontStyle: FontStyle.italic)),
          ]),
        ),
      ]),
    );
  }
}
