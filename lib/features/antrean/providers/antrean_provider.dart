// lib/features/antrean/providers/antrean_provider.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/antrean_model.dart';
import '../repositories/antrean_repository.dart';

class AntreanState {
  final List<AntreanItem> items;
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdated;

  const AntreanState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.lastUpdated,
  });

  List<AntreanItem> get menunggu =>
      items.where((e) => e.status == 'menunggu').toList();

  List<AntreanItem> get proses =>
      items.where((e) => e.status == 'proses').toList();

  AntreanState copyWith({
    List<AntreanItem>? items,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
  }) => AntreanState(
    items: items ?? this.items,
    isLoading: isLoading ?? this.isLoading,
    error: error,
    lastUpdated: lastUpdated ?? this.lastUpdated,
  );
}

class AntreanNotifier extends StateNotifier<AntreanState> {
  final AntreanRepository _repo;
  Timer? _pollTimer;
  Timer? _tickTimer;

  AntreanNotifier(this._repo) : super(const AntreanState());

  // Set state aman, pastikan notifier masih ter-mount di widget tree
  void _safeSetState(AntreanState newState) {
    if (!mounted) return;
    try {
      state = newState;
    } catch (_) {}
  }

  Future<void> fetch() async {
    if (!mounted) return;
    _safeSetState(state.copyWith(isLoading: true, error: null));
    try {
      final serverItems = await _repo.getAntrean();
      if (!mounted) return;

      // Pertahankan countdown lokal yang sudah berjalan
      final localCountdowns = {
        for (final item in state.items)
          if (item.status == 'menunggu' && item.estimasiDetik > 0)
            item.id: item.estimasiDetik,
      };

      final mergedItems = serverItems.map((serverItem) {
        final localDetik = localCountdowns[serverItem.id];
        if (localDetik != null && serverItem.status == 'menunggu') {
          return serverItem.copyWithDetik(localDetik);
        }
        return serverItem;
      }).toList();

      _safeSetState(state.copyWith(
        items: mergedItems,
        isLoading: false,
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      if (!mounted) return;
      _safeSetState(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  void startPolling({int intervalSeconds = 5}) {
    fetch();
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(
      Duration(seconds: intervalSeconds),
      (_) { if (mounted) fetch(); },
    );

    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      bool adaYangHabis = false;
      final updatedItems = <AntreanItem>[];

      for (final item in state.items) {
        if (item.status == 'menunggu' && item.estimasiDetik > 0) {
          final newDetik = item.estimasiDetik - 1;
          if (newDetik <= 0) {
            adaYangHabis = true;
            // Item tidak dimasukkan ke updatedItems (Otomatis hilang dari list)
          } else {
            updatedItems.add(item.copyWithDetik(newDetik));
          }
        } else {
          updatedItems.add(item);
        }
      }

      _safeSetState(state.copyWith(items: updatedItems));

      // Kalau ada yang habis, diam-diam panggil fetch untuk sinkron backend
      if (adaYangHabis) fetch();
    });
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _tickTimer?.cancel();
    _tickTimer = null;
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}

final antreanProvider = StateNotifierProvider<AntreanNotifier, AntreanState>((
  ref,
) {
  final notifier = AntreanNotifier(AntreanRepository());
  ref.onDispose(() {
    notifier.stopPolling();
  });
  return notifier;
});
