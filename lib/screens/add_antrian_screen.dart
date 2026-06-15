import 'package:flutter/material.dart';

import '../models/service_model.dart';
import '../services/api_service.dart';
import 'success_antrian_screen.dart';

class AddAntrianScreen extends StatefulWidget {
  const AddAntrianScreen({super.key});

  @override
  State<AddAntrianScreen> createState() => _AddAntrianScreenState();
}

class _AddAntrianScreenState extends State<AddAntrianScreen> {
  final namaController = TextEditingController();
  final nimController = TextEditingController();
  final keperluanController = TextEditingController();

  List<Service> services = [];

  int? selectedServiceId;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadServices();
  }

  Future<void> loadServices() async {
    try {
      final data = await ApiService.getServices();

      setState(() {
        services = data;

        if (services.isNotEmpty) {
          selectedServiceId = services.first.id;
        }

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> simpanData() async {
    // ===================================================
    // TAMBAHAN VALIDASI: SATPAM FORM KOSONG
    // ===================================================
    if (selectedServiceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Silakan pilih layanan terlebih dahulu!")),
      );
      return;
    }

    if (namaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Nama tidak boleh kosong!")));
      return;
    }

    if (nimController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("NIM tidak boleh kosong!")));
      return;
    }

    if (keperluanController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Keperluan tidak boleh kosong!")),
      );
      return;
    }
    // ===================================================

    try {
      // ==== REVISI DI SINI: MENGGUNAKAN KODE PILIHANMU ====
      final result = await ApiService.createAntrian(
        nama: namaController.text,
        nim: nimController.text,
        keperluan: keperluanController.text,
        serviceId: selectedServiceId!,
      );

      final data = result['data'];

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SuccessAntrianScreen(
            queueNumber: data['queue_number'],
            status: data['status'],
          ),
        ),
      );
      // ===================================================
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal menyimpan data: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Ambil Antrian")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            TextField(
              controller: namaController,
              decoration: const InputDecoration(
                labelText: "Nama",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: nimController,
              decoration: const InputDecoration(
                labelText: "NIM",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField<int>(
              initialValue: selectedServiceId,

              decoration: const InputDecoration(
                labelText: "Pilih Layanan",
                border: OutlineInputBorder(),
              ),

              items: services.map((service) {
                return DropdownMenuItem<int>(
                  value: service.id,
                  child: Text(service.serviceName),
                );
              }).toList(),

              onChanged: (value) {
                setState(() {
                  selectedServiceId = value;
                });
              },
            ),

            const SizedBox(height: 15),

            TextField(
              controller: keperluanController,
              maxLines: 3,

              decoration: const InputDecoration(
                labelText: "Keperluan",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: simpanData,

                child: const Text("AMBIL ANTRIAN"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
