class MathPuzzle {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;

  MathPuzzle({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
  });
}

class PuzzleRepository {
  static final List<MathPuzzle> puzzles = [
    MathPuzzle(
      question: "Сколько будет 15 + 27?",
      options: ["40", "42", "38", "45"],
      correctAnswerIndex: 1, // 42
    ),
    MathPuzzle(
      question: "Чему равно 64 ÷ 8?",
      options: ["6", "7", "8", "9"],
      correctAnswerIndex: 2, // 8
    ),
    MathPuzzle(
      question: "Какое число является простым?",
      options: ["12", "15", "17", "21"],
      correctAnswerIndex: 2, // 17
    ),
    MathPuzzle(
      question: "Сколько градусов в прямом углу?",
      options: ["45°", "90°", "180°", "360°"],
      correctAnswerIndex: 1, // 90°
    ),
    MathPuzzle(
      question: "Чему равно 3² + 4²?",
      options: ["7", "12", "25", "49"],
      correctAnswerIndex: 2, // 25
    ),
    MathPuzzle(
      question: "Сколько сантиметров в 2.5 метрах?",
      options: ["25 см", "250 см", "2500 см", "25000 см"],
      correctAnswerIndex: 1, // 250 см
    ),
    MathPuzzle(
      question: "Какая дробь равна 0.75?",
      options: ["1/4", "1/2", "3/4", "2/3"],
      correctAnswerIndex: 2, // 3/4
    ),
    MathPuzzle(
      question: "Чему равно 100 - 45 ÷ 5?",
      options: ["11", "91", "89", "95"],
      correctAnswerIndex: 1, // 91
    ),
    MathPuzzle(
      question: "Сколько сторон у шестиугольника?",
      options: ["5", "6", "7", "8"],
      correctAnswerIndex: 1, // 6
    ),
    MathPuzzle(
      question: "Какое число следующее в последовательности: 2, 4, 8, 16, ...?",
      options: ["20", "24", "32", "64"],
      correctAnswerIndex: 2, // 32
    ),
    MathPuzzle(
      question: "Сколько будет 7 × 8 - 9?",
      options: ["45", "47", "49", "51"],
      correctAnswerIndex: 1, // 47
    ),
    MathPuzzle(
      question: "Чему равен корень квадратный из 144?",
      options: ["11", "12", "13", "14"],
      correctAnswerIndex: 1, // 12
    ),
    MathPuzzle(
      question: "Сколько минут в 3.5 часах?",
      options: ["180 мин", "200 мин", "210 мин", "240 мин"],
      correctAnswerIndex: 2, // 210 мин
    ),
    MathPuzzle(
      question: "Какое число делится и на 3, и на 4?",
      options: ["10", "15", "20", "24"],
      correctAnswerIndex: 3, // 24
    ),
    MathPuzzle(
      question: "Чему равно 5! (факториал)?",
      options: ["60", "100", "120", "150"],
      correctAnswerIndex: 2, // 120
    ),
    MathPuzzle(
      question: "Сколько будет 2³ × 3²?",
      options: ["18", "36", "54", "72"],
      correctAnswerIndex: 3, // 72
    ),
  ];

  static MathPuzzle getRandomPuzzle() {
    final random = puzzles.toList()..shuffle();
    return random.first;
  }
}
