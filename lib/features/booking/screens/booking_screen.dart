import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
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
          SnackBar(
            content: const Text(
              'Booking berhasil! Antrean kamu sudah masuk. ✓',
              style: TextStyle(color: AppColors.ink100, fontWeight: FontWeight.w600),
            ),
            backgroundColor: AppColors.statusSelesaiBg,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context); // Balik ke HomeScreen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceAll('Exception: ', ''),
              style: const TextStyle(color: AppColors.errorText),
            ),
            backgroundColor: AppColors.errorBg,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      backgroundColor: AppColors.ink950,
      appBar: AppBar(
        backgroundColor: AppColors.ink900,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.ink100),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'BUAT BOOKING',
          style: TextStyle(
            color: AppColors.gold500,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.ink700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── SECTION LAYANAN ──
            const SectionLabel('PILIH LAYANAN'),
            const SizedBox(height: 14),

            layananAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(color: AppColors.gold500),
                ),
              ),
              error: (err, stack) => _buildErrorBox('Error: $err'),
              data: (layananList) => ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: layananList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final layanan = layananList[index];
                  final isSelected =
                      bookingState.selectedLayanan?.id == layanan.id;

                  return GestureDetector(
                    onTap: () {
                      ref.read(bookingProvider.notifier).pilihLayanan(layanan);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.gold500.withValues(alpha: 0.08)
                            : AppColors.ink900,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.gold500
                              : AppColors.ink700,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Icon
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.gold500.withValues(alpha: 0.15)
                                  : AppColors.ink800,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.gold500.withValues(alpha: 0.3)
                                    : AppColors.ink600,
                              ),
                            ),
                            child: Icon(
                              Icons.content_cut_rounded,
                              color: isSelected
                                  ? AppColors.gold500
                                  : AppColors.ink400,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  layanan.nama,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: isSelected
                                        ? AppColors.ink100
                                        : AppColors.ink200,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${layanan.durasiMenit} Menit',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.ink400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Harga
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Rp ${layanan.harga.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: isSelected
                                      ? AppColors.gold500
                                      : AppColors.ink200,
                                ),
                              ),
                              if (isSelected)
                                const Padding(
                                  padding: EdgeInsets.only(top: 4),
                                  child: Icon(
                                    Icons.check_circle_rounded,
                                    color: AppColors.gold500,
                                    size: 18,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 28),

            // Divider
            Row(
              children: [
                Expanded(child: Container(height: 1, color: AppColors.ink700)),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(Icons.arrow_downward_rounded, color: AppColors.ink600, size: 16),
                ),
                Expanded(child: Container(height: 1, color: AppColors.ink700)),
              ],
            ),

            const SizedBox(height: 28),

            // ── SECTION BARBER ──
            const SectionLabel('PILIH KAPSTER / BARBER'),
            const SizedBox(height: 14),

            barberAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(color: AppColors.gold500),
                ),
              ),
              error: (err, stack) => _buildErrorBox('Error: $err'),
              data: (barberList) => GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemCount: barberList.length,
                itemBuilder: (context, index) {
                  final barber = barberList[index];
                  final isSelected =
                      bookingState.selectedBarber?.id == barber.id;
                  final isAvailable = barber.tersedia;

                  return GestureDetector(
                    onTap: isAvailable
                        ? () => ref
                              .read(bookingProvider.notifier)
                              .pilihBarber(barber)
                        : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: !isAvailable
                            ? AppColors.ink900.withValues(alpha: 0.5)
                            : isSelected
                                ? AppColors.gold500.withValues(alpha: 0.08)
                                : AppColors.ink900,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: !isAvailable
                              ? AppColors.ink700.withValues(alpha: 0.5)
                              : isSelected
                                  ? AppColors.gold500
                                  : AppColors.ink700,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Avatar — foto profil atau inisial nama
                          _BarberAvatar(
                            fotoUrl: barber.fotoUrl,
                            nama: barber.nama,
                            isSelected: isSelected,
                            isAvailable: isAvailable,
                            size: 52,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            barber.nama,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: isAvailable
                                  ? (isSelected
                                      ? AppColors.ink100
                                      : AppColors.ink200)
                                  : AppColors.ink600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (isAvailable)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  size: 14,
                                  color: isSelected
                                      ? AppColors.gold500
                                      : AppColors.gold600,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  barber.rating.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? AppColors.gold500
                                        : AppColors.ink400,
                                  ),
                                ),
                              ],
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.statusBatalBg,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.statusBatal.withValues(alpha: 0.3),
                                ),
                              ),
                              child: const Text(
                                'NONAKTIF',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.statusBatal,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          if (isSelected) ...[
                            const SizedBox(height: 4),
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.gold500,
                              size: 16,
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),

      // ── BOTTOM BAR (TOTAL & TOMBOL) ──
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.ink900,
          border: Border(top: BorderSide(color: AppColors.ink700)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, -8),
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
                  Text(
                    'TOTAL PEMBAYARAN',
                    style: TextStyle(
                      color: AppColors.ink400,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${bookingState.totalHarga.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.gold500,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: isReadyToBook && !_isSubmitting ? _konfirmasi : null,
                  style: goldButtonStyle(),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.ink950,
                          ),
                        )
                      : const Text(
                          'KONFIRMASI →',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                            fontSize: 13,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBox(String error) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.errorBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.errorBorder),
      ),
      child: Text(
        error,
        style: const TextStyle(color: AppColors.errorText, fontSize: 13),
      ),
    );
  }
}

// ── Barber Avatar Widget ──────────────────────────────────────────────────────
// Menampilkan foto profil barber (NetworkImage) dengan fallback ke inisial nama.
// Kalau URL ada tapi gagal load, otomatis fallback ke avatar inisial.
class _BarberAvatar extends StatelessWidget {
  const _BarberAvatar({
    required this.fotoUrl,
    required this.nama,
    required this.isSelected,
    required this.isAvailable,
    this.size = 48,
  });

  final String? fotoUrl;
  final String nama;
  final bool isSelected;
  final bool isAvailable;
  final double size;

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected
        ? AppColors.gold500.withValues(alpha: 0.6)
        : AppColors.ink600;

    // Kalau ada foto_url, tampilkan NetworkImage dengan fallback
    if (fotoUrl != null && fotoUrl!.isNotEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
        ),
        child: ClipOval(
          child: Image.network(
            fotoUrl!,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildInitialAvatar(),
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return Container(
                color: AppColors.ink800,
                child: const Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: AppColors.gold500,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    // Tidak ada foto_url → tampilkan avatar inisial
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.gold500.withValues(alpha: 0.15)
            : AppColors.ink800,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
      ),
      alignment: Alignment.center,
      child: _buildInitialAvatar(),
    );
  }

  Widget _buildInitialAvatar() {
    final initial = nama.isNotEmpty ? nama[0].toUpperCase() : '?';
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: isSelected
          ? AppColors.gold500.withValues(alpha: 0.15)
          : AppColors.ink800,
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: size * 0.38,
          fontWeight: FontWeight.w800,
          color: isSelected
              ? AppColors.gold500
              : isAvailable
                  ? AppColors.ink400
                  : AppColors.ink600,
        ),
      ),
    );
  }
}
