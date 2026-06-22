import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/antrian_model.dart';
import '../services/api_service.dart';

import 'add_antrian_screen.dart';
import 'my_antrian_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final String token;

  const HomeScreen({super.key, required this.token});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 🟢 REVISI: Timer 10 detik sudah dihapus dari sini

  int _currentIndex = 0;
  final List<String> _titles = ["Dashboard", "My Antrian", "Profile"];

  final List<Color> _cardColors = [
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.green,
    Colors.teal,
    Colors.pink,
  ];

  @override
  void initState() {
    super.initState();
    // 🟢 REVISI: Logika Timer.periodic 10 detik sudah dibersihkan total dari sini
  }

  @override
  void dispose() {
    // 🟢 REVISI: Pembersihan timer sudah dihapus agar tidak error berkelanjutan
    super.dispose();
  }

  // MEMPERTAHANKAN BLOK KODE UNTUK AMBIL DATA USER
  Future<Map<String, String>> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      "name": prefs.getString('user_name') ?? "Mahasiswa",
      "nim": prefs.getString('user_nim') ?? "-",
      "email": prefs.getString('user_email') ?? "-",
    };
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildAntrianList();
      case 1:
        return MyAntrianScreen(token: widget.token);
      case 2:
        return const ProfileScreen();
      default:
        return _buildAntrianList();
    }
  }

  Widget _buildAntrianList() {
    return FutureBuilder<Map<String, String>>(
      future: getUser(),
      builder: (context, userSnapshot) {
        final user = userSnapshot.data ?? {"name": "Mahasiswa", "nim": "-"};

        return FutureBuilder<List<dynamic>>(
          future: Future.wait([
            ApiService.getAntrian(widget.token),
            ApiService.getLayanan(widget.token),
          ]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            final List<Antrian> antrianList = snapshot.data?[0] ?? [];
            final List<dynamic> layananList = snapshot.data?[1] ?? [];

            // Mempertahankan Debug Hasil Pencocokan Layanan
            for (var layanan in layananList) {
              print(
                "SERVICE: ${layanan['service_name']} (${layanan['service_code']})",
              );
            }

            // 🔥 SEKARANG HANYA MENGGUNAKAN MANUAL PULL-TO-REFRESH DI SINI
            return RefreshIndicator(
              onRefresh: () async {
                setState(() {});
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER USER INFO
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(15),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade700,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Selamat Datang 👋",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user["name"]!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "NIM: ${user["nim"]!}",
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 5,
                      ),
                      child: Text(
                        "===== STATUS LAYANAN =====",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    // Grid Status Layanan Dinamis
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 11),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final cardWidth = (constraints.maxWidth - 16) / 2;
                          return Wrap(
                            spacing: 0,
                            runSpacing: 2,
                            children: List.generate(layananList.length, (
                              index,
                            ) {
                              final layanan = layananList[index];

                              final String namaLayanan =
                                  (layanan['service_name'] ?? '').toString();
                              final String kodeLayanan =
                                  (layanan['service_code'] ?? '').toString();

                              // Log dipastikan tetap masuk per item grid
                              print(
                                "Layanan: $namaLayanan | Kode: $kodeLayanan",
                              );

                              final numSedangDilayani = _getSedangDilayani(
                                antrianList,
                                kodeLayanan,
                              );
                              final color =
                                  _cardColors[index % _cardColors.length];

                              return SizedBox(
                                width: cardWidth,
                                child: _buildStatusCard(
                                  namaLayanan,
                                  numSedangDilayani,
                                  color,
                                ),
                              );
                            }),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 15),

                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 5,
                      ),
                      child: Text(
                        "===== DAFTAR LAYANAN KAMPUS =====",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    // Daftar Pilihan Layanan Katalog Promosi
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        children: List.generate(layananList.length, (index) {
                          final layanan = layananList[index];

                          final String namaLayanan =
                              (layanan['service_name'] ?? '').toString();
                          final color = _cardColors[index % _cardColors.length];

                          return _buildLayananPromosiCard(namaLayanan, color);
                        }),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Fungsi pemindai nomor antrean tetap dipertahankan aman
  String _getSedangDilayani(List<Antrian> data, String serviceCode) {
    for (var item in data) {
      print("MENCARI ANTRIAN -> ${item.queueNumber} | ${item.status}");

      if (item.queueNumber.toUpperCase().startsWith(
            serviceCode.toUpperCase(),
          ) &&
          item.status.toLowerCase() == 'process') {
        return item.queueNumber;
      }
    }
    return "-";
  }

  Widget _buildStatusCard(String title, String queueNum, Color color) {
    return Container(
      height: 95,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 5)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              "Sedang Dilayani :",
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 2),
            Text(
              queueNum,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLayananPromosiCard(String title, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(Icons.check_circle_outline, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: const Text(
          "Layanan aktif & beroperasi pada hari kerja.",
          style: TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ),
    );
  }

  void _bukaHalamanTambahAntrian() async {
    final result = await Navigator.push<int>(
      context,
      MaterialPageRoute(builder: (_) => AddAntrianScreen(token: widget.token)),
    );

    if (result == 1) {
      setState(() {
        _currentIndex = 1;
      });
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_currentIndex],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _buildBody(),

      // Tombol FAB (+) Dipertahankan Utuh
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              onPressed: () => _bukaHalamanTambahAntrian(),
              child: const Icon(Icons.add),
            )
          : null,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue.shade700,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: "My Antrian",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
