import 'package:flutter/material.dart';
import '../models/mac.dart';
import '../models/saha.dart';
import '../services/api_client.dart';
import '../services/mac_service.dart';
import '../services/saha_service.dart';
import '../utils/theme.dart';
import 'mac_detay_screen.dart';
import 'mac_olustur_screen.dart';

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
    if (mounted) {
      setState(() {
        _yukleniyor = false;
        if (sahaRes.basarili) _saha = sahaRes.veri;
        if (macRes.basarili && macRes.veri != null) _maclar = macRes.veri!;
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
                      SliverToBoxAdapter(child: _buildMacOlusturButon()),
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

  Widget _buildMacOlusturButon() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: GestureDetector(
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
            boxShadow: [
              BoxShadow(color: AppTheme.primaryGreen.withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 4)),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_rounded, color: AppTheme.backgroundDark, size: 22),
              SizedBox(width: 8),
              Text('Bu Sahada Maç Oluştur',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.backgroundDark)),
            ],
          ),
        ),
      ),
    );
  }
}
