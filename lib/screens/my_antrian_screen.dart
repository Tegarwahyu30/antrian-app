import 'dart:async';
import 'package:flutter/material.dart';
import '../models/antrian_model.dart';
import '../services/api_service.dart';

class MyAntrianScreen extends StatefulWidget {
  final String token;

  const MyAntrianScreen({super.key, required this.token});

  @override
  State<MyAntrianScreen> createState() => _MyAntrianScreenState();
}

class _MyAntrianScreenState extends State<MyAntrianScreen> {
  late Future<List<Antrian>> futureAntrian;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();

    loadData();

    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        setState(() {
          loadData();
        });
      }
    });
  }

  void loadData() {
    futureAntrian = ApiService.getMyAntrian(widget.token);
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'waiting':
        return Colors.orange.shade700;
      case 'process':
        return Colors.blue.shade700;
      case 'done':
        return Colors.green.shade700;
      case 'cancel':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade600;
    }
  }

  // ====================================
  // 🗑️ FUNGSI UNTUK AKSI DELETE (BATAL)
  // ====================================
  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text("Batalkan Antrean?"),
        content: const Text(
          "Apakah Anda yakin ingin membatalkan antrean ini? Data akan dihapus dari sistem harian.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Kembali", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // Tutup dialog konfirmasi

              // Tampilkan Loading Spinner
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) =>
                    const Center(child: CircularProgressIndicator()),
              );

              // 🌟 TRICK: Ambil referensi State sebelum masuk ke celah asinkronus (await)
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              try {
                bool success = await ApiService.deleteAntrian(
                  id: id,
                  token: widget.token,
                );

                // Gunakan referensi yang sudah disimpan aman (bebas dari error deactivated widget)
                navigator.pop(); // Tutup loading

                if (success) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text("Antrean berhasil dibatalkan!"),
                    ),
                  );
                  if (mounted) {
                    setState(() {
                      loadData(); // Refresh data halaman
                    });
                  }
                } else {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text("Gagal membatalkan antrean.")),
                  );
                }
              } catch (e) {
                navigator.pop(); // Tutup loading
                scaffoldMessenger.showSnackBar(
                  SnackBar(content: Text("Error: $e")),
                );
              }
            },
            child: const Text(
              "Ya, Batalkan",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ====================================
  // 📝 FUNGSI UNTUK AKSI UPDATE (EDIT KEPERLUAN)
  // ====================================
  void _showEditDialog(Antrian antrian) {
    final TextEditingController keperluanController = TextEditingController(
      text: antrian.needs,
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text("Edit Keperluan Antrean"),
        content: TextField(
          controller: keperluanController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: "Ubah Keperluan / Alasan",
            border: OutlineInputBorder(),
            hintText: "Masukkan keperluan baru...",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              if (keperluanController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Keperluan tidak boleh kosong")),
                );
                return;
              }

              Navigator.pop(dialogContext); // Tutup dialog input

              // Tampilkan Loading Spinner
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) =>
                    const Center(child: CircularProgressIndicator()),
              );

              // 🌟 TRICK: Ambil referensi State sebelum masuk ke celah asinkronus (await)
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              try {
                // Trik aman mengambil data nama mahasiswa dari objek antrian secara dinamis
                String studentName = "Mahasiswa";
                try {
                  studentName = (antrian as dynamic).nama ?? "Mahasiswa";
                } catch (_) {}

                bool success = await ApiService.updateAntrian(
                  token: widget.token,
                  id: antrian.id,
                  nama: studentName,
                  keperluan: keperluanController.text.trim(),
                  layanan: antrian.service ?? "Layanan Kampus",
                );

                // Gunakan referensi yang sudah disimpan aman (bebas dari error deactivated widget)
                navigator.pop(); // Tutup loading

                if (success) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text("Keperluan antrean berhasil diperbarui!"),
                    ),
                  );
                  if (mounted) {
                    setState(() {
                      loadData(); // Refresh data halaman
                    });
                  }
                } else {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text("Gagal memperbarui antrean.")),
                  );
                }
              } catch (e) {
                navigator.pop(); // Tutup loading
                scaffoldMessenger.showSnackBar(
                  SnackBar(content: Text("Error: $e")),
                );
              }
            },
            child: const Text(
              "Simpan Perubahan",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Antrian>>(
      future: futureAntrian,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final data = snapshot.data ?? [];

        final antrianAktif = data.where((item) {
          final stat = item.status.toLowerCase();
          return stat == 'waiting' || stat == 'process';
        }).toList();

        final antrianRiwayat = data.where((item) {
          final stat = item.status.toLowerCase();
          return stat == 'done' || stat == 'cancel';
        }).toList();

        return DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Container(
                color: Colors.white,
                child: TabBar(
                  labelColor: Colors.blue.shade700,
                  unselectedLabelColor: Colors.grey.shade500,
                  indicatorColor: Colors.blue.shade700,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  tabs: [
                    Tab(text: "Aktif (${antrianAktif.length})"),
                    Tab(text: "Riwayat (${antrianRiwayat.length})"),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildAktifList(antrianAktif),
                    _buildRiwayatList(antrianRiwayat),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= TAB 1: KARTU TIKET ANTRIAN AKTIF =================
  Widget _buildAktifList(List<Antrian> list) {
    if (list.isEmpty) {
      return const Center(
        child: Text(
          "Tidak ada antrean aktif saat ini",
          style: TextStyle(color: Colors.black45),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          loadData();
        });
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final antrian = list[index];
          final status = antrian.status;
          final color = getStatusColor(status);

          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border(left: BorderSide(color: color, width: 6)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          antrian.service ?? "Layanan Kampus",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.black12,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "NO. ANTREAN",
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              antrian.queueNumber,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Keperluan:",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black45,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              antrian.needs ?? '-',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // ========================================================
                  // ⚡ INTEGRASI CRUD: TOMBOL EDIT & DELETE UNTUK STATUS WAITING
                  // ========================================================
                  if (status.toLowerCase() == 'waiting') ...[
                    const Padding(
                      padding: EdgeInsets.only(top: 12.0, bottom: 4.0),
                      child: Divider(
                        height: 1,
                        thickness: 0.5,
                        color: Colors.black12,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () => _showEditDialog(antrian),
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 16,
                            color: Colors.blue,
                          ),
                          label: const Text(
                            "Edit Keperluan",
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        TextButton.icon(
                          onPressed: () => _confirmDelete(antrian.id),
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 16,
                            color: Colors.red,
                          ),
                          label: const Text(
                            "Batalkan",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ================= TAB 2: RIWAYAT ANTREAN =================
  Widget _buildRiwayatList(List<Antrian> list) {
    if (list.isEmpty) {
      return const Center(
        child: Text(
          "Belum ada riwayat antrean",
          style: TextStyle(color: Colors.black45),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          loadData();
        });
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final antrian = list[index];
          final status = antrian.status;
          final originalColor = getStatusColor(status);

          const mutedGray = Colors.black45;
          final mutedBorderColor = Colors.grey.shade300;

          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border(
                  left: BorderSide(color: Colors.grey.shade300, width: 6),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          antrian.service ?? "Layanan Kampus",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: mutedGray,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: originalColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            color: originalColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.black12,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: mutedBorderColor),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "NO. ANTREAN",
                              style: TextStyle(
                                fontSize: 9,
                                color: mutedGray,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              antrian.queueNumber,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: mutedGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Keperluan:",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black38,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              antrian.needs ?? '-',
                              style: const TextStyle(
                                fontSize: 14,
                                color: mutedGray,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
