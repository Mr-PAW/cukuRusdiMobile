import 'package:flutter/material.dart';

import '../../auth/screens/login_screen.dart';
import '../../../core/storage/secure_storage.dart';
import '../data/customer_repository.dart';

class CustomerShellScreen extends StatefulWidget {
  const CustomerShellScreen({super.key});

  @override
  State<CustomerShellScreen> createState() => _CustomerShellScreenState();
}

class _CustomerShellScreenState extends State<CustomerShellScreen> {
  final CustomerRepository _repository = CustomerRepository();
  int _currentIndex = 0;
  int _queueRefreshToken = 0;

  void _setPage(int index) {
    setState(() => _currentIndex = index);
  }

  void _refreshQueue() {
    setState(() {
      _queueRefreshToken++;
      _currentIndex = 0;
    });
  }

  Future<void> _logout() async {
    await SecureStorage.deleteToken();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      QueueScreen(key: ValueKey(_queueRefreshToken), repository: _repository),
      BookingScreen(repository: _repository, onBooked: _refreshQueue),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      appBar: AppBar(
        titleSpacing: 16,
        title: const Text(
          'Cukur Rusdi',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.2),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem<String>(value: 'logout', child: Text('Keluar')),
            ],
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              child: const CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFFF9A825),
                child: Text(
                  'A',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF111111), Color(0xFF070707)],
          ),
        ),
        child: IndexedStack(index: _currentIndex, children: pages),
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: const Color(0xFF161616),
          indicatorColor: const Color(0xFFF9A825).withOpacity(0.14),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: selected
                  ? const Color(0xFFF9A825)
                  : const Color(0xFF727272),
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _setPage,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.query_stats_outlined),
              selectedIcon: Icon(Icons.query_stats_rounded),
              label: 'Antrean',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month_rounded),
              label: 'Booking Baru',
            ),
          ],
        ),
      ),
    );
  }
}

class QueueScreen extends StatefulWidget {
  const QueueScreen({super.key, required this.repository});

  final CustomerRepository repository;

  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> {
  late Future<List<Map<String, dynamic>>> _queueFuture;

  @override
  void initState() {
    super.initState();
    _queueFuture = widget.repository.fetchAntrean();
  }

  @override
  void didUpdateWidget(covariant QueueScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.key != widget.key) {
      _queueFuture = widget.repository.fetchAntrean();
    }
  }

  String _firstText(
    Map<String, dynamic> data,
    List<String> keys,
    String fallback,
  ) {
    for (final key in keys) {
      final value = data[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return fallback;
  }

  int? _firstNumber(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is num) {
        return value.toInt();
      }
      if (value != null) {
        final parsed = int.tryParse(value.toString());
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _queueFuture,
      builder: (context, snapshot) {
        final items = snapshot.data ?? const [];
        final item = items.isNotEmpty ? items.first : <String, dynamic>{};
        final position =
            _firstNumber(item, const [
              'posisi',
              'urutan',
              'nomor_antrian',
              'queue_number',
            ]) ??
            0;
        final waitMinutes =
            _firstNumber(item, const [
              'estimasi',
              'estimated_wait',
              'waktu_tunggu',
              'wait_minutes',
            ]) ??
            0;
        final barber = _firstText(item, const [
          'barber_nama',
          'nama_barber',
          'barber',
          'barber_name',
        ], '-');
        final status = _firstText(item, const ['status', 'state'], 'menunggu');
        final note = items.isNotEmpty
            ? 'Silakan datang ke barbershop ketika estimasi tunggu sudah mendekati 10 menit.'
            : 'Belum ada antrean aktif. Buat booking baru untuk masuk ke antrean.';

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _queueFuture = widget.repository.fetchAntrean();
            });
            await _queueFuture;
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 360),
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFF6A11A), Color(0xFFFFB52C)],
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF6A11A).withOpacity(0.18),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: 2,
                        top: 0,
                        child: Opacity(
                          opacity: 0.28,
                          child: Icon(
                            Icons.content_cut_rounded,
                            size: 80,
                            color: Colors.black.withOpacity(0.12),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'POSISI ANTREAN KAMU',
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.66),
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            items.isNotEmpty ? '#$position' : 'Belum Ada',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              _queueStat(
                                '${waitMinutes} mnt',
                                'Estimasi Tunggu',
                              ),
                              const SizedBox(width: 26),
                              _queueStat(barber, 'Barber'),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Text(
                    items.isNotEmpty ? '$note\nStatus: $status' : note,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF7C7C7C),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const Padding(
                    padding: EdgeInsets.only(top: 28),
                    child: CircularProgressIndicator(),
                  ),
                if (snapshot.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 28),
                    child: Text(
                      'Gagal memuat antrean',
                      style: TextStyle(color: Colors.red[300]),
                    ),
                  ),
                const SizedBox(height: 180),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _queueStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.black.withOpacity(0.68)),
        ),
      ],
    );
  }
}

class BookingScreen extends StatefulWidget {
  const BookingScreen({
    super.key,
    required this.repository,
    required this.onBooked,
  });

  final CustomerRepository repository;
  final VoidCallback onBooked;

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late Future<List<Map<String, dynamic>>> _barberFuture;
  late Future<List<Map<String, dynamic>>> _layananFuture;
  late Future<List<Map<String, dynamic>>> _kursiFuture;

