import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/mac.dart';
import '../../models/saha.dart';
import '../../models/takim_ilani.dart';
import '../../providers/auth_provider.dart';
import '../../providers/konum_provider.dart';
import '../../services/api_client.dart';
import '../../services/konum_service.dart';
import '../../services/mac_service.dart';
import '../../services/saha_service.dart';
import '../../utils/theme.dart';
import '../arama_screen.dart';
import '../mac_detay_screen.dart';
import '../mac_olustur_screen.dart';
import '../saha_detay_screen.dart';
import '../takim_ilanlari_screen.dart';
import '../takim_ilani_olustur_screen.dart';
import '../bildirimler_screen.dart';
import '../../providers/bildirim_provider.dart';
import '../../services/takim_ilani_service.dart';
import '../../widgets/konum_secim_sheet.dart';

class KesfetTab extends StatefulWidget {
  const KesfetTab({super.key});

  @override
  State<KesfetTab> createState() => _KesfetTabState();
}

class _KesfetTabState extends State<KesfetTab> {
  final _apiClient = ApiClient();
  final _konumService = KonumService();
  late final SahaService _sahaService = SahaService(_apiClient);
  late final MacService _macService = MacService(_apiClient);
  late final TakimIlaniService _takimIlaniService = TakimIlaniService(_apiClient);

