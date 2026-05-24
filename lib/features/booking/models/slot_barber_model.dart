// lib/features/booking/models/slot_barber_model.dart
// Model barber — parse data dari /api/v1/barber
// Response shape: { id, nama, foto_url, status, rating }
class BarberModel {
  final String id;
  final String nama;
  final String? fotoUrl;
  final String status; // 'aktif' | 'nonaktif'
  final double rating;

  BarberModel({
    required this.id,
    required this.nama,
    this.fotoUrl,
    required this.status,
    required this.rating,
  });

  // Barber bisa dipilih kalau statusnya aktif
  bool get tersedia => status == 'aktif';

  factory BarberModel.fromJson(Map<String, dynamic> json) {
    return BarberModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      nama: json['nama'] ?? '',
      fotoUrl: json['foto_url'],
      status: json['status'] ?? 'nonaktif',
      rating: double.tryParse(json['rating'].toString()) ?? 0.0,
    );
  }
}
