/// Enum que representa los roles de usuario en el sistema
enum Rol {
  cliente('CLIENTE'),
  tecnico('TECNICO');

  final String value;
  const Rol(this.value);

  /// Convierte un string a un enum Rol
  static Rol fromString(String value) {
    switch (value.toUpperCase()) {
      case 'CLIENTE':
        return Rol.cliente;
      case 'TECNICO':
        return Rol.tecnico;
      default:
        throw ArgumentError('Rol no válido: $value');
    }
  }

  /// Convierte el enum a string para JSON
  String toJson() => value;

  /// Nombre para mostrar en la UI
  String get displayName {
    switch (this) {
      case Rol.cliente:
        return 'Cliente';
      case Rol.tecnico:
        return 'Técnico';
    }
  }
}

/// Modelo que representa un Usuario en el sistema
class User {
  final int? id;
  final String nombre;
  final String email;
  final String? password;
  final Rol rol;

  User({
    this.id,
    required this.nombre,
    required this.email,
    this.password,
    required this.rol,
  });

  /// Crea un User desde un JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int?,
      nombre: json['nombre'] as String,
      email: json['email'] as String,
      password: json['password'] as String?,
      rol: Rol.fromString(json['rol'] as String),
    );
  }

  /// Convierte el User a JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'email': email,
      if (password != null) 'password': password,
      'rol': rol.toJson(),
    };
  }

  @override
  String toString() {
    return 'User{id: $id, nombre: $nombre, email: $email, rol: ${rol.displayName}}';
  }
}
