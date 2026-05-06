import 'models.dart';

class AppData {
  static const List<VocabularyWord> words = [
    VocabularyWord(word: 'Hola', translation: 'Hello', phonetic: '/ˈo.la/', example: '¡Hola! ¿Cómo estás?', category: 'Greetings'),
    VocabularyWord(word: 'Gracias', translation: 'Thank you', phonetic: '/ˈɡɾa.sjas/', example: 'Muchas gracias por tu ayuda.', category: 'Courtesy'),
    VocabularyWord(word: 'Casa', translation: 'House', phonetic: '/ˈka.sa/', example: 'Mi casa es tu casa.', category: 'Nouns'),
    VocabularyWord(word: 'Agua', translation: 'Water', phonetic: '/ˈa.ɡwa/', example: 'Necesito agua, por favor.', category: 'Nouns'),
    VocabularyWord(word: 'Bueno', translation: 'Good', phonetic: '/ˈbwe.no/', example: 'Tiene un buen corazón.', category: 'Adjectives'),
    VocabularyWord(word: 'Hablar', translation: 'To speak', phonetic: '/aˈblaɾ/', example: 'Quiero hablar español.', category: 'Verbs'),
    VocabularyWord(word: 'Comer', translation: 'To eat', phonetic: '/koˈmeɾ/', example: 'Vamos a comer juntos.', category: 'Verbs'),
    VocabularyWord(word: 'Amor', translation: 'Love', phonetic: '/aˈmoɾ/', example: 'El amor es eterno.', category: 'Nouns'),
    VocabularyWord(word: 'Libro', translation: 'Book', phonetic: '/ˈli.βɾo/', example: 'Estoy leyendo un libro.', category: 'Nouns'),
    VocabularyWord(word: 'Tiempo', translation: 'Time / Weather', phonetic: '/ˈtjem.po/', example: '¿Qué tiempo hace hoy?', category: 'Nouns'),
  ];

  static const List<GrammarRule> grammarRules = [
    GrammarRule(
      title: 'Ser vs. Estar',
      explanation: 'Both mean "to be" but serve different purposes. "Ser" describes permanent traits (identity, origin, profession). "Estar" describes temporary states (mood, location, condition).',
      examples: ['Soy estudiante. (I am a student — identity)', 'Estoy cansado. (I am tired — temporary state)'],
      tip: 'Memory trick: Ser = DOCTOR, Estar = PLACE',
    ),
    GrammarRule(
      title: 'Noun Gender',
      explanation: 'Every Spanish noun is either masculine or feminine. Most nouns ending in -o are masculine; most ending in -a are feminine. Always learn the article with the noun.',
      examples: ['El libro (the book — masc.)', 'La casa (the house — fem.)', 'El agua (exception — fem. but uses el)'],
      tip: 'Learn "el/la" with every new noun from the start!',
    ),
    GrammarRule(
      title: 'Present Tense (-ar verbs)',
      explanation: 'For regular -ar verbs, drop the -ar ending and add: -o, -as, -a, -amos, -áis, -an based on the subject.',
      examples: ['Hablo (I speak)', 'Hablas (You speak)', 'Habla (He/She speaks)', 'Hablamos (We speak)'],
      tip: 'Master -ar verbs first — they are the most common!',
    ),
    GrammarRule(
      title: 'Definite Articles',
      explanation: 'Spanish has four definite articles that must agree in gender and number with the noun they describe.',
      examples: ['El perro (the dog — masc. singular)', 'La gata (the cat — fem. singular)', 'Los libros (the books — masc. plural)', 'Las casas (the houses — fem. plural)'],
      tip: 'Articles must always match the noun in gender AND number.',
    ),
    GrammarRule(
      title: 'Making Sentences Negative',
      explanation: 'To negate a sentence in Spanish, simply place "no" directly before the conjugated verb. No extra words needed for basic negation.',
      examples: ['Hablo español. → No hablo español.', 'Tengo hambre. → No tengo hambre.', 'Ella trabaja. → Ella no trabaja.'],
      tip: 'Just add "no" before the verb — it\'s that simple!',
    ),
  ];

