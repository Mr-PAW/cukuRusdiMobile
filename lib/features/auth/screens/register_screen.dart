import 'package:cukurusdi/features/antrean/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../../antrean/screens/home_screen.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _konfCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureKonf = true;

  @override
  void dispose() {
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF111111), Color(0xFF090909)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF141414),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF262626)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.35),
                        blurRadius: 28,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 8),
                        const Icon(
                          Icons.content_cut_rounded,
                          size: 56,
                          color: Color(0xFFF9A825),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Cukur',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFF9A825),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Daftar sebagai pelanggan baru',
                          style: TextStyle(
                            color: Color(0xFF8E8E8E),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _FieldLabel(text: 'NAMA LENGKAP'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _namaCtrl,
                          textCapitalization: TextCapitalization.words,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration('Nama lengkap'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nama wajib diisi';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _FieldLabel(text: 'USERNAME'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _usernameCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration('Username'),
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
                        const SizedBox(height: 14),
                        _FieldLabel(text: 'EMAIL'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration('Email'),
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
                        const SizedBox(height: 14),
                        _FieldLabel(text: 'PASSWORD'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _passCtrl,
                          obscureText: _obscurePass,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration('Password').copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePass
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: const Color(0xFF8C8C8C),
                              ),
                              onPressed: () =>
                                  setState(() => _obscurePass = !_obscurePass),
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
                        const SizedBox(height: 14),
                        _FieldLabel(text: 'KONFIRMASI PASSWORD'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _konfCtrl,
                          obscureText: _obscureKonf,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration('Konfirmasi password')
                              .copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureKonf
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: const Color(0xFF8C8C8C),
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
                        const SizedBox(height: 18),
                        if (authState.error != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A1111),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF6A2323),
                              ),
                            ),
                            child: Text(
                              authState.error!.replaceAll('Exception: ', ''),
                              style: const TextStyle(
                                color: Color(0xFFFFB1B1),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        if (authState.error != null) const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: FilledButton(
                            onPressed: authState.isLoading ? null : _onRegister,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFF9A825),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: authState.isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: Colors.black,
                                    ),
                                  )
                                : const Text(
                                    'Daftar →',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Sudah punya akun? Masuk sekarang',
                            style: TextStyle(
                              color: Color(0xFFF9A825),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF666666)),
      filled: true,
      fillColor: const Color(0xFF101010),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF2B2B2B)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF2B2B2B)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFF9A825), width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFB23C3C)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFB23C3C), width: 1.2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF7E7E7E),
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
          fontSize: 12,
        ),
      ),
    );
  }
}