  List<Mac> _tumMaclar = [];
  List<Mac> _digerMaclar = [];
  List<Saha> _populerSahalar = [];
  List<TakimIlani> _takimIlanlari = [];
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    _yukle();
    Future.microtask(() => context.read<BildirimProvider>().sayiGuncelle());
  }

  Future<void> _yukle() async {
    setState(() => _yukleniyor = true);
    final macRes = await _macService.acikMaclar();
    final sahaRes = await _sahaService.tumSahalar();
    final ilanRes = await _takimIlaniService.aktifIlanlar();

    if (mounted) {
      final konumProvider = context.read<KonumProvider>();
      final il = (konumProvider.seciliIl ?? '').toLowerCase();
      final ilce = (konumProvider.seciliIlce ?? '').toLowerCase();
      
      setState(() {
        _yukleniyor = false;
        
        // MAÇLAR
        if (macRes.basarili && macRes.veri != null) {
          final hepsi = macRes.veri!;
          _tumMaclar = hepsi.where((m) {
            final mIl = (m.il ?? '').toLowerCase();
            final mIlce = (m.ilce ?? '').toLowerCase();
            if (il.isEmpty) return true;
            if (ilce.isEmpty) return mIl.contains(il);
            return mIl.contains(il) && mIlce.contains(ilce);
          }).toList();
          
          // Konum dışındaki maçları da "diğerleri" için sakla
          _digerMaclar = hepsi.where((m) => !_tumMaclar.contains(m)).take(10).toList();
        }

        // SAHALAR
        if (sahaRes.basarili && sahaRes.veri != null) {
          final hepsi = sahaRes.veri!;
          _populerSahalar = hepsi.where((s) {
            final adres = s.adres.toLowerCase();
            if (il.isEmpty) return true;
            return adres.contains(il);
          }).toList().take(5).toList();
        }

        // İLANLAR
        if (ilanRes.basarili && ilanRes.veri != null) {
          final hepsi = ilanRes.veri!;
          _takimIlanlari = hepsi.where((i) {
            final k = (i.konum ?? '').toLowerCase();
            if (il.isEmpty) return true;
            if (ilce.isEmpty) return k.contains(il);
            return k.contains(il) && k.contains(ilce);
          }).toList();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final isIsletme = auth.kullaniciTipi == 'ISLETME';

    return RefreshIndicator(
      onRefresh: _yukle,
      color: AppTheme.primaryGreen,
      backgroundColor: AppTheme.cardDark,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          // ── HEADER ──────────────────────────────────
          SliverToBoxAdapter(child: _buildHeader(user)),
          // ── KONUM + ARAMA ───────────────────────────
          SliverToBoxAdapter(child: _buildKonumVeArama()),
          // ── HIZLI ERİŞİM ────────────────────────────
          SliverToBoxAdapter(child: _buildQuickActions(isIsletme)),

          if (_yukleniyor)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen)),
            )
          else ...[
            // ── YAKLAŞAN MAÇLAR ─────────────────────────
            if (_tumMaclar.isNotEmpty) ...[
              SliverToBoxAdapter(child: _buildSectionHeader(
                icon: Icons.sports_soccer_rounded,
                iconColor: AppTheme.primaryGreen,
                title: 'Yaklaşan Maçlar',
                badge: '${_tumMaclar.length}',
              )),
              SliverToBoxAdapter(child: _buildMaclarHorizontal()),
            ],

            // ── TAKIM İLANLARI ─────────────────────────
            if (_takimIlanlari.isNotEmpty) ...[
              SliverToBoxAdapter(child: _buildSectionHeader(
                icon: Icons.groups_rounded,
                iconColor: AppTheme.accentPurple,
                title: 'Takım İlanları',
                badge: '${_takimIlanlari.length}',
                onTumunuGor: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TakimIlanlariScreen())),
              )),
              SliverToBoxAdapter(child: _buildTakimIlanlariHorizontal()),
            ],

            // ── DİĞER YAKLAŞAN MAÇLAR ───────────────────
            if (_tumMaclar.isEmpty && _digerMaclar.isNotEmpty) ...[
              SliverToBoxAdapter(child: _buildSectionHeader(
                icon: Icons.explore_rounded,
                iconColor: AppTheme.accentCoral,
                title: 'Diğer Yaklaşan Maçlar',
              )),
              SliverToBoxAdapter(child: _buildDigerMaclarHorizontal()),
            ],

            // ── SAHALAR ─────────────────────────────────
            if (_populerSahalar.isNotEmpty) ...[
              SliverToBoxAdapter(child: _buildSectionHeader(
                icon: Icons.stadium_rounded,
                iconColor: AppTheme.accentBlue,
                title: 'Yakındaki Sahalar',
              )),
              SliverToBoxAdapter(child: _buildSahalarGrid()),
            ],

            // ── BOŞ DURUM ───────────────────────────────
            if (_tumMaclar.isEmpty && _populerSahalar.isEmpty && _takimIlanlari.isEmpty)
              SliverToBoxAdapter(child: _buildBosEkran()),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HEADER
  // ═══════════════════════════════════════════════════════════════

  Widget _buildHeader(dynamic user) {
    final hour = DateTime.now().hour;
    String greeting;
    IconData greetIcon;
    if (hour < 12) {
      greeting = 'Günaydın';
      greetIcon = Icons.wb_sunny_rounded;
    } else if (hour < 18) {
      greeting = 'İyi günler';
      greetIcon = Icons.wb_cloudy_rounded;
    } else {
      greeting = 'İyi akşamlar';
      greetIcon = Icons.nights_stay_rounded;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        children: [
          // Sol: selamlama
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(greetIcon, size: 16, color: AppTheme.lightOrange),
                    const SizedBox(width: 6),
                    Text(greeting,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      )),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  user?.adSoyad ?? 'Kullanıcı',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          // Sağ: bildirim
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BildirimlerScreen())),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.cardDark,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.04)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.notifications_none_rounded, color: AppTheme.textSecondary, size: 22),
                  Consumer<BildirimProvider>(
                    builder: (context, bp, _) {
                      if (bp.okunmamisSayisi == 0) return const SizedBox.shrink();
                      return Positioned(
                        top: 10, right: 10,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: AppTheme.accentCoral, shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(minWidth: 8, minHeight: 8),
                          child: bp.okunmamisSayisi > 9 ? const SizedBox.shrink() : null,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // KONUM + ARAMA BİRLEŞİK KART
  // ═══════════════════════════════════════════════════════════════

  Widget _buildKonumVeArama() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.04)),
        ),
        child: Column(
          children: [
            // Konum satırı
            GestureDetector(
              onTap: _konumSec,
              child: Builder(
                builder: (context) {
                  final kp = context.watch<KonumProvider>();
                  return Row(
                    children: [
                      Container(
                        width: 34, height: 34,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.location_on_rounded, size: 18, color: AppTheme.primaryGreen),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Konum',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500,
                                color: AppTheme.textSecondary.withOpacity(0.5)),
                            ),
                            Text(
                              kp.konumEtiketi ?? 'Konum seç — tüm ilanları gör',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: kp.konumSecildi
                                    ? AppTheme.textPrimary
                                    : AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (kp.konumSecildi)
                        GestureDetector(
                          onTap: () {
                            context.read<KonumProvider>().konumTemizle();
                            _yukle();
                          },
                          child: Container(
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                              color: AppTheme.errorRed.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.close_rounded, size: 16, color: AppTheme.errorRed),
                          ),
                        )
                      else
                        Icon(Icons.keyboard_arrow_down_rounded, size: 20,
                          color: AppTheme.textSecondary.withOpacity(0.5)),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1, color: Colors.white.withOpacity(0.04)),
            ),
            // Arama satırı
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AramaScreen())),
              child: Row(
                children: [
                  Container(
                    width: 34, height: 34,
                    decoration: BoxDecoration(
                      color: AppTheme.accentBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.search_rounded, size: 18, color: AppTheme.accentBlue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Saha, maç, oyuncu veya takım ara...',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textHint,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, size: 14,
                    color: AppTheme.textSecondary.withOpacity(0.3)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HIZLI ERİŞİM BUTONLARI
  // ═══════════════════════════════════════════════════════════════

  Widget _buildQuickActions(bool isIsletme) {
    final actions = isIsletme
        ? [
            _QA('Saha Ekle', Icons.add_business_rounded, AppTheme.primaryGreen, null),
            _QA('Rezervasyonlar', Icons.calendar_month_rounded, AppTheme.accentPurple, null),
            _QA('İstatistik', Icons.bar_chart_rounded, AppTheme.accentBlue, null),
          ]
        : [
            _QA('Maç Oluştur', Icons.add_circle_outline_rounded, AppTheme.accentCoral,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MacOlusturScreen()))),
            _QA('İlan Ver', Icons.person_add_rounded, AppTheme.accentPurple,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TakimIlaniOlusturScreen()))),
          ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
      child: Row(
        children: actions.map((a) => Expanded(
          child: GestureDetector(
            onTap: a.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: [
                  Container(
                    width: 54, height: 54,
                    decoration: BoxDecoration(
                      color: a.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: a.color.withOpacity(0.12)),
                    ),
                    child: Icon(a.icon, color: a.color, size: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(a.label, textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary.withOpacity(0.7),
                    ),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ),
        )).toList(),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // BÖLÜM BAŞLIĞI
  // ═══════════════════════════════════════════════════════════════

  Widget _buildSectionHeader({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? badge,
    VoidCallback? onTumunuGor,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
      child: Row(
        children: [
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary,
          )),
          if (badge != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(badge, style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700, color: iconColor,
              )),
            ),
          ],
          const Spacer(),
          if (onTumunuGor != null)
            GestureDetector(
              onTap: onTumunuGor,
              child: Row(children: [
                Text('Tümü', style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: iconColor.withOpacity(0.7),
                )),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios_rounded, size: 12,
                  color: iconColor.withOpacity(0.5)),
              ]),
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // MAÇLAR — YATAY KART LİSTESİ
  // ═══════════════════════════════════════════════════════════════

  Widget _buildMaclarHorizontal() {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _tumMaclar.length,
        itemBuilder: (context, index) => _buildMacKart(_tumMaclar[index]),
      ),
    );
  }

  Widget _buildDigerMaclarHorizontal() {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _digerMaclar.length,
        itemBuilder: (context, index) => _buildMacKart(_digerMaclar[index]),
      ),
    );
  }

  Widget _buildMacKart(Mac mac) {
    final renk = mac.macTipi == 'RAKIP_ARANIYOR'
        ? AppTheme.accentCoral
        : mac.macTipi == 'EKSIK_OYUNCU'
            ? AppTheme.accentBlue
            : AppTheme.primaryGreen;

    return GestureDetector(
      onTap: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (_) => MacDetayScreen(macId: mac.id)));
        _yukle();
      },
      child: Container(
        width: 240,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: renk.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(color: renk.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst: Tarih + Badge'ler
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: renk.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(mac.format, style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700, color: renk,
                  )),
                ),
                const SizedBox(width: 6),
                if (mac.macTipi != 'NORMAL')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accentPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(mac.macTipiText, style: const TextStyle(
                      fontSize: 9, fontWeight: FontWeight.w600, color: AppTheme.accentPurple,
                    )),
                  ),
                const Spacer(),
                Text(mac.baslangicSaati, style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary.withOpacity(0.6),
                )),
              ],
            ),
            const SizedBox(height: 12),
            // Başlık
            Text(mac.macBasligi, style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary,
            ), maxLines: 2, overflow: TextOverflow.ellipsis),
            const Spacer(),
            // Alt bilgi
            Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 12,
                  color: AppTheme.textSecondary.withOpacity(0.4)),
                const SizedBox(width: 4),
                Text(mac.macTarihi, style: TextStyle(
                  fontSize: 11, color: AppTheme.textSecondary.withOpacity(0.5),
                )),
                const Spacer(),
                // Doluluk göstergesi
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: mac.doluMu
                        ? AppTheme.errorRed.withOpacity(0.1)
                        : AppTheme.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people_rounded, size: 12,
                        color: mac.doluMu ? AppTheme.errorRed : AppTheme.primaryGreen),
                      const SizedBox(width: 4),
                      Text('${mac.mevcutOyuncuSayisi}/${mac.maxOyuncuSayisi}',
                        style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w700,
                          color: mac.doluMu ? AppTheme.errorRed : AppTheme.primaryGreen,
                        )),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAKIM İLANLARI — YATAY KART LİSTESİ
  // ═══════════════════════════════════════════════════════════════

  Widget _buildTakimIlanlariHorizontal() {
    final goster = _takimIlanlari.take(8).toList();
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: goster.length,
        itemBuilder: (_, i) => _buildTakimIlaniKart(goster[i]),
      ),
    );
  }

  Widget _buildTakimIlaniKart(TakimIlani ilan) {
    return GestureDetector(
      onTap: () {},
      child: Stack(
        children: [
          Container(
            width: 220,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.accentPurple.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(color: AppTheme.accentPurple.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.accentPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(ilan.pozisyonText, style: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.accentPurple,
                      )),
                    ),
                    const Spacer(),
                    Text(ilan.seviyeText, style: TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary.withOpacity(0.5),
                    )),
                  ],
                ),
                const SizedBox(height: 10),
                Text(ilan.ilanBasligi, style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary,
                ), maxLines: 2, overflow: TextOverflow.ellipsis),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.shield_rounded, size: 12, color: AppTheme.accentBlue),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(ilan.takimAdi, style: TextStyle(
                        fontSize: 11, color: AppTheme.textSecondary.withOpacity(0.6),
                      ), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('${ilan.arananOyuncuSayisi} Oyuncu', style: const TextStyle(
                        fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.primaryGreen,
                      )),
                    ),
                    if (ilan.olusturanId != context.read<AuthProvider>().currentUserId)
                      GestureDetector(
                        onTap: () => _ilanKatilDialog(ilan),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: AppTheme.buttonGradient,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Katıl', style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.backgroundDark,
                          )),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _ilanKatilDialog(TakimIlani ilan) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(ilan.takimAdi, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('İletişim Bilgisi ve Not', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Örn: Telefon numaram 05...',
                hintStyle: TextStyle(color: AppTheme.textHint.withOpacity(0.5)),
                filled: true,
                fillColor: AppTheme.inputFill,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Vazgeç', style: TextStyle(color: AppTheme.textSecondary))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen, foregroundColor: AppTheme.backgroundDark),
            onPressed: () {
              if (controller.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              _katilmaIstegiGonder(ilan.id, controller.text.trim());
            },
            child: const Text('İstek Gönder'),
          ),
        ],
      ),
    );
  }

  Future<void> _katilmaIstegiGonder(String ilanId, String mesaj) async {
    final res = await _takimIlaniService.katilmaIstegiGonder(ilanId, mesaj);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(res.mesaj),
        backgroundColor: res.basarili ? AppTheme.primaryGreen : AppTheme.errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // SAHALAR — 2'Lİ GRİD KART
  // ═══════════════════════════════════════════════════════════════

  Widget _buildSahalarGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          for (int i = 0; i < _populerSahalar.length; i += 2)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(child: _buildSahaKart(_populerSahalar[i])),
                  const SizedBox(width: 10),
                  if (i + 1 < _populerSahalar.length)
                    Expanded(child: _buildSahaKart(_populerSahalar[i + 1]))
                  else
                    const Expanded(child: SizedBox()),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSahaKart(Saha saha) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
        MaterialPageRoute(builder: (_) => SahaDetayScreen(sahaId: saha.id))),
      child: Container(
        height: 130,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.accentBlue.withOpacity(0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // İkon + isim
            Row(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    gradient: AppTheme.glassGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.stadium_rounded, color: AppTheme.primaryGreen, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(saha.sahaAdi, style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary,
                  ), maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Adres
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 12,
                  color: AppTheme.textSecondary.withOpacity(0.4)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(saha.adres, style: TextStyle(
                    fontSize: 10, color: AppTheme.textSecondary.withOpacity(0.5),
                  ), maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const Spacer(),
            // Puan + Fiyat
            Row(
              children: [
                const Icon(Icons.star_rounded, color: AppTheme.amber, size: 14),
                const SizedBox(width: 3),
                Text(saha.puanOrtalamasi.toStringAsFixed(1), style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textPrimary,
                )),
                const Spacer(),
                Text('₺${saha.saatlikUcret.toStringAsFixed(0)}/s', style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.primaryGreen,
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }


  // ═══════════════════════════════════════════════════════════════
  // BOŞ EKRAN
  // ═══════════════════════════════════════════════════════════════

  Widget _buildBosEkran() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.04)),
            ),
            child: Icon(Icons.explore_off_rounded, size: 36,
              color: AppTheme.textSecondary.withOpacity(0.2)),
          ),
          const SizedBox(height: 18),
          Text(
            context.read<KonumProvider>().konumSecildi
                ? 'Bu konumda sonuç bulunamadı'
                : 'Henüz içerik yok',
            style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.read<KonumProvider>().konumSecildi
                ? 'Farklı bir konum seçmeyi deneyin'
                : 'Maç oluşturarak başlayabilirsiniz',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // KONUM FİLTRELEME
  // ═══════════════════════════════════════════════════════════════

  Future<void> _konumSec() async {
    final konumProvider = context.read<KonumProvider>();
    final secim = await showKonumSecimSheet(
      context,
      initialUlke: konumProvider.seciliKonum?.ulke,
      initialIl: konumProvider.seciliKonum?.il,
      initialIlce: konumProvider.seciliKonum?.ilce,
      showCurrentLocationButton: true,
    );
    if (!mounted || secim == null) return;
    if (secim.mevcutKonumSecildi) {
      try {
        final basarili = await konumProvider.mevcutKonumdanSec();
        if (!mounted) return;
        if (basarili) {
          _yukle();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Konum alınamadı')),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
      return;
    }
    konumProvider.konumSec(secim);
    _yukle();
  }

  List<Saha> _konumaGoreSahaFiltrele(List<Saha> sahalar, String metin) {
    if (metin.isEmpty) return sahalar;
    return sahalar.where((s) => s.adres.toLowerCase().contains(metin)).toList();
  }

  List<Mac> _konumaGoreMacFiltrele(List<Mac> maclar, String metin) {
    if (metin.isEmpty) return maclar;
    return maclar.where((m) {
      final alanlar = [
        m.il ?? '', m.ilce ?? '', m.sahaAdi ?? '',
        m.macBasligi, m.aciklama ?? '', m.takimAdi ?? '',
      ].join(' ').toLowerCase();
      return alanlar.contains(metin);
    }).toList();
  }

  List<TakimIlani> _konumaGoreIlanFiltrele(List<TakimIlani> ilanlar, String metin) {
    if (metin.isEmpty) return ilanlar;
    return ilanlar.where((i) {
      final alanlar = [
        i.konum ?? '', i.ilanBasligi, i.aciklama ?? '', i.takimAdi,
      ].join(' ').toLowerCase();
      return alanlar.contains(metin);
    }).toList();
  }


}

class _QA {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  _QA(this.label, this.icon, this.color, this.onTap);
}
