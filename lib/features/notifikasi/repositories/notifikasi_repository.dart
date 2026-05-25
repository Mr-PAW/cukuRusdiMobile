// lib/features/notifikasi/repositories/notifikasi_repository.dart
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/notifikasi_model.dart';

class NotifikasiRepository {
  final Dio _dio;

  NotifikasiRepository() : _dio = ApiClient.createDio();

  /// Ambil semua notifikasi pelanggan yang sedang login
  Future<List<NotifikasiItem>> getMyNotifikasi() async {
    try {
      final res = await _dio.get(ApiEndpoints.notifikasiMe);
      final List<dynamic> data = res.data is List
          ? res.data
          : res.data['data'] ?? [];
      return data.map((e) => NotifikasiItem.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Gagal ambil notifikasi',
      );
    }
  }

  /// Tandai satu notifikasi sudah dibaca
  Future<void> markRead(String id) async {
    try {
      await _dio.put(ApiEndpoints.notifikasiDibaca(id));
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Gagal update notifikasi',
      );
    }
  }

  /// Tandai semua notifikasi sudah dibaca
  Future<void> markAllRead() async {
    try {
      await _dio.put(ApiEndpoints.notifikasiSemuaDibaca);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Gagal update semua notifikasi',
      );
    }
  }

  /// Hapus notifikasi
  Future<void> deleteNotifikasi(String id) async {
    try {
      await _dio.delete(ApiEndpoints.notifikasiDelete(id));
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Gagal hapus notifikasi',
      );
    }
  }
}
