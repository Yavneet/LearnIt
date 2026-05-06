import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'provider.dart';
import 'data.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<LearningProvider>();
    final accuracy = p.totalQuizAttempts == 0 ? 0 : (p.quizScore / p.totalQuizAttempts * 100).round();
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      appBar: AppBar(
        backgroundColor: Colors.transparent, foregroundColor: Colors.white,
        title: const Text('My Progress'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _LevelCard(p: p),
          const SizedBox(height: 20),
          const Text('Statistics', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17)),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
              return GridView.count(
                crossAxisCount: crossAxisCount, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.4,
                children: [
                  _StatCard(label: 'Total XP', value: '${p.xp}', icon: Icons.star_rounded, color: const Color(0xFF6C63FF)),
                  _StatCard(label: 'Current Level', value: '${p.level}', icon: Icons.military_tech, color: Colors.amber),
                  _StatCard(label: 'Quiz Score', value: '${p.quizScore}/${p.totalQuizAttempts}', icon: Icons.quiz_rounded, color: const Color(0xFFFF6B6B)),
                  _StatCard(label: 'Accuracy', value: '$accuracy%', icon: Icons.track_changes_rounded, color: const Color(0xFF00C9A7)),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          const Text('Learning Distribution', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17)),
          const SizedBox(height: 8),
          const Text('See where your mastery lies across modules.', style: TextStyle(color: Color(0xFF9E9DB5), fontSize: 13)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1D2E) : Colors.white, 
              borderRadius: BorderRadius.circular(16),
              boxShadow: !isDark ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)] : null,
            ),
            height: 220,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 30,
                      sections: _getSections(p),
                    ),
                  ).animate().scale(duration: 500.ms),
                ),
                const SizedBox(width: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Indicator(color: const Color(0xFF6C63FF), text: 'Vocabulary', isSquare: true),
                    const SizedBox(height: 12),
                    _Indicator(color: const Color(0xFF00C9A7), text: 'Grammar', isSquare: true),
                    const SizedBox(height: 12),
                    _Indicator(color: isDark ? const Color(0xFF1E1D2E) : Colors.black12, text: 'Remaining', isSquare: true, borderColor: isDark ? Colors.white24 : Colors.black26),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _sectionTitle(context, 'Weekly Activity'),
          const SizedBox(height: 12),
          _ActivityChart(p: p),
          const SizedBox(height: 24),
          if (p.badges.isNotEmpty) ...[
            const Text('Badges', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17)),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: p.badges.map((b) => _BadgeChip(badge: b)).toList()),
          ] else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF1E1D2E), borderRadius: BorderRadius.circular(14)),
              child: const Row(children: [
                Icon(Icons.military_tech, color: Colors.white38, size: 28),
                SizedBox(width: 12),
                Expanded(child: Text('Complete modules and quizzes to earn badges!',
                    style: TextStyle(color: Color(0xFF9E9DB5), fontSize: 13))),
              ]),
            ),
        ]),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) => Text(
    text,
    style: TextStyle(
      fontSize: 17, 
      fontWeight: FontWeight.w700, 
      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF0F0E17),
    ),
  );
}

class _LevelCard extends StatelessWidget {
  final LearningProvider p;
  const _LevelCard({required this.p});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF3B36CC)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Level ${p.level}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
            child: Text('${p.xp} XP total', style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ]),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: p.xpProgress, backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white), minHeight: 10,
          ),
        ),
        const SizedBox(height: 8),
        Text('${p.xp % 200} / 200 XP — ${p.xpToNextLevel} XP to Level ${p.level + 1}',
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ]),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1D2E) : Colors.white, 
        borderRadius: BorderRadius.circular(14),
        boxShadow: !isDark ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)] : null,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Icon(icon, color: color, size: 22),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 22)),
          Text(label, style: const TextStyle(color: Color(0xFF9E9DB5), fontSize: 11)),
        ]),
      ]),
    );
  }
}

class _ModuleProgress extends StatelessWidget {
  final String label;
  final int current, total;
  final Color color;
  const _ModuleProgress({required this.label, required this.current, required this.total, required this.color});

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : current / total;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF1E1D2E), borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
          Text('$current / $total', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: pct, backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation<Color>(color), minHeight: 6,
          ),
        ),
      ]),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final String badge;
  const _BadgeChip({required this.badge});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1D2E), borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.5)),
      ),
      child: Text(badge, style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF0F0E17), fontSize: 13)),
    );
  }
}

List<PieChartSectionData> _getSections(LearningProvider p) {
    int learnedVocab = p.learnedVocab.length;
    int learnedGrammar = p.learnedGrammar.length;
    int totalItems = p.vocabTotal + p.grammarTotal;
    
    if (totalItems == 0) return [];
    
    double vocabPct = (learnedVocab / totalItems * 100);
    double grammarPct = (learnedGrammar / totalItems * 100);
    double remainingPct = (100 - vocabPct - grammarPct).clamp(0, 100);

    return [
      if (vocabPct > 0)
        PieChartSectionData(
          color: const Color(0xFF6C63FF),
          value: vocabPct,
          title: '${vocabPct.toStringAsFixed(0)}%',
          radius: 50,
          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      if (grammarPct > 0)
        PieChartSectionData(
          color: const Color(0xFF00C9A7),
          value: grammarPct,
          title: '${grammarPct.toStringAsFixed(0)}%',
          radius: 50,
          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      if (remainingPct > 0)
        PieChartSectionData(
          color: const Color(0xFF1E1D2E),
          value: remainingPct,
          title: '',
          radius: 40,
        ),
    ];
  }

class _Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final bool isSquare;
  final Color? borderColor;

  const _Indicator({required this.color, required this.text, required this.isSquare, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
            border: borderColor != null ? Border.all(color: borderColor!) : null,
            borderRadius: isSquare ? BorderRadius.circular(4) : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(fontSize: 14, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF0F0E17), fontWeight: FontWeight.w500)),
      ],
    );
  }

}

class _ActivityChart extends StatelessWidget {
  final LearningProvider p;
  const _ActivityChart({required this.p});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1D2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: !isDark ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)] : null,
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                const FlSpot(0, 10), const FlSpot(1, 45), const FlSpot(2, 30),
                const FlSpot(3, 80), const FlSpot(4, 50), const FlSpot(5, 70),
                FlSpot(6, p.dailyXP.toDouble()),
              ],
              isCurved: true,
              color: const Color(0xFF6C63FF),
              barWidth: 4,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: const Color(0xFF6C63FF).withOpacity(0.1)),
            ),
          ],
        ),
      ),
    );
  }
}
