// lib/features/notifikasi/providers/notifikasi_provider.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notifikasi_model.dart';
import '../repositories/notifikasi_repository.dart';

class NotifikasiState {
  final List<NotifikasiItem> items;
  final bool isLoading;
  final String? error;
  /// Notifikasi baru yang muncul sejak terakhir dicek (untuk trigger banner)
  final NotifikasiItem? newest;

  const NotifikasiState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.newest,
  });

  /// Jumlah notifikasi yang belum dibaca
  int get unreadCount => items.where((e) => !e.sudahDibaca).length;

  /// Apakah ada notifikasi belum dibaca bertipe 'giliran'
  bool get hasGiliranUnread =>
      items.any((e) => !e.sudahDibaca && e.tipe == 'giliran');

  NotifikasiState copyWith({
    List<NotifikasiItem>? items,
    bool? isLoading,
    String? error,
    NotifikasiItem? newest,
    bool clearNewest = false,
  }) =>
      NotifikasiState(
        items: items ?? this.items,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        newest: clearNewest ? null : (newest ?? this.newest),
      );
}

class NotifikasiNotifier extends StateNotifier<NotifikasiState> {
  final NotifikasiRepository _repo;
  Timer? _pollTimer;
  final Set<String> _seenIds = {};

  NotifikasiNotifier(this._repo) : super(const NotifikasiState());

  void _safeSetState(NotifikasiState newState) {
    if (!mounted) return;
    try {
      state = newState;
    } catch (_) {}
  }

  Future<void> fetch() async {
    if (!mounted) return;
    _safeSetState(state.copyWith(isLoading: true, error: null));
    try {
      final items = await _repo.getMyNotifikasi();
      if (!mounted) return;

      // Cari notifikasi paling baru yang belum pernah kita tampilkan
      NotifikasiItem? newestUnread;
      for (final item in items) {
        if (!item.sudahDibaca && !_seenIds.contains(item.id)) {
          // Ambil yang paling baru (items sudah sorted descending dari backend)
          newestUnread = item;
          break;
        }
      }

      // Tandai ID yang sudah kita proses agar tidak muncul banner berulang
      for (final item in items) {
        _seenIds.add(item.id);
      }

      _safeSetState(state.copyWith(
        items: items,
        isLoading: false,
        newest: newestUnread,
      ));
    } catch (e) {
      if (!mounted) return;
      _safeSetState(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  /// Mulai polling — dipanggil dari HomeScreen.initState
  void startPolling({int intervalSeconds = 5}) {
    fetch();
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(
      Duration(seconds: intervalSeconds),
      (_) {
        if (mounted) fetch();
      },
    );
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  /// Panggil setelah banner notifikasi sudah ditampilkan supaya tidak muncul lagi
  void clearNewest() {
    _safeSetState(state.copyWith(clearNewest: true));
  }

  Future<void> markRead(String id) async {
    try {
      await _repo.markRead(id);
      // Update lokal tanpa fetch ulang
      final updated = state.items
          .map((e) => e.id == id ? e.copyWith(sudahDibaca: true) : e)
          .toList();
      _safeSetState(state.copyWith(items: updated));
    } catch (_) {}
  }

  Future<void> markAllRead() async {
    try {
      await _repo.markAllRead();
      final updated =
          state.items.map((e) => e.copyWith(sudahDibaca: true)).toList();
      _safeSetState(state.copyWith(items: updated));
    } catch (_) {}
  }

  Future<void> deleteNotifikasi(String id) async {
    try {
      await _repo.deleteNotifikasi(id);
      final updated = state.items.where((e) => e.id != id).toList();
      _safeSetState(state.copyWith(items: updated));
    } catch (_) {}
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}

final notifikasiProvider =
    StateNotifierProvider<NotifikasiNotifier, NotifikasiState>((ref) {
  final notifier = NotifikasiNotifier(NotifikasiRepository());
  ref.onDispose(() => notifier.stopPolling());
  return notifier;
});
