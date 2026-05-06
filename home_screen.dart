import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider.dart';
import 'data.dart';
import 'vocabulary_screen.dart';
import 'grammar_screen.dart';
import 'pronunciation_screen.dart';
import 'quiz_screen.dart';
import 'progress_screen.dart';
import 'ai_tutor_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/percent_indicator.dart';

class LearnItHome extends StatelessWidget {
  const LearnItHome({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<LearningProvider>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 22),
              _buildDailyGoal(context, p),
              const SizedBox(height: 16),
              _buildQuickActions(context),
              const SizedBox(height: 28),
              if (p.getRecommendedVocabIndices().isNotEmpty) ...[
              _sectionTitle(context, 'Recommended for You'),
                const SizedBox(height: 8),
                const Text('Based on what you missed in quizzes', style: TextStyle(color: Color(0xFF9E9DB5), fontSize: 13)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: p.getRecommendedVocabIndices().length,
                    itemBuilder: (context, index) {
                      final qIndex = p.getRecommendedVocabIndices()[index];
                      if (qIndex >= AppData.quizQuestions.length) return const SizedBox();
                      final q = AppData.quizQuestions[qIndex];
                      return Container(
                        width: 200,
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1D2E),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFF6B6B).withOpacity(0.5)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.error_outline_rounded, color: Color(0xFFFF6B6B), size: 16),
                                const SizedBox(width: 6),
                                Text(q.module, style: const TextStyle(color: Color(0xFFFF6B6B), fontSize: 11, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const Spacer(),
                            Text(q.question, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const Spacer(),
                            Text('Correct: ${q.options[q.correctIndex]}', style: const TextStyle(color: Color(0xFF00C9A7), fontSize: 12)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 28),
              ],
              _sectionTitle(context, 'Modules'),
              const SizedBox(height: 12),
              _ModuleCard(
                title: 'Vocabulary',
                subtitle: 'Learn words with flashcards',
                icon: Icons.translate_rounded,
                color: const Color(0xFF6C63FF),
                progress: p.vocabTotal == 0 ? 0 : p.learnedVocab.length / p.vocabTotal,
                progressLabel: '${p.learnedVocab.length}/${p.vocabTotal} words',
                onTap: () => _push(context, const VocabularyScreen()),
              ).animate().fadeIn(delay: 100.ms).slideX(),
              const SizedBox(height: 10),
              _ModuleCard(
                title: 'Grammar',
                subtitle: 'Master Spanish grammar rules',
                icon: Icons.menu_book_rounded,
                color: const Color(0xFF00C9A7),
                progress: p.grammarTotal == 0 ? 0 : p.learnedGrammar.length / p.grammarTotal,
                progressLabel: '${p.learnedGrammar.length}/${p.grammarTotal} rules',
                onTap: () => _push(context, const GrammarScreen()),
              ).animate().fadeIn(delay: 200.ms).slideX(),
              const SizedBox(height: 10),
              _ModuleCard(
                title: 'Pronunciation',
                subtitle: 'Learn Spanish sounds & phonetics',
                icon: Icons.record_voice_over_rounded,
                color: const Color(0xFFFF6B6B),
                progress: 0,
                progressLabel: 'Interactive guide',
                onTap: () => _push(context, const PronunciationScreen()),
              ).animate().fadeIn(delay: 300.ms).slideX(),
              const SizedBox(height: 28),
              _sectionTitle(context, 'Practice'),
              const SizedBox(height: 12),
              _QuizBanner(onTap: () => _push(context, const QuizScreen())),
              if (p.badges.isNotEmpty) ...[
                const SizedBox(height: 28),
                _sectionTitle(context, 'Badges Earned'),
                const SizedBox(height: 12),
                _BadgesRow(badges: p.badges),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Widget _sectionTitle(BuildContext context, String text) => Text(
        text,
        style: TextStyle(
          fontSize: 18, 
          fontWeight: FontWeight.w700, 
          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF0F0E17),
        ),
      );

  Widget _buildHeader(BuildContext context) {
    final p = context.watch<LearningProvider>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('¡Bienvenido! 👋', style: TextStyle(fontSize: 13, color: Color(0xFF9E9DB5))),
            Text(
              'LearnIt', 
              style: TextStyle(
                fontSize: 30, 
                fontWeight: FontWeight.bold, 
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF0F0E17),
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () => p.toggleTheme(),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1D2E) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: Theme.of(context).brightness == Brightness.light 
                      ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)] : null,
                ),
                child: Icon(
                  p.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded, 
                  color: const Color(0xFF6C63FF),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProgressScreen())),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1D2E) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: Theme.of(context).brightness == Brightness.light 
                      ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)] : null,
                ),
                child: const Icon(Icons.bar_chart_rounded, color: Color(0xFF6C63FF)),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                context.read<LearningProvider>().logout();
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1D2E) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: Theme.of(context).brightness == Brightness.light 
                      ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)] : null,
                ),
                child: const Icon(Icons.logout_rounded, color: Color(0xFFFF6B6B)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDailyGoal(BuildContext context, LearningProvider p) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1D2E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: !isDark ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)] : null,
      ),
      child: Row(children: [
        CircularPercentIndicator(
          radius: 35.0, lineWidth: 8.0,
          percent: p.dailyProgress,
          center: Text("${(p.dailyProgress * 100).toInt()}%", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          progressColor: const Color(0xFF6C63FF), backgroundColor: isDark ? Colors.white10 : Colors.black12,
          circularStrokeCap: CircularStrokeCap.round,
        ).animate().scale(duration: 500.ms),
        const SizedBox(width: 20),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Daily Goal', style: TextStyle(color: Color(0xFF9E9DB5), fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('${p.dailyXP} / ${p.dailyGoal} XP', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F0E17))),
            const SizedBox(height: 4),
            Text(p.dailyXP >= p.dailyGoal ? "Goal Reached! 🎉" : "You're almost there!", style: const TextStyle(color: Color(0xFF6C63FF), fontSize: 12)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(children: [
      _actionChip(context, 'AI Tutor', Icons.psychology_rounded, const Color(0xFF6C63FF), () => _push(context, const AITutorScreen())),
      const SizedBox(width: 12),
      _actionChip(context, 'Leaderboard', Icons.leaderboard_rounded, const Color(0xFFFF8E53), () => _showLeaderboard(context)),
    ]);
  }

  Widget _actionChip(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F0E17), fontWeight: FontWeight.bold, fontSize: 13)),
          ]),
        ),
      ),
    );
  }

  void _showLeaderboard(BuildContext context) {
    final p = context.read<LearningProvider>();
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF0F0E17) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Weekly Leaderboard', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ...p.leaderboard.map((u) => ListTile(
            leading: CircleAvatar(backgroundColor: u['isMe'] == true ? const Color(0xFF6C63FF) : Colors.grey, child: Text(u['name'][0])),
            title: Text(u['name'], style: TextStyle(fontWeight: u['isMe'] == true ? FontWeight.bold : FontWeight.normal)),
            trailing: Text('${u['xp']} XP', style: const TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.bold)),
          )),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: const Color(0xFF1E1D2E), borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final String title, subtitle, progressLabel;
  final IconData icon;
  final Color color;
  final double progress;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.title, required this.subtitle, required this.icon,
    required this.color, required this.progress, required this.progressLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFF1E1D2E), borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Hero(
              tag: 'icon_\$title',
              child: Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: color),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                  Text(subtitle, style: const TextStyle(color: Color(0xFF9E9DB5), fontSize: 11)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress, backgroundColor: Colors.white12,
                            valueColor: AlwaysStoppedAnimation<Color>(color), minHeight: 4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(progressLabel, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 14),
          ],
        ),
      ),
    );
  }
}

class _QuizBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _QuizBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Icon(Icons.quiz_rounded, color: Colors.white, size: 36),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Take a Quiz!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Test your knowledge & earn XP', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 14),
          ],
        ),
      ),
    );
  }
}

class _BadgesRow extends StatelessWidget {
  final List<String> badges;
  const _BadgesRow({required this.badges});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: badges.map((b) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1D2E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.4)),
        ),
        child: Text(b, style: const TextStyle(color: Colors.white, fontSize: 12)),
      )).toList(),
    );
  }
}
