class AntrianActive {
  final String serviceName;
  final String queueNumber;

  AntrianActive({required this.serviceName, required this.queueNumber});

  factory AntrianActive.fromJson(Map<String, dynamic> json) {
    return AntrianActive(
      serviceName: json['service_name'] ?? '-',
      queueNumber: json['queue_number'] ?? '-',
    );
  }
}
