import 'package:flutter/material.dart';
import '../models/antrian_model.dart';
import '../services/api_service.dart';
import 'add_antrian_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Antrian>> futureAntrian;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() {
    futureAntrian = ApiService.getAntrian();
  }

  // 📄 Fungsi pembantu untuk menentukan warna background status box
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'process':
        return Colors.blue.shade700; // 🔵 Biru untuk membedakan dengan 'done'
      case 'waiting':
        return Colors.orange.shade700; // 🟠 Oranye untuk yang mengantre
      case 'done':
        return Colors
            .green
            .shade600; // 🟢 Hijau agar sinkron dengan Web Laravel
      default:
        return Colors.blue;
    }
  }

  // 🔄 Fungsi refresh data untuk widget RefreshIndicator
  Future<void> _handleRefresh() async {
    setState(() {
      loadData();
    });
  }

  // ✏️ LANGKAH 3: Fungsi Pop-up Dialog untuk Edit Data (Full Logic + Validasi Form + Anti Error Getter)
  void _showEditDialog(BuildContext context, Antrian antrian) {
    final formKey = GlobalKey<FormState>();

    String txtNama = "";
    try {
      txtNama = (antrian as dynamic).name ?? "";
    } catch (_) {
      txtNama = "";
    }

    String txtKeperluan = "";
    try {
      txtKeperluan = (antrian as dynamic).needs ?? "";
    } catch (_) {
      txtKeperluan = "";
    }

    String selectedLayanan = "Akademik";
    try {
      String? tempLayanan = (antrian as dynamic).service;
      if (tempLayanan != null &&
          ["Akademik", "Keuangan", "Administrasi"].contains(tempLayanan)) {
        selectedLayanan = tempLayanan;
      }
    } catch (_) {
      selectedLayanan = "Akademik";
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("Edit Data Antrian No: ${antrian.queueNumber}"),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: txtNama,
                    decoration: const InputDecoration(
                      labelText: "Nama Mahasiswa",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? "Nama tidak boleh kosong"
                        : null,
                    onSaved: (value) => txtNama = value!.trim(),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    initialValue: txtKeperluan,
                    decoration: const InputDecoration(
                      labelText: "Keperluan",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? "Keperluan tidak boleh kosong"
                        : null,
                    onSaved: (value) => txtKeperluan = value!.trim(),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: selectedLayanan,
                    decoration: const InputDecoration(
                      labelText: "Pilih Layanan",
                      border: OutlineInputBorder(),
                    ),
                    items: ["Akademik", "Keuangan", "Administrasi"].map((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      selectedLayanan = value ?? "Akademik";
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.pop(dialogContext),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text(
                "Simpan",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  Navigator.pop(dialogContext); // Tutup Dialog Form

                  bool success = await ApiService.updateAntrian(
                    antrian.id,
                    txtNama,
                    txtKeperluan,
                    selectedLayanan,
                  );

                  // Perbaikan: Gunakan context.mounted yang terasosiasi langsung dengan BuildContext halaman
                  if (!context.mounted) return;

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Data antrian berhasil diperbarui"),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _handleRefresh();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Gagal memperbarui data ke server"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  // 🗑️ LANGKAH 3: Fungsi Pop-up Dialog untuk Batal/Hapus Data dengan pengaman async gap context.mounted
  void _showDeleteDialog(BuildContext context, int id) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Batalkan Antrian"),
          content: const Text(
            "Apakah Anda yakin ingin membatalkan antrian ini? Data akan dihapus secara permanen dari sistem.",
          ),
          actions: [
            TextButton(
              child: const Text("Tidak", style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.pop(dialogContext),
            ),
            TextButton(
              child: const Text(
                "Ya, Batalkan",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () async {
                Navigator.pop(dialogContext); // Tutup dialog konfirmasi

                bool success = await ApiService.deleteAntrian(id);

                // Perbaikan: Gunakan context.mounted yang terasosiasi langsung dengan BuildContext halaman
                if (!context.mounted) return;

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Antrian sukses dibatalkan dan dihapus"),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _handleRefresh();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Gagal membatalkan antrian ke server"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Data Antrian Kampus"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _handleRefresh,
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: FutureBuilder<List<Antrian>>(
          future: futureAntrian,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            final data = snapshot.data ?? [];

            if (data.isEmpty) {
              return const Center(child: Text("Belum ada data antrian"));
            }

            // ===================================================
            // LOGIKA SORTING: Urutkan status 'process' -> 'waiting' -> 'done'
            // ===================================================
            data.sort((a, b) {
              int getStatusOrder(String status) {
                switch (status.toLowerCase()) {
                  case 'process':
                    return 1;
                  case 'waiting':
                    return 2;
                  case 'done':
                    return 3;
                  default:
                    return 4;
                }
              }

              return getStatusOrder(
                a.status,
              ).compareTo(getStatusOrder(b.status));
            });
            // ===================================================

            return ListView.builder(
              itemCount: data.length,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemBuilder: (context, index) {
                final antrian = data[index];
                final currentStatus = antrian.status.toLowerCase();

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  elevation: currentStatus == 'process' ? 4 : 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: currentStatus == 'process'
                        ? BorderSide(color: Colors.blue.shade400, width: 1.5)
                        : BorderSide.none,
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: currentStatus == 'process'
                              ? Colors.blue.shade50
                              : (currentStatus == 'done'
                                    ? Colors.green.shade50
                                    : Colors.grey.shade100),
                          child: Icon(
                            currentStatus == 'done'
                                ? Icons.check
                                : Icons.confirmation_number,
                            color: currentStatus == 'process'
                                ? Colors.blue
                                : (currentStatus == 'done'
                                      ? Colors.green
                                      : Colors.grey),
                          ),
                        ),
                        title: Text(
                          "No: ${antrian.queueNumber}",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: currentStatus == 'done'
                                ? Colors.green.shade800
                                : Colors.black87,
                          ),
                        ),
                        subtitle: const Padding(
                          padding: EdgeInsets.only(top: 4.0),
                          child: Text("Silakan pantau loket secara berkala"),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(antrian.status),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            antrian.status.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),

                      // 🌟 Tombol Aksi Kustom (Hanya muncul jika status WAITING)
                      if (currentStatus == 'waiting')
                        Padding(
                          padding: const EdgeInsets.only(
                            right: 16.0,
                            bottom: 8.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                icon: const Icon(
                                  Icons.edit,
                                  size: 18,
                                  color: Colors.orange,
                                ),
                                label: const Text(
                                  "Edit",
                                  style: TextStyle(color: Colors.orange),
                                ),
                                onPressed: () {
                                  _showEditDialog(context, antrian);
                                },
                              ),
                              const SizedBox(width: 8),
                              TextButton.icon(
                                icon: const Icon(
                                  Icons.delete_forever,
                                  size: 18,
                                  color: Colors.red,
                                ),
                                label: const Text(
                                  "Batal",
                                  style: TextStyle(color: Colors.red),
                                ),
                                onPressed: () {
                                  _showDeleteDialog(context, antrian.id);
                                },
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddAntrianScreen()),
          );
          setState(() {
            loadData();
          });
        },
      ),
    );
  }
}
