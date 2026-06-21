import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/antrian_model.dart';
import '../models/service_model.dart';

class ApiService {
  static const String baseUrl = "http://192.168.18.53:8000/api";

  // ====================================
  // LOGIN
  // ====================================
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({"email": email, "password": password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Login gagal');
    }
  }

  // ====================================
  // AMBIL SEMUA ANTRIAN (DASHBOARD)
  // ====================================
  static Future<List<Antrian>> getAntrian(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/antrians"),
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    final data = jsonDecode(response.body);
    final List list = (data is Map && data['data'] != null)
        ? data['data']
        : data;

    return list.map((e) => Antrian.fromJson(e)).toList();
  }

  // ====================================
  // GET LAYANAN (DIPERLUKAN OLEH HOME_SCREEN)
  // ====================================
  static Future<List<dynamic>> getLayanan(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/services"),
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = (data is Map && data['data'] != null)
          ? data['data']
          : data;
      return list;
    } else {
      throw Exception('Gagal mengambil data layanan');
    }
  }

  // ====================================
  // GET SERVICES (MODEL MODE)
  // ====================================
  static Future<List<Service>> getServices(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/services"),
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    final data = jsonDecode(response.body);
    final List list = (data is Map && data['data'] != null)
        ? data['data']
        : data;

    return list.map((e) => Service.fromJson(e)).toList();
  }

  // ====================================
  // CREATE ANTRIAN
  // ====================================
  static Future<Map<String, dynamic>> createAntrian({
    required String token,
    required String nama,
    required String nim,
    required String keperluan,
    required int serviceId,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/antrians"),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
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

    // Decode dulu responnya
    final data = jsonDecode(response.body);

    // Cek Status Code
    if (response.statusCode == 200 || response.statusCode == 201) {
      // Berhasil
      return data['data'] ?? data;
    } else if (response.statusCode == 400) {
      // Error khusus (seperti: "Anda masih memiliki antrean aktif")
      // Ini yang akan ditangkap oleh catch (e) di UI
      throw Exception(data['message'] ?? 'Data tidak valid');
    } else {
      // Error server lain
      throw Exception(data['message'] ?? 'Gagal membuat antrian');
    }
  }

  // ====================================
  // UPDATE ANTRIAN (DENGAN STATUS)
  // ====================================
  static Future<bool> updateAntrian({
    required String token,
    required int id,
    required String nama,
    required String keperluan,
    required String layanan,
  }) async {
    final response = await http.put(
      Uri.parse("$baseUrl/antrians/$id"),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "nama": nama,
        "keperluan": keperluan,
        "layanan": layanan,
      }),
    );

    return response.statusCode == 200;
  }

  // ====================================
  // DELETE ANTRIAN
  // ====================================
  static Future<bool> deleteAntrian({
    required int id,
    required String token,
  }) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/antrians/$id"),
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    return response.statusCode == 200;
  }

  // ====================================
  // MY ANTRIAN
  // ====================================
  static Future<List<Antrian>> getMyAntrian(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/my-antrian"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    final data = jsonDecode(response.body);
    final List list = (data is Map && data['data'] != null)
        ? data['data']
        : data;

    return list.map((e) => Antrian.fromJson(e)).toList();
  }
}
