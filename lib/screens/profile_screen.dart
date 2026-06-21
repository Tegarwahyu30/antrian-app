import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = "-";
  String nim = "-";
  String email = "-";

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      name = prefs.getString('user_name') ?? "-";
      nim = prefs.getString('user_nim') ?? "-";
      email = prefs.getString('user_email') ?? "-";
    });
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.clear();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      // Saya hapus AppBar bawaan Scaffold ini agar tidak "dobel" dengan tulisan Profile
      // yang ada di parent screen (sesuai gambar Anda).
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ==========================================
            // HEADER & FOTO PROFIL (ANTI-KETUMPUK)
            // ==========================================
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Background Biru
                Container(
                  // Margin bottom 50 ini memberi ruang aman untuk setengah lingkaran foto profil
                  margin: const EdgeInsets.only(bottom: 50),
                  height: 160, // Ukuran pasti agar tidak hancur saat di-scroll
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade700,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      "My Profile",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // Foto Avatar
                Container(
                  padding: const EdgeInsets.all(
                    4,
                  ), // Memberikan efek border putih
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue.shade50,
                    // 👇 INI JAWABAN UNTUK FOTO PROFIL 👇
                    // Mengambil inisial nama secara otomatis dari internet
                    backgroundImage: NetworkImage(
                      "https://ui-avatars.com/api/?name=$name&background=0D8ABC&color=fff&size=150",
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Nama di bawah Avatar
            Text(
              name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Mahasiswa",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 30),

            // ==========================================
            // KARTU DATA DIRI
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildInfoCard(Icons.badge_outlined, "Nama Lengkap", name),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    Icons.credit_card_outlined,
                    "Nomor Induk Mahasiswa",
                    nim,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(Icons.email_outlined, "Email", email),

                  const SizedBox(height: 40),

                  // ==========================================
                  // TOMBOL LOGOUT
                  // ==========================================
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: logout,
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: const Text(
                        "Logout",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET BANTUAN UNTUK MEMBUAT KARTU INFO
  // ==========================================
  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.blue.shade700, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
