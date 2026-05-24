// lib/features/auth/repositories/auth_repository.dart
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/storage/secure_storage.dart';
import '../models/user_model.dart';

class AuthRepository {
  final Dio _dio;

  AuthRepository() : _dio = ApiClient.createDio();

  Future<UserModel> login(String username, String password) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.login,
        data: {'username': username, 'password': password},
      );

      final user = UserModel.fromLoginJson(res.data);
      await SecureStorage.saveToken(user.token);
      return user;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Login gagal');
    }
  }

  Future<UserModel> register(
    String nama,
    String username,
    String email,
    String password,
  ) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.register,
        data: {
          'nama': nama,
          'username': username,
          'email': email,
          'password': password,
        },
      );

      // Register berhasil tapi belum dapat token
      // Langsung login otomatis biar dapat token
      return await login(username, password);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Register gagal');
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiEndpoints.logout);
    } finally {
      await SecureStorage.deleteToken();
    }
  }
}
