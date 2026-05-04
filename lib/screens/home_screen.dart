import 'package:flutter/material.dart';
import '../models/antrian_model.dart';
import '../services/api_service.dart';

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
    futureAntrian = ApiService.getAntrian();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Data Antrian Kampus")),
      body: FutureBuilder<List<Antrian>>(
        future: futureAntrian,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Terjadi error"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Data kosong"));
          }

          final data = snapshot.data!;

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final antrian = data[index];

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text("No: ${antrian.queueNumber}"),
                  subtitle: Text("Status: ${antrian.status}"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
