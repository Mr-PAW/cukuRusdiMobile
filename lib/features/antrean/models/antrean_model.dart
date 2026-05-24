// lib/features/antrean/models/antrean_model.dart
class AntreanItem {
  final String id;
  final String pelangganId;
  final String pelangganNama;
  final String kursiId;
  final String barberNama;
  final int posisiAntrean;
  final int estimasiDetik; // Countdown dalam detik, tidak di-reset oleh polling
  final String status;     // menunggu | proses | selesai | batal

  AntreanItem({
    required this.id,
    required this.pelangganId,
    required this.pelangganNama,
    required this.kursiId,
    required this.barberNama,
    required this.posisiAntrean,
    required this.estimasiDetik,
    required this.status,
  });

  AntreanItem copyWithDetik(int detik) => AntreanItem(
    id: id,
    pelangganId: pelangganId,
    pelangganNama: pelangganNama,
    kursiId: kursiId,
    barberNama: barberNama,
    posisiAntrean: posisiAntrean,
    estimasiDetik: detik,
    status: status,
  );

  factory AntreanItem.fromJson(Map<String, dynamic> json) {
    // Backend mengirim 'estimasi_menit' (satuan menit).
    // Kita konversi ke detik untuk countdown timer di app.
    // Kalau backend kirim 'estimasi_detik' langsung, pakai itu.
    int detik;
    if (json['estimasi_detik'] != null) {
      // Sudah dalam detik, pakai langsung
      detik = json['estimasi_detik'] is int
          ? json['estimasi_detik']
          : int.tryParse(json['estimasi_detik'].toString()) ?? 0;
    } else {
      // estimasi_menit → kalikan 60 untuk dapat detik
      final menit = json['estimasi_menit'] is int
          ? json['estimasi_menit'] as int
          : int.tryParse(json['estimasi_menit'].toString()) ?? 0;
      detik = menit * 60;
    }

    return AntreanItem(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      pelangganId: (json['pelanggan_id'] ?? '').toString(),
      pelangganNama: json['pelanggan_nama'] ?? '',
      kursiId: (json['kursi_id'] ?? '').toString(),
      barberNama: json['barber_nama'] ?? '',
      posisiAntrean: json['posisi_antrean'] is int
          ? json['posisi_antrean']
          : int.tryParse(json['posisi_antrean'].toString()) ?? 0,
      estimasiDetik: detik,
      status: json['status'] ?? 'menunggu',
    );
  }
}
