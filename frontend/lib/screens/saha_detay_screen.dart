import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/mac.dart';
import '../models/saha.dart';
import '../models/saha_yorum.dart';
import '../providers/auth_provider.dart';
import '../services/api_client.dart';
import '../services/mac_service.dart';
import '../services/saha_service.dart';
import '../utils/theme.dart';
import 'mac_detay_screen.dart';
import 'mac_olustur_screen.dart';
import 'rezervasyon_screen.dart';

class SahaDetayScreen extends StatefulWidget {
  final String sahaId;
  const SahaDetayScreen({super.key, required this.sahaId});

  @override
  State<SahaDetayScreen> createState() => _SahaDetayScreenState();
}

class _SahaDetayScreenState extends State<SahaDetayScreen> {
  final _apiClient = ApiClient();
  late final SahaService _sahaService = SahaService(_apiClient);
  late final MacService _macService = MacService(_apiClient);

  Saha? _saha;
  List<Mac> _maclar = [];
  List<SahaYorum> _yorumlar = [];
  bool _yukleniyor = true;

  static const _ozellikIkonlari = <String, IconData>{
    'DUS': Icons.shower_rounded,
    'OTOPARK': Icons.local_parking_rounded,
    'KAFETERYA': Icons.local_cafe_rounded,
    'AYDINLATMA': Icons.lightbulb_rounded,
    'TRIBUN': Icons.people_rounded,
    'SOYUNMA_ODASI': Icons.checkroom_rounded,
    'WIFI': Icons.wifi_rounded,
  };

