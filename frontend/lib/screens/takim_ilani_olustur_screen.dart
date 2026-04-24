import 'package:flutter/material.dart';
import '../models/takim_ilani.dart';
import '../services/api_client.dart';
import '../services/konum_service.dart';
import '../services/takim_ilani_service.dart';
import '../utils/theme.dart';
import '../widgets/konum_secim_sheet.dart';

class TakimIlaniOlusturScreen extends StatefulWidget {
  final TakimIlani? ilan;

  const TakimIlaniOlusturScreen({super.key, this.ilan});

  @override
  State<TakimIlaniOlusturScreen> createState() => _TakimIlaniOlusturScreenState();
}

class _TakimIlaniOlusturScreenState extends State<TakimIlaniOlusturScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = TakimIlaniService(ApiClient());
  final _konumService = KonumService();

  final _takimAdiController = TextEditingController();
  final _baslikController = TextEditingController();
  final _aciklamaController = TextEditingController();
  final _konumController = TextEditingController();

  String _pozisyon = 'FARKETMEZ';
  int _arananSayisi = 1;
  String _seviye = 'KARMA';
  bool _disiplinFiltresiAktif = false;
  double _minDisiplinPuani = 3.0;
  bool _gonderiliyor = false;

  final _pozisyonlar = [
    ('FARKETMEZ', 'Farketmez', Icons.sports_rounded),
    ('KALECI', 'Kaleci', Icons.sports_handball_rounded),
    ('DEFANS', 'Defans', Icons.shield_rounded),
    ('ORTASAHA', 'Orta Saha', Icons.swap_horiz_rounded),
    ('FORVET', 'Forvet', Icons.sports_soccer_rounded),
  ];
  final _seviyeler = [
    ('KARMA', 'Karma'), ('BASLANGIC', 'Başlangıç'), ('ORTA', 'Orta'), ('ILERI', 'İleri'),
  ];

  bool get _duzenlemeModu => widget.ilan != null;

  @override
  void initState() {
    super.initState();
    final ilan = widget.ilan;
    if (ilan != null) {
      _takimAdiController.text = ilan.takimAdi;
      _baslikController.text = ilan.ilanBasligi;
      _aciklamaController.text = ilan.aciklama ?? '';
      _konumController.text = ilan.konum ?? '';
      _pozisyon = ilan.arananPozisyon;
      _arananSayisi = ilan.arananOyuncuSayisi;
      _seviye = ilan.seviye;
      if (ilan.minDisiplinPuani != null) {
        _disiplinFiltresiAktif = true;
        _minDisiplinPuani = ilan.minDisiplinPuani!;
      }
    }
  }

  Future<void> _olustur() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _gonderiliyor = true);

    final data = {
      'takimAdi': _takimAdiController.text.trim(),
      'ilanBasligi': _baslikController.text.trim(),
      'aciklama': _aciklamaController.text.trim().isEmpty ? null : _aciklamaController.text.trim(),
      'arananPozisyon': _pozisyon,
      'arananOyuncuSayisi': _arananSayisi,
      'minDisiplinPuani': _disiplinFiltresiAktif ? _minDisiplinPuani : null,
      'seviye': _seviye,
      'konum': _konumController.text.trim().isEmpty ? null : _konumController.text.trim(),
    };

    final res = _duzenlemeModu
        ? await _service.ilanGuncelle(widget.ilan!.id, data)
        : await _service.ilanOlustur(data);
    if (mounted) {
      setState(() => _gonderiliyor = false);
      if (res.basarili) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_duzenlemeModu ? 'İlan güncellendi!' : 'İlan oluşturuldu!'), backgroundColor: AppTheme.primaryGreen,
          behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(res.mesaj), backgroundColor: AppTheme.errorRed,
          behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
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
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 24, 8),
                child: Row(children: [
                  IconButton(icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary), onPressed: () => Navigator.pop(context)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(
                    _duzenlemeModu ? 'İlanı Düzenle' : 'Takıma Kalıcı Oyuncu İlanı',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                  )),
                ]),
              ),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                    children: [
                      _buildInfoBanner(),
                      const SizedBox(height: 16),
                      _buildField(_takimAdiController, 'Takım Adınız', Icons.shield_rounded,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Takım adı gerekli' : null),
                      const SizedBox(height: 16),
                      _buildField(_baslikController, 'İlan Başlığı', Icons.title_rounded,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Başlık gerekli' : null),
                      const SizedBox(height: 16),
                      _buildPozisyonSecimi(),
                      const SizedBox(height: 16),
                      _buildOyuncuSayisi(),
                      const SizedBox(height: 16),
                      _buildSeviyeSecimi(),
                      const SizedBox(height: 16),
                      _buildDisiplinFiltresi(),
                      const SizedBox(height: 16),
                      _buildKonumSecici(),
                      const SizedBox(height: 16),
                      _buildField(_aciklamaController, 'Açıklama (opsiyonel)', Icons.notes_rounded, maxLines: 3),
                      const SizedBox(height: 32),
                      _buildOlusturButon(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppTheme.primaryGreen.withOpacity(0.12), AppTheme.accentPurple.withOpacity(0.08)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.2)),
      ),
      child: Row(children: [
        const Icon(Icons.info_outline_rounded, color: AppTheme.primaryGreen, size: 24),
        const SizedBox(width: 12),
        Expanded(child: Text(
          _duzenlemeModu
              ? 'İlanınızı güncelleyip tekrar yayınlayabilirsiniz. Değişiklikler ilan kartlarına anında yansır.'
              : 'Bu ekran takımınız için kalıcı oyuncu bulmak içindir. Tek maçlık eksik oyuncu arıyorsanız "Maç Oluştur" akışında "Eksik Oyuncu" tipini kullanın.',
          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary.withOpacity(0.9), height: 1.4),
        )),
      ]),
    );
  }

  Widget _buildField(TextEditingController c, String hint, IconData icon,
      {String? Function(String?)? validator, int maxLines = 1}) {
    return TextFormField(
      controller: c, validator: validator, maxLines: maxLines,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon)),
    );
  }

  Widget _buildPozisyonSecimi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Aranan Pozisyon', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary.withOpacity(0.8))),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: _pozisyonlar.map((p) {
          final sel = _pozisyon == p.$1;
          return GestureDetector(
            onTap: () => setState(() => _pozisyon = p.$1),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: sel ? AppTheme.buttonGradient : null,
                color: sel ? null : AppTheme.inputFill,
                borderRadius: BorderRadius.circular(12),
                border: sel ? null : Border.all(color: AppTheme.primaryGreen.withOpacity(0.08)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(p.$3, size: 16, color: sel ? AppTheme.backgroundDark : AppTheme.textSecondary),
                const SizedBox(width: 6),
                Text(p.$2, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                  color: sel ? AppTheme.backgroundDark : AppTheme.textSecondary)),
              ]),
            ),
          );
        }).toList()),
      ],
    );
  }

  Widget _buildOyuncuSayisi() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.inputFill, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.08))),
      child: Row(children: [
        const Icon(Icons.people_rounded, size: 20, color: AppTheme.textSecondary),
        const SizedBox(width: 12),
        const Expanded(child: Text('Aranan Oyuncu Sayısı', style: TextStyle(fontSize: 14, color: AppTheme.textPrimary))),
        Container(
          decoration: BoxDecoration(color: AppTheme.cardDark, borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            IconButton(icon: const Icon(Icons.remove_rounded, size: 18, color: AppTheme.textSecondary),
              onPressed: _arananSayisi > 1 ? () => setState(() => _arananSayisi--) : null),
            Text('$_arananSayisi', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.primaryGreen)),
            IconButton(icon: const Icon(Icons.add_rounded, size: 18, color: AppTheme.textSecondary),
              onPressed: _arananSayisi < 11 ? () => setState(() => _arananSayisi++) : null),
          ]),
        ),
      ]),
    );
  }

  Widget _buildSeviyeSecimi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Seviye', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary.withOpacity(0.8))),
        const SizedBox(height: 8),
        Wrap(spacing: 8, children: _seviyeler.map((s) {
          final sel = _seviye == s.$1;
          return GestureDetector(
            onTap: () => setState(() => _seviye = s.$1),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: sel ? AppTheme.buttonGradient : null,
                color: sel ? null : AppTheme.inputFill,
                borderRadius: BorderRadius.circular(12),
                border: sel ? null : Border.all(color: AppTheme.primaryGreen.withOpacity(0.08)),
              ),
              child: Text(s.$2, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                color: sel ? AppTheme.backgroundDark : AppTheme.textSecondary)),
            ),
          );
        }).toList()),
      ],
    );
  }

  Widget _buildDisiplinFiltresi() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.inputFill, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _disiplinFiltresiAktif ? AppTheme.amber.withOpacity(0.3) : Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.shield_rounded, size: 20, color: _disiplinFiltresiAktif ? AppTheme.amber : AppTheme.textSecondary),
            const SizedBox(width: 10),
            const Expanded(child: Text('Disiplin Puanı Filtresi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary))),
            Switch(value: _disiplinFiltresiAktif,
              onChanged: (v) => setState(() => _disiplinFiltresiAktif = v),
              activeColor: AppTheme.amber, inactiveThumbColor: AppTheme.textSecondary, inactiveTrackColor: AppTheme.cardDark),
          ]),
          if (_disiplinFiltresiAktif) ...[
            const SizedBox(height: 8),
            Text('Minimum puan: ${_minDisiplinPuani.toStringAsFixed(1)}',
              style: const TextStyle(fontSize: 12, color: AppTheme.amber, fontWeight: FontWeight.w600)),
            Slider(value: _minDisiplinPuani, min: 1.0, max: 5.0, divisions: 8,
              activeColor: AppTheme.amber, inactiveColor: AppTheme.cardDark,
              onChanged: (v) => setState(() => _minDisiplinPuani = v)),
          ],
        ],
      ),
    );
  }

  Widget _buildKonumSecici() {
    return GestureDetector(
      onTap: _konumSec,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.inputFill,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Icon(Icons.location_on_rounded, color: AppTheme.textSecondary.withOpacity(0.7)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _konumController.text.isEmpty ? 'İl/İlçe seçin (örn: Sivas / Merkez)' : _konumController.text,
                style: TextStyle(
                  fontSize: 13,
                  color: _konumController.text.isEmpty ? AppTheme.textHint : AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.textSecondary.withOpacity(0.8)),
          ],
        ),
      ),
    );
  }

  Future<void> _konumSec() async {
    final ilText = _konumController.text.contains('/') ? _konumController.text.split('/').first.trim() : _konumController.text.trim();
    final ilceText = _konumController.text.contains('/') ? _konumController.text.split('/').last.trim() : '';
    final secim = await showKonumSecimSheet(
      context,
      initialUlke: 'Turkiye',
      initialIl: ilText.isEmpty ? null : ilText,
      initialIlce: ilceText.isEmpty ? null : ilceText,
      showCurrentLocationButton: true,
    );
    if (!mounted || secim == null) return;
    if (secim.mevcutKonumSecildi) {
      try {
        final k = await _konumService.mevcutKonumuAl();
        if (!mounted) return;
        setState(() {
          final ilText = (k.il ?? '').trim();
          final ilceText = (k.ilce ?? '').trim();
          _konumController.text = ilceText.isEmpty ? ilText : '$ilText / $ilceText';
        });
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
      }
      return;
    }
    setState(() => _konumController.text = secim.ilce.isEmpty ? secim.il : '${secim.il} / ${secim.ilce}');
  }

  Widget _buildOlusturButon() {
    return GestureDetector(
      onTap: _gonderiliyor ? null : _olustur,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: _gonderiliyor ? null : AppTheme.buttonGradient,
          color: _gonderiliyor ? AppTheme.textSecondary.withOpacity(0.2) : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _gonderiliyor ? null : [BoxShadow(color: AppTheme.primaryGreen.withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Center(
          child: _gonderiliyor
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.textPrimary))
            : Text(
                _duzenlemeModu ? 'Değişiklikleri Kaydet' : 'İlan Yayınla',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.backgroundDark),
              ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _takimAdiController.dispose();
    _baslikController.dispose();
    _aciklamaController.dispose();
    _konumController.dispose();
    super.dispose();
  }
}
