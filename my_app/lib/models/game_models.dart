class Puzzle {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;

  Puzzle({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
  });
}

class Trap {
  final int x;
  final int y;
  final Puzzle puzzle;
  bool isSolved;

  Trap({
    required this.x,
    required this.y,
    required this.puzzle,
    this.isSolved = false,
  });
}

class Treasure {
  final int x;
  final int y;
  final String password;
  bool isFound;

  Treasure({
    required this.x,
    required this.y,
    required this.password,
    this.isFound = false,
  });
}

class Player {
  int x;
  int y;
  bool hasFlashlight;
  bool flashlightUsed;
  DateTime startTime;

  Player({
    required this.x,
    required this.y,
    this.hasFlashlight = true,
    this.flashlightUsed = false,
    required this.startTime,
  });
}
