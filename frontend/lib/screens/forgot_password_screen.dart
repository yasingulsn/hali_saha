import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/theme.dart';
import '../utils/validators.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final bool isKullanici;
  const ForgotPasswordScreen({super.key, required this.isKullanici});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  String? _message;
  bool _isSuccess = false;

  Future<void> _gonder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _message = null;
    });

    final res = await _authService.sifreSifirlamaIstegi(
      _emailController.text.trim(),
      widget.isKullanici ? 'KULLANICI' : 'ISLETME',
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        _message = res.mesaj;
        _isSuccess = res.basarili;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  _buildHeader(),
                  const SizedBox(height: 60),
                  _buildGlassCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 8),
        const Text(
          'Şifremi Unuttum',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
        ),
      ],
    );
  }

  Widget _buildGlassCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppTheme.cardDark.withOpacity(0.8),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.1)),
          ),
          child: _isSuccess ? _buildSuccessState() : _buildFormState(),
        ),
      ),
    );
  }

  Widget _buildFormState() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'E-posta Adresiniz',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Şifrenizi sıfırlamanız için size bir kod göndereceğiz.',
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary.withOpacity(0.7)),
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: InputDecoration(
              hintText: 'ornek@email.com',
              prefixIcon: Icon(Icons.alternate_email_rounded, color: AppTheme.primaryGreen.withOpacity(0.5)),
            ),
          ),
          const SizedBox(height: 40),
          _buildActionButton(),
          if (_message != null) ...[
            const SizedBox(height: 20),
            Text(_message!, style: TextStyle(color: AppTheme.errorRed, fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ],
      ),
    );
  }

  Widget _buildSuccessState() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppTheme.primaryGreen.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.mark_email_read_rounded, color: AppTheme.primaryGreen, size: 48),
        ),
        const SizedBox(height: 24),
        const Text(
          'Talimatlar Gönderildi!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 12),
        Text(
          'Eğer bir hesabınız varsa, şifre sıfırlama kodu e-posta adresinize gönderilmiştir.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppTheme.textSecondary.withOpacity(0.8), height: 1.5),
        ),
        const SizedBox(height: 32),
        _buildActionButton(label: 'Koda Sahibim', onTap: () {
          // Reset password screen'e git
          _showResetDialog();
        }),
        TextButton(
          onPressed: () => setState(() => _isSuccess = false),
          child: const Text('Tekrar Gönder', style: TextStyle(color: AppTheme.primaryGreen)),
        ),
      ],
    );
  }

  void _showResetDialog() {
    final tokenController = TextEditingController();
    final passController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDarkElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Şifreyi Yenile', style: TextStyle(color: AppTheme.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: tokenController,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(hintText: 'E-posta ile gelen kod'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passController,
              obscureText: true,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(hintText: 'Yeni Şifre'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Vazgeç')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen, foregroundColor: AppTheme.backgroundDark),
            onPressed: () async {
              if (tokenController.text.isEmpty || passController.text.length < 6) return;
              Navigator.pop(ctx);
              final res = await _authService.sifreSifirla(tokenController.text, passController.text);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(res.mesaj),
                  backgroundColor: res.basarili ? AppTheme.primaryGreen : AppTheme.errorRed,
                ));
                if (res.basarili) Navigator.pop(context);
              }
            },
            child: const Text('Sıfırla'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({String label = 'Gönder', VoidCallback? onTap}) {
    return GestureDetector(
      onTap: _isLoading ? null : (onTap ?? _gonder),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: _isLoading ? null : AppTheme.buttonGradient,
          color: _isLoading ? AppTheme.textSecondary.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isLoading ? [] : [
            BoxShadow(color: AppTheme.primaryGreen.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator(color: AppTheme.primaryGreen)
              : Text(
                  label,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.backgroundDark),
                ),
        ),
      ),
    );
  }
}
