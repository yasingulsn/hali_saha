import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/token_response.dart';
import '../../services/profil_service.dart';
import '../../utils/theme.dart';
import '../login_screen.dart';
import '../profil_duzenle_screen.dart';
import '../takim_istekleri_screen.dart';

class ProfilTab extends StatefulWidget {
  const ProfilTab({super.key});

  @override
  State<ProfilTab> createState() => _ProfilTabState();
}

class _ProfilTabState extends State<ProfilTab> with TickerProviderStateMixin {
  final ProfilService _profilService = ProfilService();
  KullaniciBilgi? _profilDetay;
  bool _isLoading = true;
  String? _hata;

  late AnimationController _headerAnimCtrl;
  late Animation<double> _headerFadeIn;
  late AnimationController _statsAnimCtrl;
  late Animation<double> _statsFadeIn;

  @override
  void initState() {
    super.initState();
    _headerAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _headerFadeIn = CurvedAnimation(
      parent: _headerAnimCtrl,
      curve: Curves.easeOutCubic,
    );

    _statsAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _statsFadeIn = CurvedAnimation(
      parent: _statsAnimCtrl,
      curve: Curves.easeOutCubic,
    );

    _loadProfil();
  }

  @override
  void dispose() {
    _headerAnimCtrl.dispose();
    _statsAnimCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfil() async {
    setState(() {
      _isLoading = true;
      _hata = null;
    });

    final response = await _profilService.getProfilDetay();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (response.basarili && response.veri != null) {
          _profilDetay = response.veri;
          _headerAnimCtrl.forward();
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) _statsAnimCtrl.forward();
          });
        } else {
          _hata = response.mesaj;
          // Hata olsa bile local kullanıcı bilgisini göster
          final auth = Provider.of<AuthProvider>(context, listen: false);
          _profilDetay = auth.currentUser;
          _headerAnimCtrl.forward();
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) _statsAnimCtrl.forward();
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final user = _profilDetay ?? auth.currentUser;
        final isIsletme = auth.kullaniciTipi == 'ISLETME';

        if (_isLoading && _profilDetay == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryGreen),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadProfil,
          color: AppTheme.primaryGreen,
          backgroundColor: AppTheme.cardDark,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              if (_hata != null)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.lightOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.wifi_off_rounded,
                            color: AppTheme.lightOrange, size: 18),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text('Çevrimdışı mod',
                            style: TextStyle(fontSize: 12, color: AppTheme.lightOrange),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _headerFadeIn,
                  child: _buildProfileHeader(user, isIsletme),
                ),
              ),
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _statsFadeIn,
                  child: _buildStatsCards(user),
                ),
              ),
              if (!isIsletme)
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _statsFadeIn,
                    child: _buildDetailSection(user),
                  ),
                ),
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _statsFadeIn,
                  child: _buildMenuSection(context, auth),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        );
      },
    );
  }

  // ─── HEADER ───────────────────────────────────────────────────

  Widget _buildProfileHeader(KullaniciBilgi? user, bool isIsletme) {
    final adSoyad = user?.adSoyad ?? 'Kullanıcı';
    final initials = adSoyad
        .split(' ')
        .where((s) => s.isNotEmpty)
        .map((s) => s[0].toUpperCase())
        .take(2)
        .join();

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryGreen.withOpacity(0.12),
            AppTheme.accentPurple.withOpacity(0.08),
            AppTheme.cardDark,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.primaryGreen.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.06),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGreen.withOpacity(0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Ad Soyad
          Text(
            adSoyad,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),

          // Email
          Text(
            user?.email ?? '',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 14),

          // Badges Row
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildBadge(
                icon: isIsletme ? Icons.store_rounded : Icons.shield_rounded,
                label: isIsletme ? 'İşletme' : 'Oyuncu',
                color: isIsletme ? AppTheme.accentPurple : AppTheme.primaryGreen,
              ),
              if (user?.tercihEdilenPozisyon != null &&
                  user!.tercihEdilenPozisyon!.isNotEmpty)
                _buildBadge(
                  icon: Icons.sports_soccer_rounded,
                  label: _pozisyonAdi(user.tercihEdilenPozisyon!),
                  color: AppTheme.lightOrange,
                ),
              if (user?.disiplinPuani != null)
                _buildBadge(
                  icon: Icons.stars_rounded,
                  label: 'Disiplin: ${user!.disiplinPuani!.toStringAsFixed(1)}',
                  color: _disiplinRengi(user.disiplinPuani!),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── İSTATİSTİK KARTLARI ─────────────────────────────────────

  Widget _buildStatsCards(KullaniciBilgi? user) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.sports_soccer_rounded,
              label: 'Toplam Maç',
              value: '${user?.toplamMacSayisi ?? 0}',
              gradient: AppTheme.primaryGradient,
              glowColor: AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildStatCard(
              icon: Icons.add_circle_outline_rounded,
              label: 'Oluşturduğum',
              value: '${user?.olusturduguMacSayisi ?? 0}',
              gradient: AppTheme.purpleGradient,
              glowColor: AppTheme.accentPurple,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildStatCard(
              icon: Icons.campaign_rounded,
              label: 'İlanlarım',
              value: '${user?.toplamIlanSayisi ?? 0}',
              gradient: AppTheme.coralGradient,
              glowColor: AppTheme.accentCoral,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required LinearGradient gradient,
    required Color glowColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: glowColor.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => gradient.createShader(bounds),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              foreground: Paint()
                ..shader = gradient.createShader(
                  const Rect.fromLTWH(0, 0, 60, 30),
                ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  // ─── DETAY BİLGİ BÖLÜMÜ ──────────────────────────────────────

  Widget _buildDetailSection(KullaniciBilgi? user) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.03),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profil Bilgileri',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // Disiplin Puanı — özel gösterim
            if (user?.disiplinPuani != null)
              _buildDisiplinPuaniWidget(user!.disiplinPuani!),

            if (user?.disiplinPuani != null)
              const SizedBox(height: 16),

            _buildDetailRow(
              Icons.sports_soccer_rounded,
              'Tercih Edilen Pozisyon',
              user?.tercihEdilenPozisyon != null
                  ? _pozisyonAdi(user!.tercihEdilenPozisyon!)
                  : 'Belirtilmemiş',
              AppTheme.lightOrange,
            ),
            _buildDetailRow(
              Icons.phone_rounded,
              'Telefon',
              user?.telefon ?? 'Belirtilmemiş',
              AppTheme.accentBlue,
            ),
            _buildDetailRow(
              Icons.cake_rounded,
              'Doğum Tarihi',
              user?.dogumTarihi ?? 'Belirtilmemiş',
              AppTheme.accentPink,
            ),
            _buildDetailRow(
              Icons.calendar_today_rounded,
              'Kayıt Tarihi',
              _formatKayitTarihi(user?.kayitTarihi),
              AppTheme.lightGreen,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisiplinPuaniWidget(double puan) {
    final normalized = (puan / 5.0).clamp(0.0, 1.0);
    final renk = _disiplinRengi(puan);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            renk.withOpacity(0.08),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: renk.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          // Circular indicator
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 56,
                  height: 56,
                  child: CircularProgressIndicator(
                    value: normalized,
                    strokeWidth: 5,
                    backgroundColor: renk.withOpacity(0.12),
                    color: renk,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Text(
                  puan.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: renk,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Disiplin Puanı',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: renk,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _disiplinAciklama(puan),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    Color color, {
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── MENÜ ─────────────────────────────────────────────────────

  Widget _buildMenuSection(BuildContext context, AuthProvider auth) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.03),
          ),
        ),
        child: Column(
          children: [
            _buildMenuItem(
              icon: Icons.edit_rounded,
              label: 'Profili Düzenle',
              color: AppTheme.primaryGreen,
              onTap: () => _navigateToProfilDuzenle(context),
            ),
            _buildMenuDivider(),
            _buildMenuItem(
              icon: Icons.handshake_rounded,
              label: 'Gelen İstekler',
              color: AppTheme.accentBlue,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const TakimIstekleriScreen()));
              },
            ),
            _buildMenuDivider(),
            _buildMenuItem(
              icon: Icons.notifications_none_rounded,
              label: 'Bildirimler',
              color: AppTheme.lightOrange,
              onTap: () {},
            ),
            _buildMenuDivider(),
            _buildMenuItem(
              icon: Icons.security_rounded,
              label: 'Güvenlik',
              color: AppTheme.lightGreen,
              onTap: () {},
            ),
            _buildMenuDivider(),
            _buildMenuItem(
              icon: Icons.help_outline_rounded,
              label: 'Yardım & Destek',
              color: AppTheme.textSecondary,
              onTap: () {},
            ),
            _buildMenuDivider(),
            _buildMenuItem(
              icon: Icons.info_outline_rounded,
              label: 'Hakkında',
              color: AppTheme.textSecondary,
              onTap: () {},
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Divider(
                color: AppTheme.errorRed.withOpacity(0.08),
                height: 1,
              ),
            ),
            _buildMenuItem(
              icon: Icons.devices_rounded,
              label: 'Tüm Cihazlardan Çıkış',
              color: AppTheme.accentCoral,
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.logout_rounded,
              label: 'Çıkış Yap',
              color: AppTheme.errorRed,
              onTap: () => _cikisYap(context, auth),
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        color: Colors.white.withOpacity(0.03),
        height: 1,
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withOpacity(isDestructive ? 0.08 : 0.1),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDestructive
                        ? AppTheme.errorRed
                        : AppTheme.textPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textSecondary.withOpacity(0.3),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── YARDIMCI ─────────────────────────────────────────────────

  Widget _buildBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _pozisyonAdi(String pozisyon) {
    switch (pozisyon) {
      case 'KALECI':
        return 'Kaleci';
      case 'DEFANS':
        return 'Defans';
      case 'ORTASAHA':
        return 'Orta Saha';
      case 'FORVET':
        return 'Forvet';
      default:
        return pozisyon;
    }
  }

  Color _disiplinRengi(double puan) {
    if (puan >= 4.0) return AppTheme.primaryGreen;
    if (puan >= 3.0) return AppTheme.lightOrange;
    if (puan >= 2.0) return AppTheme.accentCoral;
    return AppTheme.errorRed;
  }

  String _disiplinAciklama(double puan) {
    if (puan >= 4.5) return 'Örnek sporcu! Harika bir disipline sahipsin.';
    if (puan >= 4.0) return 'Çok iyi! Fair play anlayışın takdire şayan.';
    if (puan >= 3.0) return 'İyi seviye. Biraz daha dikkat edebilirsin.';
    if (puan >= 2.0) return 'Geliştirilmeli. Bazı maçlara katılamayabilirsin.';
    return 'Kritik seviye! Acil iyileştirme gerekli.';
  }

  String _formatKayitTarihi(String? tarih) {
    if (tarih == null) return 'Belirtilmemiş';
    try {
      final dt = DateTime.parse(tarih);
      final aylar = [
        '', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
        'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
      ];
      return '${dt.day} ${aylar[dt.month]} ${dt.year}';
    } catch (_) {
      return tarih;
    }
  }

  // ─── NAVİGASYON ───────────────────────────────────────────────

  Future<void> _navigateToProfilDuzenle(BuildContext context) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ProfilDuzenleScreen(profilDetay: _profilDetay),
      ),
    );

    if (result == true && mounted) {
      _loadProfil();
    }
  }

  // ─── ÇIKIŞ ────────────────────────────────────────────────────

  Future<void> _cikisYap(BuildContext context, AuthProvider auth) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Çıkış Yap',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        content: const Text(
          'Hesabınızdan çıkış yapmak istediğinize emin misiniz?',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'İptal',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.errorRed.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text(
                'Çıkış Yap',
                style: TextStyle(
                  color: AppTheme.errorRed,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await auth.cikis();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }
}
