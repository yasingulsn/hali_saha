import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/takim_ilani.dart';
import '../providers/auth_provider.dart';
import '../services/api_client.dart';
import '../services/takim_ilani_service.dart';
import '../utils/theme.dart';
import 'takim_ilani_olustur_screen.dart';

class TakimIlanlariScreen extends StatefulWidget {
  const TakimIlanlariScreen({super.key});

  @override
  State<TakimIlanlariScreen> createState() => _TakimIlanlariScreenState();
}

class _TakimIlanlariScreenState extends State<TakimIlanlariScreen> {
  final _service = TakimIlaniService(ApiClient());
  List<TakimIlani> _tumIlanlar = [];
  List<TakimIlani> _benimIlanlarim = [];
  bool _yukleniyor = true;
  int _seciliTab = 0;

  // Filtreler
  String? _filtrePozisyon;
  String? _filtreSeviye;

  final _pozisyonFiltreler = [
    (null, 'Tümü'),
    ('KALECI', 'Kaleci'),
    ('DEFANS', 'Defans'),
    ('ORTASAHA', 'Orta Saha'),
    ('FORVET', 'Forvet'),
    ('FARKETMEZ', 'Farketmez'),
  ];

  final _seviyeFiltreler = [
    (null, 'Tümü'),
    ('KARMA', 'Karma'),
    ('BASLANGIC', 'Başlangıç'),
    ('ORTA', 'Orta'),
    ('ILERI', 'İleri'),
  ];

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<void> _yukle() async {
    setState(() => _yukleniyor = true);
    final tumRes = await _service.aktifIlanlar();
    List<TakimIlani> benim = [];
    try {
      final benimRes = await _service.benimIlanlarim();
      if (benimRes.basarili && benimRes.veri != null) benim = benimRes.veri!;
    } catch (_) {}
    if (mounted) {
      setState(() {
        _yukleniyor = false;
        if (tumRes.basarili && tumRes.veri != null) _tumIlanlar = tumRes.veri!;
        _benimIlanlarim = benim;
      });
    }
  }

