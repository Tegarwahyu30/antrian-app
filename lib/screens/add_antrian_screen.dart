import 'package:flutter/material.dart';
import '../models/service_model.dart';
import '../services/api_service.dart';

class AddAntrianScreen extends StatefulWidget {
  final String token;

  const AddAntrianScreen({super.key, required this.token});

  @override
  State<AddAntrianScreen> createState() => _AddAntrianScreenState();
}

class _AddAntrianScreenState extends State<AddAntrianScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _nimController = TextEditingController();
  final _keperluanController = TextEditingController();

  late Future<List<Service>> _futureServices;
  int? _selectedServiceId;
  String _selectedServiceName = "-";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _futureServices = ApiService.getServices(widget.token);
  }

  void _submitData() async {
    if (!_formKey.currentState!.validate() || _selectedServiceId == null) {
      if (_selectedServiceId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Silakan pilih layanan terlebih dahulu'),
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Mengambil data response dari API
      final result = await ApiService.createAntrian(
        token: widget.token,
        nama: _namaController.text,
        nim: _nimController.text,
        keperluan: _keperluanController.text,
        serviceId: _selectedServiceId!,
      );

      if (!mounted) return;

      // Menampilkan Dialog Sukses ala Tiket Digital Modern
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Icon Sukses Terisolasi Lingkaran Soft
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green.shade600,
                    size: 55,
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Judul Utama Dialog
                const Text(
                  "Antrean Berhasil Diambil!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),

                // 3. Sub-deskripsi Petunjuk
                Text(
                  "Silakan tunjukkan nomor antrean di bawah ini kepada petugas saat dipanggil.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 24),

                // 4. Komponen Wadah Tiket Utama
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue.shade100, width: 1.5),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "NOMOR ANTREAN",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // ✅ BERES: Mengganti FontWeight.black menjadi FontWeight.w900 (paling tebal)
                      Text(
                        "${result['queue_number'] ?? '-'}",
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          color: Colors.blue.shade800,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Garis Pembatas Putus-putus Tiket
                      Divider(color: Colors.blue.shade100, thickness: 1.5),
                      const SizedBox(height: 6),

                      // Detail Nama Layanan yang Dipilih
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.layers_outlined,
                            size: 16,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              _selectedServiceName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 5. Tombol Solid "Selesai" untuk Navigasi Kembali
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Tutup Dialog Tiket
                    Navigator.pop(
                      context,
                      1,
                    ); // Melempar angka 1 untuk memicu refresh dashboard
                  },
                  child: const Text(
                    "Selesai",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menambah antrian: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Helper UI dekorasi input text box
  InputDecoration _customInputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black45, fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.blue.shade700),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Tambah Antrian',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Banner Atas
                  Container(
                    width: double.infinity,
                    color: Colors.blue.shade700,
                    padding: const EdgeInsets.only(
                      bottom: 35,
                      left: 20,
                      right: 20,
                    ),
                    child: const Text(
                      "Silakan lengkapi formulir di bawah ini dengan data yang valid untuk mendapatkan nomor antrean pelayanan.",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),

                  // Card Form Mengambang Elegan
                  Transform.translate(
                    offset: const Offset(0, -20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Card(
                        elevation: 3,
                        // ✅ BERES: Mengganti .withOpacity() menjadi .withValues(alpha: 0.15)
                        shadowColor: Colors.black.withValues(alpha: 0.15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  "Form Data Diri & Tujuan",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // INPUT NAMA LENGKAP
                                TextFormField(
                                  controller: _namaController,
                                  decoration: _customInputDecoration(
                                    label: 'Nama Lengkap',
                                    icon: Icons.person_outline,
                                  ),
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                      ? 'Nama tidak boleh kosong'
                                      : null,
                                ),
                                const SizedBox(height: 18),

                                // INPUT NIM
                                TextFormField(
                                  controller: _nimController,
                                  decoration: _customInputDecoration(
                                    label: 'NIM',
                                    icon: Icons.badge,
                                  ),
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                      ? 'NIM tidak boleh kosong'
                                      : null,
                                ),
                                const SizedBox(height: 18),

                                // INPUT KEPERLUAN
                                TextFormField(
                                  controller: _keperluanController,
                                  maxLines: 2,
                                  decoration: _customInputDecoration(
                                    label: 'Keperluan',
                                    icon: Icons.assignment_outlined,
                                  ),
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                      ? 'Keperluan tidak boleh kosong'
                                      : null,
                                ),
                                const SizedBox(height: 18),

                                // DROPDOWN LIVE DATA SERVICES
                                FutureBuilder<List<Service>>(
                                  future: _futureServices,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8.0,
                                        ),
                                        child: LinearProgressIndicator(
                                          color: Colors.blue.shade700,
                                        ),
                                      );
                                    }
                                    final services = snapshot.data ?? [];
                                    return DropdownButtonFormField<int>(
                                      decoration: _customInputDecoration(
                                        label: 'Pilih Layanan Kampus',
                                        icon: Icons.account_tree_outlined,
                                      ),
                                      initialValue: _selectedServiceId,
                                      isExpanded: true,
                                      items: services.map((service) {
                                        return DropdownMenuItem<int>(
                                          value: service.id,
                                          child: Text(
                                            service.serviceName,
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedServiceId = value;
                                          if (value != null) {
                                            final selected = services
                                                .firstWhere(
                                                  (s) => s.id == value,
                                                );
                                            _selectedServiceName =
                                                selected.serviceName;
                                          }
                                        });
                                      },
                                    );
                                  },
                                ),
                                const SizedBox(height: 30),

                                // BUTTON AMBIL ANTRIAN
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade700,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size.fromHeight(52),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                  ),
                                  onPressed: _submitData,
                                  child: const Text(
                                    'AMBIL ANTRIAN',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
