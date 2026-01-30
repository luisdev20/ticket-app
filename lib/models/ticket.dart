import 'package:ticket_app/models/user.dart';

/// Modelo de Ticket que refleja la entidad Java del backend.
/// 
/// Incluye métodos fromJson y toJson para serialización/deserialización
/// de datos desde/hacia la API REST.
class Ticket {
  /// ID único del ticket (generado por la base de datos)
  final int? id;

  /// Título del ticket
  final String titulo;

  /// Descripción detallada del ticket
  final String descripcion;

  /// Nivel de prioridad del ticket
  final Prioridad prioridad;

  /// Estado actual del ticket
  final Estado estado;

  /// Fecha y hora de creación del ticket
  final DateTime? fechaCreacion;

  /// Usuario que creó el ticket (opcional)
  final User? usuario;

  Ticket({
    this.id,
    required this.titulo,
    required this.descripcion,
    required this.prioridad,
    required this.estado,
    this.fechaCreacion,
    this.usuario,
  });

  /// Crea un Ticket desde un JSON recibido de la API
  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] as int?,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String,
      prioridad: Prioridad.fromString(json['prioridad'] as String),
      estado: Estado.fromString(json['estado'] as String),
      fechaCreacion: json['fechaCreacion'] != null
          ? DateTime.parse(json['fechaCreacion'] as String)
          : null,
      usuario: json['usuario'] != null
          ? User.fromJson(json['usuario'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Convierte el Ticket a JSON para enviar a la API
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'prioridad': prioridad.toJson(),
      'estado': estado.toJson(),
      if (fechaCreacion != null)
        'fechaCreacion': fechaCreacion!.toIso8601String(),
      if (usuario != null) 'usuario': {'id': usuario!.id},
    };
  }

  /// Crea una copia del Ticket con campos modificados
  Ticket copyWith({
    int? id,
    String? titulo,
    String? descripcion,
    Prioridad? prioridad,
    Estado? estado,
    DateTime? fechaCreacion,
  }) {
    return Ticket(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      prioridad: prioridad ?? this.prioridad,
      estado: estado ?? this.estado,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }

  @override
  String toString() {
    return 'Ticket(id: $id, titulo: $titulo, prioridad: $prioridad, estado: $estado)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Ticket &&
        other.id == id &&
        other.titulo == titulo &&
        other.descripcion == descripcion &&
        other.prioridad == prioridad &&
        other.estado == estado &&
        other.fechaCreacion == fechaCreacion;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        titulo.hashCode ^
        descripcion.hashCode ^
        prioridad.hashCode ^
        estado.hashCode ^
        fechaCreacion.hashCode;
  }
}

/// Enum de Prioridad que refleja el enum Java
enum Prioridad {
  baja('BAJA'),
  media('MEDIA'),
  alta('ALTA');

  final String value;

  const Prioridad(this.value);

  /// Convierte el enum a String para JSON
  String toJson() => value;

  /// Crea un Prioridad desde un String del JSON
  static Prioridad fromString(String value) {
    switch (value.toUpperCase()) {
      case 'BAJA':
        return Prioridad.baja;
      case 'MEDIA':
        return Prioridad.media;
      case 'ALTA':
        return Prioridad.alta;
      default:
        throw ArgumentError('Prioridad no válida: $value');
    }
  }

  /// Obtiene el nombre en español para mostrar en la UI
  String get displayName {
    switch (this) {
      case Prioridad.baja:
        return 'Baja';
      case Prioridad.media:
        return 'Media';
      case Prioridad.alta:
        return 'Alta';
    }
  }
}

/// Enum de Estado que refleja el enum Java
enum Estado {
  abierto('ABIERTO'),
  enProceso('EN_PROCESO'),
  cerrado('CERRADO');

  final String value;

  const Estado(this.value);

  /// Convierte el enum a String para JSON
  String toJson() => value;

  /// Crea un Estado desde un String del JSON
  static Estado fromString(String value) {
    switch (value.toUpperCase()) {
      case 'ABIERTO':
        return Estado.abierto;
      case 'EN_PROCESO':
        return Estado.enProceso;
      case 'CERRADO':
        return Estado.cerrado;
      default:
        throw ArgumentError('Estado no válido: $value');
    }
  }

  /// Obtiene el nombre en español para mostrar en la UI
  String get displayName {
    switch (this) {
      case Estado.abierto:
        return 'Abierto';
      case Estado.enProceso:
        return 'En Proceso';
      case Estado.cerrado:
        return 'Cerrado';
    }
  }
}
