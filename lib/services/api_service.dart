import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/antrian_model.dart';
import '../models/service_model.dart';

class ApiService {
  static const String baseUrl = "http://localhost:8000/api";

  // ====================================
  // GET DATA ANTRIAN
  // ====================================
  static Future<List<Antrian>> getAntrian() async {
    final response = await http.get(Uri.parse("$baseUrl/antrians"));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      List list = data['data'];

      return list.map((e) => Antrian.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil data antrian');
    }
  }

  // ====================================
  // GET DATA LAYANAN
  // ====================================
  static Future<List<Service>> getServices() async {
    final response = await http.get(Uri.parse("$baseUrl/services"));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      List list = data['data'];

      return list.map((e) => Service.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil data layanan');
    }
  }

  // ====================================
  // TAMBAH DATA ANTRIAN (REVISI MENGEMBALIKAN DATA JSON)
  // ====================================
  static Future<Map<String, dynamic>> createAntrian({
    required String nama,
    required String nim,
    required String keperluan,
    required int serviceId,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/antrians"),
      headers: {
        "Content-Type": "application/json",
        "Accept":
            "application/json", // Ditambahkan agar Laravel otomatis merespon format JSON jika eror
      },
      body: jsonEncode({
        "nama": nama,
        "nim": nim,
        "keperluan": keperluan,
        "service_id": serviceId,
        "queue_date": DateTime.now().toString().substring(0, 10),
        "status": "waiting",
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Mengembalikan response body berupa JSON Map dari Laravel agar bisa dibaca di Screen
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal menambah data antrian');
    }
  }

  // ✏️ Fungsi untuk Mengubah Data Antrean (API PUT)
  static Future<bool> updateAntrian(
    int id,
    String nama,
    String keperluan,
    String layanan,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/antrian/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nama': nama,
          'keperluan': keperluan,
          'layanan': layanan,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 🗑️ Fungsi untuk Membatalkan/Menghapus Antrean (API DELETE)
  static Future<bool> deleteAntrian(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/antrian/$id'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
