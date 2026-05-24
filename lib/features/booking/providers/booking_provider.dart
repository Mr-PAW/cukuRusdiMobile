import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/layanan_model.dart';
import '../models/slot_barber_model.dart';

// State class buat nyimpen semua data di page booking
class BookingState {
  final LayananModel? selectedLayanan;
  final BarberModel? selectedBarber;
  final double totalHarga;

  BookingState({
    this.selectedLayanan,
    this.selectedBarber,
    this.totalHarga = 0.0,
  });

  BookingState copyWith({
    LayananModel? selectedLayanan,
    BarberModel? selectedBarber,
    double? totalHarga,
  }) {
    return BookingState(
      selectedLayanan: selectedLayanan ?? this.selectedLayanan,
      selectedBarber: selectedBarber ?? this.selectedBarber,
      totalHarga: totalHarga ?? this.totalHarga,
    );
  }
}

class BookingNotifier extends StateNotifier<BookingState> {
  BookingNotifier() : super(BookingState());

  // Method pas user nge-tap layanan di UI
  void pilihLayanan(LayananModel layanan) {
    state = state.copyWith(
      selectedLayanan: layanan,
      totalHarga: layanan.harga, // Harga langsung ke-lock buat dipake pembayaran
    );
  }

  // Method pas user nge-tap barber
  void pilihBarber(BarberModel barber) {
    if (!barber.tersedia) {
      // Barber tidak aktif, tidak bisa dipilih
      throw Exception('Barber ini sedang tidak aktif, pilih yang lain.');
    }
    state = state.copyWith(selectedBarber: barber);
  }

  // Reset pilihan kalau user batalin
  void resetSelection() {
    state = BookingState();
  }
}

// Global Provider biar bisa diakses dari UI (BookingScreen)
final bookingProvider = StateNotifierProvider<BookingNotifier, BookingState>((
  ref,
) {
  return BookingNotifier();
});
