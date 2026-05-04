import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/antrian_model.dart';

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000/api";

  static Future<List<Antrian>> getAntrian() async {
    final response = await http.get(Uri.parse("$baseUrl/antrians"));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List list = data['data'];

      return list.map((e) => Antrian.fromJson(e)).toList();
    } else {
      throw Exception('Gagal ambil data');
    }
  }
}
