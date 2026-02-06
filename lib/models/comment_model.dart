class Comment {
  final int? id;
  final String texto;
  final DateTime fecha;
  final int ticketId;
  final int usuarioId;
  final String? usuarioNombre;

  Comment({
    this.id,
    required this.texto,
    required this.fecha,
    required this.ticketId,
    required this.usuarioId,
    this.usuarioNombre,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      texto: json['texto'],
      fecha: DateTime.parse(json['fecha']),
      ticketId: json['ticket']['id'],
      usuarioId: json['usuario']['id'],
      usuarioNombre: json['usuario']['nombre'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'texto': texto,
      'fecha': fecha.toIso8601String(),
      'ticketId': ticketId,
      'usuarioId': usuarioId,
    };
  }

  @override
  String toString() => 'Comment(id: $id, texto: $texto, fecha: $fecha)';
}
