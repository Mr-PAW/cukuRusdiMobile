import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class CustomerRepository {
  CustomerRepository() : _dio = ApiClient.createDio();

  final Dio _dio;

  Future<List<Map<String, dynamic>>> fetchBarbers() async {
    final res = await _dio.get(ApiEndpoints.barber);
    return _extractList(res.data);
  }

  Future<List<Map<String, dynamic>>> fetchLayanan() async {
    final res = await _dio.get(ApiEndpoints.layanan);
    return _extractList(res.data);
  }

  Future<List<Map<String, dynamic>>> fetchKursi() async {
    final res = await _dio.get(ApiEndpoints.kursi);
    return _extractList(res.data);
  }

  Future<List<Map<String, dynamic>>> fetchAntrean() async {
    final res = await _dio.get(ApiEndpoints.antrean);
    return _extractList(res.data);
  }

  Future<void> createBooking({
    required String barberId,
    required String layananId,
    required String kursiId,
  }) async {
    final res = await _dio.post(
      ApiEndpoints.booking,
      data: {
        'barber_id': barberId,
        'layanan_id': layananId,
        'kursi_id': kursiId,
      },
    );

    final data = res.data;
    if (data is Map<String, dynamic>) {
      final status = data['status']?.toString().toLowerCase();
      final success = status == null || status == 'success' || status == 'ok';
      if (!success) {
        throw Exception(data['message']?.toString() ?? 'Booking gagal');
      }
    }
  }

  List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    if (data is Map<String, dynamic>) {
      final candidates = [
        data['data'],
        data['result'],
        data['items'],
        data['rows'],
      ];

      for (final candidate in candidates) {
        if (candidate is List) {
          return candidate
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        }
      }

      if (_looksLikeItem(data)) {
        return [Map<String, dynamic>.from(data)];
      }
    }

    return const [];
  }

  bool _looksLikeItem(Map<String, dynamic> data) {
    return data.containsKey('id') ||
        data.containsKey('_id') ||
        data.containsKey('nama') ||
        data.containsKey('name') ||
        data.containsKey('username');
  }
}
