import 'dart:math';
import '../models/game_models.dart';

class MazeGenerator {
  static const int mazeSize = 100;
  static const int viewDistance = 3;

  // Фиксированный seed для одинакового лабиринта
  static final Random _random = Random(12345); // Постоянный seed

  List<List<int>> generateMaze() {
    print('=== ГЕНЕРАЦИЯ ЛАБИРИНТА ===');

    // Создаем базовый лабиринт с алгоритмом Prim
    var maze = List.generate(mazeSize, (_) => List.filled(mazeSize, 1));

    // Фиксированная стартовая позиция
    int startX = 1;
    int startY = 1;
    maze[startY][startX] = 0;
    print(
        'Стартовая позиция: ($startX, $startY) - значение: ${maze[startY][startX]}');

    var walls = <Point<int>>[];
    addWalls(startX, startY, maze, walls);

    while (walls.isNotEmpty) {
      var wall =
          walls.removeAt(_random.nextInt(walls.length)); // Используем _random
      int x = wall.x;
      int y = wall.y;

      // Проверяем, можно ли сделать проход
      if (isValidWall(x, y, maze)) {
        maze[y][x] = 0;

        // Добавляем соседние стены
        addWalls(x, y, maze, walls);
      }
    }

    // Создаем гарантированный выход
    createGuaranteedExit(maze);

    // Проверяем стартовую позицию
    print('Проверка старта: maze[1][1] = ${maze[1][1]}');

    return maze;
  }

  void addWalls(int x, int y, List<List<int>> maze, List<Point<int>> walls) {
    var directions = [Point(0, 1), Point(1, 0), Point(0, -1), Point(-1, 0)];

    for (var dir in directions) {
      int newX = x + dir.x;
      int newY = y + dir.y;

      if (newX >= 0 && newX < mazeSize && newY >= 0 && newY < mazeSize) {
        if (maze[newY][newX] == 1) {
          walls.add(Point(newX, newY));
        }
      }
    }
  }

  bool isValidWall(int x, int y, List<List<int>> maze) {
    int count = 0;
    var directions = [Point(0, 1), Point(1, 0), Point(0, -1), Point(-1, 0)];

    for (var dir in directions) {
      int newX = x + dir.x;
      int newY = y + dir.y;

      if (newX >= 0 && newX < mazeSize && newY >= 0 && newY < mazeSize) {
        if (maze[newY][newX] == 0) {
          count++;
        }
      }
    }

    return count == 1;
  }

  void createGuaranteedExit(List<List<int>> maze) {
    // Создаем выход в правом нижнем углу
    for (int i = mazeSize - 2; i >= 0; i--) {
      if (maze[mazeSize - 2][i] == 0) {
        maze[mazeSize - 1][i] = 0;
        break;
      }
    }
  }

  List<Trap> generateTraps(List<List<int>> maze, int count) {
    var traps = <Trap>[];
    var puzzles = _generatePuzzles();

    for (int i = 0; i < count; i++) {
      int x, y;
      int attempts = 0;
      do {
        x = _random.nextInt(mazeSize - 4) + 2; // Используем _random
        y = _random.nextInt(mazeSize - 4) + 2; // Используем _random
        attempts++;
        if (attempts > 100) break; // Защита от бесконечного цикла
      } while (
          maze[y][x] != 0 || _isNearStart(x, y) || _hasTrapNearby(x, y, traps));

      if (attempts <= 100) {
        traps.add(Trap(
          x: x,
          y: y,
          puzzle:
              puzzles[_random.nextInt(puzzles.length)], // Используем _random
        ));
      }
    }

    return traps;
  }

  Treasure generateTreasure(List<List<int>> maze, List<Trap> traps) {
    int x, y;
    int attempts = 0;

    do {
      x = _random.nextInt(mazeSize - 4) + 2; // Используем _random
      y = _random.nextInt(mazeSize - 4) + 2; // Используем _random
      attempts++;
      if (attempts > 100) break;
    } while (maze[y][x] != 0 || _isNearStart(x, y) || _hasTrapAt(x, y, traps));

    return Treasure(
      x: x,
      y: y,
      password: _generatePassword(),
    );
  }

  bool _isNearStart(int x, int y) {
    return (x - 1).abs() <= 5 &&
        (y - 1).abs() <= 5; // Увеличили зону вокруг старта
  }

  bool _hasTrapNearby(int x, int y, List<Trap> traps) {
    for (var trap in traps) {
      if ((trap.x - x).abs() <= 3 && (trap.y - y).abs() <= 3) {
        return true;
      }
    }
    return false;
  }

  bool _hasTrapAt(int x, int y, List<Trap> traps) {
    for (var trap in traps) {
      if (trap.x == x && trap.y == y) {
        return true;
      }
    }
    return false;
  }

  List<Puzzle> _generatePuzzles() {
    return [
      Puzzle(
        question: "Что идет, не двигаясь с места?",
        options: ["Часы", "Река", "Дорога", "Время"],
        correctAnswerIndex: 0,
      ),
      Puzzle(
        question: "2 + 2 × 2 = ?",
        options: ["6", "8", "4", "10"],
        correctAnswerIndex: 0,
      ),
      Puzzle(
        question: "Что можно сломать, даже не касаясь?",
        options: ["Сердце", "Обещание", "Стекло", "Дружбу"],
        correctAnswerIndex: 1,
      ),
      Puzzle(
        question: "15 ÷ 3 + 2 × 4 = ?",
        options: ["13", "15", "17", "19"],
        correctAnswerIndex: 0,
      ),
      Puzzle(
        question: "Что принадлежит вам, но другие используют это чаще?",
        options: ["Имя", "Телефон", "Деньги", "Дом"],
        correctAnswerIndex: 0,
      ),
    ];
  }

  String _generatePassword() {
    var chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return String.fromCharCodes(Iterable.generate(
        6,
        (_) => chars
            .codeUnitAt(_random.nextInt(chars.length)))); // Используем _random
  }
}
