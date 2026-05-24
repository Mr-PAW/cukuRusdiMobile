import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../antrean/screens/home_screen.dart';
import '../providers/auth_provider.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController(text: 'sulis123');
  final _passCtrl = TextEditingController(text: '123456');
  bool _obscure = true;
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
    _usernameCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(authProvider.notifier)
        .login(_usernameCtrl.text.trim(), _passCtrl.text);

    final state = ref.read(authProvider);
    if (!mounted) return;

    if (state.isLoggedIn) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
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
                        // Brand
                        Container(
                          width: 72,
                          height: 72,
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
                            size: 36,
                            color: AppColors.ink950,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'BARBERQ',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: AppColors.gold500,
                            letterSpacing: 6,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'SISTEM MANAJEMEN ANTREAN',
                          style: TextStyle(
                            color: AppColors.ink400,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 3,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Card
                        Container(
                          decoration: barberqCard(),
                          padding: const EdgeInsets.all(24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Tab bar (Masuk / Daftar)
                                Container(
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: AppColors.ink950,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.gold500,
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                          alignment: Alignment.center,
                                          child: const Text(
                                            'MASUK',
                                            style: TextStyle(
                                              color: AppColors.ink950,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 12,
                                              letterSpacing: 1.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: TextButton(
                                          onPressed: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const RegisterScreen(),
                                            ),
                                          ),
                                          child: Text(
                                            'DAFTAR',
                                            style: TextStyle(
                                              color: AppColors.ink400,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                              letterSpacing: 1.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Panel label
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: AppColors.gold500
                                              .withValues(alpha: 0.3),
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Text(
                                        'PANEL PELANGGAN',
                                        style: TextStyle(
                                          color: AppColors.gold500,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // Username
                                const FieldLabel('USERNAME'),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _usernameCtrl,
                                  style: const TextStyle(
                                    color: AppColors.ink100,
                                    fontSize: 14,
                                  ),
                                  decoration: barberqInput('Masukkan username'),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Username wajib diisi';
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
                                  obscureText: _obscure,
                                  style: const TextStyle(
                                    color: AppColors.ink100,
                                    fontSize: 14,
                                  ),
                                  decoration: barberqInput(
                                    '••••••••',
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscure
                                            ? Icons.visibility_off_rounded
                                            : Icons.visibility_rounded,
                                        color: AppColors.ink400,
                                        size: 20,
                                      ),
                                      onPressed: () => setState(
                                        () => _obscure = !_obscure,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Password wajib diisi';
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

                                // Login button
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: FilledButton(
                                    onPressed:
                                        authState.isLoading ? null : _onLogin,
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
                                            'MASUK →',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 2,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Footer
                        Text.rich(
                          TextSpan(
                            style: TextStyle(
                              color: AppColors.ink400,
                              fontSize: 12,
                            ),
                            children: const [
                              TextSpan(text: 'Bukan pelanggan? '),
                              TextSpan(
                                text: 'Daftar sekarang →',
                                style: TextStyle(
                                  color: AppColors.gold500,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 40),
                        Text(
                          'CUKUR RUSDI © 2025',
                          style: TextStyle(
                            color: AppColors.ink600,
                            fontSize: 9,
                            letterSpacing: 3,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
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
