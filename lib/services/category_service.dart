import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ticket_app/models/category_model.dart';

class CategoryService {
  static const String baseUrl = 'http://10.0.2.2:8081/api/categorias';

  /// Obtiene todas las categorías desde el backend
  static Future<List<Category>> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar categorías: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al cargar categorías: $e');
    }
  }

  /// Obtiene una categoría por su ID
  static Future<Category> fetchCategoryById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$id'));

      if (response.statusCode == 200) {
        return Category.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al cargar categoría: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al cargar categoría: $e');
    }
  }
}
