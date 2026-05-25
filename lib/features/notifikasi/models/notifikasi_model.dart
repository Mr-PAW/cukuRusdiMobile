// lib/features/notifikasi/models/notifikasi_model.dart

class NotifikasiItem {
  final String id;
  final String pelangganId;
  final String? bookingId;
  final String pesan;
  final String tipe; // 'giliran' | 'selesai' | 'batal'
  final bool sudahDibaca;
  final DateTime createdAt;

  NotifikasiItem({
    required this.id,
    required this.pelangganId,
    this.bookingId,
    required this.pesan,
    required this.tipe,
    required this.sudahDibaca,
    required this.createdAt,
  });

  factory NotifikasiItem.fromJson(Map<String, dynamic> json) {
    return NotifikasiItem(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      pelangganId: (json['pelanggan_id'] ?? '').toString(),
      bookingId: json['booking_id']?.toString(),
      pesan: json['pesan'] ?? '',
      tipe: json['tipe'] ?? 'giliran',
      sudahDibaca: json['sudah_dibaca'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  NotifikasiItem copyWith({bool? sudahDibaca}) => NotifikasiItem(
        id: id,
        pelangganId: pelangganId,
        bookingId: bookingId,
        pesan: pesan,
        tipe: tipe,
        sudahDibaca: sudahDibaca ?? this.sudahDibaca,
        createdAt: createdAt,
      );
}
