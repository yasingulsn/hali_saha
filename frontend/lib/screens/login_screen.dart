import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/validators.dart';
import '../utils/theme.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _sifreController = TextEditingController();
  final _emailFocus = FocusNode();
  final _sifreFocus = FocusNode();

  bool _sifreGizli = true;
  bool _beniHatirla = false;
  bool _isKullanici = true;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _fadeAnim = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    _pulseAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _sifreController.dispose();
    _emailFocus.dispose();
    _sifreFocus.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _girisYap() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    authProvider.clearError();

    bool success;
    if (_isKullanici) {
      success = await authProvider.kullaniciGiris(
        _emailController.text.trim(),
        _sifreController.text,
        beniHatirla: _beniHatirla,
      );
    } else {
      success = await authProvider.isletmeGiris(
        _emailController.text.trim(),
        _sifreController.text,
        beniHatirla: _beniHatirla,
      );
    }

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          _buildFieldLines(),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.07),
                      _buildLogo(),
                      const SizedBox(height: 40),
                      _buildGlassCard(),
                      const SizedBox(height: 20),
                      _buildKayitLink(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
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
      child: Stack(
        children: [
          // Radial glow top-right
          Positioned(
            top: -80,
            right: -60,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (_, __) => Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primaryGreen
                          .withOpacity(0.07 * _pulseAnim.value),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Radial glow bottom-left
          Positioned(
            bottom: -100,
            left: -80,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (_, __) => Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.accentOrange
                          .withOpacity(0.04 * _pulseAnim.value),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLines() {
    return Positioned.fill(
      child: CustomPaint(
        painter: _FieldLinesPainter(
          color: AppTheme.primaryGreen.withOpacity(0.04),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        // Animated soccer ball icon
        AnimatedBuilder(
          animation: _pulseController,
          builder: (_, __) => Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.primaryGreen.withOpacity(0.15),
                  AppTheme.primaryGreen.withOpacity(0.03),
                ],
                radius: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGreen
                      .withOpacity(0.2 * _pulseAnim.value),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryGreen.withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.sports_soccer_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppTheme.textPrimary, AppTheme.neonGreen],
          ).createShader(bounds),
          child: const Text(
            'HALI SAHA',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 6,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.primaryGreen.withOpacity(0.15),
            ),
          ),
          child: const Text(
            'Maçını bul  \u2022  Takımını kur',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
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
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryGreen.withOpacity(0.06),
                AppTheme.cardDark.withOpacity(0.8),
                AppTheme.cardDark.withOpacity(0.9),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppTheme.primaryGreen.withOpacity(0.1),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              children: [
                _buildSegmentToggle(),
                const SizedBox(height: 28),
                _buildFormSection(),
                const SizedBox(height: 18),
                _buildBeniHatirla(),
                const SizedBox(height: 6),
                _buildErrorMessage(),
                const SizedBox(height: 22),
                _buildGirisButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentToggle() {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundDark.withOpacity(0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.primaryGreen.withOpacity(0.06),
        ),
      ),
      child: Row(
        children: [
          _buildToggleItem(
            label: 'Oyuncu',
            icon: Icons.directions_run_rounded,
            isSelected: _isKullanici,
            onTap: () => setState(() => _isKullanici = true),
          ),
          _buildToggleItem(
            label: 'İşletme',
            icon: Icons.stadium_outlined,
            isSelected: !_isKullanici,
            onTap: () => setState(() => _isKullanici = false),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            gradient: isSelected ? AppTheme.buttonGradient : null,
            borderRadius: BorderRadius.circular(11),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primaryGreen.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? AppTheme.backgroundDark
                    : AppTheme.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? AppTheme.backgroundDark
                      : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormSection() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with animated underline
          Row(
            children: [
              Container(
                width: 3,
                height: 22,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: Text(
                  _isKullanici ? 'Oyuncu Girişi' : 'İşletme Girişi',
                  key: ValueKey(_isKullanici),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 13),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _isKullanici
                    ? 'Hesabınıza giriş yaparak maçlara katılın'
                    : 'İşletme panelinize erişim sağlayın',
                key: ValueKey('desc_$_isKullanici'),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Email field with label
          _buildFieldLabel('E-posta'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            focusNode: _emailFocus,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'ornek@email.com',
              prefixIcon: _buildFieldIcon(Icons.alternate_email_rounded),
            ),
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(_sifreFocus),
          ),
          const SizedBox(height: 18),
          _buildFieldLabel('Şifre'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _sifreController,
            focusNode: _sifreFocus,
            obscureText: _sifreGizli,
            validator: (v) =>
                v == null || v.isEmpty ? 'Şifre gereklidir' : null,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022',
              prefixIcon: _buildFieldIcon(Icons.lock_outline_rounded),
              suffixIcon: GestureDetector(
                onTap: () => setState(() => _sifreGizli = !_sifreGizli),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      _sifreGizli
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      key: ValueKey(_sifreGizli),
                      color: AppTheme.textSecondary,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
            onFieldSubmitted: (_) => _girisYap(),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppTheme.textSecondary.withOpacity(0.9),
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildFieldIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen.withOpacity(0.08),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Icon(icon, size: 16, color: AppTheme.primaryGreen),
      ),
    );
  }

  Widget _buildBeniHatirla() {
    return GestureDetector(
      onTap: () => setState(() => _beniHatirla = !_beniHatirla),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            // Custom animated toggle
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              width: 44,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: _beniHatirla ? AppTheme.buttonGradient : null,
                color: _beniHatirla ? null : AppTheme.backgroundDark,
                border: Border.all(
                  color: _beniHatirla
                      ? Colors.transparent
                      : AppTheme.textSecondary.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: _beniHatirla
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryGreen.withOpacity(0.3),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                alignment:
                    _beniHatirla ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 18,
                  height: 18,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _beniHatirla
                        ? AppTheme.backgroundDark
                        : AppTheme.textSecondary.withOpacity(0.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Beni Hatırla',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            AnimatedOpacity(
              opacity: _beniHatirla ? 1.0 : 0.4,
              duration: const Duration(milliseconds: 250),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _beniHatirla
                      ? AppTheme.primaryGreen.withOpacity(0.12)
                      : AppTheme.backgroundDark.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _beniHatirla
                        ? AppTheme.primaryGreen.withOpacity(0.2)
                        : Colors.transparent,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 12,
                      color: _beniHatirla
                          ? AppTheme.neonGreen
                          : AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '90 gün',
                      style: TextStyle(
                        color: _beniHatirla
                            ? AppTheme.neonGreen
                            : AppTheme.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.errorMessage == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.errorRed.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppTheme.errorRed.withOpacity(0.15),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppTheme.errorRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.warning_amber_rounded,
                      color: AppTheme.errorRed, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    auth.errorMessage!,
                    style: TextStyle(
                      color: AppTheme.errorRed.withOpacity(0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGirisButton() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final isLoading = auth.state == AuthState.loading;
        return GestureDetector(
          onTap: isLoading ? null : _girisYap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: isLoading
                  ? LinearGradient(
                      colors: [
                        AppTheme.primaryGreen.withOpacity(0.4),
                        AppTheme.fieldGreen.withOpacity(0.3),
                      ],
                    )
                  : AppTheme.buttonGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isLoading
                  ? []
                  : [
                      BoxShadow(
                        color: AppTheme.primaryGreen.withOpacity(0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: AppTheme.primaryGreen.withOpacity(0.15),
                        blurRadius: 40,
                        offset: const Offset(0, 16),
                      ),
                    ],
            ),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Giriş Yap',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.backgroundDark,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundDark.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: AppTheme.backgroundDark,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildKayitLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Hesabınız yok mu?',
          style: TextStyle(
            color: AppTheme.textSecondary.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => RegisterScreen(isKullanici: _isKullanici),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.primaryGreen.withOpacity(0.25),
              ),
            ),
            child: const Text(
              'Kayıt Ol',
              style: TextStyle(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Draws subtle soccer field lines in background
class _FieldLinesPainter extends CustomPainter {
  final Color color;

  _FieldLinesPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Center circle
    final center = Offset(size.width * 0.5, size.height * 0.35);
    canvas.drawCircle(center, 60, paint);

    // Center dot
    canvas.drawCircle(center, 3, paint..style = PaintingStyle.fill);
    paint.style = PaintingStyle.stroke;

    // Horizontal center line
    canvas.drawLine(
      Offset(size.width * 0.1, size.height * 0.35),
      Offset(size.width * 0.9, size.height * 0.35),
      paint,
    );

    // Bottom arc (penalty area)
    final arcRect = Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.92),
      width: 200,
      height: 100,
    );
    canvas.drawArc(arcRect, math.pi, math.pi, false, paint);

    // Corner arcs
    final cornerRadius = 20.0;
    // Top-left
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: cornerRadius),
      0,
      math.pi / 2,
      false,
      paint,
    );
    // Top-right
    canvas.drawArc(
      Rect.fromCircle(
          center: Offset(size.width, 0), radius: cornerRadius),
      math.pi / 2,
      math.pi / 2,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
