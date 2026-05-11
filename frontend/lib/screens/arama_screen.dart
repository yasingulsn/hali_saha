import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/mac.dart';
import '../models/saha.dart';
import '../models/takim_ilani.dart';
import '../providers/konum_provider.dart';
import '../services/api_client.dart';
import '../services/arama_service.dart';
import '../utils/theme.dart';
import 'mac_detay_screen.dart';
import 'saha_detay_screen.dart';
import 'takim_ilanlari_screen.dart';

class AramaScreen extends StatefulWidget {
  const AramaScreen({super.key});

  @override
  State<AramaScreen> createState() => _AramaScreenState();
}

class _AramaScreenState extends State<AramaScreen> with SingleTickerProviderStateMixin {
  final AramaService _aramaService = AramaService(ApiClient());
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;

  AramaSonuc? _sonuc;
  bool _araniyor = false;
  int _seciliTip = 0;
  bool _konumListelemesiYapildi = false;
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _konumBazliListeleIfNeeded();
    });
  }

  void _onChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (query.trim().length >= 2) {
        _ara(query.trim());
      }
      if (query.trim().isEmpty) {
        _konumBazliListeleIfNeeded();
      }
    });
  }

  Future<void> _ara(String query) async {
    setState(() => _araniyor = true);
    final kp = context.read<KonumProvider>();
    final res = await _aramaService.birlesikArama(
      query,
      tip: _tipDegerleri[_seciliTip],
      il: kp.seciliIl,
      ilce: kp.seciliIlce,
    );
    if (mounted) {
      setState(() {
        _araniyor = false;
        if (res.basarili) _sonuc = res.veri;
      });
    }
  }

  Future<void> _konumBazliListeleIfNeeded() async {
    final kp = context.read<KonumProvider>();
    if (!kp.konumSecildi) {
      if (!_konumListelemesiYapildi) setState(() => _sonuc = null);
      return;
    }
    setState(() => _araniyor = true);
    final res = await _aramaService.birlesikArama(
      '',
      tip: _tipDegerleri[_seciliTip],
      il: kp.seciliIl,
      ilce: kp.seciliIlce,
    );
    if (mounted) {
      setState(() {
        _araniyor = false;
        _konumListelemesiYapildi = true;
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
                      onTap: () {
                        _controller.clear();
                        _konumBazliListeleIfNeeded();
                      },
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
                if (_controller.text.trim().length >= 2) {
                  _ara(_controller.text.trim());
                } else {
                  _konumBazliListeleIfNeeded();
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
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


  Widget _buildSonuclar() {
    final kp = context.watch<KonumProvider>();
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
            Text(
              kp.konumSecildi
                  ? 'Arama kutusuna yazarak ${kp.konumEtiketi} konumunda arayın.'
                  : 'Arama kutusuna yazarak saha, maç, oyuncu veya takım ilanı arayın.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.7), fontSize: 13, height: 1.4)),
            const SizedBox(height: 20),
            Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [
              _buildOneriChip('Halı saha'), _buildOneriChip('6v6'), _buildOneriChip('Forvet'),
            ]),
          ]),
        ),
      );
    }

    if (_sonuc!.toplamSonuc == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: AppTheme.cardDark,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.04)),
              ),
              child: Icon(Icons.search_off_rounded, size: 36,
                color: AppTheme.textSecondary.withOpacity(0.3)),
            ),
            const SizedBox(height: 18),
            Text('Sonuç bulunamadı',
              style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.6), fontSize: 16, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('"${_controller.text}" ile eşleşen kayıt yok',
              style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.4), fontSize: 13),
              textAlign: TextAlign.center),
          ]),
        ),
      );
    }

    // Sonuçlı liste — konumBasligi + kategorize liste
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      children: [
        if (_sonuc!.sahalar.isNotEmpty) ...[
          _buildSectionHeader('Sahalar', Icons.stadium_rounded, _sonuc!.sahalar.length, AppTheme.accentBlue),
          ..._sonuc!.sahalar.map(_buildSahaItem),
          const SizedBox(height: 8),
        ],
        if (_sonuc!.maclar.isNotEmpty) ...[
          _buildSectionHeader('Maçlar', Icons.sports_soccer_rounded, _sonuc!.maclar.length, AppTheme.primaryGreen),
          ..._sonuc!.maclar.map(_buildMacItem),
          const SizedBox(height: 8),
        ],
        if (_sonuc!.oyuncular.isNotEmpty) ...[
          _buildSectionHeader('Oyuncular', Icons.person_rounded, _sonuc!.oyuncular.length, AppTheme.lightOrange),
          ..._sonuc!.oyuncular.map(_buildOyuncuItem),
          const SizedBox(height: 8),
        ],
        if (_sonuc!.ilanlar.isNotEmpty) ...[
          _buildSectionHeader('Takım İlanları', Icons.groups_rounded, _sonuc!.ilanlar.length, AppTheme.accentPurple),
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

  Widget _buildSectionHeader(String title, IconData icon, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Row(children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Text('$count', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
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
          border: Border.all(color: AppTheme.accentBlue.withOpacity(0.06))),
        child: Row(children: [
          Container(width: 48, height: 48,
            decoration: BoxDecoration(
              color: AppTheme.accentBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.stadium_rounded, color: AppTheme.accentBlue, size: 22)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(saha.sahaAdi, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 3),
            Row(children: [
              Icon(Icons.location_on_outlined, size: 12, color: AppTheme.textSecondary.withOpacity(0.4)),
              const SizedBox(width: 3),
              Expanded(
                child: Text(saha.adres, style: TextStyle(fontSize: 11, color: AppTheme.textSecondary.withOpacity(0.6)),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.star_rounded, size: 13, color: AppTheme.amber),
              const SizedBox(width: 3),
              Text(saha.puanOrtalamasi.toStringAsFixed(1), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(saha.sahaFormati, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppTheme.accentBlue)),
              ),
            ]),
          ])),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('₺${saha.saatlikUcret.toStringAsFixed(0)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.primaryGreen)),
              Text('/saat', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary.withOpacity(0.4))),
            ],
          ),
        ]),
      ),
    );
  }

  Widget _buildMacItem(Mac mac) {
    final renk = mac.macTipi == 'RAKIP_ARANIYOR'
        ? AppTheme.accentCoral
        : mac.macTipi == 'EKSIK_OYUNCU'
            ? AppTheme.accentBlue
            : AppTheme.primaryGreen;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MacDetayScreen(macId: mac.id))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppTheme.cardDark, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: renk.withOpacity(0.06))),
        child: Row(children: [
          Container(width: 48, height: 48,
            decoration: BoxDecoration(color: renk.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.sports_soccer_rounded, color: renk, size: 22)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(mac.macBasligi, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
              maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 3),
            Row(children: [
              Icon(Icons.calendar_today_rounded, size: 11, color: AppTheme.textSecondary.withOpacity(0.4)),
              const SizedBox(width: 4),
              Text('${mac.macTarihi}  ${mac.baslangicSaati}', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary.withOpacity(0.6))),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: renk.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(mac.format, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: renk)),
              ),
              if (mac.macTipi != 'NORMAL') ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: AppTheme.accentPurple.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                  child: Text(mac.macTipiText, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppTheme.accentPurple)),
                ),
              ],
            ]),
          ])),
          // Doluluk
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: mac.doluMu ? AppTheme.errorRed.withOpacity(0.1) : AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(children: [
              Icon(Icons.people_rounded, size: 14,
                color: mac.doluMu ? AppTheme.errorRed : AppTheme.primaryGreen),
              const SizedBox(height: 2),
              Text('${mac.mevcutOyuncuSayisi}/${mac.maxOyuncuSayisi}',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                  color: mac.doluMu ? AppTheme.errorRed : AppTheme.primaryGreen)),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildOyuncuItem(OyuncuSonuc oyuncu) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppTheme.cardDark, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.lightOrange.withOpacity(0.06))),
      child: Row(children: [
        Container(width: 48, height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.lightOrange.withOpacity(0.1),
          ),
          child: const Icon(Icons.person_rounded, color: AppTheme.lightOrange, size: 24)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(oyuncu.adSoyad, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 4),
          Row(children: [
            if (oyuncu.tercihEdilenPozisyon != null && oyuncu.tercihEdilenPozisyon!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(_pozisyonText(oyuncu.tercihEdilenPozisyon!),
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppTheme.accentBlue)),
              ),
              const SizedBox(width: 6),
            ],
            if (oyuncu.disiplinPuani > 0) ...[
              const Icon(Icons.shield_rounded, size: 12, color: AppTheme.amber),
              const SizedBox(width: 3),
              Text(oyuncu.disiplinPuani.toStringAsFixed(1),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
            ],
          ]),
        ])),
        if (oyuncu.puanOrtalamasi > 0) ...[
          Column(
            children: [
              const Icon(Icons.star_rounded, size: 18, color: AppTheme.amber),
              const SizedBox(height: 2),
              Text(oyuncu.puanOrtalamasi.toStringAsFixed(1),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            ],
          ),
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
          Container(width: 48, height: 48,
            decoration: BoxDecoration(color: AppTheme.accentPurple.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.groups_rounded, color: AppTheme.accentPurple, size: 22)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(ilan.ilanBasligi, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
              maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 3),
            Row(children: [
              Text(ilan.takimAdi, style: const TextStyle(fontSize: 12, color: AppTheme.primaryGreen, fontWeight: FontWeight.w600)),
              const SizedBox(width: 6),
              Text('•', style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.3))),
              const SizedBox(width: 6),
              Text('${ilan.arananOyuncuSayisi} oyuncu',
                style: TextStyle(fontSize: 11, color: AppTheme.textSecondary.withOpacity(0.7))),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: AppTheme.lightOrange.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(ilan.pozisyonText, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppTheme.lightOrange)),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: AppTheme.accentPurple.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(ilan.seviyeText, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppTheme.accentPurple)),
              ),
              if (ilan.konum != null && ilan.konum!.isNotEmpty) ...[
                const SizedBox(width: 6),
                Icon(Icons.location_on_outlined, size: 10, color: AppTheme.textSecondary.withOpacity(0.4)),
                const SizedBox(width: 2),
                Flexible(
                  child: Text(ilan.konum!, style: TextStyle(fontSize: 9, color: AppTheme.textSecondary.withOpacity(0.5)),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ],
            ]),
          ])),
          Icon(Icons.chevron_right_rounded, size: 20, color: AppTheme.textSecondary.withOpacity(0.3)),
        ]),
      ),
    );
  }

  String _pozisyonText(String pozisyon) {
    switch (pozisyon) {
      case 'KALECI': return 'Kaleci';
      case 'DEFANS': return 'Defans';
      case 'ORTASAHA': return 'Orta Saha';
      case 'FORVET': return 'Forvet';
      default: return pozisyon;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
