class Service {
  final int id;
  final String serviceName;
  final String serviceCode;

  Service({
    required this.id,
    required this.serviceName,
    required this.serviceCode,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      serviceName: json['service_name'],
      serviceCode: json['service_code'],
    );
  }
}
