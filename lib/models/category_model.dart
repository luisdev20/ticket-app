class Category {
  final int? id;
  final String nombre;

  Category({
    this.id,
    required this.nombre,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      nombre: json['nombre'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
    };
  }

  @override
  String toString() => 'Category(id: $id, nombre: $nombre)';
}
