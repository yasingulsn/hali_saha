import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:carousel_slider/carousel_slider.dart';

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
import '../saha_ekle_screen.dart';
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

  static const int _macSayfaBoyutu = 10;
  int _macSayfaNo = 0;
  bool _dahaFazlaMacVar = false;
  bool _maclarYukleniyor = false;

  bool _cevrimdisi = false;
  int _seciliFiltreIndex = 0;
  final _filtreler = ['Tümü', 'Sadece Açık', 'Eksik Arananlar', 'Rakip Arananlar', 'Sadece Sahalar'];

  List<Mac> get _filtrelenmisMaclar {
    if (_seciliFiltreIndex == 0) return _tumMaclar;
    if (_seciliFiltreIndex == 1) return _tumMaclar.where((m) => !m.doluMu).toList();
    if (_seciliFiltreIndex == 2) return _tumMaclar.where((m) => m.macTipi == 'EKSIK_OYUNCU').toList();
    if (_seciliFiltreIndex == 3) return _tumMaclar.where((m) => m.macTipi == 'RAKIP_ARANIYOR').toList();
    if (_seciliFiltreIndex == 4) return []; // Sadece sahalar
    return _tumMaclar;
  }

  List<TakimIlani> get _filtrelenmisIlanlar {
    if (_seciliFiltreIndex == 4) return []; // Sadece sahalar
    return _takimIlanlari;
  }

  List<Saha> get _filtrelenmisSahalar {
    if (_seciliFiltreIndex == 1 || _seciliFiltreIndex == 2 || _seciliFiltreIndex == 3) return []; 
    return _populerSahalar;
  }



  @override
  void initState() {
    super.initState();
    _yukle();
    Future.microtask(() => context.read<BildirimProvider>().sayiGuncelle());
  }

  Future<void> _yukle() async {
    setState(() {
      _yukleniyor = true;
      _macSayfaNo = 0;
      _dahaFazlaMacVar = false;
      _tumMaclar = [];
    });
    final macRes = await _macService.acikMaclar(page: 0, size: _macSayfaBoyutu);
    final sahaRes = await _sahaService.tumSahalar();
    final ilanRes = await _takimIlaniService.aktifIlanlar();

    if (mounted) {
      final konumProvider = context.read<KonumProvider>();
      final il = (konumProvider.seciliIl ?? '').toLowerCase();
      final ilce = (konumProvider.seciliIlce ?? '').toLowerCase();

      final herseyCevrimdisi = !macRes.basarili && !sahaRes.basarili && !ilanRes.basarili;

      if (herseyCevrimdisi) {
        await _cachedenYukle();
        return;
      }

      setState(() {
        _yukleniyor = false;
        _cevrimdisi = false;

        // MAÇLAR
        if (macRes.basarili && macRes.veri != null) {
          final hepsi = macRes.veri!;
          _dahaFazlaMacVar = hepsi.length >= _macSayfaBoyutu;
          _tumMaclar = hepsi.where((m) {
            final mIl = (m.il ?? '').toLowerCase();
            final mIlce = (m.ilce ?? '').toLowerCase();
            if (il.isEmpty) return true;
            if (ilce.isEmpty) return mIl.contains(il);
            return mIl.contains(il) && mIlce.contains(ilce);
          }).toList();

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

      _cacheyeKaydet(
        macRes.veri ?? [],
        sahaRes.veri ?? [],
        ilanRes.veri ?? [],
      );
    }
  }

  Future<void> _cacheyeKaydet(List<Mac> maclar, List<Saha> sahalar, List<TakimIlani> ilanlar) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cache_maclar', jsonEncode(maclar.map((m) => {
        'id': m.id, 'macBasligi': m.macBasligi, 'macTarihi': m.macTarihi,
        'baslangicSaati': m.baslangicSaati, 'bitisSaati': m.bitisSaati,
        'format': m.format, 'maxOyuncuSayisi': m.maxOyuncuSayisi,
        'mevcutOyuncuSayisi': m.mevcutOyuncuSayisi, 'macDurumu': m.macDurumu,
        'olusturanId': m.olusturanId, 'sahaAdi': m.sahaAdi, 'il': m.il, 'ilce': m.ilce,
        'macTipi': m.macTipi, 'seviye': m.seviye, 'ucretPerKisi': m.ucretPerKisi,
      }).toList()));
      await prefs.setString('cache_sahalar', jsonEncode(sahalar.map((s) => {
        'id': s.id, 'sahaAdi': s.sahaAdi, 'adres': s.adres,
        'sahaFormati': s.sahaFormati, 'saatlikUcret': s.saatlikUcret,
        'puanOrtalamasi': s.puanOrtalamasi, 'yorumSayisi': s.yorumSayisi,
        'fotografUrl': s.fotografUrl, 'kapaliMi': s.kapaliMi,
      }).toList()));
    } catch (_) {}
  }

  Future<void> _cachedenYukle() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final macJson = prefs.getString('cache_maclar');
      final sahaJson = prefs.getString('cache_sahalar');
      if (macJson != null && mounted) {
        final maclar = (jsonDecode(macJson) as List).map((e) => Mac.fromJson(e as Map<String, dynamic>)).toList();
        final sahalar = sahaJson != null
            ? (jsonDecode(sahaJson) as List).map((e) => Saha.fromJson(e as Map<String, dynamic>)).toList()
            : <Saha>[];
        setState(() {
          _yukleniyor = false;
          _cevrimdisi = true;
          _tumMaclar = maclar;
          _populerSahalar = sahalar.take(5).toList();
        });
      } else if (mounted) {
        setState(() => _yukleniyor = false);
      }
    } catch (_) {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  Future<void> _dahaFazlaYukle() async {
    if (_maclarYukleniyor || !_dahaFazlaMacVar) return;
    setState(() => _maclarYukleniyor = true);

    final sonrakiSayfa = _macSayfaNo + 1;
    final macRes = await _macService.acikMaclar(page: sonrakiSayfa, size: _macSayfaBoyutu);

    if (mounted) {
      final konumProvider = context.read<KonumProvider>();
      final il = (konumProvider.seciliIl ?? '').toLowerCase();
      final ilce = (konumProvider.seciliIlce ?? '').toLowerCase();

      setState(() {
        _maclarYukleniyor = false;
        if (macRes.basarili && macRes.veri != null) {
          final yeni = macRes.veri!;
          _dahaFazlaMacVar = yeni.length >= _macSayfaBoyutu;
          _macSayfaNo = sonrakiSayfa;
          final filtrelenmis = yeni.where((m) {
            final mIl = (m.il ?? '').toLowerCase();
            final mIlce = (m.ilce ?? '').toLowerCase();
            if (il.isEmpty) return true;
            if (ilce.isEmpty) return mIl.contains(il);
            return mIl.contains(il) && mIlce.contains(ilce);
          }).toList();
          _tumMaclar = [..._tumMaclar, ...filtrelenmis];
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

          // ── FİLTRELER ──────────────────────────────
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildFilterChips(),
          )),

          if (_cevrimdisi)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.lightOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.lightOrange.withOpacity(0.2)),
                ),
                child: const Row(children: [
                  Icon(Icons.wifi_off_rounded, color: AppTheme.lightOrange, size: 16),
                  SizedBox(width: 8),
                  Text('Çevrimdışı — önbellek gösteriliyor', style: TextStyle(fontSize: 12, color: AppTheme.lightOrange)),
                ]),
              ),
            ),

          if (_yukleniyor)
            _buildShimmerLoading()
          else ...[
            // ── SIRADAKİ MAÇIM ─────────────────────────
            SliverToBoxAdapter(child: _buildSiradakiMacim()),

            // ── YAKLAŞAN MAÇLAR ─────────────────────────
            if (_filtrelenmisMaclar.isNotEmpty) 
              _buildMaclarSliver(),

            // ── TAKIM İLANLARI ─────────────────────────
            if (_filtrelenmisIlanlar.isNotEmpty) ...[
              SliverToBoxAdapter(child: _buildSectionHeader(
                icon: Icons.groups_rounded,
                iconColor: AppTheme.accentPurple,
                title: 'Takım İlanları',
                badge: '${_filtrelenmisIlanlar.length}',
                onTumunuGor: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TakimIlanlariScreen())),
              )),
              SliverToBoxAdapter(child: _buildTakimIlanlariHorizontal()),
            ],

            // ── DİĞER YAKLAŞAN MAÇLAR ───────────────────
            if (_filtrelenmisMaclar.isEmpty && _digerMaclar.isNotEmpty) ...[
              SliverToBoxAdapter(child: _buildSectionHeader(
                icon: Icons.explore_rounded,
                iconColor: AppTheme.accentCoral,
                title: 'Diğer Yaklaşan Maçlar',
              )),
              SliverToBoxAdapter(child: _buildDigerMaclarHorizontal()),
            ],

            // ── SAHALAR ─────────────────────────────────
            if (_filtrelenmisSahalar.isNotEmpty) ...[
              SliverToBoxAdapter(child: _buildSectionHeader(
                icon: Icons.stadium_rounded,
                iconColor: AppTheme.accentBlue,
                title: 'Yakındaki Sahalar',
              )),
              SliverToBoxAdapter(child: _buildSahalarGrid()),
            ],

            // ── BOŞ DURUM ───────────────────────────────
            if (_filtrelenmisMaclar.isEmpty && _filtrelenmisSahalar.isEmpty && _filtrelenmisIlanlar.isEmpty)
              SliverToBoxAdapter(child: _buildBosEkran()),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }


  Widget _buildFilterChips() {
    final filtrelerWithIcons = [
      ('Tümü', Icons.apps_rounded),
      ('Sadece Açık', Icons.check_circle_outline_rounded),
      ('Eksik Arananlar', Icons.person_add_outlined),
      ('Rakip Arananlar', Icons.groups_outlined),
      ('Sadece Sahalar', Icons.stadium_outlined),
    ];
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filtrelerWithIcons.length,
        itemBuilder: (context, index) {
          final isSelected = _seciliFiltreIndex == index;
          final item = filtrelerWithIcons[index];
          return GestureDetector(
            onTap: () => setState(() => _seciliFiltreIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryGreen : AppTheme.cardDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppTheme.primaryGreen : Colors.white.withValues(alpha: 0.08),
                ),
                boxShadow: isSelected ? [BoxShadow(color: AppTheme.primaryGreen.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 2))] : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(item.$2, size: 13,
                    color: isSelected ? AppTheme.backgroundDark : AppTheme.textSecondary.withValues(alpha: 0.6)),
                  const SizedBox(width: 5),
                  Text(item.$1, style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppTheme.backgroundDark : AppTheme.textSecondary,
                  )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == 0) {
             return Padding(
               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
               child: Shimmer.fromColors(
                 baseColor: AppTheme.cardDark,
                 highlightColor: Colors.white.withValues(alpha: 0.05),
                 child: Row(
                   children: [
                     Container(width: 80, height: 36, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18))),
                     const SizedBox(width: 8),
                     Container(width: 80, height: 36, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18))),
                     const SizedBox(width: 8),
                     Container(width: 80, height: 36, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18))),
                   ],
                 ),
               ),
             );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Shimmer.fromColors(
              baseColor: AppTheme.cardDark,
              highlightColor: Colors.white.withValues(alpha: 0.05),
              child: Container(
                height: 180,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
              ),
            ),
          );
        },
        childCount: 3,
      ),
    );
  }

  Widget _buildSiradakiMacim() {
    final auth = context.watch<AuthProvider>();
    final userId = auth.currentUserId;
    if (userId == null || _tumMaclar.isEmpty) return const SizedBox.shrink();

    final katildigimMaclar = _tumMaclar.where((m) {
      if (m.olusturanId == userId) return true;
      if (m.katilimcilar != null) return m.katilimcilar!.any((k) => k.id == userId);
      return false;
    }).toList();
    if (katildigimMaclar.isEmpty) return const SizedBox.shrink();

    final siradaki = katildigimMaclar.first;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MacDetayScreen(macId: siradaki.id))),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFF3D1A0A), AppTheme.accentCoral.withValues(alpha: 0.08)],
              begin: Alignment.centerLeft, end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.accentCoral.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFF8A80), AppTheme.accentCoral]),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppTheme.accentCoral.withValues(alpha: 0.35), blurRadius: 10)],
                ),
                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppTheme.accentCoral.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                        child: const Text('BUGÜN', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppTheme.accentCoral, letterSpacing: 0.5)),
                      ),
                      const SizedBox(width: 6),
                      Text(siradaki.baslangicSaati,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textSecondary.withValues(alpha: 0.7))),
                    ]),
                    const SizedBox(height: 3),
                    Text(siradaki.macBasligi,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.accentCoral.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.chevron_right_rounded, color: AppTheme.accentCoral, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HEADER
  // ═══════════════════════════════════════════════════════════════

  Widget _buildHeader(dynamic user) {
    final hour = DateTime.now().hour;
    String greeting;
    String greetEmoji;
    if (hour < 6) {
      greeting = 'Gece geç';
      greetEmoji = '🌙';
    } else if (hour < 12) {
      greeting = 'Günaydın';
      greetEmoji = '☀️';
    } else if (hour < 18) {
      greeting = 'İyi günler';
      greetEmoji = '⛅';
    } else {
      greeting = 'İyi akşamlar';
      greetEmoji = '🌙';
    }

    return Stack(
      children: [
        // Arka plan dekorasyon
        Positioned.fill(
          child: ClipRect(
            child: CustomPaint(painter: _HeaderFieldPainter()),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text(greetEmoji, style: const TextStyle(fontSize: 15)),
                          const SizedBox(width: 6),
                          Text(greeting,
                            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary.withValues(alpha: 0.65), fontWeight: FontWeight.w500)),
                        ]),
                        const SizedBox(height: 3),
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [AppTheme.textPrimary, Color(0xFFB0BEC5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: Text(
                            user?.adSoyad ?? 'Kullanıcı',
                            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Bildirim butonu
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BildirimlerScreen())),
                    child: Consumer<BildirimProvider>(
                      builder: (context, bp, _) {
                        final hasBadge = bp.okunmamisSayisi > 0;
                        return Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: hasBadge ? AppTheme.accentCoral.withValues(alpha: 0.12) : AppTheme.cardDark,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: hasBadge ? AppTheme.accentCoral.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.06)),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                hasBadge ? Icons.notifications_rounded : Icons.notifications_none_rounded,
                                color: hasBadge ? AppTheme.accentCoral : AppTheme.textSecondary,
                                size: 22,
                              ),
                              if (hasBadge)
                                Positioned(
                                  top: 8, right: 8,
                                  child: Container(
                                    width: 8, height: 8,
                                    decoration: const BoxDecoration(color: AppTheme.accentCoral, shape: BoxShape.circle),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // İstatistik satırı
              Builder(builder: (context) {
                final kp = context.watch<KonumProvider>();
                final konum = kp.konumSecildi ? (kp.seciliIlce ?? kp.seciliIl ?? '') : '';
                return Row(
                  children: [
                    _statChip(
                      value: '${_tumMaclar.length}',
                      label: 'Maç',
                      icon: Icons.sports_soccer_rounded,
                      color: AppTheme.primaryGreen,
                    ),
                    const SizedBox(width: 10),
                    _statChip(
                      value: '${_takimIlanlari.length}',
                      label: 'İlan',
                      icon: Icons.groups_rounded,
                      color: AppTheme.accentPurple,
                    ),
                    const SizedBox(width: 10),
                    _statChip(
                      value: '${_populerSahalar.length}',
                      label: 'Saha',
                      icon: Icons.stadium_rounded,
                      color: AppTheme.accentBlue,
                    ),
                    if (konum.isNotEmpty) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.cardDark,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.location_on_rounded, size: 12, color: AppTheme.primaryGreen),
                              const SizedBox(width: 4),
                              Flexible(child: Text(konum,
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary.withValues(alpha: 0.8)),
                                maxLines: 1, overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statChip({required String value, required String label, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: color.withValues(alpha: 0.6))),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // KONUM + ARAMA BİRLEŞİK KART
  // ═══════════════════════════════════════════════════════════════

  Widget _buildKonumVeArama() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Konum + Temizle satırı
          Builder(builder: (context) {
            final kp = context.watch<KonumProvider>();
            return GestureDetector(
              onTap: _konumSec,
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.location_on_rounded, size: 12, color: AppTheme.primaryGreen),
                ),
                const SizedBox(width: 7),
                Text(
                  kp.konumEtiketi ?? 'Konum seç',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                    color: kp.konumSecildi ? AppTheme.textPrimary : AppTheme.primaryGreen),
                ),
                const SizedBox(width: 3),
                Icon(Icons.keyboard_arrow_down_rounded, size: 15, color: AppTheme.textSecondary.withValues(alpha: 0.6)),
                const Spacer(),
                if (kp.konumSecildi)
                  GestureDetector(
                    onTap: () { context.read<KonumProvider>().konumTemizle(); _yukle(); },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.errorRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Temizle', style: TextStyle(fontSize: 11, color: AppTheme.errorRed, fontWeight: FontWeight.w600)),
                    ),
                  ),
              ]),
            );
          }),
          const SizedBox(height: 10),
          // Arama kutusu
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AramaScreen())),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: AppTheme.cardDark,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(color: AppTheme.cardDarkElevated, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.search_rounded, size: 18, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Saha veya maç ara...', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textHint)),
                        Text('Takım, oyuncu, saha', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary.withValues(alpha: 0.45))),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(gradient: AppTheme.buttonGradient, borderRadius: BorderRadius.circular(10)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Ara', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.backgroundDark)),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, size: 13, color: AppTheme.backgroundDark),
                      ],
                    ),
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
  // HIZLI ERİŞİM BUTONLARI
  // ═══════════════════════════════════════════════════════════════

  Widget _buildQuickActions(bool isIsletme) {
    if (isIsletme) {
      final actions = [
        _QA('Saha Ekle', Icons.add_business_rounded, AppTheme.primaryGreen,
            () async {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const SahaEkleScreen()));
          if (result == true) _yukle();
        }),
        _QA('Rezervasyonlar', Icons.calendar_month_rounded, AppTheme.accentPurple,
            () => _isletmeRezervasyonlarDialog()),
        _QA('İstatistik', Icons.bar_chart_rounded, AppTheme.accentBlue,
            () => _isletmeIstatistikDialog()),
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
                        color: a.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: a.color.withValues(alpha: 0.12)),
                      ),
                      child: Icon(a.icon, color: a.color, size: 24),
                    ),
                    const SizedBox(height: 8),
                    Text(a.label, textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary.withValues(alpha: 0.7),
                      ),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ),
          )).toList(),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Row(
          children: [
            Expanded(child: _buildActionCard(
              title: 'Maç Bul',
              subtitle: 'Takım veya Oyuncu',
              icon: Icons.person_search_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFF1A1040), Color(0xFF2D1B69)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              accentColor: AppTheme.accentPurple,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AramaScreen())),
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildActionCard(
              title: 'Maç Oluştur',
              subtitle: 'Saha ve kadro',
              icon: Icons.add_circle_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFF0A2016), Color(0xFF0D2E1C)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              accentColor: AppTheme.primaryGreen,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MacOlusturScreen())),
            )),
          ],
        ),
      );
    }
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required LinearGradient gradient,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: accentColor.withValues(alpha: 0.2)),
          boxShadow: [BoxShadow(color: accentColor.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 6))],
        ),
        child: Stack(
          children: [
            // Arka plan daire dekorasyon
            Positioned(
              right: -20, top: -20,
              child: Container(
                width: 90, height: 90,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.07),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(icon, color: accentColor, size: 22),
                ),
                const Spacer(),
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Expanded(child: Text(subtitle, style: TextStyle(fontSize: 11, color: AppTheme.textSecondary.withValues(alpha: 0.6)))),
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_forward_rounded, size: 12, color: accentColor),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
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
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
          if (badge != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(badge, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: iconColor)),
            ),
          ],
          const Spacer(),
          if (onTumunuGor != null)
            GestureDetector(
              onTap: onTumunuGor,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(children: [
                  Text('Tümü', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: iconColor)),
                  const SizedBox(width: 3),
                  Icon(Icons.arrow_forward_ios_rounded, size: 10, color: iconColor),
                ]),
              ),
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // MAÇLAR — YATAY KART LİSTESİ
  // ═══════════════════════════════════════════════════════════════

  Widget _buildMaclarSliver() {
    if (_filtrelenmisMaclar.isEmpty) return const SliverToBoxAdapter(child: SizedBox());
    
    final heroMac = _filtrelenmisMaclar.first;
    final digerleri = _filtrelenmisMaclar.skip(1).toList();

    return SliverList(
      delegate: SliverChildListDelegate([
        _buildSectionHeader(
          icon: Icons.sports_soccer_rounded,
          iconColor: AppTheme.primaryGreen,
          title: 'Öne Çıkan Maç',
          badge: 'Yakınında',
        ),
        _buildHeroMacKart(heroMac),
        if (digerleri.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 12, left: 20),
            child: Text('Diğer Yaklaşan Maçlar (${digerleri.length})',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          ),
          _buildMaclarHorizontalList(digerleri),
        ],
        if (_dahaFazlaMacVar || _maclarYukleniyor)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: _maclarYukleniyor
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen, strokeWidth: 2))
                : OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryGreen,
                      side: BorderSide(color: AppTheme.primaryGreen.withValues(alpha: 0.4)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      minimumSize: const Size(double.infinity, 0),
                    ),
                    onPressed: _dahaFazlaYukle,
                    icon: const Icon(Icons.expand_more_rounded, size: 20),
                    label: const Text('Daha Fazla Maç Yükle', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  ),
          ),
      ]),
    );
  }

  Widget _buildHeroMacKart(Mac mac) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (_) => MacDetayScreen(macId: mac.id)));
        _yukle();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.cardDark, AppTheme.surfaceDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(color: AppTheme.primaryGreen.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Hero(
                  tag: 'mac_format_hero_${mac.id}',
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: AppTheme.primaryGreen, borderRadius: BorderRadius.circular(8)),
                      child: Text(mac.format, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.backgroundDark)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (mac.macTipi != 'NORMAL')
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                     decoration: BoxDecoration(color: AppTheme.accentPurple.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                     child: Text(mac.macTipiText, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.accentPurple)),
                   ),
                const Spacer(),
                const Icon(Icons.local_fire_department_rounded, color: AppTheme.accentCoral, size: 20),
              ],
            ),
            const SizedBox(height: 16),
            Text(mac.macBasligi, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_rounded, size: 14, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Expanded(child: Text(mac.sahaAdi ?? mac.ilce ?? 'Konum Belirtilmemiş', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary))),
              ],
            ),
            const SizedBox(height: 16),
            // Doluluk Barı
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: mac.mevcutOyuncuSayisi,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.buttonGradient,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: (mac.maxOyuncuSayisi - mac.mevcutOyuncuSayisi) > 0 ? (mac.maxOyuncuSayisi - mac.mevcutOyuncuSayisi) : 0,
                    child: const SizedBox(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${mac.mevcutOyuncuSayisi}/${mac.maxOyuncuSayisi} Oyuncu', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                Row(
                  children: [
                    Text(mac.baslangicSaati, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('Detay', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primaryGreen)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaclarHorizontalList(List<Mac> maclar) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: CarouselSlider.builder(
        key: ValueKey('${maclar.length}_${_seciliFiltreIndex}'),
        itemCount: maclar.length,
        options: CarouselOptions(
          height: 180,
          viewportFraction: 0.7,
          enableInfiniteScroll: false,
          padEnds: false,
        ),
        itemBuilder: (context, index, realIndex) {
          return Padding(
            padding: EdgeInsets.only(left: index == 0 ? 20 : 6, right: 6),
            child: _buildMacKart(maclar[index]),
          );
        },
      ),
    );
  }

  Widget _buildDigerMaclarHorizontal() {
    return _buildMaclarHorizontalList(_digerMaclar);
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
          border: Border.all(color: renk.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(color: renk.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst: Tarih + Badge'ler
            Row(
              children: [
                Hero(
                  tag: 'mac_format_${mac.id}',
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: renk.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(mac.format, style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700, color: renk,
                      )),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                if (mac.macTipi != 'NORMAL')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accentPurple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(mac.macTipiText, style: const TextStyle(
                      fontSize: 9, fontWeight: FontWeight.w600, color: AppTheme.accentPurple,
                    )),
                  ),
                const Spacer(),
                Text(mac.baslangicSaati, style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary.withValues(alpha: 0.6),
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
                  color: AppTheme.textSecondary.withValues(alpha: 0.4)),
                const SizedBox(width: 4),
                Text(mac.macTarihi, style: TextStyle(
                  fontSize: 11, color: AppTheme.textSecondary.withValues(alpha: 0.5),
                )),
                const Spacer(),
                // Doluluk göstergesi
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: mac.doluMu
                        ? AppTheme.errorRed.withValues(alpha: 0.1)
                        : AppTheme.primaryGreen.withValues(alpha: 0.1),
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
    final goster = _filtrelenmisIlanlar.take(8).toList();
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
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TakimIlanlariScreen())),
      child: Stack(
        children: [
          Container(
            width: 220,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.accentPurple.withValues(alpha: 0.1)),
              boxShadow: [
                BoxShadow(color: AppTheme.accentPurple.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4)),
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
                        color: AppTheme.accentPurple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(ilan.pozisyonText, style: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.accentPurple,
                      )),
                    ),
                    const Spacer(),
                    Text(ilan.seviyeText, style: TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary.withValues(alpha: 0.5),
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
                        fontSize: 11, color: AppTheme.textSecondary.withValues(alpha: 0.6),
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
                        color: AppTheme.primaryGreen.withValues(alpha: 0.1),
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
                hintStyle: TextStyle(color: AppTheme.textHint.withValues(alpha: 0.5)),
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
              final mesaj = controller.text.trim();
              Navigator.pop(ctx);
              _katilmaIstegiGonder(ilan.id, mesaj);
            },
            child: const Text('İstek Gönder'),
          ),
        ],
      ),
    ).then((_) => controller.dispose());
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
    return SizedBox(
      height: 148,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filtrelenmisSahalar.length,
        itemBuilder: (_, i) => _buildSahaKart(_filtrelenmisSahalar[i]),
      ),
    );
  }

  Widget _buildSahaKart(Saha saha) {
    final rating = saha.puanOrtalamasi;
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SahaDetayScreen(sahaId: saha.id))),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.accentBlue.withValues(alpha: 0.1)),
          boxShadow: [BoxShadow(color: AppTheme.accentBlue.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.accentBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(Icons.stadium_rounded, color: AppTheme.accentBlue, size: 18),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.amber.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, size: 11, color: AppTheme.amber),
                      const SizedBox(width: 3),
                      Text(rating.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.amber)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(saha.sahaAdi,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
              maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 3),
            Row(children: [
              Icon(Icons.location_on_outlined, size: 11, color: AppTheme.textSecondary.withValues(alpha: 0.4)),
              const SizedBox(width: 3),
              Expanded(child: Text(saha.adres,
                style: TextStyle(fontSize: 10, color: AppTheme.textSecondary.withValues(alpha: 0.5)),
                maxLines: 1, overflow: TextOverflow.ellipsis)),
            ]),
            const Spacer(),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(saha.sahaFormati, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.accentBlue)),
              ),
              const Spacer(),
              Text('₺${saha.saatlikUcret.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.primaryGreen)),
              Text('/s', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary.withValues(alpha: 0.5))),
            ]),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.explore_off_rounded, size: 40, color: AppTheme.primaryGreen),
            ),
            const SizedBox(height: 20),
            const Text(
              'Buralar Henüz Çok Sessiz',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              context.read<KonumProvider>().konumSecildi
                  ? 'Seçtiğiniz konumda şu an aktif bir içerik bulunmuyor. İlk adımı siz atın!'
                  : 'Çevrenizde aktif bir maç veya ilan bulunamadı. Hemen yeni bir tane oluşturun.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary.withValues(alpha: 0.8), height: 1.4),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: AppTheme.backgroundDark,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MacOlusturScreen())),
                icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                label: const Text('Yeni Maç Oluştur', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textPrimary,
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _konumSec,
                    icon: const Icon(Icons.location_on_rounded, size: 16),
                    label: const Text('Konum Değiştir', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.accentPurple,
                      side: BorderSide(color: AppTheme.accentPurple.withValues(alpha: 0.2)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TakimIlanlariScreen())),
                    icon: const Icon(Icons.groups_rounded, size: 16),
                    label: const Text('İlanlara Bak', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
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
  // İŞLETME DİYALOGLARI
  // ═══════════════════════════════════════════════════════════════

  void _isletmeRezervasyonlarDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Icon(Icons.calendar_month_rounded, color: AppTheme.accentPurple, size: 22),
          SizedBox(width: 10),
          Text('Rezervasyonlar', style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.accentPurple.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(children: [
                Icon(Icons.event_available_rounded, size: 48, color: AppTheme.accentPurple.withValues(alpha: 0.4)),
                const SizedBox(height: 12),
                const Text('Rezervasyon sistemi yakında!', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                const SizedBox(height: 6),
                Text('Sahanızı kullanıcılar şu an maç oluşturarak rezerve edebilir.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary.withValues(alpha: 0.8))),
              ]),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentPurple, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _isletmeIstatistikDialog() {
    final toplamMac = _tumMaclar.length;
    final toplamSaha = _populerSahalar.length;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Icon(Icons.bar_chart_rounded, color: AppTheme.accentBlue, size: 22),
          SizedBox(width: 10),
          Text('İstatistik', style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _istatistikSatir('Bölgedeki Aktif Maç', '$toplamMac', Icons.sports_soccer_rounded, AppTheme.primaryGreen),
            const SizedBox(height: 12),
            _istatistikSatir('Bölgedeki Saha', '$toplamSaha', Icons.stadium_rounded, AppTheme.accentBlue),
            const SizedBox(height: 12),
            _istatistikSatir('Aktif Takım İlanı', '${_takimIlanlari.length}', Icons.groups_rounded, AppTheme.accentPurple),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Kapat', style: TextStyle(color: AppTheme.textSecondary)),
          ),
        ],
      ),
    );
  }

  Widget _istatistikSatir(String label, String deger, IconData icon, Color renk) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: renk.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: renk.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: renk.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: renk, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: TextStyle(fontSize: 13, color: AppTheme.textSecondary.withValues(alpha: 0.8)))),
          Text(deger, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: renk)),
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

class _HeaderFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00BFA5).withOpacity(0.04)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // büyük daire
    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.width * 1.1, size.height * 0.5), radius: size.height * 1.1),
      math.pi * 0.55, math.pi * 0.9, false, paint,
    );
    // küçük daire
    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.width * 1.1, size.height * 0.5), radius: size.height * 0.55),
      math.pi * 0.45, math.pi, false, paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