  List<TakimIlani> get _filtrelenmisIlanlar {
    final kaynak = _seciliTab == 0 ? _tumIlanlar : _benimIlanlarim;
    return kaynak.where((ilan) {
      if (_filtrePozisyon != null && ilan.arananPozisyon != _filtrePozisyon) return false;
      if (_filtreSeviye != null && ilan.seviye != _filtreSeviye) return false;
      return true;
    }).toList();
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
              _buildTabBar(),
              _buildAciklamaNotu(),
              if (_seciliTab == 0) _buildFiltreler(),
              Expanded(
                child: _yukleniyor
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
                  : RefreshIndicator(
                      onRefresh: _yukle, color: AppTheme.primaryGreen,
                      child: _buildIlanListesi(_filtrelenmisIlanlar,
                        _seciliTab == 0 ? 'Filtre ile eşleşen ilan yok' : 'Henüz ilan vermediniz'),
                    ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const TakimIlaniOlusturScreen()));
          if (result == true) _yukle();
        },
        backgroundColor: AppTheme.primaryGreen,
        icon: const Icon(Icons.add_rounded, color: AppTheme.backgroundDark),
        label: const Text('İlan Ver', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.backgroundDark)),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 24, 8),
      child: Row(children: [
        IconButton(icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary), onPressed: () => Navigator.pop(context)),
        const SizedBox(width: 8),
        const Expanded(child: Text('Takım İlanları', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimary))),
      ]),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppTheme.cardDark, borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        _buildTab('Tüm İlanlar', 0),
        _buildTab('İlanlarım (${_benimIlanlarim.length})', 1),
      ]),
    );
  }

  Widget _buildAciklamaNotu() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 8, 24, 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.accentPurple.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentPurple.withOpacity(0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(Icons.info_outline_rounded, size: 16, color: AppTheme.accentPurple),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Buradaki ilanlar takıma kalıcı oyuncu aramak içindir. Tek maçlık oyuncu araması için Açık Maçlar bölümündeki "Eksik Oyuncu" tipini kullanın.',
              style: TextStyle(
                fontSize: 11,
                height: 1.35,
                color: AppTheme.textSecondary.withOpacity(0.85),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String text, int index) {
    final sel = _seciliTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _seciliTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(gradient: sel ? AppTheme.buttonGradient : null, borderRadius: BorderRadius.circular(10)),
          child: Text(text, textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
              color: sel ? AppTheme.backgroundDark : AppTheme.textSecondary)),
        ),
      ),
    );
  }

  Widget _buildFiltreler() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
          child: Text('Pozisyon', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary.withOpacity(0.7))),
        ),
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: _pozisyonFiltreler.map((f) {
              final sel = _filtrePozisyon == f.$1;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () => setState(() => _filtrePozisyon = f.$1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: sel ? AppTheme.buttonGradient : null,
                      color: sel ? null : AppTheme.cardDark,
                      borderRadius: BorderRadius.circular(10),
                      border: sel ? null : Border.all(color: AppTheme.primaryGreen.withOpacity(0.06)),
                    ),
                    child: Text(f.$2, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                      color: sel ? AppTheme.backgroundDark : AppTheme.textSecondary)),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
          child: Text('Seviye', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary.withOpacity(0.7))),
        ),
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: _seviyeFiltreler.map((f) {
              final sel = _filtreSeviye == f.$1;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () => setState(() => _filtreSeviye = f.$1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: sel ? AppTheme.buttonGradient : null,
                      color: sel ? null : AppTheme.cardDark,
                      borderRadius: BorderRadius.circular(10),
                      border: sel ? null : Border.all(color: AppTheme.primaryGreen.withOpacity(0.06)),
                    ),
                    child: Text(f.$2, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                      color: sel ? AppTheme.backgroundDark : AppTheme.textSecondary)),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildIlanListesi(List<TakimIlani> ilanlar, String bosText) {
    if (ilanlar.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.article_outlined, size: 48, color: AppTheme.textSecondary.withOpacity(0.3)),
        const SizedBox(height: 12),
        Text(bosText, style: TextStyle(fontSize: 15, color: AppTheme.textSecondary.withOpacity(0.6))),
      ]));
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
      itemCount: ilanlar.length,
      itemBuilder: (context, index) => _buildIlanCard(ilanlar[index]),
    );
  }

  Widget _buildIlanCard(TakimIlani ilan) {
    return GestureDetector(
      onTap: () => _showIlanDetay(ilan),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardDark, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.03)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppTheme.primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(ilan.takimAdi, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primaryGreen)),
              ),
              const Spacer(),
              if (ilan.minDisiplinPuani != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppTheme.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.shield_rounded, size: 12, color: AppTheme.amber),
                    const SizedBox(width: 4),
                    Text('${ilan.minDisiplinPuani!.toStringAsFixed(1)}+', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.amber)),
                  ]),
                ),
            ]),
            const SizedBox(height: 10),
            Text(ilan.ilanBasligi, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            if (ilan.aciklama != null) ...[
              const SizedBox(height: 6),
              Text(ilan.aciklama!, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary.withOpacity(0.8))),
            ],
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 6, children: [
              _buildTag(Icons.person_rounded, '${ilan.arananOyuncuSayisi} oyuncu'),
              _buildTag(Icons.sports_soccer_rounded, ilan.pozisyonText),
              _buildTag(Icons.signal_cellular_alt_rounded, ilan.seviyeText),
              if (ilan.konum != null) _buildTag(Icons.location_on_rounded, ilan.konum!),
            ]),
            if (ilan.olusturanAdi != null) ...[
              const SizedBox(height: 10),
              Row(children: [
                CircleAvatar(radius: 12, backgroundColor: AppTheme.primaryGreen.withOpacity(0.2),
                  child: const Icon(Icons.person_rounded, size: 14, color: AppTheme.primaryGreen)),
                const SizedBox(width: 8),
                Text(ilan.olusturanAdi!, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ]),
            ],
            if (_seciliTab == 1) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _kartActionButton(
                      text: 'Düzenle',
                      icon: Icons.edit_rounded,
                      color: AppTheme.accentBlue,
                      onTap: () => _ilanDuzenle(ilan),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _kartActionButton(
                      text: 'Sil',
                      icon: Icons.delete_outline_rounded,
                      color: AppTheme.errorRed,
                      onTap: () => _ilanSil(ilan),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _ilanDuzenle(TakimIlani ilan) async {
    final sonuc = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TakimIlaniOlusturScreen(ilan: ilan)),
    );
    if (sonuc == true) _yukle();
  }

  Future<void> _ilanSil(TakimIlani ilan) async {
    final onay = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDarkElevated,
        title: const Text('İlan silinsin mi?', style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text('Bu işlem geri alınamaz.', style: TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sil', style: TextStyle(color: AppTheme.errorRed)),
          ),
        ],
      ),
    );
    if (onay != true) return;

    final res = await _service.ilanSil(ilan.id);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(res.basarili ? 'İlan silindi' : res.mesaj),
        backgroundColor: res.basarili ? AppTheme.primaryGreen : AppTheme.errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    if (res.basarili) _yukle();
  }

  Widget _kartActionButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: AppTheme.inputFill, borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: AppTheme.textSecondary),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  void _showIlanDetay(TakimIlani ilan) {
    final userId = context.read<AuthProvider>().currentUser?.id;
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TakimIlaniDetaySheet(
        ilan: ilan,
        benimMi: ilan.olusturanId == userId,
        onDegisti: _yukle,
      ),
    );
  }
}

