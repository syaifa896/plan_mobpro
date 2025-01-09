import 'dart:convert';
import 'package:http/http.dart' as http;

class LogicAPI {
  static Future<bool> hapusTugas(String idTugas) async {
    final url = 'https://api.nstack.in/v1/todos/$idTugas';
    final uri = Uri.parse(url);
    final response = await http.delete(uri);
    return response.statusCode == 200;
  }

  static Future<List?> ambilTugas() async {
    final url = 'https://api.nstack.in/v1/todos?page=1&limit=10';
    final uri = Uri.parse(url);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final result = json['items'] as List;
      return result;
    } else {
      return null;
    }
  }

  static Future<bool> editTugas(String idnya, Map body) async {
    final url = 'https://api.nstack.in/v1/todos/$idnya';
    final uri = Uri.parse(url);
    final response = await http.put(uri,
        body: jsonEncode(body), headers: {'Content-Type': 'application/json'});
    return response.statusCode == 200;
  }

  static Future<bool> tambahTugas(Map body) async {
    final url = 'https://api.nstack.in/v1/todos/';
    final uri = Uri.parse(url);
    final response = await http.post(uri,
        body: jsonEncode(body), headers: {'Content-Type': 'application/json'});
    return response.statusCode == 201;
  }
}
