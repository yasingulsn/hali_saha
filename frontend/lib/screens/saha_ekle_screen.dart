import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../services/saha_service.dart';
import '../utils/theme.dart';

class SahaEkleScreen extends StatefulWidget {
  const SahaEkleScreen({super.key});

  @override
  State<SahaEkleScreen> createState() => _SahaEkleScreenState();
}

class _SahaEkleScreenState extends State<SahaEkleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sahaAdiCtrl = TextEditingController();
  final _adresCtrl = TextEditingController();
  final _ucretCtrl = TextEditingController();

  late final SahaService _sahaService = SahaService(ApiClient());

  String _secilenFormat = '5v5';
  bool _kapaliMi = false;
  bool _yukleniyor = false;

  final _formatlar = ['5v5', '6v6', '7v7', '8v8', '11v11'];

  final _ozellikler = {
    'DUS': false,
    'OTOPARK': false,
    'KAFETERYA': false,
    'AYDINLATMA': false,
    'TRIBUN': false,
    'SOYUNMA_ODASI': false,
    'WIFI': false,
  };

  static const _ozellikLabels = {
    'DUS': 'Duş',
    'OTOPARK': 'Otopark',
    'KAFETERYA': 'Kafeterya',
    'AYDINLATMA': 'Aydınlatma',
    'TRIBUN': 'Tribün',
    'SOYUNMA_ODASI': 'Soyunma Odası',
    'WIFI': 'Wi-Fi',
  };

  static const _ozellikIkonlar = {
    'DUS': Icons.shower_rounded,
    'OTOPARK': Icons.local_parking_rounded,
    'KAFETERYA': Icons.local_cafe_rounded,
    'AYDINLATMA': Icons.lightbulb_rounded,
    'TRIBUN': Icons.people_rounded,
    'SOYUNMA_ODASI': Icons.checkroom_rounded,
    'WIFI': Icons.wifi_rounded,
  };

  @override
  void dispose() {
    _sahaAdiCtrl.dispose();
    _adresCtrl.dispose();
    _ucretCtrl.dispose();
    super.dispose();
  }

  String get _secilenOzellikler {
    return _ozellikler.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .join(',');
  }

  Future<void> _sahaEkle() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _yukleniyor = true);

    final data = {
      'sahaAdi': _sahaAdiCtrl.text.trim(),
      'adres': _adresCtrl.text.trim(),
      'sahaFormati': _secilenFormat,
      'saatlikUcret': double.tryParse(_ucretCtrl.text.trim()) ?? 0,
      'kapaliMi': _kapaliMi,
      'ozellikler': _secilenOzellikler,
    };

    final res = await _sahaService.sahaEkle(data);

    if (!mounted) return;
    setState(() => _yukleniyor = false);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(res.mesaj),
      backgroundColor: res.basarili ? AppTheme.primaryGreen : AppTheme.errorRed,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));

    if (res.basarili) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saha Ekle', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Temel Bilgiler'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _sahaAdiCtrl,
                label: 'Saha Adı',
                icon: Icons.stadium_rounded,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Saha adı giriniz' : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _adresCtrl,
                label: 'Adres',
                icon: Icons.location_on_rounded,
                maxLines: 2,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Adres giriniz' : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _ucretCtrl,
                label: 'Saatlik Ücret (₺)',
                icon: Icons.attach_money_rounded,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Ücret giriniz';
                  if (double.tryParse(v) == null) return 'Geçerli bir sayı giriniz';
                  return null;
                },
              ),

              const SizedBox(height: 24),
              _buildSectionTitle('Saha Formatı'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _formatlar.map((f) {
                  final selected = _secilenFormat == f;
                  return GestureDetector(
                    onTap: () => setState(() => _secilenFormat = f),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? AppTheme.primaryGreen : AppTheme.cardDark,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected ? AppTheme.primaryGreen : Colors.white.withOpacity(0.08),
                        ),
                      ),
                      child: Text(
                        f,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: selected ? AppTheme.backgroundDark : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),
              _buildSectionTitle('Özellikler'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _ozellikler.keys.map((key) {
                  final selected = _ozellikler[key]!;
                  final icon = _ozellikIkonlar[key]!;
                  final label = _ozellikLabels[key]!;
                  return GestureDetector(
                    onTap: () => setState(() => _ozellikler[key] = !selected),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? AppTheme.accentBlue.withOpacity(0.15) : AppTheme.cardDark,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected ? AppTheme.accentBlue : Colors.white.withOpacity(0.06),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, size: 15, color: selected ? AppTheme.accentBlue : AppTheme.textSecondary),
                          const SizedBox(width: 6),
                          Text(label, style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600,
                            color: selected ? AppTheme.accentBlue : AppTheme.textSecondary,
                          )),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sahamı Kapat', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                        SizedBox(height: 2),
                        Text('Geçici olarak rezervasyona kapat', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                      ],
                    ),
                    Switch(
                      value: _kapaliMi,
                      onChanged: (v) => setState(() => _kapaliMi = v),
                      activeColor: AppTheme.primaryGreen,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: AppTheme.backgroundDark,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: _yukleniyor ? null : _sahaEkle,
                  child: _yukleniyor
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Sahayı Ekle', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textSecondary));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppTheme.textPrimary),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 20),
        filled: true,
        fillColor: AppTheme.cardDark,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.errorRed)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.errorRed)),
      ),
    );
  }
}
