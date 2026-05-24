import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../antrean/screens/home_screen.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _konfCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureKonf = true;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut));
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _namaCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _konfCtrl.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(authProvider.notifier)
        .register(
          _namaCtrl.text.trim(),
          _usernameCtrl.text.trim(),
          _emailCtrl.text.trim(),
          _passCtrl.text,
        );

    final state = ref.read(authProvider);
    if (!mounted) return;

    if (state.isLoggedIn) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0F0F0F), AppColors.ink950],
              ),
            ),
          ),

          // Subtle gold glow at top
          Positioned(
            top: -80,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 300,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.gold500.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Barber pole left
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 4,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.gold500,
                    AppColors.ink950,
                    AppColors.ink100,
                    AppColors.ink950,
                    AppColors.gold500,
                    AppColors.ink950,
                    AppColors.ink100,
                    AppColors.ink950,
                    AppColors.gold500,
                  ],
                ),
              ),
            ),
          ),

          // Barber pole right
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 4,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.gold500,
                    AppColors.ink950,
                    AppColors.ink100,
                    AppColors.ink950,
                    AppColors.gold500,
                    AppColors.ink950,
                    AppColors.ink100,
                    AppColors.ink950,
                    AppColors.gold500,
                  ],
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 16),

                        // Brand icon
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.gold500,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.gold500.withValues(alpha: 0.3),
                                blurRadius: 24,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.content_cut_rounded,
                            size: 32,
                            color: AppColors.ink950,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'BARBERQ',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: AppColors.gold500,
                            letterSpacing: 5,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'DAFTAR SEBAGAI PELANGGAN BARU',
                          style: TextStyle(
                            color: AppColors.ink400,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2.5,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Card
                        Container(
                          decoration: barberqCard(),
                          padding: const EdgeInsets.all(24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Nama
                                const FieldLabel('NAMA LENGKAP'),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _namaCtrl,
                                  textCapitalization: TextCapitalization.words,
                                  style: const TextStyle(
                                    color: AppColors.ink100,
                                    fontSize: 14,
                                  ),
                                  decoration:
                                      barberqInput('Nama lengkap kamu'),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Nama wajib diisi';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Username
                                const FieldLabel('USERNAME'),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _usernameCtrl,
                                  style: const TextStyle(
                                    color: AppColors.ink100,
                                    fontSize: 14,
                                  ),
                                  decoration: barberqInput('Username'),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Username wajib diisi';
                                    }
                                    if (value.contains(' ')) {
                                      return 'Username tidak boleh pakai spasi';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Email
                                const FieldLabel('EMAIL'),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _emailCtrl,
                                  keyboardType: TextInputType.emailAddress,
                                  style: const TextStyle(
                                    color: AppColors.ink100,
                                    fontSize: 14,
                                  ),
                                  decoration: barberqInput('Email'),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Email wajib diisi';
                                    }
                                    if (!value.contains('@')) {
                                      return 'Format email tidak valid';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Password
                                const FieldLabel('PASSWORD'),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _passCtrl,
                                  obscureText: _obscurePass,
                                  style: const TextStyle(
                                    color: AppColors.ink100,
                                    fontSize: 14,
                                  ),
                                  decoration: barberqInput(
                                    '••••••••',
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePass
                                            ? Icons.visibility_off_rounded
                                            : Icons.visibility_rounded,
                                        color: AppColors.ink400,
                                        size: 20,
                                      ),
                                      onPressed: () => setState(
                                        () => _obscurePass = !_obscurePass,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Password wajib diisi';
                                    }
                                    if (value.length < 6) {
                                      return 'Password minimal 6 karakter';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Konfirmasi Password
                                const FieldLabel('KONFIRMASI PASSWORD'),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _konfCtrl,
                                  obscureText: _obscureKonf,
                                  style: const TextStyle(
                                    color: AppColors.ink100,
                                    fontSize: 14,
                                  ),
                                  decoration: barberqInput(
                                    '••••••••',
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureKonf
                                            ? Icons.visibility_off_rounded
                                            : Icons.visibility_rounded,
                                        color: AppColors.ink400,
                                        size: 20,
                                      ),
                                      onPressed: () => setState(
                                        () => _obscureKonf = !_obscureKonf,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Konfirmasi password wajib diisi';
                                    }
                                    if (value != _passCtrl.text) {
                                      return 'Password tidak cocok';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),

                                // Error message
                                if (authState.error != null) ...[
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.errorBg,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.errorBorder,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Text('⚠ ',
                                            style: TextStyle(fontSize: 14)),
                                        Expanded(
                                          child: Text(
                                            authState.error!.replaceAll(
                                              'Exception: ',
                                              '',
                                            ),
                                            style: const TextStyle(
                                              color: AppColors.errorText,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],

                                // Register button
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: FilledButton(
                                    onPressed: authState.isLoading
                                        ? null
                                        : _onRegister,
                                    style: goldButtonStyle(),
                                    child: authState.isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.2,
                                              color: AppColors.ink950,
                                            ),
                                          )
                                        : const Text(
                                            'DAFTAR →',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 2,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Back to login
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text(
                                    'Sudah punya akun? Masuk sekarang →',
                                    style: TextStyle(
                                      color: AppColors.gold500,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),
                        Text(
                          'CUKUR RUSDI © 2025',
                          style: TextStyle(
                            color: AppColors.ink600,
                            fontSize: 9,
                            letterSpacing: 3,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
