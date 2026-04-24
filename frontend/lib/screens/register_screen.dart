import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/validators.dart';
import '../utils/theme.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  final bool isKullanici;

  const RegisterScreen({super.key, required this.isKullanici});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Ortak alanlar
  final _emailController = TextEditingController();
  final _sifreController = TextEditingController();
  final _sifreTekrarController = TextEditingController();
  final _telefonController = TextEditingController();

  // Kullanıcı alanları
  final _adSoyadController = TextEditingController();

  // İşletme alanları
  final _isletmeAdiController = TextEditingController();
  final _yetkiliAdSoyadController = TextEditingController();
  final _vergiNoController = TextEditingController();
  final _adresController = TextEditingController();

  bool _sifreGizli = true;
  bool _sifreTekrarGizli = true;

  @override
  void dispose() {
    _emailController.dispose();
    _sifreController.dispose();
    _sifreTekrarController.dispose();
    _telefonController.dispose();
    _adSoyadController.dispose();
    _isletmeAdiController.dispose();
    _yetkiliAdSoyadController.dispose();
    _vergiNoController.dispose();
    _adresController.dispose();
    super.dispose();
  }

  Future<void> _kayitOl() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    authProvider.clearError();

    bool success;
    if (widget.isKullanici) {
      success = await authProvider.kullaniciKayit(
        adSoyad: _adSoyadController.text.trim(),
        email: _emailController.text.trim(),
        sifre: _sifreController.text,
        telefon: _telefonController.text.trim().isEmpty
            ? null
            : _telefonController.text.trim(),
      );
    } else {
      success = await authProvider.isletmeKayit(
        isletmeAdi: _isletmeAdiController.text.trim(),
        yetkiliAdSoyad: _yetkiliAdSoyadController.text.trim(),
        email: _emailController.text.trim(),
        sifre: _sifreController.text,
        telefon: _telefonController.text.trim(),
        vergiNo: _vergiNoController.text.trim().isEmpty
            ? null
            : _vergiNoController.text.trim(),
        adres: _adresController.text.trim().isEmpty
            ? null
            : _adresController.text.trim(),
      );
    }

    if (success && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isKullanici ? 'Oyuncu Kayıt' : 'İşletme Kayıt'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildHeader(),
                const SizedBox(height: 24),
                if (widget.isKullanici) ..._buildKullaniciFields(),
                if (!widget.isKullanici) ..._buildIsletmeFields(),
                ..._buildOrtakFields(),
                const SizedBox(height: 16),
                _buildErrorMessage(),
                const SizedBox(height: 24),
                _buildKayitButton(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.isKullanici
              ? 'Oyuncu olarak kayıt ol'
              : 'İşletmenizi kayıt edin',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.isKullanici
              ? 'Maçlara katılmak için hesap oluşturun'
              : 'Sahanızı listelemek için hesap oluşturun',
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildKullaniciFields() {
    return [
      TextFormField(
        controller: _adSoyadController,
        validator: Validators.adSoyad,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(
          hintText: 'Ad Soyad',
          prefixIcon: Icon(Icons.person_outline),
        ),
      ),
      const SizedBox(height: 16),
    ];
  }

  List<Widget> _buildIsletmeFields() {
    return [
      TextFormField(
        controller: _isletmeAdiController,
        validator: (v) => Validators.zorunluAlan(v, 'İşletme adı'),
        decoration: const InputDecoration(
          hintText: 'İşletme Adı',
          prefixIcon: Icon(Icons.business),
        ),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _yetkiliAdSoyadController,
        validator: Validators.adSoyad,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(
          hintText: 'Yetkili Ad Soyad',
          prefixIcon: Icon(Icons.person_outline),
        ),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _vergiNoController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          hintText: 'Vergi No (Opsiyonel)',
          prefixIcon: Icon(Icons.receipt_long),
        ),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _adresController,
        maxLines: 2,
        decoration: const InputDecoration(
          hintText: 'Adres (Opsiyonel)',
          prefixIcon: Icon(Icons.location_on_outlined),
        ),
      ),
      const SizedBox(height: 16),
    ];
  }

  List<Widget> _buildOrtakFields() {
    return [
      TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        validator: Validators.email,
        decoration: const InputDecoration(
          hintText: 'Email',
          prefixIcon: Icon(Icons.email_outlined),
        ),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _telefonController,
        keyboardType: TextInputType.phone,
        validator: widget.isKullanici
            ? Validators.telefon
            : (v) => Validators.zorunluAlan(v, 'Telefon'),
        decoration: InputDecoration(
          hintText: widget.isKullanici
              ? 'Telefon (Opsiyonel)'
              : 'Telefon',
          prefixIcon: const Icon(Icons.phone_outlined),
        ),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _sifreController,
        obscureText: _sifreGizli,
        validator: Validators.sifre,
        decoration: InputDecoration(
          hintText: 'Şifre',
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            icon: Icon(
              _sifreGizli ? Icons.visibility_off : Icons.visibility,
              color: AppTheme.textSecondary,
            ),
            onPressed: () => setState(() => _sifreGizli = !_sifreGizli),
          ),
        ),
      ),
      const SizedBox(height: 8),
      const Padding(
        padding: EdgeInsets.only(left: 4),
        child: Text(
          'En az 8 karakter, büyük/küçük harf ve rakam içermelidir',
          style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
        ),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _sifreTekrarController,
        obscureText: _sifreTekrarGizli,
        validator: (v) => Validators.sifreTekrar(v, _sifreController.text),
        decoration: InputDecoration(
          hintText: 'Şifre Tekrar',
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            icon: Icon(
              _sifreTekrarGizli ? Icons.visibility_off : Icons.visibility,
              color: AppTheme.textSecondary,
            ),
            onPressed: () =>
                setState(() => _sifreTekrarGizli = !_sifreTekrarGizli),
          ),
        ),
      ),
    ];
  }

  Widget _buildErrorMessage() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.errorMessage == null) return const SizedBox.shrink();
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.errorRed.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.errorRed.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline,
                  color: AppTheme.errorRed, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  auth.errorMessage!,
                  style: const TextStyle(
                      color: AppTheme.errorRed, fontSize: 13),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKayitButton() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final isLoading = auth.state == AuthState.loading;
        return ElevatedButton(
          onPressed: isLoading ? null : _kayitOl,
          child: isLoading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : const Text('Kayıt Ol'),
        );
      },
    );
  }
}
