class LayananModel {
  final String id;
  final String nama;
  final int durasiMenit;
  final double harga; // Ini yang bakal disimpen buat pembayaran

  LayananModel({
    required this.id,
    required this.nama,
    required this.durasiMenit,
    required this.harga,
  });

  factory LayananModel.fromJson(Map<String, dynamic> json) {
    return LayananModel(
      id: json['id'] ?? '',
      nama: json['nama'] ?? '',
      durasiMenit: json['durasi_menit'] ?? 0,
      // Parse harga bener-bener ke double biar aman pas kalkulasi bayar
      harga: double.tryParse(json['harga'].toString()) ?? 0.0,
    );
  }
}
