import 'package:flutter/material.dart';
import '../models/takim_ilani_istek.dart';
import '../services/api_client.dart';
import '../services/takim_ilani_service.dart';
import '../utils/theme.dart';

class TakimIstekleriScreen extends StatefulWidget {
  const TakimIstekleriScreen({super.key});

  @override
  State<TakimIstekleriScreen> createState() => _TakimIstekleriScreenState();
}

class _TakimIstekleriScreenState extends State<TakimIstekleriScreen> {
  final TakimIlaniService _service = TakimIlaniService(ApiClient());
  List<TakimIlaniIstek> _gelenler = [];
  List<TakimIlaniIstek> _gonderilenler = [];
  bool _yukleniyor = true;
  int _seciliTab = 0;

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<void> _yukle() async {
    setState(() => _yukleniyor = true);
    final results = await Future.wait([
      _service.gelenIstekler(),
      _service.gonderdigimIstekler(),
    ]);
    if (mounted) {
      setState(() {
        _yukleniyor = false;
        _gelenler = results[0].veri ?? [];
        _gonderilenler = results[1].veri ?? [];
      });
    }
  }

  Future<void> _onayla(TakimIlaniIstek istek) async {
    final res = await _service.istekOnayla(istek.id);
    if (!mounted) return;
    _snackBar(res.basarili ? 'İstek onaylandı!' : res.mesaj,
        res.basarili ? AppTheme.primaryGreen : AppTheme.errorRed);
    if (res.basarili) _yukle();
  }

  Future<void> _reddet(TakimIlaniIstek istek) async {
    final res = await _service.istekReddet(istek.id);
    if (!mounted) return;
    _snackBar(res.basarili ? 'İstek reddedildi.' : res.mesaj,
        res.basarili ? AppTheme.accentCoral : AppTheme.errorRed);
    if (res.basarili) _yukle();
  }

  void _snackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
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
              Expanded(
                child: _yukleniyor
                    ? const Center(
                        child: CircularProgressIndicator(color: AppTheme.primaryGreen))
                    : RefreshIndicator(
                        onRefresh: _yukle,
                        color: AppTheme.primaryGreen,
                        child: _seciliTab == 0
                            ? _buildGelenlerList()
                            : _buildGonderilenlerList(),
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
        const Expanded(
          child: Text(
            'Takım İstekleri',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: AppTheme.cardDark, borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        _buildTab('Gelenler (${_gelenler.length})', 0),
        _buildTab('Gönderdiklerim (${_gonderilenler.length})', 1),
      ]),
    );
  }

  Widget _buildTab(String text, int index) {
    final sel = _seciliTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _seciliTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: sel ? AppTheme.buttonGradient : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: sel ? AppTheme.backgroundDark : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGelenlerList() {
    if (_gelenler.isEmpty) {
      return _buildBosEkran(
        Icons.move_to_inbox_outlined,
        'Bekleyen istek yok',
        'İlanlarınıza gelen katılma istekleri burada görünür',
      );
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: _gelenler.length,
      itemBuilder: (_, i) => _buildGelenIstekKart(_gelenler[i]),
    );
  }

  Widget _buildGonderilenlerList() {
    if (_gonderilenler.isEmpty) {
      return _buildBosEkran(
        Icons.send_outlined,
        'Henüz istek göndermediniz',
        'Takım ilanlarına katılma isteği gönderdiğinizde burada görünür',
      );
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: _gonderilenler.length,
      itemBuilder: (_, i) => _buildGonderilenIstekKart(_gonderilenler[i]),
    );
  }

  Widget _buildGelenIstekKart(TakimIlaniIstek istek) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppTheme.primaryGreen.withOpacity(0.15),
              child: const Icon(Icons.person_rounded,
                  color: AppTheme.primaryGreen, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    istek.gonderenAdSoyad,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    istek.ilanBasligi,
                    style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary.withOpacity(0.7)),
                  ),
                ],
              ),
            ),
            Text(
              _formatTarih(istek.olusturulmaTarihi),
              style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary.withOpacity(0.5)),
            ),
          ]),
          if (istek.mesaj.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.inputFill,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.format_quote_rounded,
                      size: 14,
                      color: AppTheme.textSecondary.withOpacity(0.4)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      istek.mesaj,
                      style: TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: AppTheme.textSecondary.withOpacity(0.8),
                          height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: _aksiyon(
                text: 'Onayla',
                icon: Icons.check_rounded,
                color: AppTheme.primaryGreen,
                onTap: () => _onayla(istek),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _aksiyon(
                text: 'Reddet',
                icon: Icons.close_rounded,
                color: AppTheme.errorRed,
                onTap: () => _reddet(istek),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildGonderilenIstekKart(TakimIlaniIstek istek) {
    final durumRenk = _durumRenk(istek.durum);
    final durumIkon = _durumIkon(istek.durum);
    final durumYazi = _durumYazi(istek.durum);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: durumRenk.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: durumRenk.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.campaign_rounded,
                  color: durumRenk, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    istek.ilanBasligi,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppTheme.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatTarih(istek.olusturulmaTarihi),
                    style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary.withOpacity(0.6)),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: durumRenk.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(durumIkon, size: 12, color: durumRenk),
                const SizedBox(width: 4),
                Text(
                  durumYazi,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: durumRenk),
                ),
              ]),
            ),
          ]),
          if (istek.mesaj.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              '"${istek.mesaj}"',
              style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: AppTheme.textSecondary.withOpacity(0.6),
                  height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBosEkran(IconData ikon, String baslik, String aciklama) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: 300,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(ikon,
                    size: 56, color: AppTheme.textSecondary.withOpacity(0.2)),
                const SizedBox(height: 16),
                Text(baslik,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textSecondary.withOpacity(0.5))),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Text(
                    aciklama,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary.withOpacity(0.35),
                        height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _aksiyon({
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
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(text,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, color: color)),
        ]),
      ),
    );
  }

  Color _durumRenk(String durum) {
    switch (durum) {
      case 'ONAYLANDI':
        return AppTheme.primaryGreen;
      case 'REDDEDILDI':
        return AppTheme.errorRed;
      default:
        return AppTheme.amber;
    }
  }

  IconData _durumIkon(String durum) {
    switch (durum) {
      case 'ONAYLANDI':
        return Icons.check_circle_rounded;
      case 'REDDEDILDI':
        return Icons.cancel_rounded;
      default:
        return Icons.hourglass_bottom_rounded;
    }
  }

  String _durumYazi(String durum) {
    switch (durum) {
      case 'ONAYLANDI':
        return 'Onaylandı';
      case 'REDDEDILDI':
        return 'Reddedildi';
      default:
        return 'Beklemede';
    }
  }

  String _formatTarih(String tarih) {
    if (tarih.isEmpty) return '';
    try {
      final dt = DateTime.parse(tarih).toLocal();
      final fark = DateTime.now().difference(dt);
      if (fark.inMinutes < 60) return '${fark.inMinutes}d önce';
      if (fark.inHours < 24) return '${fark.inHours}s önce';
      if (fark.inDays < 7) return '${fark.inDays}g önce';
      return '${dt.day}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
    } catch (_) {
      return '';
    }
  }
}
