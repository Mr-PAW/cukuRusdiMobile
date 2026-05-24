class BarberModel {
  final String id;
  final String nama;
  final String? fotoUrl; // diabaikan di UI, tapi tetap di-parse
  final String status; // misal: 'aktif', 'nonaktif'
  final double rating;

  BarberModel({
    required this.id,
    required this.nama,
    this.fotoUrl,
    required this.status,
    required this.rating,
  });

  // Barber tersedia kalau statusnya 'aktif'
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
