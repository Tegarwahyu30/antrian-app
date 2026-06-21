class Antrian {
  final int id;
  final String queueNumber;
  final String status;
  final String? name;
  final String? needs;
  final String? service;

  Antrian({
    required this.id,
    required this.queueNumber,
    required this.status,
    this.name,
    this.needs,
    this.service,
  });

  factory Antrian.fromJson(Map<String, dynamic> json) {
    return Antrian(
      id: json['id'],
      queueNumber: json['queue_number'].toString(),
      status: json['status'],
      name: json['nama'],
      needs: json['keperluan'],
      // ✅ PERBAIKAN: Membongkar objek nested 'service' lalu mengambil 'service_name' dari Laravel
      service: json['service'] != null
          ? json['service']['service_name']?.toString()
          : 'Layanan Kampus',
    );
  }
}
