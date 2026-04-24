import 'dart:async';
import 'package:flutter/material.dart';
import '../models/mac.dart';
import '../models/saha.dart';
import '../models/takim_ilani.dart';
import '../services/api_client.dart';
import '../services/arama_service.dart';
import '../services/konum_service.dart';
import '../utils/theme.dart';
import '../widgets/konum_secim_sheet.dart';
import 'mac_detay_screen.dart';
import 'saha_detay_screen.dart';
import 'takim_ilanlari_screen.dart';

class AramaScreen extends StatefulWidget {
  const AramaScreen({super.key});

  @override
  State<AramaScreen> createState() => _AramaScreenState();
}

class _AramaScreenState extends State<AramaScreen> {
  final AramaService _aramaService = AramaService(ApiClient());
  final KonumService _konumService = KonumService();
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;

  AramaSonuc? _sonuc;
  bool _araniyor = false;
  String? _konumEtiketi;
  int _seciliTip = 0;
  final _tipler = ['Tümü', 'Sahalar', 'Maçlar', 'Oyuncu Profilleri', 'Takım İlanları'];
  final _tipDegerleri = [null, 'sahalar', 'maclar', 'oyuncular', 'ilanlar'];
  final _tipIkonlari = [
    Icons.apps_rounded,
    Icons.stadium_rounded,
    Icons.sports_soccer_rounded,
    Icons.person_rounded,
    Icons.groups_rounded,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  void _onChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (query.trim().length >= 2) _ara(query.trim());
      if (query.trim().isEmpty) setState(() => _sonuc = null);
    });
  }

  Future<void> _ara(String query) async {
    setState(() => _araniyor = true);
    final res = await _aramaService.birlesikArama(query, tip: _tipDegerleri[_seciliTip]);
    if (mounted) {
      setState(() {
        _araniyor = false;
        if (res.basarili) _sonuc = res.veri;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildKonumBar(),
              _buildTipFiltre(),
              Expanded(child: _buildSonuclar()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 24, 8),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary), onPressed: () => Navigator.pop(context)),
          const SizedBox(width: 4),
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(color: AppTheme.cardDark, borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.08))),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  Icon(Icons.search_rounded, color: AppTheme.textSecondary.withOpacity(0.6), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _controller, focusNode: _focusNode,
                      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Saha, maç, oyuncu profili veya takım ilanı ara...',
                        border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero, isDense: true,
                      ),
                      onChanged: _onChanged,
                    ),
                  ),
                  if (_controller.text.isNotEmpty)
                    GestureDetector(
                      onTap: () { _controller.clear(); setState(() => _sonuc = null); },
                      child: Padding(padding: const EdgeInsets.only(right: 12),
                        child: Icon(Icons.close_rounded, color: AppTheme.textSecondary.withOpacity(0.6), size: 18)),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipFiltre() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _tipler.length,
        itemBuilder: (ctx, i) {
          final isSelected = _seciliTip == i;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () {
                setState(() => _seciliTip = i);
                if (_controller.text.trim().length >= 2) _ara(_controller.text.trim());
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppTheme.buttonGradient : null,
                  color: isSelected ? null : AppTheme.cardDark,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(_tipIkonlari[i], size: 16,
                    color: isSelected ? AppTheme.backgroundDark : AppTheme.textSecondary.withOpacity(0.6)),
                  const SizedBox(width: 6),
                  Text(_tipler[i], style: TextStyle(fontSize: 13, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppTheme.backgroundDark : AppTheme.textSecondary)),
                ]),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildKonumBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 6, 24, 10),
      child: GestureDetector(
        onTap: _konumdanAra,
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
                  _konumEtiketi ?? 'Ulke / Sehir / Ilce sec',
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

  Future<void> _konumdanAra() async {
    final secim = await showKonumSecimSheet(
      context,
      showCurrentLocationButton: true,
    );
    if (!mounted || secim == null) return;
    String q;
    String etiket;
    if (secim.mevcutKonumSecildi) {
      try {
        final konum = await _konumService.mevcutKonumuAl();
        if (!mounted) return;
        final il = (konum.il ?? '').trim();
        final ilce = (konum.ilce ?? '').trim();
        etiket = [il, ilce].where((e) => e.isNotEmpty).join(' / ');
        q = [il, ilce].where((e) => e.isNotEmpty).join(' ').trim();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
        return;
      }
    } else {
      final il = secim.il.trim();
      final ilce = secim.ilce.trim();
      etiket = [il, ilce].where((e) => e.isNotEmpty).join(' / ');
      q = [il, ilce].where((e) => e.isNotEmpty).join(' ').trim();
    }
    if (q.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lutfen gecerli bir sehir/ilce secin.')),
      );
      return;
    }

    setState(() {
      _konumEtiketi = etiket;
      _seciliTip = 0;
    });
    _controller.text = q;
    await _ara(q);
  }

  Widget _buildSonuclar() {
    if (_araniyor) return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen));

    if (_sonuc == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.manage_search_rounded, size: 64, color: AppTheme.textSecondary.withOpacity(0.2)),
            const SizedBox(height: 16),
            const Text('Ne aramak istersiniz?', style: TextStyle(color: AppTheme.textPrimary, fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Oyuncu sekmesi profilleri, takım ilanları sekmesi ise takıma kalıcı oyuncu arayan ilanları gösterir.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.7), fontSize: 13, height: 1.4)),
            const SizedBox(height: 24),
            Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [
              _buildOneriChip('Halı saha'), _buildOneriChip('6v6'), _buildOneriChip('Forvet'),
            ]),
          ]),
        ),
      );
    }

    if (_sonuc!.toplamSonuc == 0) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.search_off_rounded, size: 64, color: AppTheme.textSecondary.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text('Sonuç bulunamadı', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
          const SizedBox(height: 6),
          Text('"${_controller.text}" ile eşleşen kayıt yok',
            style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.6), fontSize: 13)),
        ]),
      );
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      children: [
        if (_sonuc!.sahalar.isNotEmpty) ...[
          _buildSectionHeader('Sahalar', Icons.stadium_rounded, _sonuc!.sahalar.length),
          ..._sonuc!.sahalar.map(_buildSahaItem),
        ],
        if (_sonuc!.maclar.isNotEmpty) ...[
          _buildSectionHeader('Maçlar', Icons.sports_soccer_rounded, _sonuc!.maclar.length),
          ..._sonuc!.maclar.map(_buildMacItem),
        ],
        if (_sonuc!.oyuncular.isNotEmpty) ...[
          _buildSectionHeader('Oyuncular', Icons.person_rounded, _sonuc!.oyuncular.length),
          ..._sonuc!.oyuncular.map(_buildOyuncuItem),
        ],
        if (_sonuc!.ilanlar.isNotEmpty) ...[
          _buildSectionHeader('Takım İlanları', Icons.groups_rounded, _sonuc!.ilanlar.length),
          ..._sonuc!.ilanlar.map(_buildIlanItem),
        ],
      ],
    );
  }

  Widget _buildOneriChip(String text) {
    return GestureDetector(
      onTap: () {
        _controller.text = text;
        _ara(text);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(color: AppTheme.cardDark, borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.1))),
        child: Text(text, style: TextStyle(fontSize: 13, color: AppTheme.textSecondary.withOpacity(0.8))),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Row(children: [
        Icon(icon, size: 18, color: AppTheme.primaryGreen),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: AppTheme.primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Text('$count', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryGreen)),
        ),
      ]),
    );
  }

  Widget _buildSahaItem(Saha saha) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SahaDetayScreen(sahaId: saha.id))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppTheme.cardDark, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.06))),
        child: Row(children: [
          Container(width: 44, height: 44,
            decoration: BoxDecoration(gradient: AppTheme.glassGradient, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.stadium_rounded, color: AppTheme.primaryGreen, size: 20)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(saha.sahaAdi, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            Text(saha.adres, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
          Text('₺${saha.saatlikUcret.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primaryGreen)),
        ]),
      ),
    );
  }

  Widget _buildMacItem(Mac mac) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MacDetayScreen(macId: mac.id))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppTheme.cardDark, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.06))),
        child: Row(children: [
          Container(width: 44, height: 44,
            decoration: BoxDecoration(color: AppTheme.primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.sports_soccer_rounded, color: AppTheme.primaryGreen, size: 20)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(mac.macBasligi, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            Row(children: [
              Text('${mac.macTarihi}  ${mac.baslangicSaati}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(color: AppTheme.primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(mac.format, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.primaryGreen)),
              ),
            ]),
          ])),
          Text('${mac.mevcutOyuncuSayisi}/${mac.maxOyuncuSayisi}',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: mac.doluMu ? AppTheme.accentCoral : AppTheme.primaryGreen)),
        ]),
      ),
    );
  }

  Widget _buildOyuncuItem(OyuncuSonuc oyuncu) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppTheme.cardDark, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.06))),
      child: Row(children: [
        Container(width: 44, height: 44,
          decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppTheme.glassGradient),
          child: const Icon(Icons.person_rounded, color: AppTheme.primaryGreen, size: 22)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(oyuncu.adSoyad, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          if (oyuncu.disiplinPuani > 0)
            Row(children: [
              const Icon(Icons.shield_rounded, size: 12, color: AppTheme.amber),
              const SizedBox(width: 4),
              Text('Disiplin: ${oyuncu.disiplinPuani.toStringAsFixed(1)}', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
            ]),
        ])),
        if (oyuncu.puanOrtalamasi > 0) ...[
          const Icon(Icons.star_rounded, size: 16, color: AppTheme.amber),
          const SizedBox(width: 4),
          Text(oyuncu.puanOrtalamasi.toStringAsFixed(1), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        ],
      ]),
    );
  }

  Widget _buildIlanItem(TakimIlani ilan) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TakimIlanlariScreen())),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppTheme.cardDark, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.accentPurple.withOpacity(0.08))),
        child: Row(children: [
          Container(width: 44, height: 44,
            decoration: BoxDecoration(color: AppTheme.accentPurple.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.groups_rounded, color: AppTheme.accentPurple, size: 22)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(ilan.ilanBasligi, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            Row(children: [
              Text(ilan.takimAdi, style: const TextStyle(fontSize: 12, color: AppTheme.primaryGreen, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              Text('${ilan.arananOyuncuSayisi} oyuncu • ${ilan.pozisyonText}',
                style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
            ]),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: AppTheme.accentPurple.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
            child: Text(ilan.seviyeText, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.accentPurple)),
          ),
        ]),
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