class TakimIlaniDetaySheet extends StatelessWidget {
  final TakimIlani ilan;
  final bool benimMi;
  final VoidCallback onDegisti;
  const TakimIlaniDetaySheet({required this.ilan, required this.benimMi, required this.onDegisti});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
      decoration: const BoxDecoration(
        color: AppTheme.cardDarkElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(color: AppTheme.textSecondary.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
          Flexible(
            child: ListView(
              shrinkWrap: true, physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppTheme.primaryGreen.withOpacity(0.15), AppTheme.primaryGreen.withOpacity(0.05)]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(children: [
                    const Icon(Icons.shield_rounded, size: 22, color: AppTheme.primaryGreen),
                    const SizedBox(width: 10),
                    Text(ilan.takimAdi, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.primaryGreen)),
                  ]),
                ),
                const SizedBox(height: 16),
                Text(ilan.ilanBasligi, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                if (ilan.aciklama != null) ...[
                  const SizedBox(height: 10),
                  Text(ilan.aciklama!, style: TextStyle(fontSize: 14, color: AppTheme.textSecondary.withOpacity(0.9), height: 1.5)),
                ],
                const SizedBox(height: 20),
                _infoRow(Icons.person_rounded, 'Aranan Oyuncu', '${ilan.arananOyuncuSayisi} kişi'),
                _infoRow(Icons.sports_soccer_rounded, 'Pozisyon', ilan.pozisyonText),
                _infoRow(Icons.signal_cellular_alt_rounded, 'Seviye', ilan.seviyeText),
                if (ilan.konum != null) _infoRow(Icons.location_on_rounded, 'Konum', ilan.konum!),
                if (ilan.minDisiplinPuani != null)
                  _infoRow(Icons.shield_rounded, 'Min. Disiplin Puanı', '${ilan.minDisiplinPuani!.toStringAsFixed(1)} / 5.0',
                    valueColor: AppTheme.amber),
                if (ilan.olusturanAdi != null) _infoRow(Icons.person_outline_rounded, 'İlan Sahibi', ilan.olusturanAdi!),
                const SizedBox(height: 24),
                if (benimMi)
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.2)),
                        ),
                        child: const Center(
                          child: Text(
                            'Bu sizin ilanınız',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.primaryGreen),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _actionButton(
                              context: context,
                              text: 'Düzenle',
                              icon: Icons.edit_rounded,
                              color: AppTheme.accentBlue,
                              onTap: () async {
                                Navigator.pop(context);
                                final sonuc = await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => TakimIlaniOlusturScreen(ilan: ilan)),
                                );
                                if (sonuc == true) onDegisti();
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _actionButton(
                              context: context,
                              text: 'Sil',
                              icon: Icons.delete_outline_rounded,
                              color: AppTheme.errorRed,
                              onTap: () => _ilanSil(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                else
                  GestureDetector(
                    onTap: () => _katilDialog(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(gradient: AppTheme.buttonGradient, borderRadius: BorderRadius.circular(16)),
                      child: const Center(child: Text('Katıl',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.backgroundDark))),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _katilDialog(BuildContext context) {
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
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              final service = TakimIlaniService(ApiClient());
              final res = await service.katilmaIstegiGonder(ilan.id, controller.text.trim());
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(res.mesaj),
                  backgroundColor: res.basarili ? AppTheme.primaryGreen : AppTheme.errorRed,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ));
                if (res.basarili) Navigator.pop(context);
              }
            },
            child: const Text('İstek Gönder'),
          ),
        ],
      ),
    );
  }

  Future<void> _ilanSil(BuildContext context) async {
    final onay = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDarkElevated,
        title: const Text('İlan silinsin mi?', style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text(
          'Bu işlem geri alınamaz.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sil', style: TextStyle(color: AppTheme.errorRed)),
          ),
        ],
      ),
    );

    if (onay != true || !context.mounted) return;
    final service = TakimIlaniService(ApiClient());
    final res = await service.ilanSil(ilan.id);
    if (!context.mounted) return;

    if (res.basarili) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('İlan silindi'),
          backgroundColor: AppTheme.primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      onDegisti();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.mesaj),
          backgroundColor: AppTheme.errorRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Widget _actionButton({
    required BuildContext context,
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppTheme.primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: AppTheme.primaryGreen),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontSize: 11, color: AppTheme.textSecondary.withOpacity(0.7))),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: valueColor ?? AppTheme.textPrimary)),
        ])),
      ]),
    );
  }
}
