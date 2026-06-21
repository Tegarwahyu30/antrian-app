class UserStorage {
  static Map<String, dynamic>? user;

  static void saveUser(Map<String, dynamic> data) {
    user = data;
  }

  static Map<String, dynamic>? getUser() {
    return user;
  }

  static void clear() {
    user = null;
  }
}