  static const _ozellikLabels = <String, String>{
    'DUS': 'Duş',
    'OTOPARK': 'Otopark',
    'KAFETERYA': 'Kafeterya',
    'AYDINLATMA': 'Aydınlatma',
    'TRIBUN': 'Tribün',
    'SOYUNMA_ODASI': 'Soyunma Odası',
    'WIFI': 'Wi-Fi',
  };

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<void> _yukle() async {
    final sahaRes = await _sahaService.sahaDetay(widget.sahaId);
    final macRes = await _macService.sahaMaclari(widget.sahaId);
    final yorumRes = await _sahaService.sahaYorumlari(widget.sahaId);
    if (mounted) {
      setState(() {
        _yukleniyor = false;
        if (sahaRes.basarili) _saha = sahaRes.veri;
        if (macRes.basarili && macRes.veri != null) _maclar = macRes.veri!;
        if (yorumRes.basarili && yorumRes.veri != null) _yorumlar = yorumRes.veri!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: _yukleniyor
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
            : _saha == null
                ? const Center(child: Text('Saha bulunamadı', style: TextStyle(color: AppTheme.textSecondary)))
                : CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      _buildAppBar(),
                      SliverToBoxAdapter(child: _buildBilgiler()),
                      SliverToBoxAdapter(child: _buildOzellikler()),
                      if (_maclar.isNotEmpty) ...[
                        SliverToBoxAdapter(child: _buildSectionTitle('Bu Sahadaki Maçlar')),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (ctx, i) => _buildMacItem(_maclar[i]),
                              childCount: _maclar.length,
                            ),
                          ),
                        ),
                      ],
                      SliverToBoxAdapter(child: _buildButonlar()),
                      SliverToBoxAdapter(child: _buildYorumlar()),
                      const SliverToBoxAdapter(child: SizedBox(height: 40)),
                    ],
                  ),
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      expandedHeight: 200,
      pinned: true,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.backgroundDark.withOpacity(0.6),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary, size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primaryGreen.withOpacity(0.2),
                AppTheme.backgroundDark,
              ],
            ),
          ),
          child: Center(
            child: Icon(Icons.stadium_rounded, size: 80, color: AppTheme.primaryGreen.withOpacity(0.3)),
          ),
        ),
      ),
    );
  }

  Widget _buildBilgiler() {
    final s = _saha!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(s.sahaAdi,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(s.sahaFormati,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primaryGreen)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (s.isletmeAdi != null)
            Text(s.isletmeAdi!,
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary.withOpacity(0.8))),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: AppTheme.textSecondary.withOpacity(0.6)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(s.adres, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.06)),
            ),
            child: Row(
              children: [
                _buildInfoItem(Icons.star_rounded, AppTheme.amber,
                  s.puanOrtalamasi.toStringAsFixed(1), '${s.yorumSayisi} yorum'),
                _buildDivider(),
                _buildInfoItem(Icons.attach_money_rounded, AppTheme.primaryGreen,
                  '₺${s.saatlikUcret.toStringAsFixed(0)}', '/saat'),
                _buildDivider(),
                _buildInfoItem(
                  s.kapaliMi ? Icons.roofing_rounded : Icons.wb_sunny_rounded,
                  s.kapaliMi ? AppTheme.lightGreen : AppTheme.accentCoral,
                  s.kapaliMi ? 'Kapalı' : 'Açık', 'saha'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, Color color, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
          Text(label, style: TextStyle(fontSize: 11, color: AppTheme.textSecondary.withOpacity(0.7))),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 40, color: AppTheme.primaryGreen.withOpacity(0.08));
  }

  Widget _buildOzellikler() {
    if (_saha == null || _saha!.ozellikListesi.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Özellikler',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _saha!.ozellikListesi.map((o) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.cardDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.06)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_ozellikIkonlari[o] ?? Icons.check_circle_outline_rounded,
                      size: 18, color: AppTheme.primaryGreen),
                    const SizedBox(width: 8),
                    Text(_ozellikLabels[o] ?? o,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: Row(
        children: [
          Container(width: 3, height: 18,
            decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildMacItem(Mac mac) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MacDetayScreen(macId: mac.id))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(mac.macBasligi, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  const SizedBox(height: 4),
                  Text('${mac.macTarihi}  ${mac.baslangicSaati}',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: mac.doluMu ? AppTheme.textSecondary.withOpacity(0.15) : AppTheme.primaryGreen.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('${mac.mevcutOyuncuSayisi}/${mac.maxOyuncuSayisi}',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                  color: mac.doluMu ? AppTheme.textSecondary : AppTheme.primaryGreen)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYorumlar() {
    final auth = context.read<AuthProvider>();
    final isKullanici = auth.kullaniciTipi == 'KULLANICI';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('Yorumlar', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const Spacer(),
          if (isKullanici)
            GestureDetector(
              onTap: () => _yorumDialog(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.amber.withOpacity(0.2)),
                ),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.star_rounded, size: 14, color: AppTheme.amber),
                  SizedBox(width: 6),
                  Text('Değerlendir', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.amber)),
                ]),
              ),
            ),
        ]),
        const SizedBox(height: 12),
        if (_yorumlar.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.03)),
            ),
            child: Center(child: Text('Henüz yorum yapılmamış',
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary.withOpacity(0.6)))),
          )
        else
          ...(_yorumlar.map((y) => _buildYorumKart(y))),
      ]),
    );
  }

  Widget _buildYorumKart(SahaYorum y) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.primaryGreen.withOpacity(0.1)),
            child: Center(child: Text(
              (y.kullaniciAdSoyad?.isNotEmpty == true ? y.kullaniciAdSoyad![0].toUpperCase() : '?'),
              style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.primaryGreen),
            )),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(y.kullaniciAdSoyad ?? 'Anonim',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          ),
          Row(mainAxisSize: MainAxisSize.min, children: List.generate(5, (i) => Icon(
            i < y.puan ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 14,
            color: AppTheme.amber,
          ))),
          if (y.tarih != null) ...[
            const SizedBox(width: 8),
            Text(y.tarih!, style: TextStyle(fontSize: 10, color: AppTheme.textSecondary.withOpacity(0.5))),
          ],
        ]),
        if (y.yorum != null && y.yorum!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(y.yorum!, style: TextStyle(fontSize: 13, color: AppTheme.textSecondary.withOpacity(0.8), height: 1.4)),
        ],
      ]),
    );
  }

  void _yorumDialog() {
    int seciliPuan = 5;
    final yorumCtrl = TextEditingController();
    bool yukleniyor = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: AppTheme.cardDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(children: [
            Icon(Icons.star_rounded, color: AppTheme.amber, size: 22),
            SizedBox(width: 10),
            Text('Sahayı Değerlendir', style: TextStyle(color: AppTheme.textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
          ]),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final y = i + 1;
                return GestureDetector(
                  onTap: () => setS(() => seciliPuan = y),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      y <= seciliPuan ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: AppTheme.amber, size: 36,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: yorumCtrl,
              maxLines: 3,
              maxLength: 300,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Yorumunuz (isteğe bağlı)',
                hintStyle: TextStyle(color: AppTheme.textSecondary.withOpacity(0.5)),
                filled: true,
                fillColor: AppTheme.backgroundDark,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                counterStyle: TextStyle(color: AppTheme.textSecondary.withOpacity(0.5)),
              ),
            ),
          ]),
          actions: [
            TextButton(
              onPressed: yukleniyor ? null : () => Navigator.pop(ctx),
              child: const Text('Vazgeç', style: TextStyle(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.amber, foregroundColor: Colors.white),
              onPressed: yukleniyor ? null : () async {
                setS(() => yukleniyor = true);
                final res = await _sahaService.yorumEkle(widget.sahaId, seciliPuan, yorumCtrl.text.trim());
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(res.mesaj),
                    backgroundColor: res.basarili ? AppTheme.primaryGreen : AppTheme.errorRed,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ));
                  if (res.basarili) _yukle();
                }
              },
              child: yukleniyor
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Gönder'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButonlar() {
    final isIsletme = context.read<AuthProvider>().kullaniciTipi == 'ISLETME';
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        children: [
          // Rezervasyon butonu (sadece kullanıcılar için)
          if (!isIsletme && _saha != null && !(_saha!.kapaliMi)) ...[
            GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => RezervasyonScreen(saha: _saha!))),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppTheme.accentPurple, AppTheme.accentBlue]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: AppTheme.accentPurple.withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_month_rounded, color: Colors.white, size: 22),
                    SizedBox(width: 8),
                    Text('Rezervasyon Yap', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          // Maç oluştur butonu
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push(context,
                MaterialPageRoute(builder: (_) => MacOlusturScreen(onSaha: _saha)));
              if (result == true) _yukle();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: AppTheme.buttonGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: AppTheme.primaryGreen.withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded, color: AppTheme.backgroundDark, size: 22),
                  SizedBox(width: 8),
                  Text('Bu Sahada Maç Oluştur', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.backgroundDark)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
