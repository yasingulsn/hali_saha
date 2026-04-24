import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/mac.dart';
import '../../models/saha.dart';
import '../../models/takim_ilani.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_client.dart';
import '../../services/konum_service.dart';
import '../../services/mac_service.dart';
import '../../services/saha_service.dart';
import '../../services/takim_ilani_service.dart';
import '../../utils/theme.dart';
import '../arama_screen.dart';
import '../mac_detay_screen.dart';
import '../mac_olustur_screen.dart';
import '../saha_detay_screen.dart';
import '../takim_ilanlari_screen.dart';
import '../takim_ilani_olustur_screen.dart';
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
  List<Saha> _populerSahalar = [];
  List<TakimIlani> _takimIlanlari = [];
  bool _yukleniyor = true;
  KonumSecim? _konumSecim;
  String? _konumAramaMetni;

  String? _macFormatFiltre;
  String? _macTipiFiltre;

  final _formatFiltreler = [null, '5v5', '6v6', '7v7', '8v8', '11v11'];

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<void> _yukle() async {
    setState(() => _yukleniyor = true);
    final macRes = await _macService.acikMaclar();
    final sahaRes = await _sahaService.tumSahalar();
    List<TakimIlani> ilanlar = [];
    try {
      final ilanRes = await _takimIlaniService.aktifIlanlar();
      if (ilanRes.basarili && ilanRes.veri != null) ilanlar = ilanRes.veri!;
    } catch (_) {}
    if (mounted) {
      setState(() {
        _yukleniyor = false;
        if (macRes.basarili && macRes.veri != null) _tumMaclar = _konumaGoreMacFiltrele(macRes.veri!);
        if (sahaRes.basarili && sahaRes.veri != null) {
          _populerSahalar = _konumaGoreSahaFiltrele(sahaRes.veri!).take(5).toList();
        }
        _takimIlanlari = _konumaGoreIlanFiltrele(ilanlar);
      });
    }
  }

  List<Mac> get _filtrelenmislMaclar {
    return _tumMaclar.where((m) {
      if (_macFormatFiltre != null && m.format != _macFormatFiltre) return false;
      if (_macTipiFiltre != null && m.macTipi != _macTipiFiltre) return false;
      return true;
    }).toList();
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
          SliverToBoxAdapter(child: _buildHeader(context, user, isIsletme)),
          SliverToBoxAdapter(child: _buildKonumBar()),
          SliverToBoxAdapter(child: _buildSearchBar()),
          SliverToBoxAdapter(child: _buildQuickActions(isIsletme)),
          if (_yukleniyor)
            const SliverToBoxAdapter(
              child: Padding(padding: EdgeInsets.only(top: 60),
                child: Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))),
            )
          else ...[
            if (_populerSahalar.isNotEmpty) ...[
              SliverToBoxAdapter(child: _buildSectionTitle('Sahalar', null)),
              SliverToBoxAdapter(child: _buildSahalarList()),
            ],
            if (_takimIlanlari.isNotEmpty) ...[
              SliverToBoxAdapter(child: _buildSectionTitle('Takıma Kalıcı Oyuncu İlanları', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const TakimIlanlariScreen()));
              })),
              SliverToBoxAdapter(child: _buildTakimIlanlariList()),
            ],
            SliverToBoxAdapter(child: _buildMaclarBaslik()),
            SliverToBoxAdapter(child: _buildMacFiltreler()),
            if (_filtrelenmislMaclar.isEmpty)
              SliverToBoxAdapter(
                child: Padding(padding: const EdgeInsets.all(40),
                  child: Center(child: Column(children: [
                    Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(color: AppTheme.cardDark, shape: BoxShape.circle),
                      child: Icon(Icons.sports_soccer_outlined, size: 32, color: AppTheme.textSecondary.withOpacity(0.2)),
                    ),
                    const SizedBox(height: 14),
                    Text(_tumMaclar.isEmpty ? 'Henüz maç yok' : 'Filtreyle eşleşen maç yok',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textSecondary.withOpacity(0.5))),
                  ]))),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildMacItem(_filtrelenmislMaclar[index]),
                  childCount: _filtrelenmislMaclar.length,
                )),
              ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic user, bool isIsletme) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) { greeting = 'Günaydın'; }
    else if (hour < 18) { greeting = 'İyi günler'; }
    else { greeting = 'İyi akşamlar'; }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('$greeting,', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary.withOpacity(0.7), fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(user?.adSoyad ?? 'Kullanıcı',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary, letterSpacing: -0.3)),
        ])),
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: AppTheme.cardDark, borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.04))),
          child: Stack(alignment: Alignment.center, children: [
            const Icon(Icons.notifications_none_rounded, color: AppTheme.textSecondary, size: 22),
            Positioned(top: 10, right: 10,
              child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.accentCoral, shape: BoxShape.circle))),
          ]),
        ),
      ]),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AramaScreen())),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: AppTheme.cardDark, borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.04)),
          ),
          child: Row(children: [
            const SizedBox(width: 16),
            Icon(Icons.search_rounded, color: AppTheme.textSecondary.withOpacity(0.4), size: 22),
            const SizedBox(width: 12),
            Text('Saha, maç, oyuncu veya takım ara...', style: TextStyle(fontSize: 14, color: AppTheme.textHint, fontWeight: FontWeight.w500)),
          ]),
        ),
      ),
    );
  }

  Widget _buildKonumBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 2),
      child: GestureDetector(
        onTap: _konumSec,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.14),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.25)),
          ),
          child: Row(
            children: [
              const Icon(Icons.location_on_rounded, size: 18, color: AppTheme.primaryGreen),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _konumSecim?.etiket ?? 'Ulke / Sehir / Ilce sec',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                ),
              ),
              Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppTheme.textSecondary.withOpacity(0.8)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _konumSec() async {
    final secim = await showKonumSecimSheet(
      context,
      initialUlke: _konumSecim?.ulke,
      initialIl: _konumSecim?.il,
      initialIlce: _konumSecim?.ilce,
      showCurrentLocationButton: true,
    );
    if (!mounted || secim == null) return;
    if (secim.mevcutKonumSecildi) {
      try {
        final k = await _konumService.mevcutKonumuAl();
        if (!mounted) return;
        final yeni = KonumSecim(ulke: 'Turkiye', il: k.il ?? '', ilce: k.ilce ?? '');
        setState(() {
          _konumSecim = yeni;
          _konumAramaMetni = yeni.aramaMetni.trim();
        });
        _yukle();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
      return;
    }
    setState(() {
      _konumSecim = secim;
      _konumAramaMetni = secim.aramaMetni;
    });
    _yukle();
  }

  List<Saha> _konumaGoreSahaFiltrele(List<Saha> sahalar) {
    final metin = (_konumAramaMetni ?? '').toLowerCase();
    if (metin.isEmpty) return sahalar;
    return sahalar.where((s) {
      final adres = s.adres.toLowerCase();
      return metin.isNotEmpty && adres.contains(metin);
    }).toList();
  }

  List<Mac> _konumaGoreMacFiltrele(List<Mac> maclar) {
    final metin = (_konumAramaMetni ?? '').toLowerCase();
    if (metin.isEmpty) return maclar;
    return maclar.where((m) {
      final alanlar = [
        m.sahaAdi ?? '',
        m.macBasligi,
        m.aciklama ?? '',
        m.takimAdi ?? '',
        m.rakipNotu ?? '',
      ].join(' ').toLowerCase();
      return alanlar.contains(metin);
    }).toList();
  }

  List<TakimIlani> _konumaGoreIlanFiltrele(List<TakimIlani> ilanlar) {
    final metin = (_konumAramaMetni ?? '').toLowerCase();
    if (metin.isEmpty) return ilanlar;
    return ilanlar.where((i) {
      final alanlar = [
        i.konum ?? '',
        i.ilanBasligi,
        i.aciklama ?? '',
        i.takimAdi,
      ].join(' ').toLowerCase();
      return alanlar.contains(metin);
    }).toList();
  }

  Widget _buildQuickActions(bool isIsletme) {
    final actions = isIsletme
        ? [
            _QuickAction('Saha Ekle', Icons.add_business_rounded, AppTheme.primaryGreen),
            _QuickAction('Rezervasyonlar', Icons.calendar_month_rounded, AppTheme.accentPurple),
            _QuickAction('İstatistik', Icons.bar_chart_rounded, AppTheme.accentBlue),
            _QuickAction('Arama', Icons.search_rounded, AppTheme.accentCoral),
          ]
        : [
            _QuickAction('Maç Oluştur', Icons.add_circle_outline_rounded, AppTheme.accentCoral),
            _QuickAction('Takıma Oyuncu İlanı', Icons.person_add_rounded, AppTheme.accentPurple),
          ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
      child: Row(children: actions.asMap().entries.map((entry) {
        final i = entry.key;
        final a = entry.value;
        return Expanded(child: _buildQuickActionItem(a, i, isIsletme));
      }).toList()),
    );
  }

  Widget _buildQuickActionItem(_QuickAction action, int index, bool isIsletme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: () {
          if (!isIsletme && index == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const MacOlusturScreen()));
          } else if (!isIsletme && index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const TakimIlaniOlusturScreen()));
          } else if (isIsletme && index == 3) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AramaScreen()));
          }
        },
        child: Column(children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: action.color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: action.color.withOpacity(0.08)),
            ),
            child: Icon(action.icon, color: action.color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(action.label, textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary.withOpacity(0.7)),
            maxLines: 1, overflow: TextOverflow.ellipsis),
        ]),
      ),
    );
  }

  Widget _buildSectionTitle(String title, VoidCallback? onTumunuGor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 14),
      child: Row(children: [
        Container(width: 3, height: 18,
          decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        const Spacer(),
        if (onTumunuGor != null)
          GestureDetector(
            onTap: onTumunuGor,
            child: Row(children: [
              Text('Tümünü Gör', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primaryGreen.withOpacity(0.7))),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppTheme.primaryGreen.withOpacity(0.5)),
            ]),
          ),
      ]),
    );
  }

  Widget _buildMaclarBaslik() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Row(children: [
        Container(width: 3, height: 18,
          decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 10),
        const Text('Açık Maçlar', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: AppTheme.primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Text('${_filtrelenmislMaclar.length}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primaryGreen)),
        ),
      ]),
    );
  }

  Widget _buildMacFiltreler() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
      child: Column(children: [
        SizedBox(
          height: 34,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              ..._formatFiltreler.map((f) {
                final sel = _macFormatFiltre == f;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => setState(() => _macFormatFiltre = f),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        gradient: sel ? AppTheme.buttonGradient : null,
                        color: sel ? null : AppTheme.cardDark,
                        borderRadius: BorderRadius.circular(10),
                        border: sel ? null : Border.all(color: Colors.white.withOpacity(0.03)),
                      ),
                      child: Text(f ?? 'Tüm Format', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                        color: sel ? AppTheme.backgroundDark : AppTheme.textSecondary)),
                    ),
                  ),
                );
              }),
              const SizedBox(width: 8),
              ...['NORMAL', 'RAKIP_ARANIYOR', 'EKSIK_OYUNCU'].map((t) {
                final sel = _macTipiFiltre == t;
                final label = t == 'NORMAL' ? 'Normal' : t == 'RAKIP_ARANIYOR' ? 'Rakip Aranıyor' : 'Eksik Oyuncu';
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => setState(() => _macTipiFiltre = sel ? null : t),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        gradient: sel ? LinearGradient(colors: [AppTheme.accentBlue, AppTheme.accentBlue.withOpacity(0.8)]) : null,
                        color: sel ? null : AppTheme.cardDark,
                        borderRadius: BorderRadius.circular(10),
                        border: sel ? null : Border.all(color: AppTheme.accentBlue.withOpacity(0.08)),
                      ),
                      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                        color: sel ? Colors.white : AppTheme.accentBlue.withOpacity(0.6))),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildTakimIlanlariList() {
    final gosterilecek = _takimIlanlari.take(5).toList();
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: gosterilecek.length,
        itemBuilder: (context, index) => _buildTakimIlaniCard(gosterilecek[index]),
      ),
    );
  }

  Widget _buildTakimIlaniCard(TakimIlani ilan) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TakimIlanlariScreen())),
      child: Container(
        width: 220,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.accentPurple.withOpacity(0.08)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppTheme.accentBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
              child: Text(ilan.takimAdi, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.accentBlue),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: AppTheme.accentPurple.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
              child: Text(ilan.pozisyonText, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppTheme.accentPurple)),
            ),
          ]),
          const SizedBox(height: 10),
          Text(ilan.ilanBasligi, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
            maxLines: 2, overflow: TextOverflow.ellipsis),
          const Spacer(),
          Row(children: [
            Icon(Icons.person_rounded, size: 14, color: AppTheme.textSecondary.withOpacity(0.5)),
            const SizedBox(width: 4),
            Text('${ilan.arananOyuncuSayisi} oyuncu', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary.withOpacity(0.6))),
            const Spacer(),
            Text(ilan.seviyeText, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary.withOpacity(0.5))),
          ]),
        ]),
      ),
    );
  }

  Widget _buildMacItem(Mac mac) {
    final renk = mac.doluMu ? AppTheme.accentCoral : AppTheme.primaryGreen;

    return GestureDetector(
      onTap: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (_) => MacDetayScreen(macId: mac.id)));
        _yukle();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardDark, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.03)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            _buildBadge(mac.format, renk),
            const SizedBox(width: 6),
            _buildBadge(mac.seviyeText, AppTheme.accentPurple),
            if (mac.macTipi != 'NORMAL') ...[
              const SizedBox(width: 6),
              _buildBadge(mac.macTipiText, AppTheme.accentBlue),
            ],
            const Spacer(),
            Text(mac.baslangicSaati, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary.withOpacity(0.5))),
          ]),
          const SizedBox(height: 10),
          Text(mac.macBasligi, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 6),
          Row(children: [
            if (mac.sahaAdi != null) ...[
              Icon(Icons.location_on_outlined, size: 13, color: AppTheme.textSecondary.withOpacity(0.4)),
              const SizedBox(width: 3),
              Expanded(child: Text(mac.sahaAdi!, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary.withOpacity(0.6)),
                maxLines: 1, overflow: TextOverflow.ellipsis)),
            ] else
              Expanded(child: Text(mac.macTarihi, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary.withOpacity(0.6)))),
            if (mac.eksikOyuncuMu && mac.eksikOyuncuSayisi != null) ...[
              Icon(Icons.person_search_rounded, size: 14, color: AppTheme.accentBlue),
              const SizedBox(width: 4),
              Text('${mac.eksikOyuncuSayisi} kişi aranıyor',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.accentBlue)),
            ] else ...[
              Text('${mac.mevcutOyuncuSayisi}/${mac.maxOyuncuSayisi}',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary.withOpacity(0.6))),
            ],
            if (mac.ucretPerKisi > 0) ...[
              const SizedBox(width: 8),
              Text('₺${mac.ucretPerKisi.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primaryGreen)),
            ],
          ]),
        ]),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    );
  }

  Widget _buildSahalarList() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _populerSahalar.length,
        itemBuilder: (context, index) => _buildSahaCard(_populerSahalar[index]),
      ),
    );
  }

  Widget _buildSahaCard(Saha saha) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SahaDetayScreen(sahaId: saha.id))),
      child: Container(
        width: 200,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardDark, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.03)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(gradient: AppTheme.glassGradient, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.stadium_rounded, color: AppTheme.primaryGreen, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(saha.sahaAdi, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                maxLines: 1, overflow: TextOverflow.ellipsis),
              Row(children: [
                Icon(Icons.location_on_outlined, size: 11, color: AppTheme.textSecondary.withOpacity(0.5)),
                const SizedBox(width: 2),
                Expanded(child: Text(saha.adres, style: TextStyle(fontSize: 10, color: AppTheme.textSecondary.withOpacity(0.5)),
                  maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
            ])),
          ]),
          const Spacer(),
          Row(children: [
            const Icon(Icons.star_rounded, color: AppTheme.amber, size: 15),
            const SizedBox(width: 4),
            Text(saha.puanOrtalamasi.toStringAsFixed(1), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const Spacer(),
            Text('₺${saha.saatlikUcret.toStringAsFixed(0)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.primaryGreen)),
          ]),
        ]),
      ),
    );
  }
}

class _QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  _QuickAction(this.label, this.icon, this.color);
}
