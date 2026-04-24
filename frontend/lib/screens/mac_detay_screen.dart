import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/mac.dart';
import '../providers/auth_provider.dart';
import '../services/api_client.dart';
import '../services/mac_service.dart';
import '../utils/theme.dart';

class MacDetayScreen extends StatefulWidget {
  final String macId;
  const MacDetayScreen({super.key, required this.macId});

  @override
  State<MacDetayScreen> createState() => _MacDetayScreenState();
}

class _MacDetayScreenState extends State<MacDetayScreen> {
  final MacService _macService = MacService(ApiClient());
  Mac? _mac;
  bool _yukleniyor = true;
  bool _islemYapiliyor = false;

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<void> _yukle() async {
    final res = await _macService.macDetay(widget.macId);
    if (mounted) {
      setState(() {
        _yukleniyor = false;
        if (res.basarili) _mac = res.veri;
      });
    }
  }

  Future<void> _katil() async {
    setState(() => _islemYapiliyor = true);
    final res = await _macService.macaKatil(widget.macId);
    if (mounted) {
      setState(() => _islemYapiliyor = false);
      if (res.basarili && res.veri != null) {
        setState(() => _mac = res.veri);
        _showSnackbar('Maça katıldınız!', AppTheme.primaryGreen);
      } else {
        _showSnackbar(res.mesaj, AppTheme.errorRed);
      }
    }
  }

  Future<void> _ayril() async {
    setState(() => _islemYapiliyor = true);
    final res = await _macService.mactanAyril(widget.macId);
    if (mounted) {
      setState(() => _islemYapiliyor = false);
      if (res.basarili && res.veri != null) {
        setState(() => _mac = res.veri);
        _showSnackbar('Maçtan ayrıldınız', AppTheme.accentCoral);
      } else {
        _showSnackbar(res.mesaj, AppTheme.errorRed);
      }
    }
  }

  void _showSnackbar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthProvider>().currentUser?.id;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: _yukleniyor
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
            : _mac == null
                ? const Center(child: Text('Maç bulunamadı', style: TextStyle(color: AppTheme.textSecondary)))
                : SafeArea(
                    child: Column(
                      children: [
                        _buildHeader(),
                        Expanded(
                          child: ListView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                            children: [
                              _buildBilgiKart(),
                              if (_mac!.macTipi != 'NORMAL') ...[
                                const SizedBox(height: 14),
                                _buildMacTipiBanner(),
                              ],
                              const SizedBox(height: 14),
                              _buildDetaylar(),
                              if (_mac!.minDisiplinPuani != null) ...[
                                const SizedBox(height: 14),
                                _buildDisiplinBanner(),
                              ],
                              const SizedBox(height: 14),
                              _buildOyuncuDurumu(),
                              if (_mac!.katilimcilar != null && _mac!.katilimcilar!.isNotEmpty) ...[
                                const SizedBox(height: 18),
                                _buildKatilimcilar(),
                              ],
                              if (_mac!.aciklama != null && _mac!.aciklama!.isNotEmpty) ...[
                                const SizedBox(height: 14),
                                _buildAciklama(),
                              ],
                              const SizedBox(height: 24),
                              _buildAksiyon(userId),
                            ],
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
      padding: const EdgeInsets.fromLTRB(8, 8, 24, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text('Maç Detayı',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _mac!.acikMi ? AppTheme.primaryGreen.withOpacity(0.12) : AppTheme.textSecondary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(_mac!.macDurumu,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                color: _mac!.acikMi ? AppTheme.primaryGreen : AppTheme.textSecondary)),
          ),
        ],
      ),
    );
  }

