import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/mac.dart';
import '../models/rezervasyon.dart';
import '../providers/auth_provider.dart';
import '../services/api_client.dart';
import '../services/mac_service.dart';
import '../services/rezervasyon_service.dart';
import '../utils/theme.dart';
import 'mac_detay_screen.dart';

class TakvimScreen extends StatefulWidget {
  const TakvimScreen({super.key});

  @override
  State<TakvimScreen> createState() => _TakvimScreenState();
}

class _TakvimScreenState extends State<TakvimScreen> {
  final _apiClient = ApiClient();
  late final MacService _macService = MacService(_apiClient);
  late final RezervasyonService _rezervasyonService = RezervasyonService(_apiClient);

  List<Mac> _maclar = [];
  List<Rezervasyon> _rezervasyonlar = [];
  bool _yukleniyor = true;
  DateTime _seciliAy = DateTime.now();
  DateTime? _seciliGun;

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<void> _yukle() async {
    setState(() => _yukleniyor = true);
    final auth = context.read<AuthProvider>();
    final macRes = await _macService.benimMaclarim();
    if (auth.kullaniciTipi == 'KULLANICI') {
      final rezRes = await _rezervasyonService.benimRezervasyonlarim();
      if (mounted) {
        setState(() {
          _maclar = macRes.veri ?? [];
          _rezervasyonlar = rezRes.veri ?? [];
          _yukleniyor = false;
        });
      }
    } else {
      if (mounted) setState(() { _maclar = macRes.veri ?? []; _yukleniyor = false; });
    }
  }

  Set<String> get _macTarihleri => _maclar.map((m) => m.macTarihi).toSet();
  Set<String> get _rezervasyonTarihleri => _rezervasyonlar.map((r) => r.rezervasyonTarihi).toSet();

  List<Mac> _gunMaclari(DateTime gun) {
    final tarih = '${gun.year}-${gun.month.toString().padLeft(2, '0')}-${gun.day.toString().padLeft(2, '0')}';
    return _maclar.where((m) => m.macTarihi == tarih).toList();
  }

  List<Rezervasyon> _gunRezervasyonlari(DateTime gun) {
    final tarih = '${gun.year}-${gun.month.toString().padLeft(2, '0')}-${gun.day.toString().padLeft(2, '0')}';
    return _rezervasyonlar.where((r) => r.rezervasyonTarihi == tarih).toList();
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
        title: const Text('Takvim', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
      ),
      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
          : Column(children: [
              _buildAyNavigasyon(),
              _buildTakvim(),
              const Divider(color: Colors.white12, height: 1),
              Expanded(child: _buildSecilenGunDetay()),
            ]),
    );
  }

  Widget _buildAyNavigasyon() {
    final ayIsim = _ayIsmi(_seciliAy.month);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(children: [
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded, color: AppTheme.textPrimary),
          onPressed: () => setState(() => _seciliAy = DateTime(_seciliAy.year, _seciliAy.month - 1, 1)),
        ),
        Expanded(
          child: Text('$ayIsim ${_seciliAy.year}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right_rounded, color: AppTheme.textPrimary),
          onPressed: () => setState(() => _seciliAy = DateTime(_seciliAy.year, _seciliAy.month + 1, 1)),
        ),
      ]),
    );
  }

  Widget _buildTakvim() {
    final ilkGun = DateTime(_seciliAy.year, _seciliAy.month, 1);
    final sonGun = DateTime(_seciliAy.year, _seciliAy.month + 1, 0);
    final basOfseti = (ilkGun.weekday - 1) % 7;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(children: [
        Row(children: ['Pt', 'Sa', 'Ça', 'Pe', 'Cu', 'Ct', 'Pz']
            .map((g) => Expanded(child: Center(child: Text(g,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary.withOpacity(0.6))))))
            .toList()),
        const SizedBox(height: 6),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 1),
          itemCount: basOfseti + sonGun.day,
          itemBuilder: (_, i) {
            if (i < basOfseti) return const SizedBox.shrink();
            final gun = DateTime(_seciliAy.year, _seciliAy.month, i - basOfseti + 1);
            return _buildGunHucresi(gun);
          },
        ),
      ]),
    );
  }

  Widget _buildGunHucresi(DateTime gun) {
    final tarih = '${gun.year}-${gun.month.toString().padLeft(2, '0')}-${gun.day.toString().padLeft(2, '0')}';
    final bugunTarih = DateTime.now();
    final bugun = gun.day == bugunTarih.day && gun.month == bugunTarih.month && gun.year == bugunTarih.year;
    final secili = _seciliGun != null && gun.day == _seciliGun!.day &&
        gun.month == _seciliGun!.month && gun.year == _seciliGun!.year;
    final macVar = _macTarihleri.contains(tarih);
    final rezervVar = _rezervasyonTarihleri.contains(tarih);

    return GestureDetector(
      onTap: () => setState(() => _seciliGun = gun),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: secili ? AppTheme.primaryGreen : (bugun ? AppTheme.primaryGreen.withOpacity(0.15) : Colors.transparent),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('${gun.day}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: secili || bugun ? FontWeight.w800 : FontWeight.w500,
                color: secili ? AppTheme.backgroundDark : AppTheme.textPrimary,
              )),
          if (macVar || rezervVar)
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              if (macVar) Container(width: 4, height: 4, margin: const EdgeInsets.only(right: 2),
                  decoration: BoxDecoration(color: secili ? AppTheme.backgroundDark : AppTheme.primaryGreen, shape: BoxShape.circle)),
              if (rezervVar) Container(width: 4, height: 4,
                  decoration: BoxDecoration(color: secili ? AppTheme.backgroundDark : AppTheme.accentPurple, shape: BoxShape.circle)),
            ]),
        ]),
      ),
    );
  }

  Widget _buildSecilenGunDetay() {
    if (_seciliGun == null) {
      return Center(child: Text('Bir gün seçin', style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.5))));
    }
    final maclar = _gunMaclari(_seciliGun!);
    final rezervler = _gunRezervasyonlari(_seciliGun!);

    if (maclar.isEmpty && rezervler.isEmpty) {
      return Center(child: Text('Bu gün etkinlik yok', style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.5))));
    }

    return ListView(padding: const EdgeInsets.all(16), children: [
      if (maclar.isNotEmpty) ...[
        const Text('Maçlar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primaryGreen)),
        const SizedBox(height: 8),
        ...maclar.map((m) => ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          tileColor: AppTheme.cardDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          leading: const Icon(Icons.sports_soccer_rounded, color: AppTheme.primaryGreen),
          title: Text(m.macBasligi, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          subtitle: Text('${m.baslangicSaati} - ${m.bitisSaati}', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary.withOpacity(0.7))),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MacDetayScreen(macId: m.id))),
        )),
      ],
      if (rezervler.isNotEmpty) ...[
        const SizedBox(height: 12),
        const Text('Rezervasyonlar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.accentPurple)),
        const SizedBox(height: 8),
        ...rezervler.map((r) => ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          tileColor: AppTheme.cardDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          leading: const Icon(Icons.calendar_today_rounded, color: AppTheme.accentPurple),
          title: Text(r.sahaAdi ?? 'Saha', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          subtitle: Text('${r.baslangicSaati} - ${r.bitisSaati}  •  ${r.durumText}',
              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary.withOpacity(0.7))),
        )),
      ],
    ]);
  }

  String _ayIsmi(int ay) {
    const aylar = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
        'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];
    return aylar[ay - 1];
  }
}
