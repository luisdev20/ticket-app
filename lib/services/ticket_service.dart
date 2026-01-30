import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:ticket_app/models/ticket.dart';

/// Servicio para interactuar con la API REST de tickets
class TicketService {
  /// URL base de la API
  /// 
  /// Nota: En Android emulador, localhost no funciona.
  /// Se debe usar 10.0.2.2 que es la IP especial del emulador
  /// para acceder al localhost de la máquina host.
  static String get baseUrl {
    // Detectar si estamos en Android
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8081/api/tickets';
    }
    // Para iOS, Windows, Web, etc., usar localhost
    return 'http://localhost:8081/api/tickets';
  }

  /// Headers comunes para las peticiones HTTP
  static final Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
  };

  /// Obtiene todos los tickets desde el backend
  /// 
  /// Retorna una lista de [Ticket] o lanza una excepción si falla.
  /// 
  /// Ejemplo:
  /// ```dart
  /// try {
  ///   final tickets = await TicketService.fetchTickets();
  ///   print('Tickets obtenidos: ${tickets.length}');
  /// } catch (e) {
  ///   print('Error al obtener tickets: $e');
  /// }
  /// ```
  static Future<List<Ticket>> fetchTickets() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        // Decodificar el JSON
        final List<dynamic> jsonList = json.decode(utf8.decode(response.bodyBytes));
        
        // Convertir cada JSON a un objeto Ticket
        return jsonList.map((json) => Ticket.fromJson(json)).toList();
      } else {
        throw TicketServiceException(
          'Error al obtener tickets: ${response.statusCode}',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }
    } on SocketException {
      throw TicketServiceException(
        'No se pudo conectar al servidor. Verifica que el backend esté corriendo en $baseUrl',
      );
    } catch (e) {
      if (e is TicketServiceException) rethrow;
      throw TicketServiceException('Error inesperado: $e');
    }
  }

  /// Crea un nuevo ticket en el backend
  /// 
  /// Parámetros:
  /// - [ticket]: El ticket a crear (sin ID, ya que lo genera el backend)
  /// 
  /// Retorna el [Ticket] creado con su ID asignado por el backend.
  /// 
  /// Ejemplo:
  /// ```dart
  /// final nuevoTicket = Ticket(
  ///   titulo: 'Bug en login',
  ///   descripcion: 'El botón no responde',
  ///   prioridad: Prioridad.alta,
  ///   estado: Estado.abierto,
  /// );
  /// 
  /// try {
  ///   final ticketCreado = await TicketService.createTicket(nuevoTicket);
  ///   print('Ticket creado con ID: ${ticketCreado.id}');
  /// } catch (e) {
  ///   print('Error al crear ticket: $e');
  /// }
  /// ```
  static Future<Ticket> createTicket(Ticket ticket) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: _headers,
        body: json.encode(ticket.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Decodificar el JSON del ticket creado
        final Map<String, dynamic> jsonResponse = 
            json.decode(utf8.decode(response.bodyBytes));
        
        // Retornar el ticket con el ID asignado por el backend
        return Ticket.fromJson(jsonResponse);
      } else {
        throw TicketServiceException(
          'Error al crear ticket: ${response.statusCode}',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }
    } on SocketException {
      throw TicketServiceException(
        'No se pudo conectar al servidor. Verifica que el backend esté corriendo en $baseUrl',
      );
    } catch (e) {
      if (e is TicketServiceException) rethrow;
      throw TicketServiceException('Error inesperado: $e');
    }
  }

  /// Obtiene un ticket específico por su ID
  /// 
  /// Parámetros:
  /// - [id]: El ID del ticket a obtener
  /// 
  /// Retorna el [Ticket] encontrado o lanza una excepción si no existe.
  static Future<Ticket> getTicketById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = 
            json.decode(utf8.decode(response.bodyBytes));
        return Ticket.fromJson(jsonResponse);
      } else if (response.statusCode == 404) {
        throw TicketServiceException(
          'Ticket con ID $id no encontrado',
          statusCode: 404,
        );
      } else {
        throw TicketServiceException(
          'Error al obtener ticket: ${response.statusCode}',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }
    } on SocketException {
      throw TicketServiceException(
        'No se pudo conectar al servidor. Verifica que el backend esté corriendo en $baseUrl',
      );
    } catch (e) {
      if (e is TicketServiceException) rethrow;
      throw TicketServiceException('Error inesperado: $e');
    }
  }

  /// Actualiza un ticket existente
  /// 
  /// Parámetros:
  /// - [id]: El ID del ticket a actualizar
  /// - [ticket]: El ticket con los datos actualizados
  /// 
  /// Retorna el [Ticket] actualizado.
  static Future<Ticket> updateTicket(int id, Ticket ticket) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: _headers,
        body: json.encode(ticket.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = 
            json.decode(utf8.decode(response.bodyBytes));
        return Ticket.fromJson(jsonResponse);
      } else if (response.statusCode == 404) {
        throw TicketServiceException(
          'Ticket con ID $id no encontrado',
          statusCode: 404,
        );
      } else {
        throw TicketServiceException(
          'Error al actualizar ticket: ${response.statusCode}',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }
    } on SocketException {
      throw TicketServiceException(
        'No se pudo conectar al servidor. Verifica que el backend esté corriendo en $baseUrl',
      );
    } catch (e) {
      if (e is TicketServiceException) rethrow;
      throw TicketServiceException('Error inesperado: $e');
    }
  }

  /// Elimina un ticket por su ID
  /// 
  /// Parámetros:
  /// - [id]: El ID del ticket a eliminar
  /// 
  /// Retorna `true` si se eliminó correctamente.
  static Future<bool> deleteTicket(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: _headers,
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 404) {
        throw TicketServiceException(
          'Ticket con ID $id no encontrado',
          statusCode: 404,
        );
      } else {
        throw TicketServiceException(
          'Error al eliminar ticket: ${response.statusCode}',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }
    } on SocketException {
      throw TicketServiceException(
        'No se pudo conectar al servidor. Verifica que el backend esté corriendo en $baseUrl',
      );
    } catch (e) {
      if (e is TicketServiceException) rethrow;
      throw TicketServiceException('Error inesperado: $e');
    }
  }
}

/// Excepción personalizada para errores del servicio de tickets
class TicketServiceException implements Exception {
  final String message;
  final int? statusCode;
  final String? responseBody;

  TicketServiceException(
    this.message, {
    this.statusCode,
    this.responseBody,
  });

  @override
  String toString() {
    final buffer = StringBuffer('TicketServiceException: $message');
    if (statusCode != null) {
      buffer.write(' (Status: $statusCode)');
    }
    if (responseBody != null && responseBody!.isNotEmpty) {
      buffer.write('\nRespuesta: $responseBody');
    }
    return buffer.toString();
  }
}