  Widget _buildBilgiKart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(spacing: 8, runSpacing: 8, children: [
            _buildBadge(_mac!.format, AppTheme.primaryGreen, large: true),
            _buildBadge(_mac!.seviyeText, AppTheme.accentPurple),
            if (_mac!.macTipi != 'NORMAL')
              _buildBadge(_mac!.macTipiText, AppTheme.accentBlue),
          ]),
          const SizedBox(height: 16),
          Text(_mac!.macBasligi,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
          const SizedBox(height: 6),
          if (_mac!.olusturanAdi != null)
            Row(children: [
              Icon(Icons.person_outline_rounded, size: 16, color: AppTheme.textSecondary.withOpacity(0.6)),
              const SizedBox(width: 6),
              Text('Organizatör: ${_mac!.olusturanAdi}',
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary.withOpacity(0.7))),
            ]),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color, {bool large = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: large ? 12 : 10, vertical: large ? 6 : 4),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(
        fontSize: large ? 14 : 12,
        fontWeight: large ? FontWeight.w800 : FontWeight.w700,
        color: color)),
    );
  }

  Widget _buildDetaylar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: Column(children: [
        _buildDetayRow(Icons.calendar_today_rounded, 'Tarih:', _mac!.macTarihi),
        const SizedBox(height: 12),
        _buildDetayRow(Icons.access_time_rounded, 'Saat:', '${_mac!.baslangicSaati} - ${_mac!.bitisSaati}'),
        if (_mac!.sahaAdi != null) ...[
          const SizedBox(height: 12),
          _buildDetayRow(Icons.stadium_rounded, 'Saha:', _mac!.sahaAdi!),
        ],
        if (_mac!.ucretPerKisi > 0) ...[
          const SizedBox(height: 12),
          _buildDetayRow(Icons.payments_rounded, 'Kişi Başı:', '₺${_mac!.ucretPerKisi.toStringAsFixed(0)}'),
        ],
      ]),
    );
  }

  Widget _buildDetayRow(IconData icon, String label, String value) {
    return Row(children: [
      Container(
        width: 32, height: 32,
        decoration: BoxDecoration(color: AppTheme.primaryGreen.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 16, color: AppTheme.primaryGreen.withOpacity(0.7)),
      ),
      const SizedBox(width: 12),
      Text(label, style: TextStyle(fontSize: 13, color: AppTheme.textSecondary.withOpacity(0.6))),
      const Spacer(),
      Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
    ]);
  }

  Widget _buildOyuncuDurumu() {
    if (_mac!.eksikOyuncuMu && _mac!.eksikOyuncuSayisi != null) {
      final mevcutEklenen = _mac!.mevcutOyuncuSayisi - 1;
      final aranan = _mac!.eksikOyuncuSayisi!;
      final kalanEksik = aranan - mevcutEklenen;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardDark, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF42A5F5).withOpacity(0.1)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.person_search_rounded, size: 20, color: const Color(0xFF42A5F5)),
            const SizedBox(width: 10),
            const Text('Eksik Oyuncu Durumu', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: kalanEksik > 0 ? const Color(0xFF42A5F5).withOpacity(0.12) : AppTheme.primaryGreen.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8)),
              child: Text(kalanEksik > 0 ? '$kalanEksik kişi aranıyor' : 'Tamamlandı',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                  color: kalanEksik > 0 ? const Color(0xFF42A5F5) : AppTheme.primaryGreen)),
            ),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            _buildStatBox('Aranan', '$aranan', const Color(0xFF42A5F5)),
            const SizedBox(width: 10),
            _buildStatBox('Katılan', '$mevcutEklenen', AppTheme.primaryGreen),
            const SizedBox(width: 10),
            _buildStatBox('Kalan', '${kalanEksik > 0 ? kalanEksik : 0}', AppTheme.accentCoral),
          ]),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: aranan > 0 ? (mevcutEklenen / aranan).clamp(0.0, 1.0) : 0,
              minHeight: 6,
              backgroundColor: AppTheme.backgroundDark,
              valueColor: AlwaysStoppedAnimation<Color>(
                kalanEksik <= 0 ? AppTheme.primaryGreen : const Color(0xFF42A5F5)),
            ),
          ),
        ]),
      );
    }

    final oran = _mac!.maxOyuncuSayisi > 0 ? _mac!.mevcutOyuncuSayisi / _mac!.maxOyuncuSayisi : 0.0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('Doluluk', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const Spacer(),
          Text('${_mac!.mevcutOyuncuSayisi}/${_mac!.maxOyuncuSayisi}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.primaryGreen)),
        ]),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: oran, minHeight: 8,
            backgroundColor: AppTheme.backgroundDark,
            valueColor: AlwaysStoppedAnimation<Color>(_mac!.doluMu ? AppTheme.accentCoral : AppTheme.primaryGreen),
          ),
        ),
      ]),
    );
  }

  Widget _buildStatBox(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
        child: Column(children: [
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: AppTheme.textSecondary.withOpacity(0.6))),
        ]),
      ),
    );
  }

  Widget _buildKatilimcilar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Text('Katılımcılar', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const Spacer(),
          Text('${_mac!.katilimcilar!.length} kişi', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary.withOpacity(0.6))),
        ]),
        const SizedBox(height: 12),
        ...(_mac!.katilimcilar!.map((k) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.cardDark, borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.03)),
          ),
          child: Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(shape: BoxShape.circle, gradient: AppTheme.glassGradient),
              child: const Icon(Icons.person_rounded, color: AppTheme.primaryGreen, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(k.adSoyad, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
            ),
            if (k.disiplinPuani != null)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: AppTheme.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.shield_rounded, size: 10, color: AppTheme.amber),
                  const SizedBox(width: 3),
                  Text(k.disiplinPuani!.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.amber)),
                ]),
              ),
            Container(
              width: 8, height: 8,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: k.katilimDurumu == 'ONAYLANDI' ? AppTheme.neonGreen : AppTheme.amber),
            ),
          ]),
        ))),
      ],
    );
  }

  Widget _buildMacTipiBanner() {
    final isEksik = _mac!.eksikOyuncuMu;
    final color = const Color(0xFF42A5F5);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withOpacity(0.08), color.withOpacity(0.02)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.12)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(isEksik ? Icons.person_add_rounded : Icons.groups_rounded, size: 22, color: color),
          const SizedBox(width: 10),
          Text(_mac!.macTipiText, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color)),
        ]),
        if (_mac!.takimAdi != null && _mac!.takimAdi!.isNotEmpty) ...[
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.shield_rounded, size: 16, color: AppTheme.textSecondary),
            const SizedBox(width: 6),
            Text('Takım: ${_mac!.takimAdi}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          ]),
        ],
        if (isEksik && _mac!.eksikOyuncuSayisi != null) ...[
          const SizedBox(height: 8),
          Text('${_mac!.eksikOyuncuSayisi} oyuncu aranıyor',
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary.withOpacity(0.8))),
        ],
        if (_mac!.rakipNotu != null && _mac!.rakipNotu!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('Not: ${_mac!.rakipNotu}', style: TextStyle(fontSize: 13,
            color: AppTheme.textSecondary.withOpacity(0.7), fontStyle: FontStyle.italic)),
        ],
      ]),
    );
  }

  Widget _buildDisiplinBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.amber.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.amber.withOpacity(0.12)),
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: AppTheme.amber.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.shield_rounded, size: 20, color: AppTheme.amber),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Disiplin Puanı Gereksinimi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.amber)),
          const SizedBox(height: 2),
          Text('Minimum ${_mac!.minDisiplinPuani!.toStringAsFixed(1)} puan gerekli',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary.withOpacity(0.7))),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: AppTheme.amber.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
          child: Text('${_mac!.minDisiplinPuani!.toStringAsFixed(1)}+',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.amber)),
        ),
      ]),
    );
  }

  Widget _buildAciklama() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Açıklama', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        const SizedBox(height: 8),
        Text(_mac!.aciklama!, style: TextStyle(fontSize: 14, color: AppTheme.textSecondary.withOpacity(0.8), height: 1.5)),
      ]),
    );
  }

  Widget _buildAksiyon(String? userId) {
    if (_mac == null || !_mac!.acikMi) return const SizedBox.shrink();

    final benKatildimMi = _mac!.katilimcilar?.any((k) => k.id == userId && k.katilimDurumu == 'ONAYLANDI') ?? false;
    final benOlusturdum = _mac!.olusturanId == userId;

    if (benOlusturdum) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.15)),
        ),
        child: const Center(child: Text('Bu maçı siz oluşturdunuz',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.primaryGreen))),
      );
    }

    if (benKatildimMi) {
      return GestureDetector(
        onTap: _islemYapiliyor ? null : _ayril,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppTheme.errorRed.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.errorRed.withOpacity(0.15)),
          ),
          child: Center(
            child: _islemYapiliyor
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.errorRed))
              : const Text('Maçtan Ayrıl', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.errorRed)),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: _islemYapiliyor ? null : _katil,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: _islemYapiliyor ? null : AppTheme.buttonGradient,
          color: _islemYapiliyor ? AppTheme.textSecondary.withOpacity(0.15) : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _islemYapiliyor ? null : [
            BoxShadow(color: AppTheme.primaryGreen.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Center(
          child: _islemYapiliyor
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.textPrimary))
            : const Text('Maça Katıl', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.backgroundDark)),
        ),
      ),
    );
  }
}
