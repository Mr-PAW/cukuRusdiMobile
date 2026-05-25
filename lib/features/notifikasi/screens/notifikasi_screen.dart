// lib/features/notifikasi/screens/notifikasi_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/notifikasi_provider.dart';
import '../models/notifikasi_model.dart';

class NotifikasiScreen extends ConsumerStatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  ConsumerState<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends ConsumerState<NotifikasiScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh ketika layar dibuka
    Future.microtask(() => ref.read(notifikasiProvider.notifier).fetch());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notifikasiProvider);

    return Scaffold(
      backgroundColor: AppColors.ink950,
      appBar: AppBar(
        backgroundColor: AppColors.ink900,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'NOTIFIKASI',
          style: TextStyle(
            color: AppColors.ink100,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
        actions: [
          if (state.unreadCount > 0)
            TextButton(
              onPressed: () =>
                  ref.read(notifikasiProvider.notifier).markAllRead(),
              child: const Text(
                'Baca Semua',
                style: TextStyle(
                  color: AppColors.gold500,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.ink700),
        ),
      ),
      body: state.isLoading && state.items.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.gold500),
            )
          : state.items.isEmpty
              ? _buildEmpty()
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: state.items.length,
                  separatorBuilder: (_, __) =>
                      Container(height: 1, color: AppColors.ink800),
                  itemBuilder: (context, i) =>
                      _buildNotifTile(state.items[i]),
                ),
    );
  }

  Widget _buildNotifTile(NotifikasiItem item) {
    final isUnread = !item.sudahDibaca;

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.statusBatal.withValues(alpha: 0.15),
        child: const Icon(Icons.delete_outline_rounded,
            color: AppColors.statusBatal),
      ),
      onDismissed: (_) =>
          ref.read(notifikasiProvider.notifier).deleteNotifikasi(item.id),
      child: InkWell(
        onTap: isUnread
            ? () => ref.read(notifikasiProvider.notifier).markRead(item.id)
            : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          color: isUnread
              ? AppColors.gold500.withValues(alpha: 0.05)
              : Colors.transparent,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon tipe
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _tipeColor(item.tipe).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    _tipeIcon(item.tipe),
                    color: _tipeColor(item.tipe),
                    size: 20,
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // Konten
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _tipeLabel(item.tipe),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _tipeColor(item.tipe),
                            letterSpacing: 1.5,
                          ),
                        ),
                        if (isUnread) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.gold500,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                        const Spacer(),
                        Text(
                          _formatTime(item.createdAt),
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.ink400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.pesan,
                      style: TextStyle(
                        fontSize: 13,
                        color: isUnread ? AppColors.ink100 : AppColors.ink400,
                        fontWeight: isUnread
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.ink900,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.ink700),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 32,
              color: AppColors.ink600,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'BELUM ADA NOTIFIKASI',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.ink400,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Kamu akan mendapat notifikasi\nketika giliran tiba',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.ink600,
            ),
          ),
        ],
      ),
    );
  }

  Color _tipeColor(String tipe) {
    switch (tipe) {
      case 'giliran':
        return AppColors.gold500;
      case 'selesai':
        return AppColors.statusProses;
      case 'batal':
        return AppColors.statusBatal;
      default:
        return AppColors.ink400;
    }
  }

  IconData _tipeIcon(String tipe) {
    switch (tipe) {
      case 'giliran':
        return Icons.content_cut_rounded;
      case 'selesai':
        return Icons.check_circle_outline_rounded;
      case 'batal':
        return Icons.cancel_outlined;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  String _tipeLabel(String tipe) {
    switch (tipe) {
      case 'giliran':
        return 'GILIRAN TIBA';
      case 'selesai':
        return 'SELESAI';
      case 'batal':
        return 'DIBATALKAN';
      default:
        return 'NOTIFIKASI';
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m lalu';
    if (diff.inHours < 24) return '${diff.inHours}j lalu';
    return '${dt.day}/${dt.month}';
  }
}
