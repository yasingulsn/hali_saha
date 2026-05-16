import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_client.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';

class KullaniciProfilScreen extends StatefulWidget {
  final String kullaniciId;
  final String? adSoyad;
  const KullaniciProfilScreen({super.key, required this.kullaniciId, this.adSoyad});

  @override
  State<KullaniciProfilScreen> createState() => _KullaniciProfilScreenState();
}

class _KullaniciProfilScreenState extends State<KullaniciProfilScreen> {
  final _apiClient = ApiClient();
  Map<String, dynamic>? _profil;
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<void> _yukle() async {
    try {
      final res = await _apiClient.dio.get('${ApiConstants.profil.replaceAll('/profil', '')}/kullanici/${widget.kullaniciId}');
      if (mounted && res.data['basarili'] == true) {
        setState(() { _profil = res.data['veri']; _yukleniyor = false; });
      }
    } catch (_) {
      if (mounted) setState(() => _yukleniyor = false);
    }
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
        title: Text(widget.adSoyad ?? 'Profil',
            style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
        actions: [
          if (context.read<AuthProvider>().kullaniciTipi == 'KULLANICI')
            IconButton(
              icon: const Icon(Icons.flag_rounded, color: AppTheme.accentCoral, size: 20),
              tooltip: 'Şikayet Et',
              onPressed: () => _sikayetDialog(),
            ),
        ],
      ),
      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
          : _profil == null
              ? const Center(child: Text('Profil yüklenemedi', style: TextStyle(color: AppTheme.textSecondary)))
              : _buildProfil(),
    );
  }

  Widget _buildProfil() {
    final p = _profil!;
    final disiplin = (p['disiplinPuani'] as num?)?.toDouble() ?? 5.0;
    final disiplinRenk = disiplin >= 4.0
        ? AppTheme.primaryGreen
        : disiplin >= 3.0
            ? AppTheme.lightOrange
            : AppTheme.errorRed;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        // Avatar
        Container(
          width: 88, height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppTheme.primaryGradient,
            border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3), width: 3),
          ),
          child: p['profilFotoUrl'] != null
              ? ClipOval(child: Image.network(p['profilFotoUrl'], fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _avatarIcon(p)))
              : _avatarIcon(p),
        ),
        const SizedBox(height: 16),
        Text(p['adSoyad'] ?? '',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
        if (p['il'] != null) ...[
          const SizedBox(height: 4),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.location_on_rounded, size: 14, color: AppTheme.textSecondary),
            const SizedBox(width: 4),
            Text('${p['il']}${p['ilce'] != null ? ' / ${p['ilce']}' : ''}',
                style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          ]),
        ],
        const SizedBox(height: 24),

        // İstatistik satırı
        Row(children: [
          _statKart('Disiplin', disiplin.toStringAsFixed(1), disiplinRenk, Icons.shield_rounded),
          const SizedBox(width: 12),
          _statKart('Toplam Maç', '${p['toplamMacSayisi'] ?? 0}', AppTheme.accentBlue, Icons.sports_soccer_rounded),
          const SizedBox(width: 12),
          _statKart('Değerlendirme', '${p['yorumSayisi'] ?? 0}', AppTheme.accentPurple, Icons.star_rounded),
        ]),
        const SizedBox(height: 20),

        // Detay kartı
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.cardDark,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Oyuncu Bilgileri', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 16),
            if (p['tercihEdilenPozisyon'] != null)
              _bilgiSatiri(Icons.sports_soccer_rounded, 'Pozisyon', _pozisyonText(p['tercihEdilenPozisyon'])),
            _bilgiSatiri(Icons.verified_user_rounded, 'Disiplin Puanı',
                '${disiplin.toStringAsFixed(2)} / 5.00', renk: disiplinRenk),
            if (p['kayitTarihi'] != null)
              _bilgiSatiri(Icons.calendar_today_rounded, 'Üyelik',
                  _tarihFormatla(p['kayitTarihi'])),
          ]),
        ),
      ]),
    );
  }

  Widget _avatarIcon(Map p) {
    final ad = (p['adSoyad'] as String? ?? '?')[0].toUpperCase();
    return Center(child: Text(ad, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white)));
  }

  Widget _statKart(String baslik, String deger, Color renk, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: renk.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: renk.withOpacity(0.15)),
        ),
        child: Column(children: [
          Icon(icon, color: renk, size: 22),
          const SizedBox(height: 8),
          Text(deger, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: renk)),
          const SizedBox(height: 4),
          Text(baslik, style: TextStyle(fontSize: 10, color: AppTheme.textSecondary.withOpacity(0.7))),
        ]),
      ),
    );
  }

  Widget _bilgiSatiri(IconData icon, String etiket, String deger, {Color? renk}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(color: AppTheme.surfaceDark, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 16, color: renk ?? AppTheme.textSecondary),
        ),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(etiket, style: TextStyle(fontSize: 11, color: AppTheme.textSecondary.withOpacity(0.6))),
          Text(deger, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
              color: renk ?? AppTheme.textPrimary)),
        ]),
      ]),
    );
  }

  String _pozisyonText(String p) {
    const map = {'KALECI': 'Kaleci', 'DEFANS': 'Defans', 'ORTA_SAHA': 'Orta Saha', 'FORVET': 'Forvet'};
    return map[p] ?? p;
  }

  void _sikayetDialog() {
    String? seciliKategori;
    final aciklamaCtrl = TextEditingController();
    bool yukleniyor = false;

    const kategoriler = {
      'GELMEME': 'Maça gelmedi',
      'KAVGA': 'Kavga / saldırgan davranış',
      'KURAL_IHLALI': 'Kural ihlali',
      'DIGER': 'Diğer',
    };

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: AppTheme.cardDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(children: [
            Icon(Icons.flag_rounded, color: AppTheme.accentCoral, size: 20),
            SizedBox(width: 10),
            Text('Şikayet Et', style: TextStyle(color: AppTheme.textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
          ]),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            ...kategoriler.entries.map((e) => RadioListTile<String>(
              value: e.key,
              groupValue: seciliKategori,
              onChanged: (v) => setS(() => seciliKategori = v),
              title: Text(e.value, style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary)),
              activeColor: AppTheme.accentCoral,
              dense: true,
              contentPadding: EdgeInsets.zero,
            )),
            const SizedBox(height: 8),
            TextField(
              controller: aciklamaCtrl,
              maxLines: 2,
              maxLength: 300,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Açıklama (isteğe bağlı)',
                hintStyle: TextStyle(color: AppTheme.textSecondary.withOpacity(0.5), fontSize: 12),
                filled: true,
                fillColor: AppTheme.backgroundDark,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
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
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentCoral, foregroundColor: Colors.white),
              onPressed: (yukleniyor || seciliKategori == null) ? null : () async {
                setS(() => yukleniyor = true);
                try {
                  await _apiClient.dio.post('/api/sikayetler', data: {
                    'sikayetEdilenId': widget.kullaniciId,
                    'kategori': seciliKategori,
                    if (aciklamaCtrl.text.trim().isNotEmpty) 'aciklama': aciklamaCtrl.text.trim(),
                  });
                  if (!ctx.mounted) return;
                  Navigator.pop(ctx);
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Şikayetiniz alındı'),
                    backgroundColor: AppTheme.primaryGreen,
                    behavior: SnackBarBehavior.floating,
                  ));
                } catch (_) {
                  setS(() => yukleniyor = false);
                }
              },
              child: yukleniyor
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Gönder'),
            ),
          ],
        ),
      ),
    ).then((_) => aciklamaCtrl.dispose());
  }

  String _tarihFormatla(String tarih) {
    try {
      final d = DateTime.parse(tarih);
      return '${d.day}.${d.month}.${d.year}';
    } catch (_) {
      return tarih;
    }
  }
}
