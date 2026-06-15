import 'package:flutter/material.dart';

class SuccessAntrianScreen extends StatelessWidget {
  final String queueNumber;
  final String status;

  const SuccessAntrianScreen({
    super.key,
    required this.queueNumber,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Antrian Berhasil")),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              const Icon(Icons.check_circle, size: 100),

              const SizedBox(height: 20),

              const Text(
                "Kode Antrian Anda",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              Text(
                queueNumber,
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                "Status : ${status.toUpperCase()}",
                style: const TextStyle(fontSize: 18),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text("KEMBALI"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