  String? _selectedBarberId;
  String? _selectedLayananId;
  String? _selectedKursiId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _barberFuture = widget.repository.fetchBarbers();
    _layananFuture = widget.repository.fetchLayanan();
    _kursiFuture = widget.repository.fetchKursi();
  }

  String _itemId(Map<String, dynamic> item) {
    return item['id']?.toString() ?? item['_id']?.toString() ?? '';
  }

  String _itemLabel(
    Map<String, dynamic> item,
    List<String> keys,
    String fallback,
  ) {
    for (final key in keys) {
      final value = item[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return fallback;
  }

  double _itemRating(Map<String, dynamic> item) {
    final rating = item['rating'] ?? item['rate'] ?? item['nilai'];
    if (rating is num) return rating.toDouble();
    return double.tryParse(rating?.toString() ?? '') ?? 0;
  }

  Future<void> _submitBooking() async {
    if (_selectedBarberId == null ||
        _selectedLayananId == null ||
        _selectedKursiId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih barber, layanan, dan kursi terlebih dahulu'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await widget.repository.createBooking(
        barberId: _selectedBarberId!,
        layananId: _selectedLayananId!,
        kursiId: _selectedKursiId!,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Booking berhasil dibuat')));
      widget.onBooked();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle('PILIH BARBER'),
          const SizedBox(height: 12),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _barberFuture,
            builder: (context, snapshot) {
              final items = snapshot.data ?? const [];
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const _LoadingCard();
              }
              if (items.isEmpty) {
                return const _EmptyStateCard('Belum ada data barber.');
              }
              return SizedBox(
                height: 126,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final id = _itemId(item);
                    final name = _itemLabel(item, const [
                      'nama',
                      'name',
                      'full_name',
                    ], 'Barber');
                    final rating = _itemRating(item);
                    final selected = _selectedBarberId == id;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedBarberId = id),
                      child: Container(
                        width: 150,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFFF9A825).withOpacity(0.08)
                              : const Color(0xFF141414),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: selected
                                ? const Color(0xFFF9A825)
                                : const Color(0xFF2D2D2D),
                            width: 1.2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: const Color(0xFFF9A825),
                              child: Text(
                                name.isNotEmpty ? name[0].toUpperCase() : 'B',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              name,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '★ ${rating.toStringAsFixed(1)}',
                              style: const TextStyle(
                                color: Color(0xFFC7C7C7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 18),
          const _PanelTitle('PILIH LAYANAN & KURSI'),
          const SizedBox(height: 12),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _layananFuture,
            builder: (context, layananSnapshot) {
              return FutureBuilder<List<Map<String, dynamic>>>(
                future: _kursiFuture,
                builder: (context, kursiSnapshot) {
                  final layananItems = layananSnapshot.data ?? const [];
                  final kursiItems = kursiSnapshot.data ?? const [];

                  if (layananSnapshot.connectionState ==
                          ConnectionState.waiting ||
                      kursiSnapshot.connectionState ==
                          ConnectionState.waiting) {
                    return const _LoadingCard();
                  }

                  if (layananItems.isEmpty && kursiItems.isEmpty) {
                    return const _EmptyStateCard(
                      'Belum ada data layanan atau kursi.',
                    );
                  }

                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141414),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFF2D2D2D)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _StyledDropdown<Map<String, dynamic>>(
                                label: 'LAYANAN',
                                value: _selectedLayananId,
                                items: layananItems,
                                itemLabel: (item) => _itemLabel(item, const [
                                  'nama',
                                  'name',
                                  'judul',
                                ], 'Layanan'),
                                itemValue: _itemId,
                                onChanged: (value) =>
                                    setState(() => _selectedLayananId = value),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _StyledDropdown<Map<String, dynamic>>(
                                label: 'KURSI',
                                value: _selectedKursiId,
                                items: kursiItems,
                                itemLabel: (item) => _itemLabel(item, const [
                                  'nama',
                                  'name',
                                  'kode',
                                ], 'Kursi'),
                                itemValue: _itemId,
                                onChanged: (value) =>
                                    setState(() => _selectedKursiId = value),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: FilledButton.icon(
                            onPressed: _isSubmitting ? null : _submitBooking,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFF9A825),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: _isSubmitting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                    ),
                                  )
                                : const Icon(Icons.calendar_month_rounded),
                            label: Text(
                              _isSubmitting ? 'Memproses...' : 'Buat Booking',
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class _PanelTitle extends StatelessWidget {
  const _PanelTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF5F5F5F),
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.35,
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2D2D2D)),
      ),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2.2),
        ),
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2D2D2D)),
      ),
      child: Text(text, style: const TextStyle(color: Color(0xFFB0B0B0))),
    );
  }
}

class _StyledDropdown<T> extends StatelessWidget {
  const _StyledDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.itemValue,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<T> items;
  final String Function(T item) itemLabel;
  final String Function(T item) itemValue;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6D6D6D),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          items: items
              .map(
                (item) => DropdownMenuItem<String>(
                  value: itemValue(item),
                  child: Text(itemLabel(item)),
                ),
              )
              .toList(),
          onChanged: onChanged,
          dropdownColor: const Color(0xFF181818),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF0F0F0F),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2D2D2D)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2D2D2D)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFF9A825),
                width: 1.3,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          hint: const Text('Pilih', style: TextStyle(color: Color(0xFF9D9D9D))),
        ),
      ],
    );
  }
}
