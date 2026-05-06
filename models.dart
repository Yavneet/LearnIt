// ============================================================
// LearnIt - Data Models
// ============================================================

class VocabularyWord {
  final String word;
  final String translation;
  final String example;
  final String phonetic;
  final String category;

  const VocabularyWord({
    required this.word,
    required this.translation,
    required this.example,
    required this.phonetic,
    required this.category,
  });
}

class GrammarRule {
  final String title;
  final String explanation;
  final List<String> examples;
  final String tip;

  const GrammarRule({
    required this.title,
    required this.explanation,
    required this.examples,
    required this.tip,
  });
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String module;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.module,
  });
}

class PronunciationGuide {
  final String sound;
  final String ipa;
  final String englishLike;
  final String example;

  const PronunciationGuide({
    required this.sound,
    required this.ipa,
    required this.englishLike,
    required this.example,
  });
}
