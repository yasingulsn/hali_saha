import 'dart:math' as math;
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

class _MacOlusturScreenState extends State<MacOlusturScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _apiClient = ApiClient();
  late final MacService _macService = MacService(_apiClient);
  late final SahaService _sahaService = SahaService(_apiClient);
  final _konumService = KonumService();

  final _baslikController = TextEditingController();
  final _aciklamaController = TextEditingController();
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
  int _ucret = 0;

  bool _onizlemeAcik = false;

  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;

  final _formatlar = ['3v3', '4v4', '5v5', '6v6', '7v7', '8v8', '9v9', '10v10', '11v11'];
  final _oyuncuSayilari = {
    '3v3': 6, '4v4': 8, '5v5': 10, '6v6': 12, '7v7': 14,
    '8v8': 16, '9v9': 18, '10v10': 20, '11v11': 22,
  };
  final _seviyeler = [
    ('KARMA', 'Karma', Color(0xFFB388FF), Icons.shuffle_rounded),
    ('BASLANGIC', 'Başlangıç', Color(0xFF82B1FF), Icons.trending_up_rounded),
    ('ORTA', 'Orta', Color(0xFF00BFA5), Icons.equalizer_rounded),
    ('ILERI', 'İleri', Color(0xFFFFB74D), Icons.local_fire_department_rounded),
  ];
  final _macTipleri = [
    ('NORMAL', 'Normal Maç', Icons.sports_soccer_rounded, 'Bireysel oyuncular katılır', Color(0xFF00BFA5)),
    ('RAKIP_ARANIYOR', 'Rakip Aranıyor', Icons.groups_rounded, 'Takımınıza rakip arıyorsunuz', Color(0xFFB388FF)),
    ('EKSIK_OYUNCU', 'Eksik Oyuncu', Icons.person_add_rounded, 'Takımınıza oyuncu arıyorsunuz', Color(0xFFFFB74D)),
  ];

  bool get _duzenlemeModu => widget.mac != null;

  String get _seviyeText {
    const m = {
      'KARMA': 'Karma', 'BASLANGIC': 'Başlangıç', 'ORTA': 'Orta', 'ILERI': 'İleri',
    };
    return m[_seviye] ?? _seviye;
  }

  bool get _bolum1Tamam => _baslikController.text.trim().isNotEmpty;
  bool get _bolum2Tamam => _ilController.text.isNotEmpty;
  bool get _bolum3Tamam => true;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();

    _baslikController.addListener(() => setState(() {}));
    _ilController.addListener(() => setState(() {}));

    _secilenSaha = widget.onSaha;
    if (widget.onSaha != null) {
      _format = widget.onSaha!.sahaFormati;
      _maxOyuncu = _oyuncuSayilari[_format] ?? 12;
    }
    final m = widget.mac;
    if (m != null) {
      _baslikController.text = m.macBasligi;
      _aciklamaController.text = m.aciklama ?? '';
      _ucret = m.ucretPerKisi.toInt();
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

  @override
  void dispose() {
    _animController.dispose();
    _baslikController.dispose();
    _aciklamaController.dispose();
    _takimAdiController.dispose();
    _rakipNotuController.dispose();
    _eksikSayiController.dispose();
    _ilController.dispose();
    _ilceController.dispose();
    super.dispose();
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
      'ucretPerKisi': _ucret.toDouble(),
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
          content: Text(_duzenlemeModu ? 'Maç güncellendi!' : 'Maç oluşturuldu!'),
          backgroundColor: AppTheme.primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(res.mesaj),
          backgroundColor: AppTheme.errorRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                      children: [
                        _buildLivePreviewCard(),
                        const SizedBox(height: 20),
                        _buildMacTipiSecimi(),
                        const SizedBox(height: 20),
                        _buildSection(
                          icon: Icons.sports_soccer_rounded,
                          iconColor: AppTheme.primaryGreen,
                          title: 'Maç Bilgileri',
                          isDone: _bolum1Tamam,
                          children: [
                            _buildTextField(
                              _baslikController, 'Maç Başlığı', Icons.title_rounded,
                              validator: (v) => v == null || v.trim().isEmpty ? 'Başlık gerekli' : null,
                            ),
                            if (_macTipi != 'NORMAL') ...[
                              const SizedBox(height: 12),
                              _buildTextField(_takimAdiController, 'Takım Adı', Icons.shield_rounded),
                            ],
                            if (_macTipi == 'EKSIK_OYUNCU') ...[
                              const SizedBox(height: 12),
                              _buildExsikOyuncuStepper(),
                            ],
                            if (_macTipi == 'RAKIP_ARANIYOR') ...[
                              const SizedBox(height: 12),
                              _buildTextField(_rakipNotuController, 'Rakibe not (opsiyonel)',
                                Icons.message_rounded, maxLines: 2),
                            ],
                            const SizedBox(height: 12),
                            _buildTextField(_aciklamaController, 'Açıklama (opsiyonel)',
                              Icons.notes_rounded, maxLines: 3),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildSection(
                          icon: Icons.stadium_outlined,
                          iconColor: AppTheme.accentBlue,
                          title: 'Saha & Konum',
                          isDone: _bolum2Tamam,
                          children: [
                            _buildSahaSecimi(),
                            const SizedBox(height: 12),
                            _buildKonumSecici(),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildSection(
                          icon: Icons.event_rounded,
                          iconColor: AppTheme.accentOrange,
                          title: 'Tarih & Saat',
                          isDone: _bolum3Tamam,
                          children: [_buildTarihSaat()],
                        ),
                        const SizedBox(height: 16),
                        _buildFormatSecimi(),
                        const SizedBox(height: 16),
                        _buildSeviyeSecimi(),
                        const SizedBox(height: 16),
                        _buildSection(
                          icon: Icons.payments_rounded,
                          iconColor: AppTheme.fieldGreen,
                          title: 'Kişi Başı Ücret',
                          isDone: true,
                          children: [_buildUcretStepper()],
                        ),
                        const SizedBox(height: 16),
                        _buildDisiplinFiltresi(),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
              _buildStickyBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────
  // HEADER
  // ──────────────────────────────────────
  Widget _buildHeader() {
    return Stack(
      children: [
        // subtle field-line decoration
        Positioned.fill(
          child: ClipRect(
            child: CustomPaint(painter: _FieldLinePainter()),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 14, 16, 14),
          child: Row(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.cardDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.07)),
                    ),
                    child: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary, size: 20),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
                      child: Text(
                        _duzenlemeModu ? 'Maçı Düzenle' : 'Maç Oluştur',
                        style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w900,
                          color: Colors.white, letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    Text(
                      _duzenlemeModu ? 'Maç bilgilerini güncelleyin' : 'Yeni bir maç düzenleyin',
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary.withOpacity(0.65)),
                    ),
                  ],
                ),
              ),
              // completion progress ring
              _buildProgressRing(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressRing() {
    final tamamlanan = [_bolum1Tamam, _bolum2Tamam, _bolum3Tamam].where((b) => b).length;
    final oran = tamamlanan / 3.0;
    final color = oran == 1.0 ? AppTheme.primaryGreen : (oran > 0.5 ? AppTheme.accentOrange : AppTheme.textSecondary);

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 34,
            height: 34,
            child: CircularProgressIndicator(
              value: oran,
              strokeWidth: 3,
              backgroundColor: AppTheme.cardDarkElevated,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              strokeCap: StrokeCap.round,
            ),
          ),
          Text(
            '$tamamlanan/3',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────
  // LIVE PREVIEW CARD
  // ──────────────────────────────────────
  Widget _buildLivePreviewCard() {
    final baslik = _baslikController.text.trim().isEmpty ? 'Maç başlığı...' : _baslikController.text.trim();
    final macTipi = _macTipleri.firstWhere((t) => t.$1 == _macTipi);
    final seviyeColor = (_seviyeler.firstWhere((s) => s.$1 == _seviye)).$3;

    return GestureDetector(
      onTap: () => setState(() => _onizlemeAcik = !_onizlemeAcik),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.18)),
          boxShadow: [
            BoxShadow(color: AppTheme.primaryGreen.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            // header row
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.preview_rounded, size: 14, color: AppTheme.primaryGreen),
                  ),
                  const SizedBox(width: 10),
                  const Text('Canlı Önizleme',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primaryGreen)),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _onizlemeAcik ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            // collapsed preview chips
            if (!_onizlemeAcik)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: Row(
                  children: [
                    _previewChip(_format, AppTheme.accentPurple),
                    const SizedBox(width: 6),
                    _previewChip(_seviyeText, seviyeColor),
                    const SizedBox(width: 6),
                    _previewChip(macTipi.$2.split(' ').first, macTipi.$5),
                    const Spacer(),
                    Text(
                      '${_baslangicSaati.hour.toString().padLeft(2, '0')}:${_baslangicSaati.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textSecondary.withOpacity(0.6)),
                    ),
                  ],
                ),
              ),
            // expanded preview — full card
            if (_onizlemeAcik)
              Container(
                margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundDark,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _previewChip(_format, AppTheme.accentPurple),
                        const SizedBox(width: 6),
                        _previewChip(_seviyeText, seviyeColor),
                        if (_macTipi != 'NORMAL') ...[
                          const SizedBox(width: 6),
                          _previewChip(macTipi.$2, macTipi.$5),
                        ],
                        const Spacer(),
                        Text(
                          '${_baslangicSaati.hour.toString().padLeft(2, '0')}:${_baslangicSaati.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary.withOpacity(0.6)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      baslik,
                      style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700,
                        color: _baslikController.text.trim().isEmpty ? AppTheme.textHint : AppTheme.textPrimary,
                      ),
                    ),
                    if (_secilenSaha != null || _ilController.text.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(children: [
                        Icon(Icons.location_on_outlined, size: 13, color: AppTheme.textSecondary.withOpacity(0.5)),
                        const SizedBox(width: 4),
                        Text(
                          _secilenSaha?.sahaAdi ?? '${_ilController.text} / ${_ilceController.text}',
                          style: TextStyle(fontSize: 11, color: AppTheme.textSecondary.withOpacity(0.55)),
                        ),
                      ]),
                    ],
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: 0,
                            minHeight: 5,
                            backgroundColor: AppTheme.cardDark,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (_ucret > 0)
                        Text('₺$_ucret',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primaryGreen)),
                      if (_ucret > 0) const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: AppTheme.buttonGradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Katıl', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.backgroundDark)),
                      ),
                    ]),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _previewChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }

  // ──────────────────────────────────────
  // SECTION CARD
  // ──────────────────────────────────────
  Widget _buildSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required bool isDone,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDone ? iconColor.withOpacity(0.2) : Colors.white.withOpacity(0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 15, color: iconColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isDone
                    ? Container(
                        key: const ValueKey('done'),
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_rounded, size: 10, color: AppTheme.backgroundDark),
                      )
                    : Container(
                        key: const ValueKey('pending'),
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.textSecondary.withOpacity(0.25)),
                        ),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  // ──────────────────────────────────────
  // MAÇ TİPİ
  // ──────────────────────────────────────
  Widget _buildMacTipiSecimi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text('Maç Tipi',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
              color: AppTheme.textSecondary.withOpacity(0.8), letterSpacing: 0.3)),
        ),
        Row(
          children: List.generate(_macTipleri.length, (i) {
            final t = _macTipleri[i];
            final isSelected = _macTipi == t.$1;
            final color = t.$5;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _macTipi = t.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(right: i < _macTipleri.length - 1 ? 8 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected ? color.withOpacity(0.13) : AppTheme.cardDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? color.withOpacity(0.5) : Colors.white.withOpacity(0.06),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected ? color.withOpacity(0.2) : AppTheme.inputFill,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(t.$3, size: 20, color: isSelected ? color : AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t.$2.split(' ').first,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                          color: isSelected ? color : AppTheme.textSecondary),
                      ),
                      if (t.$2.split(' ').length > 1)
                        Text(
                          t.$2.split(' ').skip(1).join(' '),
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                            color: isSelected ? color.withOpacity(0.7) : AppTheme.textSecondary.withOpacity(0.5)),
                        ),
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 20,
                        height: 3,
                        decoration: BoxDecoration(
                          color: isSelected ? color : Colors.transparent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ──────────────────────────────────────
  // TEXT FIELD
  // ──────────────────────────────────────
  Widget _buildTextField(
    TextEditingController controller, String hint, IconData icon, {
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon)),
    );
  }

  // ──────────────────────────────────────
  // SAHA SEÇİMİ
  // ──────────────────────────────────────
  Widget _buildSahaSecimi() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.inputFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Saha?>(
          value: _secilenSaha,
          isExpanded: true,
          dropdownColor: AppTheme.cardDarkElevated,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.textSecondary),
          hint: Row(children: [
            Icon(Icons.stadium_outlined, color: AppTheme.textSecondary.withOpacity(0.5), size: 20),
            const SizedBox(width: 12),
            const Text('Saha seçilmedi', style: TextStyle(color: AppTheme.textHint, fontSize: 14)),
          ]),
          items: [
            const DropdownMenuItem<Saha?>(value: null,
              child: Text('Saha seçilmedi', style: TextStyle(color: AppTheme.textSecondary))),
            ..._sahalar.map((s) => DropdownMenuItem(value: s,
              child: Text(s.sahaAdi, style: const TextStyle(color: AppTheme.textPrimary)))),
          ],
          onChanged: (val) => setState(() {
            _secilenSaha = val;
            if (val != null) { _format = val.sahaFormati; _maxOyuncu = _oyuncuSayilari[_format] ?? 12; }
          }),
        ),
      ),
    );
  }

  // ──────────────────────────────────────
  // TARİH & SAAT
  // ──────────────────────────────────────
  Widget _buildTarihSaat() {
    return Row(children: [
      Expanded(child: _buildDatePicker()),
      const SizedBox(width: 8),
      Expanded(child: _buildTimePicker('Başlangıç', _baslangicSaati, (t) => setState(() => _baslangicSaati = t))),
      const SizedBox(width: 8),
      Expanded(child: _buildTimePicker('Bitiş', _bitisSaati, (t) => setState(() => _bitisSaati = t))),
    ]);
  }

  Widget _buildDatePicker() {
    final months = ['', 'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];
    final dayNames = ['Paz', 'Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt'];
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _secilenTarih,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 90)),
          builder: (ctx, child) => Theme(
            data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryGreen, surface: AppTheme.cardDark)),
            child: child!,
          ),
        );
        if (picked != null) setState(() => _secilenTarih = picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.inputFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.accentOrange.withOpacity(0.25)),
        ),
        child: Column(children: [
          Icon(Icons.calendar_today_rounded, size: 15, color: AppTheme.accentOrange.withOpacity(0.9)),
          const SizedBox(height: 5),
          Text('${_secilenTarih.day} ${months[_secilenTarih.month]}',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
          Text(dayNames[_secilenTarih.weekday % 7],
            style: TextStyle(fontSize: 10, color: AppTheme.accentOrange.withOpacity(0.7), fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  Widget _buildTimePicker(String label, TimeOfDay time, Function(TimeOfDay) onChanged) {
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
          builder: (ctx, child) => Theme(
            data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryGreen, surface: AppTheme.cardDark)),
            child: child!,
          ),
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.inputFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.accentOrange.withOpacity(0.25)),
        ),
        child: Column(children: [
          Text(label,
            style: TextStyle(fontSize: 10, color: AppTheme.textSecondary.withOpacity(0.55), fontWeight: FontWeight.w600)),
          const SizedBox(height: 5),
          Text('${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
          Text('saat', style: TextStyle(fontSize: 10, color: AppTheme.accentOrange.withOpacity(0.7), fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  // ──────────────────────────────────────
  // FORMAT SEÇİMİ
  // ──────────────────────────────────────
  Widget _buildFormatSecimi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppTheme.accentPurple.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.grid_view_rounded, size: 14, color: AppTheme.accentPurple),
              ),
              const SizedBox(width: 10),
              const Text('Format', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              const SizedBox(width: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Container(
                  key: ValueKey(_format),
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accentPurple.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('$_format · $_maxOyuncu kişi',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.accentPurple)),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.cardDark,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: Column(
            children: [
              // top row: 3v3 to 7v7
              Row(
                children: _formatlar.take(5).map((f) => _formatChip(f)).toList(),
              ),
              const SizedBox(height: 8),
              // bottom row: 8v8 to 11v11
              Row(
                children: _formatlar.skip(5).map((f) => _formatChip(f)).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _formatChip(String f) {
    final isSelected = _format == f;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() { _format = f; _maxOyuncu = _oyuncuSayilari[f] ?? 12; }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected ? const LinearGradient(
              colors: [Color(0xFFB388FF), Color(0xFF7C4DFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ) : null,
            color: isSelected ? null : AppTheme.inputFill,
            borderRadius: BorderRadius.circular(10),
            border: isSelected ? null : Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(children: [
            Text(f, style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w800,
              color: isSelected ? Colors.white : AppTheme.textPrimary,
            )),
            Text('${_oyuncuSayilari[f]}', style: TextStyle(
              fontSize: 9,
              color: isSelected ? Colors.white.withOpacity(0.7) : AppTheme.textSecondary,
            )),
          ]),
        ),
      ),
    );
  }

  // ──────────────────────────────────────
  // SEVİYE SEÇİMİ
  // ──────────────────────────────────────
  Widget _buildSeviyeSecimi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppTheme.accentOrange.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.leaderboard_rounded, size: 14, color: AppTheme.accentOrange),
              ),
              const SizedBox(width: 10),
              const Text('Seviye', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            ],
          ),
        ),
        Row(
          children: List.generate(_seviyeler.length, (i) {
            final s = _seviyeler[i];
            final isSelected = _seviye == s.$1;
            final color = s.$3;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _seviye = s.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: EdgeInsets.only(right: i < _seviyeler.length - 1 ? 8 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected ? color.withOpacity(0.13) : AppTheme.cardDark,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? color.withOpacity(0.45) : Colors.white.withOpacity(0.06),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: EdgeInsets.all(isSelected ? 8 : 6),
                      decoration: BoxDecoration(
                        color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(s.$4, size: 18, color: isSelected ? color : AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 5),
                    Text(s.$2, style: TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w700,
                      color: isSelected ? color : AppTheme.textSecondary,
                    )),
                  ]),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ──────────────────────────────────────
  // ÜCRET STEPPER
  // ──────────────────────────────────────
  Widget _buildUcretStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.inputFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          _stepperButton(
            icon: Icons.remove_rounded,
            onTap: () => setState(() { if (_ucret >= 10) _ucret -= 10; }),
            enabled: _ucret > 0,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  _ucret == 0 ? 'Ücretsiz' : '₺$_ucret',
                  style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w900,
                    color: _ucret == 0 ? AppTheme.textSecondary : AppTheme.fieldGreen,
                  ),
                ),
                Text(
                  'kişi başı',
                  style: TextStyle(fontSize: 11, color: AppTheme.textSecondary.withOpacity(0.5)),
                ),
              ],
            ),
          ),
          _stepperButton(
            icon: Icons.add_rounded,
            onTap: () => setState(() => _ucret += 10),
            enabled: true,
          ),
        ],
      ),
    );
  }

  Widget _stepperButton({required IconData icon, required VoidCallback onTap, required bool enabled}) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: enabled ? AppTheme.cardDarkElevated : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 22, color: enabled ? AppTheme.textPrimary : AppTheme.textSecondary.withOpacity(0.3)),
      ),
    );
  }

  // ──────────────────────────────────────
  // EKSİK OYUNCU STEPPER
  // ──────────────────────────────────────
  Widget _buildExsikOyuncuStepper() {
    final eksik = int.tryParse(_eksikSayiController.text) ?? 1;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.inputFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          _stepperButton(
            icon: Icons.remove_rounded,
            onTap: () => setState(() { if (eksik > 1) _eksikSayiController.text = '${eksik - 1}'; }),
            enabled: eksik > 1,
          ),
          Expanded(
            child: Column(
              children: [
                Text('$eksik', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.accentOrange)),
                Text('oyuncu eksik', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary.withOpacity(0.5))),
              ],
            ),
          ),
          _stepperButton(
            icon: Icons.add_rounded,
            onTap: () => setState(() { _eksikSayiController.text = '${eksik + 1}'; }),
            enabled: true,
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────
  // DİSİPLİN FİLTRESİ
  // ──────────────────────────────────────
  Widget _buildDisiplinFiltresi() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _disiplinFiltresiAktif ? AppTheme.amber.withOpacity(0.3) : Colors.white.withOpacity(0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: (_disiplinFiltresiAktif ? AppTheme.amber : AppTheme.textSecondary).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.shield_rounded, size: 15,
                  color: _disiplinFiltresiAktif ? AppTheme.amber : AppTheme.textSecondary),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Disiplin Puanı Filtresi',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                    Text('Düşük puanlı oyuncuları engelle',
                      style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              Switch(
                value: _disiplinFiltresiAktif,
                onChanged: (v) => setState(() {
                  _disiplinFiltresiAktif = v;
                  if (v && _minDisiplinPuani == null) _minDisiplinPuani = 3.0;
                }),
                activeColor: AppTheme.amber,
                inactiveThumbColor: AppTheme.textSecondary,
                inactiveTrackColor: AppTheme.cardDarkElevated,
              ),
            ],
          ),
          if (_disiplinFiltresiAktif) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.amber.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Row(children: List.generate(5, (i) {
                    final filled = i < (_minDisiplinPuani ?? 3.0).round();
                    return Icon(Icons.star_rounded, size: 16,
                      color: filled ? AppTheme.amber : AppTheme.cardDarkElevated);
                  })),
                  const SizedBox(width: 8),
                  Text('${_minDisiplinPuani?.toStringAsFixed(1)} min puan',
                    style: const TextStyle(fontSize: 12, color: AppTheme.amber, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Text('altı katılamaz',
                    style: TextStyle(fontSize: 11, color: AppTheme.textSecondary.withOpacity(0.6))),
                ],
              ),
            ),
            Slider(
              value: _minDisiplinPuani ?? 3.0, min: 1.0, max: 5.0, divisions: 8,
              activeColor: AppTheme.amber,
              inactiveColor: AppTheme.cardDarkElevated,
              onChanged: (v) => setState(() => _minDisiplinPuani = v),
            ),
          ],
        ],
      ),
    );
  }

  // ──────────────────────────────────────
  // KONUM
  // ──────────────────────────────────────
  Widget _buildKonumSecici() {
    final hasKonum = _ilController.text.isNotEmpty;
    return GestureDetector(
      onTap: _konumSec,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.inputFill,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: hasKonum ? AppTheme.accentBlue.withOpacity(0.3) : Colors.white.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.accentBlue.withOpacity(hasKonum ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.location_on_rounded, size: 15,
                color: hasKonum ? AppTheme.accentBlue : AppTheme.textSecondary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hasKonum
                    ? (_ilceController.text.isEmpty ? _ilController.text : '${_ilController.text} / ${_ilceController.text}')
                    : 'İl / İlçe seçin',
                style: TextStyle(
                  fontSize: 14,
                  color: hasKonum ? AppTheme.textPrimary : AppTheme.textHint,
                  fontWeight: hasKonum ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded, size: 18,
              color: AppTheme.textSecondary.withOpacity(0.6)),
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
        setState(() { _ilController.text = k.il ?? ''; _ilceController.text = k.ilce ?? ''; });
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
      }
      return;
    }
    setState(() { _ilController.text = secim.il; _ilceController.text = secim.ilce; });
  }

  // ──────────────────────────────────────
  // STICKY BOTTOM BAR
  // ──────────────────────────────────────
  Widget _buildStickyBottomBar() {
    final allDone = _bolum1Tamam && _bolum2Tamam;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundDark,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!allDone)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline_rounded, size: 13,
                    color: AppTheme.textSecondary.withOpacity(0.5)),
                  const SizedBox(width: 5),
                  Text(
                    !_bolum1Tamam ? 'Maç başlığı gerekli' : 'Konum seçimi gerekli',
                    style: TextStyle(fontSize: 11, color: AppTheme.textSecondary.withOpacity(0.5)),
                  ),
                ],
              ),
            ),
          GestureDetector(
            onTap: _gonderiliyor ? null : _macOlustur,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                gradient: _gonderiliyor ? null : AppTheme.buttonGradient,
                color: _gonderiliyor ? AppTheme.textSecondary.withOpacity(0.15) : null,
                borderRadius: BorderRadius.circular(18),
                boxShadow: _gonderiliyor ? null : [
                  BoxShadow(color: AppTheme.primaryGreen.withOpacity(0.30), blurRadius: 20, offset: const Offset(0, 6)),
                  BoxShadow(color: AppTheme.primaryGreen.withOpacity(0.12), blurRadius: 40, offset: const Offset(0, 14)),
                ],
              ),
              child: Center(
                child: _gonderiliyor
                    ? const SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.textPrimary))
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.sports_soccer_rounded, size: 19, color: AppTheme.backgroundDark),
                          const SizedBox(width: 10),
                          Text(
                            _duzenlemeModu ? 'Değişiklikleri Kaydet' : 'Maç Oluştur',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                              color: AppTheme.backgroundDark, letterSpacing: 0.3),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
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
}

// ──────────────────────────────────────
// BACKGROUND FIELD LINES PAINTER
// ──────────────────────────────────────
class _FieldLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00BFA5).withOpacity(0.035)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // center circle arc (top half)
    final center = Offset(size.width * 0.85, size.height * 0.5);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: size.height * 0.9),
      math.pi * 0.6,
      math.pi * 0.8,
      false,
      paint,
    );
    // inner circle
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: size.height * 0.45),
      math.pi * 0.5,
      math.pi * 0.9,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
