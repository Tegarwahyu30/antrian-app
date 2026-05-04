class Antrian {
  final int id;
  final String queueNumber;
  final String status;

  Antrian({required this.id, required this.queueNumber, required this.status});

  factory Antrian.fromJson(Map<String, dynamic> json) {
    return Antrian(
      id: json['id'],
      queueNumber: json['queue_number'],
      status: json['status'],
    );
  }
}
