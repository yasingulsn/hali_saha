import 'package:flutter/material.dart';
import '../models/rezervasyon.dart';
import '../services/api_client.dart';
import '../services/rezervasyon_service.dart';
import '../utils/theme.dart';

class IsletmeRezervasyonScreen extends StatefulWidget {
  const IsletmeRezervasyonScreen({super.key});

  @override
  State<IsletmeRezervasyonScreen> createState() => _IsletmeRezervasyonScreenState();
}

class _IsletmeRezervasyonScreenState extends State<IsletmeRezervasyonScreen>
    with SingleTickerProviderStateMixin {
  final _service = RezervasyonService(ApiClient());
  List<Rezervasyon> _hepsi = [];
  bool _yukleniyor = true;
  late TabController _tabCtrl;

  static const _tabs = ['Bekleyen', 'Onaylı', 'Geçmiş'];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _yukle();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _yukle() async {
    setState(() => _yukleniyor = true);
    final res = await _service.isletmeRezervasyonlari();
    if (mounted) setState(() { _hepsi = res.veri ?? []; _yukleniyor = false; });
  }

  List<Rezervasyon> get _bekleyen => _hepsi.where((r) => r.beklemede).toList();
  List<Rezervasyon> get _onaylandi => _hepsi.where((r) => r.onaylandi).toList();
  List<Rezervasyon> get _gecmis => _hepsi.where((r) => r.iptal || r.tamamlandi).toList();

  Future<void> _onayla(Rezervasyon r) async {
    final res = await _service.onayla(r.id);
    if (mounted) {
      _showSnack(res.mesaj, res.basarili ? AppTheme.primaryGreen : AppTheme.errorRed);
      if (res.basarili) _yukle();
    }
  }

  Future<void> _reddet(Rezervasyon r) async {
    final res = await _service.reddet(r.id);
    if (mounted) {
      _showSnack(res.mesaj, res.basarili ? AppTheme.accentCoral : AppTheme.errorRed);
      if (res.basarili) _yukle();
    }
  }

  void _showSnack(String msg, Color color) {
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
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Rezervasyonlar',
            style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: AppTheme.primaryGreen,
          labelColor: AppTheme.primaryGreen,
          unselectedLabelColor: AppTheme.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: [
            Tab(text: '${_tabs[0]} (${_bekleyen.length})'),
            Tab(text: '${_tabs[1]} (${_onaylandi.length})'),
            Tab(text: _tabs[2]),
          ],
        ),
      ),
      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
          : RefreshIndicator(
              onRefresh: _yukle,
              color: AppTheme.primaryGreen,
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  _buildListe(_bekleyen, showActions: true),
                  _buildListe(_onaylandi),
                  _buildListe(_gecmis),
                ],
              ),
            ),
    );
  }

  Widget _buildListe(List<Rezervasyon> liste, {bool showActions = false}) {
    if (liste.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.event_busy_rounded, size: 56, color: AppTheme.textSecondary.withOpacity(0.3)),
          const SizedBox(height: 12),
          Text('Rezervasyon yok', style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.5))),
        ]),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: liste.length,
      itemBuilder: (_, i) => _buildKart(liste[i], showActions: showActions),
    );
  }

  Widget _buildKart(Rezervasyon r, {bool showActions = false}) {
    final durumRenk = r.onaylandi
        ? AppTheme.primaryGreen
        : r.beklemede
            ? AppTheme.amber
            : AppTheme.textSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: durumRenk.withOpacity(0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(r.sahaAdi ?? 'Saha', style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                if (r.kullaniciAdSoyad != null) ...[
                  const SizedBox(height: 2),
                  Text(r.kullaniciAdSoyad!, style: TextStyle(
                      fontSize: 12, color: AppTheme.textSecondary.withOpacity(0.7))),
                ],
              ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: durumRenk.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(r.durumText, style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700, color: durumRenk)),
            ),
          ]),
          const SizedBox(height: 12),
          _infoRow(Icons.calendar_today_rounded, r.rezervasyonTarihi),
          const SizedBox(height: 6),
          _infoRow(Icons.access_time_rounded, '${r.baslangicSaati} - ${r.bitisSaati}'),
          if (r.toplamUcret != null) ...[
            const SizedBox(height: 6),
            _infoRow(Icons.payments_rounded, '₺${r.toplamUcret!.toStringAsFixed(0)}'),
          ],
          if (r.notlar != null && r.notlar!.isNotEmpty) ...[
            const SizedBox(height: 6),
            _infoRow(Icons.notes_rounded, r.notlar!),
          ],
          if (showActions) ...[
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _reddet(r),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.errorRed.withOpacity(0.5)),
                    foregroundColor: AppTheme.errorRed,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Reddet'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _onayla(r),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Onayla'),
                ),
              ),
            ]),
          ],
        ]),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(children: [
      Icon(icon, size: 14, color: AppTheme.textSecondary.withOpacity(0.6)),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: TextStyle(fontSize: 13, color: AppTheme.textSecondary.withOpacity(0.8)))),
    ]);
  }
}
