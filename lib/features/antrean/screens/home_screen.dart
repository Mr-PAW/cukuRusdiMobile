// lib/features/antrean/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/antrean_provider.dart';
import '../models/antrean_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../booking/screens/booking_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Mulai polling saat screen dibuka
    Future.microtask(
      () =>
          ref.read(antreanProvider.notifier).startPolling(intervalSeconds: 5),
    );
  }

  @override
  void dispose() {
    ref.read(antreanProvider.notifier).stopPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final antreanState = ref.watch(antreanProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, ${authState.user?.nama ?? 'Pelanggan'} 👋',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            if (antreanState.lastUpdated != null)
              Text(
                'Update: ${_formatTime(antreanState.lastUpdated!)}',
                style: TextStyle(fontSize: 11, color: Colors.grey[400]),
              ),
          ],
        ),
        actions: [
          // Refresh manual
          IconButton(
            icon: antreanState.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                : const Icon(Icons.refresh, color: Colors.black),
            onPressed: antreanState.isLoading
                ? null
                : () => ref.read(antreanProvider.notifier).fetch(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(antreanProvider.notifier).fetch(),
        child: CustomScrollView(
          slivers: [
            // Banner jika antrean kosong
            if (!antreanState.isLoading && antreanState.items.isEmpty)
              SliverFillRemaining(child: _buildEmpty()),

            // Error state
            if (antreanState.error != null)
              SliverToBoxAdapter(child: _buildError(antreanState.error!)),

            // Sedang proses
            if (antreanState.proses.isNotEmpty) ...[
              _buildSectionHeader(
                '🔄 Sedang Proses',
                antreanState.proses.length,
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) =>
                      _buildAntreanCard(antreanState.proses[i], isProses: true),
                  childCount: antreanState.proses.length,
                ),
              ),
            ],

            // Menunggu
            if (antreanState.menunggu.isNotEmpty) ...[
              _buildSectionHeader('⏳ Menunggu', antreanState.menunggu.length),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _buildAntreanCard(antreanState.menunggu[i]),
                  childCount: antreanState.menunggu.length,
                ),
              ),
            ],

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),

      // FAB booking
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const BookingScreen()));
        },
        backgroundColor: Colors.black,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Booking',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildSectionHeader(String title, int count) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count orang',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAntreanCard(AntreanItem item, {bool isProses = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isProses ? Colors.black : Colors.grey.shade200,
          width: isProses ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
                color: isProses ? Colors.black : Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '${item.posisiAntrean}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isProses ? Colors.white : Colors.black,
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
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Barber: ${item.barberNama}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            // Estimasi & status badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildStatusBadge(item.status),
                const SizedBox(height: 6),
                Text(
                  _formatCountdown(item.estimasiDetik),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: item.estimasiDetik <= 30
                        ? Colors.red.shade400
                        : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color text;
    String label;

    switch (status) {
      case 'proses':
        bg = Colors.black;
        text = Colors.white;
        label = 'Proses';
        break;
      case 'selesai':
        bg = Colors.green.shade50;
        text = Colors.green.shade700;
        label = 'Selesai';
        break;
      default:
        bg = Colors.grey.shade100;
        text = Colors.grey.shade700;
        label = 'Menunggu';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: text,
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.content_cut, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Antrean kosong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Belum ada yang booking hari ini',
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.red.shade400, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                error.replaceAll('Exception: ', ''),
                style: TextStyle(color: Colors.red.shade700, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  // Format detik ke mm:ss — merah kalau ≤ 30 detik
  String _formatCountdown(int totalDetik) {
    if (totalDetik <= 0) return '⏱ Sebentar lagi';
    final mnt = totalDetik ~/ 60;
    final dtk = totalDetik % 60;
    if (mnt == 0) return '${dtk}s';
    return '${mnt}m ${dtk.toString().padLeft(2, '0')}s';
  }
}
