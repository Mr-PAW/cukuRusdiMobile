import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/layanan_model.dart';
import '../models/slot_barber_model.dart';

class BookingRepository {
  final Dio _dio;

  BookingRepository(this._dio);

  // Ambil list layanan (GET /api/v1/layanan)
  Future<List<LayananModel>> getLayanan() async {
    try {
      final response = await _dio.get(ApiEndpoints.layanan);
      return (response.data['data'] as List)
          .map((e) => LayananModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Gagal mengambil data layanan',
      );
    }
  }

  // Ambil list barber aktif (GET /api/v1/barber)
  // Backend sudah filter status='aktif', dan booking controller
  // akan otomatis temukan kursi dari barber_id
  Future<List<BarberModel>> getBarber() async {
    try {
      final response = await _dio.get(ApiEndpoints.barber);
      return (response.data['data'] as List)
          .map((e) => BarberModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Gagal mengambil data barber',
      );
    }
  }

  // POST booking baru (POST /api/v1/booking)
  Future<void> createBooking({
    required String barberId,
    required String layananId,
  }) async {
    try {
      await _dio.post(
        ApiEndpoints.booking,
        data: {'barber_id': barberId, 'layanan_id': layananId},
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Gagal membuat booking',
      );
    }
  }
}

// Provider untuk repository — menggunakan ApiClient yang sudah ada
final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository(ApiClient.createDio());
});

// Fetch list layanan
final listLayananProvider = FutureProvider<List<LayananModel>>((ref) async {
  final repo = ref.read(bookingRepositoryProvider);
  return await repo.getLayanan();
});

// Fetch list barber aktif dari /api/v1/barber
final listBarberProvider = FutureProvider<List<BarberModel>>((ref) async {
  final repo = ref.read(bookingRepositoryProvider);
  return await repo.getBarber();
});
