class UserModel {
  final String name;
  final String nim;
  final String email;

  UserModel({required this.name, required this.nim, required this.email});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'],
      nim: json['nim'],
      email: json['email'],
    );
  }
}
