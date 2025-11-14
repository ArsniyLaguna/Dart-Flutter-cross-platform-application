import 'package:flutter/material.dart';
import 'scary_maze_screen.dart';
import 'scary_maze_screen.dart';

class GameSelectionScreen extends StatelessWidget {
  final String username;

  const GameSelectionScreen({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Выбор игры',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutDialog(context);
              } else if (value == 'profile') {
                _showProfileDialog(context);
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 8),
                    Text('Профиль'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Выйти', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Приветствие
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Привет, $username!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Выберите игру:',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Сетка игр
// Сетка игр
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12, // Уменьшили расстояние
                mainAxisSpacing: 12, // Уменьшили расстояние
                padding: const EdgeInsets.all(12), // Уменьшили padding
                childAspectRatio: 0.9, // Соотношение сторон карточек
                children: [
                  // В сетке игр замените карточку лабиринта:
                  _GameCard(
                    title: 'Жуткий Лабиринт',
                    icon: Icons.psychology,
                    color: Colors.red,
                    description: 'Найди способ выбраться',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ScaryMazeScreen(),
                        ),
                      );
                    },
                  ),
                  // Игра 2: Викторина (заглушка)
                  _GameCard(
                    title: 'Викторина',
                    icon: Icons.quiz,
                    color: Colors.green,
                    description: 'Проверьте свои знания',
                    onTap: () {
                      _showComingSoonDialog(context, 'Викторина');
                    },
                  ),

                  // Игра 3: Пазл (заглушка)
                  _GameCard(
                    title: 'Пазл',
                    icon: Icons.extension,
                    color: Colors.orange,
                    description: 'Соберите картинку',
                    onTap: () {
                      _showComingSoonDialog(context, 'Пазл');
                    },
                  ),

                  // Игра 4: Реакция (заглушка)
                  _GameCard(
                    title: 'Реакция',
                    icon: Icons.timer,
                    color: Colors.purple,
                    description: 'Тест на скорость реакции',
                    onTap: () {
                      _showComingSoonDialog(context, 'Реакция');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Выход'),
          content: const Text('Вы уверены, что хотите выйти?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Возвращаемся на экран приветствия
                Navigator.pushNamedAndRemoveUntil(
                    context, '/', (route) => false);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Выйти'),
            ),
          ],
        );
      },
    );
  }

  void _showProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Профиль'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Имя: $username'),
              const SizedBox(height: 10),
              const Text('Статус: Игрок'),
              const SizedBox(height: 10),
              const Text('Игр сыграно: 0'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Закрыть'),
            ),
          ],
        );
      },
    );
  }

  void _showComingSoonDialog(BuildContext context, String gameName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Скоро будет доступно'),
          content: Text('Игра "$gameName" находится в разработке.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

// Виджет карточки игры
class _GameCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String description;
  final VoidCallback onTap;

  const _GameCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[800],
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12.0), // Уменьшили padding
          constraints: const BoxConstraints(
            minHeight: 140, // Фиксированная минимальная высота
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 40, // Уменьшили иконку
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16, // Уменьшили шрифт
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 1, // Ограничили в одну строку
                overflow: TextOverflow.ellipsis, // Троеточие если не помещается
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 11, // Уменьшили шрифт описания
                  color: Colors.grey[400],
                  height: 1.2, // Уменьшили межстрочный интервал
                ),
                textAlign: TextAlign.center,
                maxLines: 2, // Ограничили в две строки
                overflow: TextOverflow.ellipsis, // Троеточие если не помещается
              ),
            ],
          ),
        ),
      ),
    );
  }
}
