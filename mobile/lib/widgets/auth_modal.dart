import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';

class AuthModalSheet extends StatefulWidget {
  const AuthModalSheet({super.key});

  @override
  State<AuthModalSheet> createState() => _AuthModalSheetState();
}

class _AuthModalSheetState extends State<AuthModalSheet> {
  bool _isLogin = true;
  String _selectedRole = 'siswa';
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  String? _errorMsg;
  String? _successMsg;

  Future<void> _handleAuth() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
      _successMsg = null;
    });

    try {
      final supabase = Supabase.instance.client;
      if (_isLogin) {
        await supabase.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        setState(() => _successMsg = 'Berhasil masuk!');
      } else {
        await supabase.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          data: {
            'full_name': _nameController.text.trim(),
            'role': _selectedRole,
            'phone': _phoneController.text.trim(),
          },
        );
        setState(() => _successMsg = 'Akun berhasil terdaftar!');
      }

      await Future.delayed(const Duration(milliseconds: 1000));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _errorMsg = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF111115),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(top: BorderSide(color: AppColors.cardBorder, width: 1.5)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isLogin ? 'Masuk ke Akun LPK' : 'Daftar Akun Baru',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: const Text('Supabase Auth', style: TextStyle(fontSize: 10, color: AppColors.primaryLight, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Tab Toggle
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isLogin = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _isLogin ? AppColors.primary : Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text('Masuk', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: _isLogin ? Colors.white : AppColors.textMuted)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isLogin = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: !_isLogin ? AppColors.primary : Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text('Daftar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: !_isLogin ? Colors.white : AppColors.textMuted)),
                    ),
                  ),
                ),
              ],
            ),

            if (_errorMsg != null) ...[
              const SizedBox(height: 10),
              Text(_errorMsg!, style: const TextStyle(color: Colors.redAccent, fontSize: 11)),
            ],
            if (_successMsg != null) ...[
              const SizedBox(height: 10),
              Text(_successMsg!, style: const TextStyle(color: AppColors.emerald, fontSize: 11)),
            ],

            const SizedBox(height: 14),

            if (!_isLogin) ...[
              // Role selection
              const Text('Daftar Sebagai:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedRole = 'siswa'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _selectedRole == 'siswa' ? AppColors.primary.withOpacity(0.2) : Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _selectedRole == 'siswa' ? AppColors.primary : Colors.transparent),
                        ),
                        alignment: Alignment.center,
                        child: const Text('Siswa (Kursus)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedRole = 'mitra'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _selectedRole == 'mitra' ? AppColors.primary.withOpacity(0.2) : Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _selectedRole == 'mitra' ? AppColors.primary : Colors.transparent),
                        ),
                        alignment: Alignment.center,
                        child: const Text('Mitra Instruktur', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                decoration: _inputDecoration('Nama Lengkap', Icons.person_rounded),
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration('Nomor WhatsApp', Icons.phone_rounded),
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 10),
            ],

            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDecoration('Alamat Email', Icons.email_rounded),
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: _inputDecoration('Kata Sandi', Icons.lock_rounded),
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleAuth,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isLoading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(_isLogin ? 'Masuk Sekarang' : 'Daftar Akun', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSubtle, fontSize: 12),
      prefixIcon: Icon(icon, color: AppColors.textSubtle, size: 16),
      filled: true,
      fillColor: Colors.white.withOpacity(0.04),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }
}
