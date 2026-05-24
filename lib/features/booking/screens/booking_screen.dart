import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/booking_provider.dart';
import '../repositories/booking_repository.dart';
import '../../antrean/providers/antrean_provider.dart';

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  bool _isSubmitting = false;

  Future<void> _konfirmasi() async {
    final bookingState = ref.read(bookingProvider);
    final barber = bookingState.selectedBarber!;
    final layanan = bookingState.selectedLayanan!;

    setState(() => _isSubmitting = true);

    try {
      final repo = ref.read(bookingRepositoryProvider);
      await repo.createBooking(
        barberId: barber.id,
        layananId: layanan.id,
      );

      // Reset pilihan booking
      ref.read(bookingProvider.notifier).resetSelection();

      // Trigger fetch antrean langsung biar muncul tanpa nunggu polling
      ref.read(antreanProvider.notifier).fetch();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking berhasil! Antrean kamu sudah masuk.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Balik ke HomeScreen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch state pilihan user
    final bookingState = ref.watch(bookingProvider);

    // Watch data dari API
    final layananAsync = ref.watch(listLayananProvider);
    final barberAsync = ref.watch(listBarberProvider);

    // Validasi tombol: cuma bisa lanjut kalau layanan & barber udah dipilih
    final isReadyToBook =
        bookingState.selectedLayanan != null &&
        bookingState.selectedBarber != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Buat Booking Baru'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih Layanan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // --- SECTION LAYANAN ---
            layananAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error: $err'),
              data: (layananList) => ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: layananList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final layanan = layananList[index];
                  final isSelected =
                      bookingState.selectedLayanan?.id == layanan.id;

                  return ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? Colors.blue : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    tileColor: isSelected ? Colors.blue.withOpacity(0.1) : null,
                    title: Text(
                      layanan.nama,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('${layanan.durasiMenit} Menit'),
                    trailing: Text('Rp ${layanan.harga.toStringAsFixed(0)}'),
                    onTap: () {
                      ref.read(bookingProvider.notifier).pilihLayanan(layanan);
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Pilih Kapster / Barber',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // --- SECTION BARBER ---
            barberAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error: $err'),
              data: (barberList) => GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.5,
                ),
                itemCount: barberList.length,
                itemBuilder: (context, index) {
                  final barber = barberList[index];
                  final isSelected =
                      bookingState.selectedBarber?.id == barber.id;

                  return InkWell(
                    onTap: barber.tersedia
                        ? () => ref
                              .read(bookingProvider.notifier)
                              .pilihBarber(barber)
                        : null, // Disable tap kalau tidak aktif
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: barber.tersedia
                            ? (isSelected
                                  ? Colors.blue.withOpacity(0.1)
                                  : Colors.white)
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: barber.tersedia
                              ? (isSelected
                                    ? Colors.blue
                                    : Colors.grey.shade300)
                              : Colors.grey.shade400,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            barber.nama,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: barber.tersedia
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            barber.tersedia
                                ? '⭐ ${barber.rating.toStringAsFixed(1)}'
                                : 'Tidak Aktif',
                            style: TextStyle(
                              fontSize: 12,
                              color: barber.tersedia
                                  ? Colors.amber.shade700
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // --- BOTTOM NAVIGATION (TOTAL & TOMBOL) ---
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Pembayaran',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    'Rp ${bookingState.totalHarga.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: isReadyToBook && !_isSubmitting ? _konfirmasi : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Konfirmasi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
