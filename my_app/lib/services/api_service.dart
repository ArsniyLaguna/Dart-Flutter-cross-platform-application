import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl =
      'https://script.google.com/macros/s/AKfycbzAnWgQijDKReC9o17iqxfiu0x-AaNpuhvEHur1DcQWCgfbv8F1z_0pQy3Fu9kiLpVj/exec';

  static Future<Map<String, dynamic>> registerUser({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      print('🚀 Отправка запроса регистрации...');
      print('👤 Username: $username');
      print('📧 Email: $email');

      // Используем GET запрос с параметрами в URL
      final uri = Uri.parse(_baseUrl).replace(
        queryParameters: {
          'action': 'register',
          'username': username,
          'email': email,
          'password': password,
        },
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 30));

      print('📡 Статус ответа: ${response.statusCode}');
      print('📨 Тело ответа: ${response.body}');

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        print('✅ Ответ от сервера: $result');

        if (result['status'] == 'success') {
          return result;
        } else {
          throw Exception(result['message']);
        }
      } else {
        throw Exception('Ошибка сервера: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Ошибка: $e');
      throw Exception('Ошибка регистрации: $e');
    }
  }

  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      print('🚀 Отправка запроса входа...');
      print('📧 Email: $email');

      final uri = Uri.parse(_baseUrl).replace(
        queryParameters: {
          'action': 'login',
          'email': email,
          'password': password,
        },
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 30));

      print('📡 Статус ответа: ${response.statusCode}');
      print('📨 Тело ответа: ${response.body}');

      if (response.statusCode == 200) {
        final result = json.decode(response.body);

        if (result['status'] == 'success') {
          return result;
        } else {
          throw Exception(result['message']);
        }
      } else {
        throw Exception('Ошибка сервера: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка входа: $e');
    }
  }
}
