import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider.dart';
import 'data.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQ = 0;
  int? _selectedOption;
  bool _answered = false;
  int _sessionScore = 0;
  bool _quizDone = false;

  void _selectAnswer(int index, LearningProvider p) {
    if (_answered) return;
    final correct = index == p.quizQuestions[_currentQ].correctIndex;
    p.recordQuizAnswer(correct, wordIndex: _currentQ);
    if (correct) _sessionScore++;
    setState(() { _selectedOption = index; _answered = true; });
  }

  void _nextQuestion(LearningProvider p) {
    if (_currentQ < p.quizQuestions.length - 1) {
      setState(() { _currentQ++; _selectedOption = null; _answered = false; });
    } else {
      setState(() => _quizDone = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<LearningProvider>();

    if (p.isLoadingContent || p.quizQuestions.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent, foregroundColor: Colors.white,
        title: const Text('Quiz'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: Text(
              _quizDone ? 'Done!' : '${_currentQ + 1}/${p.quizQuestions.length}',
              style: const TextStyle(color: Color(0xFFFF6B6B), fontWeight: FontWeight.bold),
            )),
          ),
        ],
      ),
      body: _quizDone ? _buildResult(context) : _buildQuestion(p),
    );
  }

  Widget _buildQuestion(LearningProvider p) {
    final q = p.quizQuestions[_currentQ];
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: (p.quizQuestions.isEmpty) ? 0 : (_currentQ + 1) / p.quizQuestions.length,
            backgroundColor: Colors.white12,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6B6B)),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 10),
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B6B).withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(q.module, style: const TextStyle(color: Color(0xFFFF6B6B), fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ]),
        const SizedBox(height: 24),
        Text('Q${_currentQ + 1}.', style: const TextStyle(color: Color(0xFF9E9DB5), fontSize: 14)),
        const SizedBox(height: 8),
        Text(q.question, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700, height: 1.3)),
        const SizedBox(height: 32),
        ...List.generate(q.options.length, (i) => _OptionTile(
          option: q.options[i], index: i,
          selected: _selectedOption == i,
          answered: _answered,
          isCorrect: i == q.correctIndex,
          onTap: () => _selectAnswer(i, p),
        )),
        const Spacer(),
        if (_answered)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _nextQuestion(p),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B6B), foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(_currentQ == AppData.quizQuestions.length - 1 ? 'See Results' : 'Next Question →'),
            ),
          ),
        const SizedBox(height: 10),
      ]),
    );
  }

  Widget _buildResult(BuildContext context) {
    final total = AppData.quizQuestions.length;
    final pct = (_sessionScore / total * 100).round();
    final msg = pct >= 80 ? '🏆 Excellent!' : pct >= 60 ? '👍 Good job!' : '📚 Keep practicing!';
    final color = pct >= 80 ? const Color(0xFF00C9A7) : pct >= 60 ? const Color(0xFF6C63FF) : const Color(0xFFFF6B6B);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(msg, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 28),
          Container(
            width: 140, height: 140,
            decoration: BoxDecoration(shape: BoxShape.circle,
              border: Border.all(color: color, width: 6),
              color: color.withOpacity(0.1),
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('$pct%', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: color)),
              Text('$_sessionScore/$total', style: const TextStyle(color: Colors.white70, fontSize: 14)),
            ]),
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF1E1D2E), borderRadius: BorderRadius.circular(16)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _resultStat('Session', '$_sessionScore/$total', const Color(0xFF6C63FF)),
              _resultStat('XP Earned', '+${_sessionScore * 20}', const Color(0xFF00C9A7)),
              _resultStat('Accuracy', '$pct%', color),
            ]),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF), foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Back to Home'),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _resultStat(String label, String value, Color color) => Column(children: [
    Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
    const SizedBox(height: 4),
    Text(label, style: const TextStyle(color: Color(0xFF9E9DB5), fontSize: 12)),
  ]);
}

class _OptionTile extends StatelessWidget {
  final String option;
  final int index;
  final bool selected, answered, isCorrect;
  final VoidCallback onTap;

  const _OptionTile({
    required this.option, required this.index, required this.selected,
    required this.answered, required this.isCorrect, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg = const Color(0xFF1E1D2E);
    Color border = Colors.transparent;
    Color textColor = Colors.white;

    if (answered && isCorrect) { bg = const Color(0xFF00C9A7).withOpacity(0.15); border = const Color(0xFF00C9A7); textColor = const Color(0xFF00C9A7); }
    else if (answered && selected && !isCorrect) { bg = const Color(0xFFFF6B6B).withOpacity(0.15); border = const Color(0xFFFF6B6B); textColor = const Color(0xFFFF6B6B); }
    else if (selected) { border = const Color(0xFF6C63FF); }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: 1.5),
        ),
        child: Row(children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: answered && isCorrect
                  ? const Color(0xFF00C9A7)
                  : answered && selected && !isCorrect
                      ? const Color(0xFFFF6B6B)
                      : Colors.white12,
            ),
            child: Center(child: Text(
              answered && isCorrect ? '✓' : answered && selected ? '✗' : String.fromCharCode(65 + index),
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13),
            )),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(option, style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w500))),
        ]),
      ),
    );
  }
}
