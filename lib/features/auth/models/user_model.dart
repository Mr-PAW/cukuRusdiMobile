// lib/features/auth/models/user_model.dart
class UserModel {
  final String id;
  final String nama;
  final String username;
  final String token;

  UserModel({
    required this.id,
    required this.nama,
    required this.username,
    required this.token,
  });

  // Response login: { status, token, data: { id, nama, username } }
  factory UserModel.fromLoginJson(Map<String, dynamic> json) => UserModel(
    id: json['data']['id'].toString(),
    nama: json['data']['nama'] ?? '',
    username: json['data']['username'] ?? '',
    token: json['token'] ?? '',
  );

  // Response register: { status, message, data: { id, nama, username } }
  // Register tidak return token, jadi token kosong dulu
  factory UserModel.fromRegisterJson(Map<String, dynamic> json) => UserModel(
    id: json['data']['id'].toString(),
    nama: json['data']['nama'] ?? '',
    username: json['data']['username'] ?? '',
    token: '', // register tidak return token
  );
}
