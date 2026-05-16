import 'package:flutter/material.dart';
import '../models/mac.dart';
import '../models/token_response.dart';
import '../services/api_client.dart';
import '../services/mac_service.dart';
import '../utils/theme.dart';
import 'mac_detay_screen.dart';

class IstatistikScreen extends StatefulWidget {
  final KullaniciBilgi user;
  const IstatistikScreen({super.key, required this.user});

  @override
  State<IstatistikScreen> createState() => _IstatistikScreenState();
}

class _IstatistikScreenState extends State<IstatistikScreen> {
  final MacService _macService = MacService(ApiClient());
  List<Mac> _sonMaclar = [];
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<void> _yukle() async {
    try {
      final res = await _macService.benimMaclarim();
      if (mounted) {
        setState(() {
          _yukleniyor = false;
          if (res.basarili && res.veri != null) {
            _sonMaclar = res.veri!.take(5).toList();
          }
        });
      }
    } catch (_) {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final u = widget.user;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _yukleniyor
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppTheme.primaryGreen))
                    : RefreshIndicator(
                        onRefresh: _yukle,
                        color: AppTheme.primaryGreen,
                        child: ListView(
                          physics: const BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics()),
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                          children: [
                            _buildDisiplinKart(u),
                            const SizedBox(height: 16),
                            _buildAnaStatKartlari(u),
                            const SizedBox(height: 16),
                            _buildAktiviteKarti(u),
                            const SizedBox(height: 16),
                            if (_sonMaclar.isNotEmpty) ...[
                              _buildSonMaclarBaslik(),
                              const SizedBox(height: 12),
                              ..._sonMaclar.map(_buildMacSatiri),
                            ],
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 24, 8),
      child: Row(children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 8),
        const Text(
          'İstatistikler',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary),
        ),
      ]),
    );
  }

  Widget _buildDisiplinKart(KullaniciBilgi u) {
    final puan = u.disiplinPuani ?? 5.0;
    final normalized = (puan / 5.0).clamp(0.0, 1.0);
    final renk = _disiplinRengi(puan);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          renk.withOpacity(0.12),
          renk.withOpacity(0.04),
          AppTheme.cardDark,
        ], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: renk.withOpacity(0.2)),
      ),
      child: Row(children: [
        SizedBox(
          width: 72,
          height: 72,
          child: Stack(alignment: Alignment.center, children: [
            SizedBox(
              width: 72,
              height: 72,
              child: CircularProgressIndicator(
                value: normalized,
                strokeWidth: 7,
                backgroundColor: renk.withOpacity(0.12),
                color: renk,
                strokeCap: StrokeCap.round,
              ),
            ),
            Text(
              puan.toStringAsFixed(1),
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: renk),
            ),
          ]),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Disiplin Puanı',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 4),
            Text(
              _disiplinAciklama(puan),
              style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary.withOpacity(0.7),
                  height: 1.4),
            ),
            const SizedBox(height: 8),
            Row(children: [
              Icon(Icons.people_rounded,
                  size: 13, color: AppTheme.textSecondary.withOpacity(0.5)),
              const SizedBox(width: 4),
              Text(
                '${u.aldiguPuanSayisi} oyuncu tarafından puanlandı',
                style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary.withOpacity(0.5)),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _buildAnaStatKartlari(KullaniciBilgi u) {
    return Row(children: [
      Expanded(
          child: _statKart(
        ikon: Icons.sports_soccer_rounded,
        deger: '${u.toplamMacSayisi}',
        etiket: 'Toplam Maç',
        gradient: AppTheme.primaryGradient,
        glow: AppTheme.primaryGreen,
      )),
      const SizedBox(width: 10),
      Expanded(
          child: _statKart(
        ikon: Icons.add_circle_outline_rounded,
        deger: '${u.olusturduguMacSayisi}',
        etiket: 'Oluşturduğum',
        gradient: AppTheme.purpleGradient,
        glow: AppTheme.accentPurple,
      )),
      const SizedBox(width: 10),
      Expanded(
          child: _statKart(
        ikon: Icons.campaign_rounded,
        deger: '${u.toplamIlanSayisi}',
        etiket: 'İlanlarım',
        gradient: AppTheme.coralGradient,
        glow: AppTheme.accentCoral,
      )),
    ]);
  }

  Widget _statKart({
    required IconData ikon,
    required String deger,
    required String etiket,
    required LinearGradient gradient,
    required Color glow,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: glow.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
              color: glow.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(children: [
        ShaderMask(
          shaderCallback: (b) => gradient.createShader(b),
          child: Icon(ikon, color: Colors.white, size: 26),
        ),
        const SizedBox(height: 10),
        Text(
          deger,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            foreground: Paint()
              ..shader =
                  gradient.createShader(const Rect.fromLTWH(0, 0, 60, 30)),
          ),
        ),
        const SizedBox(height: 4),
        Text(etiket,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary.withOpacity(0.7))),
      ]),
    );
  }

  Widget _buildAktiviteKarti(KullaniciBilgi u) {
    final sonMac = _formatSonMac(u.sonMacTarihi);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Aktivite',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary)),
        const SizedBox(height: 16),
        _aktiviteSatiri(
          ikon: Icons.calendar_today_rounded,
          renk: AppTheme.accentBlue,
          etiket: 'Son 30 Gün',
          deger: '${u.sonOtuzGunMacSayisi} maç',
        ),
        const SizedBox(height: 12),
        _aktiviteSatiri(
          ikon: Icons.history_rounded,
          renk: AppTheme.lightOrange,
          etiket: 'Son Maç',
          deger: sonMac,
        ),
        const SizedBox(height: 12),
        _aktiviteSatiri(
          ikon: Icons.sports_soccer_rounded,
          renk: AppTheme.primaryGreen,
          etiket: 'Tercih Pozisyon',
          deger: _pozisyonAdi(u.tercihEdilenPozisyon),
        ),
        if (u.il != null && u.ilce != null) ...[
          const SizedBox(height: 12),
          _aktiviteSatiri(
            ikon: Icons.location_on_rounded,
            renk: AppTheme.accentPurple,
            etiket: 'Konum',
            deger: '${u.ilce}, ${u.il}',
          ),
        ],
      ]),
    );
  }

  Widget _aktiviteSatiri({
    required IconData ikon,
    required Color renk,
    required String etiket,
    required String deger,
  }) {
    return Row(children: [
      Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
            color: renk.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(ikon, color: renk, size: 18),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(etiket,
              style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary.withOpacity(0.6))),
          const SizedBox(height: 2),
          Text(deger,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary)),
        ]),
      ),
    ]);
  }

  Widget _buildSonMaclarBaslik() {
    return const Row(children: [
      Text('Son Maçlar',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary)),
    ]);
  }

  Widget _buildMacSatiri(Mac mac) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => MacDetayScreen(macId: mac.id))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.03)),
        ),
        child: Row(children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.sports_soccer_rounded,
                color: AppTheme.primaryGreen, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(mac.macBasligi,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 3),
              Text('${mac.macTarihi}  ${mac.baslangicSaati}',
                  style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary.withOpacity(0.6))),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(mac.format,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryGreen)),
          ),
        ]),
      ),
    );
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

  String _pozisyonAdi(String? poz) {
    switch (poz) {
      case 'KALECI': return 'Kaleci';
      case 'DEFANS': return 'Defans';
      case 'ORTASAHA': return 'Orta Saha';
      case 'FORVET': return 'Forvet';
      default: return 'Belirtilmemiş';
    }
  }

  String _formatSonMac(String? tarih) {
    if (tarih == null) return 'Henüz maç yok';
    try {
      final dt = DateTime.parse(tarih).toLocal();
      final fark = DateTime.now().difference(dt);
      if (fark.inDays == 0) return 'Bugün';
      if (fark.inDays == 1) return 'Dün';
      if (fark.inDays < 7) return '${fark.inDays} gün önce';
      if (fark.inDays < 30) return '${(fark.inDays / 7).floor()} hafta önce';
      return '${dt.day}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
    } catch (_) {
      return 'Bilinmiyor';
    }
  }
}
