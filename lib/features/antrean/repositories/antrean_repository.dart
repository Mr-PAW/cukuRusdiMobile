// lib/features/antrean/repositories/antrean_repository.dart
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/antrean_model.dart';

class AntreanRepository {
  final Dio _dio;

  AntreanRepository() : _dio = ApiClient.createDio();

  // Ambil semua antrean (untuk home screen)
  Future<List<AntreanItem>> getAntrean() async {
    try {
      final res = await _dio.get(ApiEndpoints.antrean);

      final List<dynamic> data = res.data is List
          ? res.data
          : res.data['data'] ?? [];

      return data.map((e) => AntreanItem.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Gagal ambil antrean');
    }
  }

  // Estimasi giliran pelanggan spesifik
  Future<AntreanItem?> getAntreanByBooking(String bookingId) async {
    try {
      final res = await _dio.get(ApiEndpoints.antreanByBooking(bookingId));

      final data = res.data is Map ? res.data['data'] ?? res.data : res.data;
      if (data == null) return null;

      return AntreanItem.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw Exception(e.response?.data?['message'] ?? 'Gagal ambil estimasi');
    }
  }
}