  static const List<PronunciationGuide> pronunciationGuides = [
    PronunciationGuide(sound: 'A', ipa: '/a/', englishLike: 'Like "a" in "father"', example: 'Agua, Amor, Casa'),
    PronunciationGuide(sound: 'E', ipa: '/e/', englishLike: 'Like "e" in "pet"', example: 'Este, Elefante'),
    PronunciationGuide(sound: 'I', ipa: '/i/', englishLike: 'Like "ee" in "see"', example: 'Isla, Libro'),
    PronunciationGuide(sound: 'O', ipa: '/o/', englishLike: 'Like "o" in "hot"', example: 'Oso, Hola'),
    PronunciationGuide(sound: 'U', ipa: '/u/', englishLike: 'Like "oo" in "food"', example: 'Uva, Muro'),
    PronunciationGuide(sound: 'J', ipa: '/x/', englishLike: 'Like "h" in "hat" (but stronger)', example: 'Jugar, Jamón'),
    PronunciationGuide(sound: 'Ñ', ipa: '/ɲ/', englishLike: 'Like "ny" in "canyon"', example: 'Niño, España'),
    PronunciationGuide(sound: 'RR', ipa: '/r/', englishLike: 'Rolled/trilled "r"', example: 'Perro, Tierra'),
    PronunciationGuide(sound: 'LL', ipa: '/ʝ/', englishLike: 'Like "y" in "yes"', example: 'Llamar, Llave'),
    PronunciationGuide(sound: 'H', ipa: '/–/', englishLike: 'Always silent!', example: 'Hola, Hablar'),
  ];

  static const List<QuizQuestion> quizQuestions = [
    QuizQuestion(question: 'What does "Hola" mean?', options: ['Goodbye', 'Hello', 'Thank you', 'Please'], correctIndex: 1, module: 'Vocabulary'),
    QuizQuestion(question: 'What does "Gracias" mean?', options: ['Sorry', 'Hello', 'Thank you', 'Yes'], correctIndex: 2, module: 'Vocabulary'),
    QuizQuestion(question: 'What does "Casa" mean?', options: ['Car', 'Water', 'House', 'Book'], correctIndex: 2, module: 'Vocabulary'),
    QuizQuestion(question: 'What does "Hablar" mean?', options: ['To eat', 'To run', 'To sleep', 'To speak'], correctIndex: 3, module: 'Vocabulary'),
    QuizQuestion(question: 'What does "Amor" mean?', options: ['Time', 'Love', 'Water', 'Good'], correctIndex: 1, module: 'Vocabulary'),
    QuizQuestion(question: 'Which verb means "to be" for permanent traits?', options: ['Estar', 'Tener', 'Ser', 'Hacer'], correctIndex: 2, module: 'Grammar'),
    QuizQuestion(question: 'Most Spanish nouns ending in -o are...?', options: ['Feminine', 'Masculine', 'Neutral', 'Plural'], correctIndex: 1, module: 'Grammar'),
    QuizQuestion(question: 'How do you negate a sentence in Spanish?', options: ['Add "not" after verb', 'Add "no" before verb', 'Add "non" at start', 'Change the verb'], correctIndex: 1, module: 'Grammar'),
    QuizQuestion(question: 'The Spanish letter "H" is...?', options: ['Strongly aspirated', 'Like English H', 'Always silent', 'Like Spanish J'], correctIndex: 2, module: 'Pronunciation'),
    QuizQuestion(question: 'The Spanish "Ñ" sounds like...?', options: ['/n/', '/ɲ/ (ny in canyon)', '/ng/', '/m/'], correctIndex: 1, module: 'Pronunciation'),
  ];
}
