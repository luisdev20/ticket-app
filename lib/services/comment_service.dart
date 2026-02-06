import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ticket_app/models/comment_model.dart';

class CommentService {
  static const String baseUrl = 'http://10.0.2.2:8081/api';

  /// Obtiene todos los comentarios de un ticket
  static Future<List<Comment>> fetchCommentsByTicket(int ticketId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tickets/$ticketId/comentarios'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Comment.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar comentarios: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al cargar comentarios: $e');
    }
  }

  /// Crea un nuevo comentario en un ticket
  static Future<Comment> createComment(int ticketId, String texto) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/tickets/$ticketId/comentarios'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'texto': texto,
          'usuarioId': userId,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Comment.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al crear comentario: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al crear comentario: $e');
    }
  }
}
