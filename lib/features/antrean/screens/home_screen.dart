// lib/features/antrean/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/antrean_provider.dart';
import '../models/antrean_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../../booking/screens/booking_screen.dart';
import '../../notifikasi/providers/notifikasi_provider.dart';
import '../../notifikasi/screens/notifikasi_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bannerController;
  late Animation<Offset> _bannerSlide;
  late Animation<double> _bannerFade;

  @override
  void initState() {
    super.initState();

    // Animasi banner — slide dari atas
    _bannerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _bannerSlide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _bannerController,
      curve: Curves.easeOutCubic,
    ));
    _bannerFade = CurvedAnimation(
      parent: _bannerController,
      curve: Curves.easeOut,
    );

    // Mulai polling antrean
    Future.microtask(
      () => ref.read(antreanProvider.notifier).startPolling(intervalSeconds: 5),
    );

    // Mulai polling notifikasi
    Future.microtask(
      () => ref
          .read(notifikasiProvider.notifier)
          .startPolling(intervalSeconds: 5),
    );
  }

  @override
  void dispose() {
    ref.read(antreanProvider.notifier).stopPolling();
    ref.read(notifikasiProvider.notifier).stopPolling();
    _bannerController.dispose();
    super.dispose();
  }

  void _doLogout() async {
    await ref.read(authProvider.notifier).logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  /// Tampilkan animated banner notifikasi giliran
  void _showGiliranBanner(String pesan) async {
    _bannerController.forward(from: 0);
    await Future.delayed(const Duration(seconds: 5));
    if (mounted) {
      _bannerController.reverse();
      // Tandai notifikasi sudah dibaca setelah 5 detik
      ref.read(notifikasiProvider.notifier).clearNewest();
    }
  }

  @override
  Widget build(BuildContext context) {
    final antreanState = ref.watch(antreanProvider);
    final authState = ref.watch(authProvider);

    // Pantau notifikasi baru — trigger banner jika ada giliran baru
    ref.listen<NotifikasiState>(notifikasiProvider, (prev, next) {
      final newest = next.newest;
      if (newest != null && newest.tipe == 'giliran') {
        _showGiliranBanner(newest.pesan);
      }
    });

    final notifState = ref.watch(notifikasiProvider);
    final unreadCount = notifState.unreadCount;

    return Scaffold(
      backgroundColor: AppColors.ink950,
      appBar: AppBar(
        backgroundColor: AppColors.ink900,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            const Text(
              'BARBERQ',
              style: TextStyle(
                color: AppColors.gold500,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.ink600),
                borderRadius: BorderRadius.circular(20),
                color: AppColors.ink800,
              ),
              child: Text(
                'PELANGGAN',
                style: TextStyle(
                  color: AppColors.ink400,
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Refresh manual
          IconButton(
            icon: antreanState.isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.gold500,
                    ),
                  )
                : const Icon(Icons.refresh_rounded,
                    color: AppColors.ink400, size: 20),
            onPressed: antreanState.isLoading
                ? null
                : () => ref.read(antreanProvider.notifier).fetch(),
          ),

          // Bell notifikasi dengan badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: AppColors.ink400, size: 22),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const NotifikasiScreen()),
                  );
                },
                tooltip: 'Notifikasi',
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: AppColors.gold500,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        unreadCount > 9 ? '9+' : '$unreadCount',
                        style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          color: AppColors.ink950,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          Container(
              width: 1,
              height: 16,
              color: AppColors.ink700,
              margin: const EdgeInsets.symmetric(horizontal: 4)),
          IconButton(
            icon: const Icon(Icons.logout_rounded,
                color: AppColors.ink400, size: 20),
            onPressed: _doLogout,
            tooltip: 'Keluar',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.ink700),
        ),
      ),

      body: Stack(
        children: [
          // ── Main content ──────────────────────────────────────────────
          RefreshIndicator(
            color: AppColors.gold500,
            backgroundColor: AppColors.ink900,
            onRefresh: () => ref.read(antreanProvider.notifier).fetch(),
            child: CustomScrollView(
              slivers: [
                // Greeting header
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, ${authState.user?.nama ?? 'Pelanggan'} 👋',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink100,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (antreanState.lastUpdated != null)
                          Text(
                            'Update terakhir: ${_formatTime(antreanState.lastUpdated!)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.ink400,
                              letterSpacing: 0.5,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Stats row
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        _buildStatCard(
                          'MENUNGGU',
                          '${antreanState.menunggu.length}',
                          AppColors.statusMenunggu,
                          AppColors.statusMenungguBg,
                        ),
                        const SizedBox(width: 12),
                        _buildStatCard(
                          'PROSES',
                          '${antreanState.proses.length}',
                          AppColors.statusProses,
                          AppColors.statusProsesBg,
                        ),
                        const SizedBox(width: 12),
                        _buildStatCard(
                          'TOTAL',
                          '${antreanState.items.length}',
                          AppColors.gold500,
                          AppColors.ink900,
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                // Banner jika antrean kosong
                if (!antreanState.isLoading && antreanState.items.isEmpty)
                  SliverFillRemaining(child: _buildEmpty()),

                // Error state
                if (antreanState.error != null)
                  SliverToBoxAdapter(
                      child: _buildError(antreanState.error!)),

                // Sedang proses
                if (antreanState.proses.isNotEmpty) ...[
                  _buildSectionHeader(
                      'SEDANG PROSES', antreanState.proses.length),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _buildAntreanCard(
                          antreanState.proses[i],
                          isProses: true),
                      childCount: antreanState.proses.length,
                    ),
                  ),
                ],

                // Menunggu
                if (antreanState.menunggu.isNotEmpty) ...[
                  _buildSectionHeader(
                      'MENUNGGU', antreanState.menunggu.length),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) =>
                          _buildAntreanCard(antreanState.menunggu[i]),
                      childCount: antreanState.menunggu.length,
                    ),
                  ),
                ],

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),

          // ── Animated giliran banner ───────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: _bannerSlide,
              child: FadeTransition(
                opacity: _bannerFade,
                child: _buildGiliranBanner(),
              ),
            ),
          ),
        ],
      ),

      // FAB booking
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const BookingScreen()),
          );
        },
        backgroundColor: AppColors.gold500,
        icon: const Icon(Icons.add_rounded, color: AppColors.ink950),
        label: const Text(
          'BOOKING',
          style: TextStyle(
            color: AppColors.ink950,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // ── Giliran banner widget ──────────────────────────────────────────────────
  Widget _buildGiliranBanner() {
    final newest = ref.read(notifikasiProvider).newest;
    return GestureDetector(
      onTap: () {
        _bannerController.reverse();
        ref.read(notifikasiProvider.notifier).clearNewest();
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const NotifikasiScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.gold500.withValues(alpha: 0.95),
              const Color(0xFFD4A017).withValues(alpha: 0.95),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold500.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.ink950.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text('✂️', style: TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'GILIRAN ANDA TIBA! 🔔',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink950,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    newest?.pesan ?? 'Segera menuju kursi barber',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.ink950,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.ink950, size: 20),
          ],
        ),
      ),
    );
  }

  // ── Stat card ──────────────────────────────────────────────────────────────
  Widget _buildStatCard(
      String label, String value, Color accent, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accent.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: accent.withValues(alpha: 0.7),
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: accent,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section header ─────────────────────────────────────────────────────────
  SliverToBoxAdapter _buildSectionHeader(String title, int count) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.ink400,
                letterSpacing: 2.5,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.ink800,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.ink600),
              ),
              child: Text(
                '$count orang',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.ink400,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Antrean card ───────────────────────────────────────────────────────────
  Widget _buildAntreanCard(AntreanItem item, {bool isProses = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.ink900,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isProses
              ? AppColors.gold500.withValues(alpha: 0.3)
              : AppColors.ink700,
          width: isProses ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Nomor antrean
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isProses ? AppColors.gold500 : AppColors.ink800,
                borderRadius: BorderRadius.circular(12),
                border:
                    isProses ? null : Border.all(color: AppColors.ink600),
              ),
              child: Center(
                child: Text(
                  '${item.posisiAntrean}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color:
                        isProses ? AppColors.ink950 : AppColors.ink100,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            // Info pelanggan & barber
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.pelangganNama,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.ink100,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Barber: ${item.barberNama}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.ink400,
                    ),
                  ),
                ],
              ),
            ),

            // Estimasi & status badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                statusBadge(item.status),
                const SizedBox(height: 8),
                Text(
                  _formatCountdown(item.estimasiDetik),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: item.estimasiDetik <= 30
                        ? AppColors.statusBatal
                        : AppColors.ink400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty state ────────────────────────────────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.ink900,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.ink700),
            ),
            child: const Icon(
              Icons.content_cut_rounded,
              size: 36,
              color: AppColors.ink600,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'ANTREAN KOSONG',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.ink400,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Belum ada yang booking hari ini',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.ink600,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BookingScreen()),
              );
            },
            style: goldButtonStyle(),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text(
              'BUAT BOOKING',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Error state ────────────────────────────────────────────────────────────
  Widget _buildError(String error) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.errorBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.errorBorder),
        ),
        child: Row(
          children: [
            const Icon(Icons.wifi_off_rounded,
                color: AppColors.errorText, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                error.replaceAll('Exception: ', ''),
                style: const TextStyle(
                    color: AppColors.errorText, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String _formatCountdown(int totalDetik) {
    if (totalDetik <= 0) return '⏱ Sebentar lagi';
    final mnt = totalDetik ~/ 60;
    final dtk = totalDetik % 60;
    if (mnt == 0) return '${dtk}s';
    return '${mnt}m ${dtk.toString().padLeft(2, '0')}s';
  }
}
