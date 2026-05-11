import 'package:flutter/material.dart';
import '../models/mac.dart';
import '../models/saha.dart';
import '../services/api_client.dart';
import '../services/konum_service.dart';
import '../services/mac_service.dart';
import '../services/saha_service.dart';
import '../utils/theme.dart';
import '../widgets/konum_secim_sheet.dart';

class MacOlusturScreen extends StatefulWidget {
  final Saha? onSaha;
  final Mac? mac;
  const MacOlusturScreen({super.key, this.onSaha, this.mac});

  @override
  State<MacOlusturScreen> createState() => _MacOlusturScreenState();
}

class _MacOlusturScreenState extends State<MacOlusturScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiClient = ApiClient();
  late final MacService _macService = MacService(_apiClient);
  late final SahaService _sahaService = SahaService(_apiClient);
  final _konumService = KonumService();

  final _baslikController = TextEditingController();
  final _aciklamaController = TextEditingController();
  final _ucretController = TextEditingController(text: '0');
  final _takimAdiController = TextEditingController();
  final _rakipNotuController = TextEditingController();
  final _eksikSayiController = TextEditingController(text: '1');
  final _ilController = TextEditingController();
  final _ilceController = TextEditingController();

  DateTime _secilenTarih = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _baslangicSaati = const TimeOfDay(hour: 20, minute: 0);
  TimeOfDay _bitisSaati = const TimeOfDay(hour: 21, minute: 0);
  String _format = '6v6';
  int _maxOyuncu = 12;
  String _seviye = 'KARMA';
  String _macTipi = 'NORMAL';
  double? _minDisiplinPuani;
  bool _disiplinFiltresiAktif = false;
  Saha? _secilenSaha;
  List<Saha> _sahalar = [];
  bool _gonderiliyor = false;

  final _formatlar = ['3v3', '4v4', '5v5', '6v6', '7v7', '8v8', '9v9', '10v10', '11v11'];
  final _oyuncuSayilari = {
    '3v3': 6, '4v4': 8, '5v5': 10, '6v6': 12, '7v7': 14,
    '8v8': 16, '9v9': 18, '10v10': 20, '11v11': 22,
  };
  final _seviyeler = [
    ('KARMA', 'Karma'), ('BASLANGIC', 'Başlangıç'), ('ORTA', 'Orta'), ('ILERI', 'İleri'),
  ];
  final _macTipleri = [
    ('NORMAL', 'Normal Maç', Icons.sports_soccer_rounded, 'Bireysel oyuncular katılır'),
    ('RAKIP_ARANIYOR', 'Rakip Aranıyor', Icons.groups_rounded, 'Takımınıza rakip arıyorsunuz'),
    ('EKSIK_OYUNCU', 'Eksik Oyuncu', Icons.person_add_rounded, 'Takımınıza oyuncu arıyorsunuz'),
  ];

  bool get _duzenlemeModu => widget.mac != null;

  @override
  void initState() {
    super.initState();
    _secilenSaha = widget.onSaha;
    if (widget.onSaha != null) {
      _format = widget.onSaha!.sahaFormati;
      _maxOyuncu = _oyuncuSayilari[_format] ?? 12;
    }
    final m = widget.mac;
    if (m != null) {
      _baslikController.text = m.macBasligi;
      _aciklamaController.text = m.aciklama ?? '';
      _ucretController.text = m.ucretPerKisi.toStringAsFixed(0);
      _takimAdiController.text = m.takimAdi ?? '';
      _rakipNotuController.text = m.rakipNotu ?? '';
      _eksikSayiController.text = (m.eksikOyuncuSayisi ?? 1).toString();
      _ilController.text = m.il ?? '';
      _ilceController.text = m.ilce ?? '';
      _format = m.format;
      _maxOyuncu = m.maxOyuncuSayisi;
      _seviye = m.seviye;
      _macTipi = m.macTipi;
      _minDisiplinPuani = m.minDisiplinPuani;
      _disiplinFiltresiAktif = m.minDisiplinPuani != null;
      final parsedDate = DateTime.tryParse(m.macTarihi);
      if (parsedDate != null) _secilenTarih = parsedDate;
      _baslangicSaati = _parseTimeOfDay(m.baslangicSaati, _baslangicSaati);
      _bitisSaati = _parseTimeOfDay(m.bitisSaati, _bitisSaati);
    }
    _sahalariYukle();
  }

  Future<void> _sahalariYukle() async {
    final res = await _sahaService.tumSahalar();
    if (mounted && res.basarili && res.veri != null) {
      setState(() {
        _sahalar = res.veri!;
        if (widget.mac?.sahaId != null) {
          try {
            _secilenSaha = _sahalar.firstWhere((s) => s.id == widget.mac!.sahaId);
          } catch (_) {}
        }
      });
    }
  }

  Future<void> _macOlustur() async {
    if (!_formKey.currentState!.validate()) return;

    if (_ilController.text.isEmpty || _ilceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Lütfen il ve ilçe bilgisini seçin'),
        backgroundColor: AppTheme.errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }

    setState(() => _gonderiliyor = true);

    final data = {
      'macBasligi': _baslikController.text.trim(),
      'sahaId': _secilenSaha?.id,
      'macTarihi': '${_secilenTarih.year}-${_secilenTarih.month.toString().padLeft(2, '0')}-${_secilenTarih.day.toString().padLeft(2, '0')}',
      'baslangicSaati': '${_baslangicSaati.hour.toString().padLeft(2, '0')}:${_baslangicSaati.minute.toString().padLeft(2, '0')}',
      'bitisSaati': '${_bitisSaati.hour.toString().padLeft(2, '0')}:${_bitisSaati.minute.toString().padLeft(2, '0')}',
      'format': _format,
      'maxOyuncuSayisi': _maxOyuncu,
      'aciklama': _aciklamaController.text.trim().isEmpty ? null : _aciklamaController.text.trim(),
      'seviye': _seviye,
      'ucretPerKisi': double.tryParse(_ucretController.text) ?? 0,
      'macTipi': _macTipi,
      'minDisiplinPuani': _disiplinFiltresiAktif ? _minDisiplinPuani : null,
      'eksikOyuncuSayisi': _macTipi == 'EKSIK_OYUNCU' ? (int.tryParse(_eksikSayiController.text) ?? 1) : null,
      'takimAdi': (_macTipi != 'NORMAL' && _takimAdiController.text.trim().isNotEmpty) ? _takimAdiController.text.trim() : null,
      'rakipNotu': (_macTipi == 'RAKIP_ARANIYOR' && _rakipNotuController.text.trim().isNotEmpty) ? _rakipNotuController.text.trim() : null,
      'il': _ilController.text.trim().isEmpty ? null : _ilController.text.trim(),
      'ilce': _ilceController.text.trim().isEmpty ? null : _ilceController.text.trim(),
    };

    final res = _duzenlemeModu
        ? await _macService.macGuncelle(widget.mac!.id, data)
        : await _macService.macOlustur(data);
    if (mounted) {
      setState(() => _gonderiliyor = false);
      if (res.basarili) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_duzenlemeModu ? 'Maç güncellendi!' : 'Maç oluşturuldu!'), backgroundColor: AppTheme.primaryGreen,
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
              _buildHeader(),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                    children: [
                      _buildMacTipiSecimi(),
                      const SizedBox(height: 16),
                      _buildTextField(_baslikController, 'Maç Başlığı', Icons.sports_soccer_rounded,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Başlık gerekli' : null),
                      if (_macTipi != 'NORMAL') ...[
                        const SizedBox(height: 16),
                        _buildTextField(_takimAdiController, 'Takım Adı', Icons.shield_rounded),
                      ],
                      const SizedBox(height: 16),
                      _buildSahaSecimi(),
                      const SizedBox(height: 16),
                      _buildTarihSaat(),
                      const SizedBox(height: 16),
                      _buildFormatSecimi(),
                      const SizedBox(height: 16),
                      _buildSeviyeSecimi(),
                      const SizedBox(height: 16),
                      _buildDisiplinFiltresi(),
                      if (_macTipi == 'EKSIK_OYUNCU') ...[
                        const SizedBox(height: 16),
                        _buildTextField(_eksikSayiController, 'Kaç oyuncu eksik?', Icons.person_add_rounded,
                          keyboardType: TextInputType.number),
                      ],
                      if (_macTipi == 'RAKIP_ARANIYOR') ...[
                        const SizedBox(height: 16),
                        _buildTextField(_rakipNotuController, 'Rakibe not (opsiyonel)', Icons.message_rounded, maxLines: 2),
                      ],
                      const SizedBox(height: 16),
                      _buildKonumSecici(),
                      const SizedBox(height: 16),
                      _buildTextField(_ucretController, 'Kişi Başı Ücret (₺)', Icons.attach_money_rounded, keyboardType: TextInputType.number),
                      const SizedBox(height: 16),
                      _buildTextField(_aciklamaController, 'Açıklama (opsiyonel)', Icons.notes_rounded, maxLines: 3),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 24, 8),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary), onPressed: () => Navigator.pop(context)),
          const SizedBox(width: 8),
          Expanded(child: Text(
            _duzenlemeModu ? 'Maçı Düzenle' : 'Maç Oluştur',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
          )),
        ],
      ),
    );
  }

  Widget _buildMacTipiSecimi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Maç Tipi', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary.withOpacity(0.8))),
        const SizedBox(height: 8),
        ...(_macTipleri.map((t) {
          final isSelected = _macTipi == t.$1;
          return GestureDetector(
            onTap: () => setState(() => _macTipi = t.$1),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: isSelected ? AppTheme.buttonGradient : null,
                color: isSelected ? null : AppTheme.inputFill,
                borderRadius: BorderRadius.circular(14),
                border: isSelected ? null : Border.all(color: AppTheme.primaryGreen.withOpacity(0.08)),
              ),
              child: Row(
                children: [
                  Icon(t.$3, size: 22, color: isSelected ? AppTheme.backgroundDark : AppTheme.textSecondary),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.$2, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                          color: isSelected ? AppTheme.backgroundDark : AppTheme.textPrimary)),
                        Text(t.$4, style: TextStyle(fontSize: 11,
                          color: isSelected ? AppTheme.backgroundDark.withOpacity(0.7) : AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle_rounded, size: 20, color: AppTheme.backgroundDark),
                ],
              ),
            ),
          );
        })),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon,
      {String? Function(String?)? validator, TextInputType? keyboardType, int maxLines = 1}) {
    return TextFormField(
      controller: controller, validator: validator, keyboardType: keyboardType, maxLines: maxLines,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon)),
    );
  }

  Widget _buildSahaSecimi() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.inputFill, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.08)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Saha?>(
          value: _secilenSaha, isExpanded: true, dropdownColor: AppTheme.cardDarkElevated,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.textSecondary),
          hint: Row(children: [
            Icon(Icons.stadium_outlined, color: AppTheme.textSecondary.withOpacity(0.6), size: 22),
            const SizedBox(width: 12),
            const Text('Saha Seçin (opsiyonel)', style: TextStyle(color: AppTheme.textHint, fontSize: 14)),
          ]),
          items: [
            const DropdownMenuItem<Saha?>(value: null, child: Text('Saha seçilmedi', style: TextStyle(color: AppTheme.textSecondary))),
            ..._sahalar.map((s) => DropdownMenuItem(value: s, child: Text(s.sahaAdi, style: const TextStyle(color: AppTheme.textPrimary)))),
          ],
          onChanged: (val) => setState(() { _secilenSaha = val; if (val != null) { _format = val.sahaFormati; _maxOyuncu = _oyuncuSayilari[_format] ?? 12; } }),
        ),
      ),
    );
  }

  Widget _buildTarihSaat() {
    return Row(children: [
      Expanded(child: _buildDatePicker()),
      const SizedBox(width: 10),
      Expanded(child: _buildTimePicker('Başlangıç', _baslangicSaati, (t) => setState(() => _baslangicSaati = t))),
      const SizedBox(width: 10),
      Expanded(child: _buildTimePicker('Bitiş', _bitisSaati, (t) => setState(() => _bitisSaati = t))),
    ]);
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(context: context, initialDate: _secilenTarih,
          firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 90)),
          builder: (ctx, child) => Theme(data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(primary: AppTheme.primaryGreen, surface: AppTheme.cardDark)), child: child!));
        if (picked != null) setState(() => _secilenTarih = picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(color: AppTheme.inputFill, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.08))),
        child: Column(children: [
          Icon(Icons.calendar_today_rounded, size: 18, color: AppTheme.textSecondary.withOpacity(0.6)),
          const SizedBox(height: 4),
          Text('${_secilenTarih.day}/${_secilenTarih.month}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        ]),
      ),
    );
  }

  Widget _buildTimePicker(String label, TimeOfDay time, Function(TimeOfDay) onChanged) {
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(context: context, initialTime: time,
          builder: (ctx, child) => Theme(data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(primary: AppTheme.primaryGreen, surface: AppTheme.cardDark)), child: child!));
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(color: AppTheme.inputFill, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.08))),
        child: Column(children: [
          Text(label, style: TextStyle(fontSize: 10, color: AppTheme.textSecondary.withOpacity(0.6))),
          const SizedBox(height: 4),
          Text('${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        ]),
      ),
    );
  }

  Widget _buildFormatSecimi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Format', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary.withOpacity(0.8))),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: _formatlar.map((f) {
            final isSelected = _format == f;
            return GestureDetector(
              onTap: () => setState(() { _format = f; _maxOyuncu = _oyuncuSayilari[f] ?? 12; }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppTheme.buttonGradient : null,
                  color: isSelected ? null : AppTheme.inputFill,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected ? null : Border.all(color: AppTheme.primaryGreen.withOpacity(0.08)),
                ),
                child: Column(children: [
                  Text(f, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800,
                    color: isSelected ? AppTheme.backgroundDark : AppTheme.textPrimary)),
                  Text('${_oyuncuSayilari[f]} kişi', style: TextStyle(fontSize: 10,
                    color: isSelected ? AppTheme.backgroundDark.withOpacity(0.7) : AppTheme.textSecondary)),
                ]),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSeviyeSecimi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Seviye', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary.withOpacity(0.8))),
        const SizedBox(height: 8),
        Wrap(spacing: 8, children: _seviyeler.map((s) {
          final isSelected = _seviye == s.$1;
          return GestureDetector(
            onTap: () => setState(() => _seviye = s.$1),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: isSelected ? AppTheme.buttonGradient : null,
                color: isSelected ? null : AppTheme.inputFill,
                borderRadius: BorderRadius.circular(12),
                border: isSelected ? null : Border.all(color: AppTheme.primaryGreen.withOpacity(0.08)),
              ),
              child: Text(s.$2, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                color: isSelected ? AppTheme.backgroundDark : AppTheme.textSecondary)),
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
          Row(
            children: [
              Icon(Icons.shield_rounded, size: 20, color: _disiplinFiltresiAktif ? AppTheme.amber : AppTheme.textSecondary),
              const SizedBox(width: 10),
              const Expanded(child: Text('Disiplin Puanı Filtresi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary))),
              Switch(
                value: _disiplinFiltresiAktif,
                onChanged: (v) => setState(() { _disiplinFiltresiAktif = v; if (v && _minDisiplinPuani == null) _minDisiplinPuani = 3.0; }),
                activeColor: AppTheme.amber,
                inactiveThumbColor: AppTheme.textSecondary,
                inactiveTrackColor: AppTheme.cardDark,
              ),
            ],
          ),
          if (_disiplinFiltresiAktif) ...[
            const SizedBox(height: 8),
            Text('Minimum puan: ${_minDisiplinPuani?.toStringAsFixed(1) ?? "3.0"}',
              style: const TextStyle(fontSize: 12, color: AppTheme.amber, fontWeight: FontWeight.w600)),
            Slider(
              value: _minDisiplinPuani ?? 3.0, min: 1.0, max: 5.0, divisions: 8,
              activeColor: AppTheme.amber,
              inactiveColor: AppTheme.cardDark,
              onChanged: (v) => setState(() => _minDisiplinPuani = v),
            ),
            Text('Bu puanın altındaki oyuncular maça katılamaz',
              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary.withOpacity(0.7))),
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
                _ilController.text.isEmpty
                    ? 'İl/İlçe seçin (örn: Sivas / Merkez)'
                    : _ilceController.text.isEmpty
                        ? _ilController.text
                        : '${_ilController.text} / ${_ilceController.text}',
                style: TextStyle(
                  fontSize: 13,
                  color: _ilController.text.isEmpty ? AppTheme.textHint : AppTheme.textPrimary,
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
    final secim = await showKonumSecimSheet(
      context,
      initialUlke: 'Turkiye',
      initialIl: _ilController.text.isEmpty ? null : _ilController.text,
      initialIlce: _ilceController.text.isEmpty ? null : _ilceController.text,
      showCurrentLocationButton: true,
    );
    if (!mounted || secim == null) return;
    if (secim.mevcutKonumSecildi) {
      try {
        final k = await _konumService.mevcutKonumuAl();
        if (!mounted) return;
        setState(() {
          _ilController.text = k.il ?? '';
          _ilceController.text = k.ilce ?? '';
        });
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
      }
      return;
    }
    setState(() {
      _ilController.text = secim.il;
      _ilceController.text = secim.ilce;
    });
  }

  Widget _buildOlusturButon() {
    return GestureDetector(
      onTap: _gonderiliyor ? null : _macOlustur,
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
                _duzenlemeModu ? 'Değişiklikleri Kaydet' : 'Maç Oluştur',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.backgroundDark),
              ),
        ),
      ),
    );
  }

  TimeOfDay _parseTimeOfDay(String value, TimeOfDay fallback) {
    final parts = value.split(':');
    if (parts.length < 2) return fallback;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return fallback;
    return TimeOfDay(hour: hour, minute: minute);
  }

  @override
  void dispose() {
    _baslikController.dispose();
    _aciklamaController.dispose();
    _ucretController.dispose();
    _takimAdiController.dispose();
    _rakipNotuController.dispose();
    _eksikSayiController.dispose();
    _ilController.dispose();
    _ilceController.dispose();
    super.dispose();
  }
}
