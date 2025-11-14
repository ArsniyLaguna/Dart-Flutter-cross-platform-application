import 'package:flutter/material.dart';
import 'api_service.dart';

class AuthService with ChangeNotifier {
  bool _isLoggedIn = false;
  String? _username;
  String? _email;

  bool get isLoggedIn => _isLoggedIn;
  String? get username => _username;
  String? get email => _email;

  // Метод для регистрации
  Future<void> register(String username, String email, String password) async {
    try {
      final response = await ApiService.registerUser(
        username: username,
        email: email,
        password: password,
      );

      if (response['status'] == 'success') {
        _isLoggedIn = true;
        _username = username;
        _email = email;
        notifyListeners();
      } else {
        throw Exception(response['message']);
      }
    } catch (e) {
      throw Exception('Ошибка регистрации: $e');
    }
  }

  // Метод для входа
  Future<void> login(String email, String password) async {
    try {
      final response = await ApiService.loginUser(
        email: email,
        password: password,
      );

      if (response['status'] == 'success') {
        _isLoggedIn = true;
        _username = response['data']['username'];
        _email = email;
        notifyListeners();
      } else {
        throw Exception(response['message']);
      }
    } catch (e) {
      throw Exception('Ошибка входа: $e');
    }
  }

  // Метод для выхода
  void logout() {
    _isLoggedIn = false;
    _username = null;
    _email = null;
    notifyListeners();
  }

  // Метод для гостевого входа
  void guestLogin() {
    _isLoggedIn = true;
    _username = 'Гость';
    _email = null;
    notifyListeners();
  }
}
