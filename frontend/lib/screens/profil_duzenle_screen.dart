import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/token_response.dart';
import '../providers/auth_provider.dart';
import '../services/profil_service.dart';
import '../utils/theme.dart';

class ProfilDuzenleScreen extends StatefulWidget {
  final KullaniciBilgi? profilDetay;

  const ProfilDuzenleScreen({super.key, this.profilDetay});

  @override
  State<ProfilDuzenleScreen> createState() => _ProfilDuzenleScreenState();
}

class _ProfilDuzenleScreenState extends State<ProfilDuzenleScreen> {
  final ProfilService _profilService = ProfilService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _adSoyadCtrl;
  late TextEditingController _telefonCtrl;
  late TextEditingController _dogumTarihiCtrl;
  String? _secilenPozisyon;
  bool _isLoading = false;
  File? _secilenFoto;
  String? _mevcutFotoUrl;

  static const _pozisyonlar = [
    {'value': 'KALECI', 'label': 'Kaleci', 'icon': Icons.sports_handball_rounded},
    {'value': 'DEFANS', 'label': 'Defans', 'icon': Icons.shield_rounded},
    {'value': 'ORTASAHA', 'label': 'Orta Saha', 'icon': Icons.swap_horiz_rounded},
    {'value': 'FORVET', 'label': 'Forvet', 'icon': Icons.sports_soccer_rounded},
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.profilDetay;
    _adSoyadCtrl = TextEditingController(text: p?.adSoyad ?? '');
    _telefonCtrl = TextEditingController(text: p?.telefon ?? '');
    _dogumTarihiCtrl = TextEditingController(text: p?.dogumTarihi ?? '');
    _secilenPozisyon = p?.tercihEdilenPozisyon;
    _mevcutFotoUrl = p?.profilFotoUrl;
  }

