import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider.dart';
import 'data.dart';

class GrammarScreen extends StatelessWidget {
  const GrammarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<LearningProvider>();

    if (p.isLoadingContent || p.grammarRules.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent, foregroundColor: Colors.white,
        title: const Text('Grammar Rules'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: Text('${p.learnedGrammar.length}/${p.grammarRules.length} done',
              style: const TextStyle(color: Color(0xFF00C9A7), fontWeight: FontWeight.bold))),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: p.grammarRules.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final rule = p.grammarRules[index];
          final learned = p.learnedGrammar.contains(index);
          return _GrammarCard(rule: rule, index: index, learned: learned,
            onLearn: () => p.markGrammarLearned(index));
        },
      ),
    );
  }
}

class _GrammarCard extends StatefulWidget {
  final dynamic rule;
  final int index;
  final bool learned;
  final VoidCallback onLearn;
  const _GrammarCard({required this.rule, required this.index, required this.learned, required this.onLearn});

  @override
  State<_GrammarCard> createState() => _GrammarCardState();
}

class _GrammarCardState extends State<_GrammarCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1D2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: !isDark ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)] : null,
        border: widget.learned
            ? Border.all(color: const Color(0xFF00C9A7).withOpacity(0.5), width: 1.5)
            : null,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: widget.learned
                      ? const Color(0xFF00C9A7).withOpacity(0.15)
                      : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  widget.learned ? Icons.check_circle_rounded : Icons.auto_stories_rounded,
                  color: widget.learned ? const Color(0xFF00C9A7) : (isDark ? Colors.white38 : Colors.black38),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(widget.rule.title,
                      style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F0E17), fontWeight: FontWeight.w700, fontSize: 15)),
                  if (widget.learned)
                    const Text('Learned +15 XP', style: TextStyle(color: Color(0xFF00C9A7), fontSize: 11)),
                ]),
              ),
              Icon(_expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: Colors.white38),
            ]),
          ),
        ),
        if (_expanded) ...[
          const Divider(color: Colors.white12, height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.rule.explanation,
                  style: TextStyle(color: isDark ? const Color(0xFFB0AFCA) : Colors.black87, fontSize: 14, height: 1.5)),
              const SizedBox(height: 14),
              Text('Examples:', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F0E17), fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              ...List.generate(widget.rule.examples.length, (i) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('• ', style: TextStyle(color: Color(0xFF00C9A7), fontSize: 14)),
                  Expanded(child: Text(widget.rule.examples[i],
                      style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13, fontStyle: FontStyle.italic))),
                ]),
              )),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C9A7).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF00C9A7).withOpacity(0.2)),
                ),
                child: Row(children: [
                  const Icon(Icons.lightbulb_rounded, color: Color(0xFF00C9A7), size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(widget.rule.tip,
                      style: const TextStyle(color: Color(0xFF00C9A7), fontSize: 12))),
                ]),
              ),
              const SizedBox(height: 14),
              if (!widget.learned)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: widget.onLearn,
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Mark as Learned (+15 XP)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C9A7),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              const SizedBox(height: 4),
            ]),
          ),
        ],
      ]),
    );
  }
}
