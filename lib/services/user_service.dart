import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:ticket_app/models/user.dart';

/// Servicio para interactuar con la API REST de usuarios
class UserService {
  /// URL base de la API de usuarios
  /// 
  /// Nota: En Android emulador, localhost no funciona.
  /// Se debe usar 10.0.2.2 que es la IP especial del emulador
  /// para acceder al localhost de la máquina host.
  static String get baseUrl {
    // Detectar si estamos en Android
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8081/api/usuarios';
    }
    // Para iOS, Windows, Web, etc., usar localhost
    return 'http://localhost:8081/api/usuarios';
  }

  /// Headers comunes para las peticiones HTTP
  static final Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
  };

  /// Obtiene todos los usuarios desde el backend
  /// 
  /// Retorna una lista de [User] o lanza una excepción si falla.
  /// 
  /// Ejemplo:
  /// ```dart
  /// try {
  ///   final usuarios = await UserService.fetchUsers();
  ///   print('Usuarios obtenidos: ${usuarios.length}');
  /// } catch (e) {
  ///   print('Error al obtener usuarios: $e');
  /// }
  /// ```
  static Future<List<User>> fetchUsers() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        // Decodificar el JSON
        final List<dynamic> jsonList = json.decode(utf8.decode(response.bodyBytes));
        
        // Convertir cada JSON a un objeto User
        return jsonList.map((json) => User.fromJson(json)).toList();
      } else {
        throw UserServiceException(
          'Error al obtener usuarios: ${response.statusCode}',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }
    } on SocketException {
      throw UserServiceException(
        'No se pudo conectar al servidor. Verifica que el backend esté corriendo en $baseUrl',
      );
    } catch (e) {
      if (e is UserServiceException) rethrow;
      throw UserServiceException('Error inesperado: $e');
    }
  }

  /// Obtiene un usuario específico por su ID
  /// 
  /// Parámetros:
  /// - [id]: El ID del usuario a obtener
  /// 
  /// Retorna el [User] encontrado o lanza una excepción si no existe.
  static Future<User> getUserById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = 
            json.decode(utf8.decode(response.bodyBytes));
        return User.fromJson(jsonResponse);
      } else if (response.statusCode == 404) {
        throw UserServiceException(
          'Usuario con ID $id no encontrado',
          statusCode: 404,
        );
      } else {
        throw UserServiceException(
          'Error al obtener usuario: ${response.statusCode}',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }
    } on SocketException {
      throw UserServiceException(
        'No se pudo conectar al servidor. Verifica que el backend esté corriendo en $baseUrl',
      );
    } catch (e) {
      if (e is UserServiceException) rethrow;
      throw UserServiceException('Error inesperado: $e');
    }
  }

  /// Crea un nuevo usuario en el backend
  /// 
  /// Parámetros:
  /// - [user]: El usuario a crear (sin ID, ya que lo genera el backend)
  /// 
  /// Retorna el [User] creado con su ID asignado por el backend.
  static Future<User> createUser(User user) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: _headers,
        body: json.encode(user.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Decodificar el JSON del usuario creado
        final Map<String, dynamic> jsonResponse = 
            json.decode(utf8.decode(response.bodyBytes));
        
        // Retornar el usuario con el ID asignado por el backend
        return User.fromJson(jsonResponse);
      } else {
        throw UserServiceException(
          'Error al crear usuario: ${response.statusCode}',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }
    } on SocketException {
      throw UserServiceException(
        'No se pudo conectar al servidor. Verifica que el backend esté corriendo en $baseUrl',
      );
    } catch (e) {
      if (e is UserServiceException) rethrow;
      throw UserServiceException('Error inesperado: $e');
    }
  }
}

/// Excepción personalizada para errores del servicio de usuarios
class UserServiceException implements Exception {
  final String message;
  final int? statusCode;
  final String? responseBody;

  UserServiceException(
    this.message, {
    this.statusCode,
    this.responseBody,
  });

  @override
  String toString() {
    final buffer = StringBuffer('UserServiceException: $message');
    if (statusCode != null) {
      buffer.write(' (Status: $statusCode)');
    }
    if (responseBody != null && responseBody!.isNotEmpty) {
      buffer.write('\nRespuesta: $responseBody');
    }
    return buffer.toString();
  }
}