  @override
  void dispose() {
    _adSoyadCtrl.dispose();
    _telefonCtrl.dispose();
    _dogumTarihiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Profili Düzenle',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppTheme.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Profil Fotoğrafı ───────────────────────────────
              Center(
                child: GestureDetector(
                  onTap: _fotoSecDialog,
                  child: Stack(alignment: Alignment.bottomRight, children: [
                    Container(
                      width: 88, height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.primaryGradient,
                        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.4), width: 3),
                      ),
                      child: _secilenFoto != null
                          ? ClipOval(child: Image.file(_secilenFoto!, fit: BoxFit.cover))
                          : _mevcutFotoUrl != null
                              ? ClipOval(child: Image.network(_mevcutFotoUrl!, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _avatarHarf()))
                              : _avatarHarf(),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.backgroundDark, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt_rounded, size: 14, color: AppTheme.backgroundDark),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 8),
              Center(child: Text('Fotoğrafı değiştir',
                  style: TextStyle(fontSize: 12, color: AppTheme.primaryGreen.withOpacity(0.8)))),
              const SizedBox(height: 24),

              // ── Ad Soyad ───────────────────────────────────────
              _buildSectionTitle('Ad Soyad'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _adSoyadCtrl,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                decoration: _inputDecoration(
                  hint: 'Ad Soyad',
                  icon: Icons.person_rounded,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Ad soyad boş olamaz';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // ── Telefon ────────────────────────────────────────
              _buildSectionTitle('Telefon'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _telefonCtrl,
                keyboardType: TextInputType.phone,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                decoration: _inputDecoration(
                  hint: '05XX XXX XX XX',
                  icon: Icons.phone_rounded,
                ),
              ),
              const SizedBox(height: 24),

              // ── Tercih Edilen Pozisyon ─────────────────────────
              _buildSectionTitle('Tercih Edilen Pozisyon'),
              const SizedBox(height: 12),
              _buildPozisyonSecimi(),
              const SizedBox(height: 24),

              // ── Doğum Tarihi ───────────────────────────────────
              _buildSectionTitle('Doğum Tarihi'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _selectDate,
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _dogumTarihiCtrl,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: _inputDecoration(
                      hint: 'Tarih seçin',
                      icon: Icons.cake_rounded,
                      suffix: Icons.calendar_today_rounded,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // ── Kaydet Butonu ──────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 56,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryGreen.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _kaydet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_rounded,
                                  color: Colors.white, size: 22),
                              SizedBox(width: 10),
                              Text(
                                'Değişiklikleri Kaydet',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── POZİSYON SEÇİMİ ─────────────────────────────────────────

  Widget _buildPozisyonSecimi() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _pozisyonlar.map((p) {
        final isSelected = _secilenPozisyon == p['value'];
        return GestureDetector(
          onTap: () {
            setState(() {
              _secilenPozisyon =
                  _secilenPozisyon == p['value'] ? null : p['value'] as String;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryGreen.withOpacity(0.12)
                  : AppTheme.inputFill,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primaryGreen.withOpacity(0.5)
                    : Colors.white.withOpacity(0.06),
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryGreen.withOpacity(0.08),
                        blurRadius: 10,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  p['icon'] as IconData,
                  size: 20,
                  color: isSelected
                      ? AppTheme.primaryGreen
                      : AppTheme.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  p['label'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? AppTheme.primaryGreen
                        : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── TARİH SEÇİCİ ────────────────────────────────────────────

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _parseDate(_dogumTarihiCtrl.text) ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryGreen,
              onPrimary: Colors.white,
              surface: AppTheme.cardDark,
              onSurface: AppTheme.textPrimary,
            ),
            dialogBackgroundColor: AppTheme.surfaceDark,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dogumTarihiCtrl.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  DateTime? _parseDate(String text) {
    try {
      return DateTime.parse(text);
    } catch (_) {
      return null;
    }
  }

  // ─── KAYDET ───────────────────────────────────────────────────

  Widget _avatarHarf() {
    final ad = widget.profilDetay?.adSoyad ?? '?';
    return Center(child: Text(ad[0].toUpperCase(),
        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white)));
  }

  void _fotoSecDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.photo_library_rounded, color: AppTheme.primaryGreen),
            title: const Text('Galeriden Seç', style: TextStyle(color: AppTheme.textPrimary)),
            onTap: () async {
              Navigator.pop(context);
              final picker = ImagePicker();
              final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512, imageQuality: 80);
              if (picked != null && mounted) setState(() => _secilenFoto = File(picked.path));
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt_rounded, color: AppTheme.accentBlue),
            title: const Text('Kameradan Çek', style: TextStyle(color: AppTheme.textPrimary)),
            onTap: () async {
              Navigator.pop(context);
              final picker = ImagePicker();
              final picked = await picker.pickImage(source: ImageSource.camera, maxWidth: 512, maxHeight: 512, imageQuality: 80);
              if (picked != null && mounted) setState(() => _secilenFoto = File(picked.path));
            },
          ),
          if (_mevcutFotoUrl != null || _secilenFoto != null)
            ListTile(
              leading: const Icon(Icons.delete_rounded, color: AppTheme.errorRed),
              title: const Text('Fotoğrafı Kaldır', style: TextStyle(color: AppTheme.errorRed)),
              onTap: () {
                Navigator.pop(context);
                setState(() { _secilenFoto = null; _mevcutFotoUrl = null; });
              },
            ),
        ]),
      ),
    );
  }

  Future<void> _kaydet() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final response = await _profilService.profilGuncelle(
      adSoyad: _adSoyadCtrl.text.trim(),
      telefon: _telefonCtrl.text.trim().isEmpty ? null : _telefonCtrl.text.trim(),
      tercihEdilenPozisyon: _secilenPozisyon,
      dogumTarihi: _dogumTarihiCtrl.text.trim().isEmpty
          ? null
          : _dogumTarihiCtrl.text.trim(),
      il: widget.profilDetay?.il,
      ilce: widget.profilDetay?.ilce,
      profilFotoUrl: _mevcutFotoUrl,
    );

    if (mounted) {
      setState(() => _isLoading = false);

      if (response.basarili && response.veri != null) {
        // AuthProvider'ı güncelle (hem state hem local storage)
        context.read<AuthProvider>().updateCurrentUser(response.veri!);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded,
                    color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text('Profil başarıyla güncellendi!',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            backgroundColor: AppTheme.primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
        // true döndürerek önceki sayfanın yenilenmesini sağla
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(response.mesaj,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            backgroundColor: AppTheme.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  // ─── YARDIMCI ─────────────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppTheme.textSecondary.withOpacity(0.7),
        letterSpacing: 0.5,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    IconData? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20),
      suffixIcon: suffix != null
          ? Icon(suffix, size: 18, color: AppTheme.textSecondary)
          : null,
    );
  }
}
