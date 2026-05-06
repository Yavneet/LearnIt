import 'package:flutter/material.dart';
import 'data.dart';
import 'package:provider/provider.dart';
import 'provider.dart';

class PronunciationScreen extends StatelessWidget {
  const PronunciationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<LearningProvider>();
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    if (p.isLoadingContent || p.pronunciationGuides.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Pronunciation Guide'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B6B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFF6B6B).withOpacity(0.3)),
            ),
            child: Row(children: [
              const Icon(Icons.record_voice_over_rounded, color: Color(0xFFFF6B6B), size: 28),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Spanish Phonetics', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F0E17), fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                const Text('Learn how each sound is produced. Symbols shown in IPA notation.',
                    style: TextStyle(color: Color(0xFF9E9DB5), fontSize: 12)),
              ])),
            ]),
          ),
          const SizedBox(height: 16),
          Text('Vowels', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F0E17), fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 8),
          ...p.pronunciationGuides.take(5).map((g) => _PronunciationCard(guide: g)),
          const SizedBox(height: 16),
          Text('Consonants', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F0E17), fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 8),
          ...p.pronunciationGuides.skip(5).map((g) => _PronunciationCard(guide: g)),
          const SizedBox(height: 16),
          _StressRulesCard(),
        ],
      ),
    );
  }
}

class _PronunciationCard extends StatelessWidget {
  final dynamic guide;
  const _PronunciationCard({required this.guide});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1D2E) : Colors.white, 
        borderRadius: BorderRadius.circular(14),
        boxShadow: !isDark ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)] : null,
      ),
      child: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: Text(guide.sound,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(guide.ipa, style: const TextStyle(color: Color(0xFFFF6B6B), fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(width: 8),
            Expanded(child: Text(guide.englishLike,
                style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 12), overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.format_quote_rounded, color: Colors.white38, size: 14),
            const SizedBox(width: 4),
            Expanded(child: Text(guide.example,
                style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 12, fontStyle: FontStyle.italic))),
          ]),
        ])),
        IconButton(
          onPressed: () => context.read<LearningProvider>().speak(guide.example),
          icon: const Icon(Icons.play_circle_outline_rounded, color: Color(0xFFFF6B6B)),
        ),
      ]),
    );
  }
}

class _StressRulesCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1D2E) : Colors.white, 
        borderRadius: BorderRadius.circular(16),
        boxShadow: !isDark ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)] : null,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFFFF6B6B), size: 20),
          const SizedBox(width: 8),
          Text('Word Stress Rules', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F0E17), fontWeight: FontWeight.bold, fontSize: 15)),
        ]),
        const SizedBox(height: 12),
        _stressRule(context, '1', 'Words ending in a vowel, -n, or -s → stress the second-to-last syllable', 'ca-SA, ha-BLAN'),
        _stressRule(context, '2', 'Words ending in other consonants → stress the last syllable', 'ha-BLAR, ciu-DAD'),
        _stressRule(context, '3', 'Written accent (´) always overrides the rules', 'café, fácil, canción'),
      ]),
    );
  }

  Widget _stressRule(BuildContext context, String num, String rule, String example) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 22, height: 22,
          decoration: BoxDecoration(color: const Color(0xFFFF6B6B).withOpacity(0.15), shape: BoxShape.circle),
          child: Center(child: Text(num, style: const TextStyle(color: Color(0xFFFF6B6B), fontSize: 11, fontWeight: FontWeight.bold))),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(rule, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13)),
          const SizedBox(height: 2),
          Text(example, style: const TextStyle(color: Color(0xFFFF6B6B), fontSize: 12, fontStyle: FontStyle.italic)),
        ])),
      ]),
    );
  }
}
