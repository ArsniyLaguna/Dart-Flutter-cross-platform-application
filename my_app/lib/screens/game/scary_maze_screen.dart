import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '/utils/puzzles.dart';

class ScaryMazeScreen extends StatefulWidget {
  const ScaryMazeScreen({super.key});

  @override
  State<ScaryMazeScreen> createState() => _ScaryMazeScreenState();
}

class _ScaryMazeScreenState extends State<ScaryMazeScreen>
    with SingleTickerProviderStateMixin {
  // Размер лабиринта
  static const int mazeSize = 20;

  // Позиции
  List<int> playerPosition = [1, 1];

  // Код и состояние игры
  String _chestCode = "";
  bool _doorOpened = false;
  bool _showCodeDialog = false;

  // Таймер
  Duration _elapsedTime = Duration.zero;
  late Timer _timer;
  DateTime _startTime = DateTime.now();

  // Матрица лабиринта 20x20 (0 - проход, 1 - стена, 2 - дверь, 3 - сундук, 4 - пустой сундук, 5 - ловушка)
  List<List<int>> maze = [
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 1],
    [1, 0, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1],
    [1, 0, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1],
    [1, 5, 1, 1, 0, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 0, 1],
    [1, 0, 1, 1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1],
    [1, 0, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1],
    [1, 0, 0, 0, 0, 1, 0, 1, 1, 1, 0, 1, 5, 1, 0, 1, 4, 1, 0, 1],
    [1, 0, 1, 1, 1, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 1, 1],
    [1, 0, 1, 0, 0, 0, 0, 0, 4, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1],
    [1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1],
    [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1],
    [1, 1, 1, 1, 0, 1, 0, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1],
    [1, 0, 3, 1, 0, 1, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 1],
    [1, 0, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 0, 1, 0, 1],
    [1, 0, 1, 1, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 1, 1, 0, 1, 0, 1],
    [1, 0, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1],
    [1, 5, 1, 1, 0, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1],
    [1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 5, 0, 0, 0, 4, 2, 0, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
  ];

  // Анимация
  late AnimationController _animationController;

  // Настройки отображения
  double cellSize = 40.0;
  static const int viewDistance = 3;

  @override
  void initState() {
    super.initState();
    _enterFullScreen();
    _generateChestCode();
    _startTimer();

    // Инициализация анимации
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  void _startTimer() {
    _startTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedTime = DateTime.now().difference(_startTime);
      });
    });
  }

  void _enterFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _exitFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer.cancel();
    _exitFullScreen();
    super.dispose();
  }

  // Генерация случайного четырёхзначного кода
  void _generateChestCode() {
    final random = math.Random();
    _chestCode = (1000 + random.nextInt(9000)).toString();
    // Для отладки можно использовать debugPrint вместо print
  }

  // Форматирование времени для таймера
  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Игровое поле с плавным затемнением
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double screenWidth = constraints.maxWidth;
                final double screenHeight = constraints.maxHeight;

                // Рассчитываем размер клетки для 7x7
                final double availableSize =
                    (screenWidth < screenHeight ? screenWidth : screenHeight) *
                        0.8;
                cellSize = availableSize / 7;

                return Center(
                  child: Container(
                    width: cellSize * 7,
                    height: cellSize * 7,
                    child: CustomPaint(
                      painter: _MazeWithSmoothFogPainter(
                        maze: maze,
                        playerPosition: playerPosition,
                        cellSize: cellSize,
                        viewDistance: viewDistance,
                        doorOpened: _doorOpened,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Управление - четкий крест
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: _buildControlCross(),
          ),

          // Информация
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 20,
            child: _buildGameInfo(),
          ),

          // Кнопка выхода
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            right: 20,
            child: _buildExitButton(),
          ),

          // Диалог с кодом (если активен)
          if (_showCodeDialog) _buildCodeDialog(),
        ],
      ),
    );
  }

  Widget _buildControlCross() {
    return Center(
      child: Container(
        width: 240,
        height: 240,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            // Верхняя кнопка
            Positioned(
              top: 0,
              left: 80,
              child: _buildSquareControlButton(
                Icons.arrow_upward,
                () => _movePlayer(-1, 0),
              ),
            ),

            // Нижняя кнопка
            Positioned(
              bottom: 0,
              left: 80,
              child: _buildSquareControlButton(
                Icons.arrow_downward,
                () => _movePlayer(1, 0),
              ),
            ),

            // Левая кнопка
            Positioned(
              left: 0,
              top: 80,
              child: _buildSquareControlButton(
                Icons.arrow_back,
                () => _movePlayer(0, -1),
              ),
            ),

            // Правая кнопка
            Positioned(
              right: 0,
              top: 80,
              child: _buildSquareControlButton(
                Icons.arrow_forward,
                () => _movePlayer(0, 1),
              ),
            ),

            // Центральная область (пустая)
            Positioned(
              top: 80,
              left: 80,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSquareControlButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          border: Border.all(
            color: Colors.white.withOpacity(0.4),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }

  Widget _buildGameInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Время: ${_formatTime(_elapsedTime)}',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            'Позиция: ${playerPosition[0]},${playerPosition[1]}',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(height: 4),
          const SizedBox(height: 4),
          Text(
            'Дверь: ${_doorOpened ? 'Открыта' : 'Закрыта'}',
            style: TextStyle(
              color: _doorOpened ? Colors.green : Colors.red,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExitButton() {
    return GestureDetector(
      onTap: () {
        _exitFullScreen();
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.green),
        ),
        child: const Icon(Icons.close, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildCodeDialog() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.8),
        child: Center(
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.yellow, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '🎁 Сундук с кодом',
                  style: TextStyle(
                    color: Colors.yellow,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                const Icon(Icons.lock_outline, color: Colors.yellow, size: 40),
                const SizedBox(height: 15),
                const Text(
                  'Код для выхода:',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  _chestCode,
                  style: const TextStyle(
                    color: Colors.yellow,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Запомните этот код!\nОн откроет дверь.',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showCodeDialog = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 12),
                  ),
                  child: const Text('Закрыть'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _movePlayer(int dx, int dy) {
    int newX = playerPosition[0] + dx;
    int newY = playerPosition[1] + dy;

    if (newX >= 0 && newX < mazeSize && newY >= 0 && newY < mazeSize) {
      int cellType = maze[newX][newY];

      // Проверяем тип клетки
      if (cellType == 0) {
        // Свободная клетка - двигаемся
        _performMove(newX, newY);
      } else if (cellType == 1) {
        // Стена - не двигаемся
        return;
      } else if (cellType == 2) {
        // Дверь
        _handleDoor(newX, newY);
      } else if (cellType == 3) {
        // Сундук
        _handleChest(newX, newY);
      } else if (cellType == 4) {
        // Пустой сундук
        _handleEmptyChest(newX, newY);
      } else if (cellType == 5) {
        // Ловушка с головоломкой
        _handleTrap(newX, newY);
      }
    }
  }

  void _performMove(int newX, int newY) {
    _animationController.forward().then((_) {
      _animationController.reset();
      setState(() {
        playerPosition = [newX, newY];
        _checkWinCondition();
      });
    });
  }

  void _handleDoor(int x, int y) {
    if (_doorOpened) {
      // Дверь уже открыта - проходим
      _performMove(x, y);
    } else {
      // Дверь закрыта - показываем диалог ввода кода
      _showDoorDialog();
    }
  }

  void _handleChest(int x, int y) {
    // Показываем диалог с кодом и разрешаем проходить через сундук
    setState(() {
      _showCodeDialog = true;
    });
    _performMove(x, y);
  }

  void _handleEmptyChest(int x, int y) {
    // Показываем сообщение о пустом сундуке
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Сундук пуст...'),
        backgroundColor: Colors.grey,
        duration: Duration(seconds: 2),
      ),
    );
    _performMove(x, y);
  }

  void _handleTrap(int x, int y) {
    // Показываем головоломку
    _showPuzzleDialog(x, y);
  }

  void _showPuzzleDialog(int trapX, int trapY) {
    _showPuzzleDialogInternal(trapX, trapY, PuzzleRepository.getRandomPuzzle());
  }

  void _showPuzzleDialogInternal(int trapX, int trapY, MathPuzzle puzzle) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.grey[900],
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '⚡ ЛОВУШКА!',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                const Icon(Icons.warning, color: Colors.orange, size: 40),
                const SizedBox(height: 15),
                const Text(
                  'Решите головоломку, чтобы продолжить:',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  puzzle.question,
                  style: const TextStyle(
                    color: Colors.yellow,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Column(
                  children: puzzle.options.asMap().entries.map((entry) {
                    int index = entry.key;
                    String option = entry.value;
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ElevatedButton(
                        onPressed: () {
                          _handlePuzzleAnswer(
                            index == puzzle.correctAnswerIndex,
                            trapX,
                            trapY,
                            puzzle,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(option),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handlePuzzleAnswer(
      bool isCorrect, int trapX, int trapY, MathPuzzle currentPuzzle) {
    if (isCorrect) {
      // Правильный ответ - закрываем диалог и обезвреживаем ловушку
      Navigator.of(context).pop();

      setState(() {
        maze[trapX][trapY] = 0; // Заменяем ловушку на проход
        playerPosition = [trapX, trapY]; // Перемещаем игрока в клетку ловушки
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Правильно! Ловушка обезврежена.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Неправильный ответ - закрываем текущий диалог и открываем новый с другой головоломкой
      Navigator.of(context).pop();

      // Находим новую головоломку, отличную от текущей
      MathPuzzle newPuzzle = PuzzleRepository.getRandomPuzzle();
      while (newPuzzle.question == currentPuzzle.question) {
        newPuzzle = PuzzleRepository.getRandomPuzzle();
      }

      // Показываем сообщение об ошибке
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Неправильно! Попробуйте еще раз.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );

      // Открываем новый диалог с новой головоломкой
      Future.delayed(const Duration(milliseconds: 500), () {
        _showPuzzleDialogInternal(trapX, trapY, newPuzzle);
      });
    }
  }

  void _showDoorDialog() {
    TextEditingController codeController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.grey[900],
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '🚪 Дверь заперта',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                const Icon(Icons.lock, color: Colors.red, size: 40),
                const SizedBox(height: 15),
                const Text(
                  'Введите код из сундука:',
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: codeController,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[800],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    hintText: 'Введите 4 цифры',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Отмена'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (codeController.text == _chestCode) {
                          // Правильный код - открываем дверь
                          setState(() {
                            _doorOpened = true;
                            // Заменяем все двери на проходы
                            for (int i = 0; i < mazeSize; i++) {
                              for (int j = 0; j < mazeSize; j++) {
                                if (maze[i][j] == 2) {
                                  maze[i][j] = 0;
                                }
                              }
                            }
                          });
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Дверь открыта!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          // Неправильный код
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Неверный код!'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Открыть'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _checkWinCondition() {
    // Победа, когда игрок достигает выхода [18,18]
    if (playerPosition[0] == 18 && playerPosition[1] == 18) {
      _showWinDialog();
    }
  }

  void _showWinDialog() {
    _timer.cancel(); // Останавливаем таймер при победе

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green, width: 3),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events, color: Colors.yellow, size: 60),
                const SizedBox(height: 20),
                const Text(
                  'ПОБЕДА!',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  'Ваше время: ${_formatTime(_elapsedTime)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Вы выбрались из лабиринта!',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                      child:
                          const Text('Выйти', style: TextStyle(fontSize: 16)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _resetGame();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                      child:
                          const Text('Заново', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _resetGame() {
    setState(() {
      playerPosition = [1, 1];
      _doorOpened = false;
      _showCodeDialog = false;
      _elapsedTime = Duration.zero;
      _generateChestCode();
      _startTimer();

      // Восстанавливаем исходную матрицу с дверями
      maze = [
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 1],
        [1, 0, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1],
        [1, 0, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1],
        [1, 5, 1, 1, 0, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 0, 1],
        [1, 0, 1, 1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1],
        [1, 0, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1],
        [1, 0, 0, 0, 0, 1, 0, 1, 1, 1, 0, 1, 5, 1, 0, 1, 4, 1, 0, 1],
        [1, 0, 1, 1, 1, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 1, 1],
        [1, 0, 1, 0, 0, 0, 0, 0, 4, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1],
        [1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1],
        [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1],
        [1, 1, 1, 1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1],
        [1, 0, 3, 1, 0, 1, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 1],
        [1, 0, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 0, 1, 0, 1],
        [1, 0, 1, 1, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 1, 1, 0, 1, 0, 1],
        [1, 0, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1],
        [1, 5, 1, 1, 0, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 5, 0, 0, 0, 4, 2, 0, 1],
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
      ];
    });
  }
}

// Painter с плавным затемнением и тёмно-зелёными стенами
class _MazeWithSmoothFogPainter extends CustomPainter {
  final List<List<int>> maze;
  final List<int> playerPosition;
  final double cellSize;
  final int viewDistance;
  final bool doorOpened;

  _MazeWithSmoothFogPainter({
    required this.maze,
    required this.playerPosition,
    required this.cellSize,
    required this.viewDistance,
    required this.doorOpened,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Игрок
    final playerPaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.fill;

    final playerGlowPaint = Paint()
      ..color = Colors.yellow.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    // Рисуем видимую область 7x7 (3 клетки в каждую сторону от игрока)
    for (int i = playerPosition[0] - viewDistance;
        i <= playerPosition[0] + viewDistance;
        i++) {
      for (int j = playerPosition[1] - viewDistance;
          j <= playerPosition[1] + viewDistance;
          j++) {
        // Координаты на холсте
        final double x = (j - (playerPosition[1] - viewDistance)) * cellSize;
        final double y = (i - (playerPosition[0] - viewDistance)) * cellSize;

        final rect = Rect.fromLTWH(x, y, cellSize, cellSize);

        // Рассчитываем расстояние от игрока для плавного затемнения
        double distance =
            _calculateDistance(i, j, playerPosition[0], playerPosition[1]);
        double opacity = _calculateOpacity(distance);

        // Проверяем границы лабиринта
        if (i >= 0 && i < maze.length && j >= 0 && j < maze[i].length) {
          int cellType = maze[i][j];

          if (cellType == 1) {
            // Стена с учетом затемнения
            final wallPaintWithOpacity = Paint()
              ..color = const Color(0xFF1B5E20).withOpacity(opacity)
              ..style = PaintingStyle.fill;

            final wallDetailPaintWithOpacity = Paint()
              ..color = const Color(0xFF2E7D32).withOpacity(opacity)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.0;

            canvas.drawRect(rect, wallPaintWithOpacity);
            canvas.drawRect(rect.deflate(1), wallDetailPaintWithOpacity);
          } else if (cellType == 0 || cellType == 5) {
            // Проход ИЛИ ловушка (выглядят одинаково) с учетом затемнения
            final pathPaintWithOpacity = Paint()
              ..color = const Color(0xFF121212).withOpacity(opacity)
              ..style = PaintingStyle.fill;

            canvas.drawRect(rect, pathPaintWithOpacity);
          } else if (cellType == 2) {
            // Дверь с учетом затемнения
            final doorPaintWithOpacity = Paint()
              ..color = (doorOpened
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFF795548))
                  .withOpacity(opacity)
              ..style = PaintingStyle.fill;

            canvas.drawRect(rect, doorPaintWithOpacity);

            // Рисуем значок двери
            if (!doorOpened) {
              final lockPaint = Paint()
                ..color = Colors.yellow.withOpacity(opacity)
                ..style = PaintingStyle.fill;

              final lockRect = Rect.fromCircle(
                center: Offset(x + cellSize / 2, y + cellSize / 2),
                radius: cellSize * 0.15,
              );
              canvas.drawOval(lockRect, lockPaint);
            }
          } else if (cellType == 3) {
            // Сундук с учетом затемнения
            final chestPaintWithOpacity = Paint()
              ..color = const Color(0xFFFFD700).withOpacity(opacity)
              ..style = PaintingStyle.fill;

            canvas.drawRect(rect, chestPaintWithOpacity);

            // Рисуем значок сундука
            final chestDetailPaint = Paint()
              ..color = const Color(0xFFB8860B).withOpacity(opacity)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5;

            canvas.drawRect(rect.deflate(cellSize * 0.2), chestDetailPaint);
          } else if (cellType == 4) {
            // Пустой сундук с учетом затемнения
            final emptyChestPaintWithOpacity = Paint()
              ..color = const Color(0xFF808080).withOpacity(opacity)
              ..style = PaintingStyle.fill;

            canvas.drawRect(rect, emptyChestPaintWithOpacity);

            // Рисуем значок пустого сундука
            final emptyChestDetailPaint = Paint()
              ..color = const Color(0xFF606060).withOpacity(opacity)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5;

            canvas.drawRect(
                rect.deflate(cellSize * 0.2), emptyChestDetailPaint);
          }
        } else {
          // За границами лабиринта - полная темнота
          final fogPaint = Paint()
            ..color = Colors.black.withOpacity(0.9)
            ..style = PaintingStyle.fill;

          canvas.drawRect(rect, fogPaint);
        }
      }
    }

    // Рисуем игрока (желтая точка в центре)
    final playerX = viewDistance * cellSize;
    final playerY = viewDistance * cellSize;
    final playerRect = Rect.fromCircle(
      center: Offset(playerX + cellSize / 2, playerY + cellSize / 2),
      radius: cellSize * 0.3,
    );

    // Свечение игрока
    canvas.drawOval(playerRect, playerGlowPaint);
    canvas.drawOval(playerRect, playerPaint);
  }

  double _calculateDistance(int x1, int y1, int x2, int y2) {
    return math.sqrt(math.pow(x1 - x2, 2) + math.pow(y1 - y2, 2)).toDouble();
  }

  double _calculateOpacity(double distance) {
    // Плавное уменьшение opacity от 1.0 на расстоянии 0 до 0.1 на расстоянии 3
    if (distance <= 1.0) return 1.0;
    if (distance >= viewDistance.toDouble()) return 0.1;

    return 1.0 - (distance / viewDistance) * 0.9;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
