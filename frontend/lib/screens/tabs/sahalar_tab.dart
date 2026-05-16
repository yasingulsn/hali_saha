import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/saha.dart';
import '../../services/api_client.dart';
import '../../services/saha_service.dart';
import '../../utils/theme.dart';
import '../saha_detay_screen.dart';

class SahalarTab extends StatefulWidget {
  const SahalarTab({super.key});

  @override
  State<SahalarTab> createState() => _SahalarTabState();
}

class _SahalarTabState extends State<SahalarTab> {
  final SahaService _sahaService = SahaService(ApiClient());
  final TextEditingController _aramaController = TextEditingController();

  List<Saha> _sahalar = [];
  bool _yukleniyor = true;
  String? _hata;
  int _seciliFiltre = 0;
  bool _haritaGorunumu = false;

  final _filtreler = ['Tümü', 'Kapalı', 'Açık', 'En Ucuz', 'En Pahalı'];

  @override
  void initState() {
    super.initState();
    _aramaController.addListener(() => setState(() {}));
    _sahalariYukle();
  }

  Future<void> _sahalariYukle() async {
    setState(() { _yukleniyor = true; _hata = null; });
    final response = await _sahaService.tumSahalar();
    if (mounted) {
      setState(() {
        _yukleniyor = false;
        if (response.basarili && response.veri != null) {
          _sahalar = response.veri!;
        } else {
          _hata = response.mesaj;
        }
      });
    }
  }

  Future<void> _ara(String query) async {
    if (query.trim().isEmpty) {
      _sahalariYukle();
      return;
    }
    setState(() { _yukleniyor = true; _hata = null; });
    final response = await _sahaService.sahalarAra(query.trim());
    if (mounted) {
      setState(() {
        _yukleniyor = false;
        if (response.basarili && response.veri != null) {
          _sahalar = response.veri!;
        }
      });
    }
  }

  List<Saha> get _filtrelenmis {
    var liste = List<Saha>.from(_sahalar);
    switch (_seciliFiltre) {
      case 1: liste = liste.where((s) => s.kapaliMi).toList(); break;
      case 2: liste = liste.where((s) => !s.kapaliMi).toList(); break;
      case 3: liste.sort((a, b) => a.saatlikUcret.compareTo(b.saatlikUcret)); break;
      case 4: liste.sort((a, b) => b.saatlikUcret.compareTo(a.saatlikUcret)); break;
    }
    return liste;
  }

  @override
  Widget build(BuildContext context) {
    if (_haritaGorunumu) {
      return Column(
        children: [
          _buildSearchBar(),
          _buildFilters(),
          Expanded(child: _buildHaritaGorunumu()),
        ],
      );
    }
    return RefreshIndicator(
      onRefresh: _sahalariYukle,
      color: AppTheme.primaryGreen,
      backgroundColor: AppTheme.cardDark,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(child: _buildSearchBar()),
          SliverToBoxAdapter(child: _buildFilters()),
          if (_yukleniyor)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen)),
            )
          else if (_hata != null)
            SliverFillRemaining(child: _buildHata())
          else if (_filtrelenmis.isEmpty)
            SliverFillRemaining(child: _buildBos())
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildSahaItem(_filtrelenmis[index]),
                  childCount: _filtrelenmis.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildHaritaGorunumu() {
    final sahalarKonum = _filtrelenmis.where((s) => s.enlem != null && s.boylam != null).toList();
    final center = sahalarKonum.isNotEmpty
        ? LatLng(
            sahalarKonum.map((s) => s.enlem!).reduce((a, b) => a + b) / sahalarKonum.length,
            sahalarKonum.map((s) => s.boylam!).reduce((a, b) => a + b) / sahalarKonum.length,
          )
        : const LatLng(41.0082, 28.9784);

    if (_yukleniyor) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen));
    }

    return RefreshIndicator(
      onRefresh: _sahalariYukle,
      color: AppTheme.primaryGreen,
      child: Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: center,
            initialZoom: sahalarKonum.isEmpty ? 10 : 12,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.halisaha_app',
            ),
            MarkerLayer(
              markers: sahalarKonum.map((saha) {
                return Marker(
                  point: LatLng(saha.enlem!, saha.boylam!),
                  width: 48,
                  height: 46,
                  child: GestureDetector(
                    onTap: () => _sahaMarkerTiklandi(saha),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryGreen.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.stadium_rounded, color: Colors.white, size: 18),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        if (sahalarKonum.isEmpty)
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.cardDark.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Konumu olan saha bulunamadı',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
          ),
      ],
    ));
  }

  void _sahaMarkerTiklandi(Saha saha) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.stadium_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(saha.sahaAdi,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(saha.adres,
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary.withOpacity(0.7)),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(saha.sahaFormati,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primaryGreen)),
              ),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              const Icon(Icons.star_rounded, color: AppTheme.amber, size: 16),
              const SizedBox(width: 4),
              Text(saha.puanOrtalamasi.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              Text('  (${saha.yorumSayisi} yorum)',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              const Spacer(),
              Text('₺${saha.saatlikUcret.toStringAsFixed(0)}/saat',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.primaryGreen)),
            ]),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => SahaDetayScreen(sahaId: saha.id)));
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: AppTheme.buttonGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text('Detaya Git',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.backgroundDark)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: AppTheme.cardDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.08)),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Icon(Icons.search_rounded, color: AppTheme.textSecondary.withOpacity(0.6), size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _aramaController,
                      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Saha ara...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      onSubmitted: _ara,
                    ),
                  ),
                  if (_aramaController.text.isNotEmpty)
                    GestureDetector(
                      onTap: () { _aramaController.clear(); _sahalariYukle(); },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(Icons.close_rounded, color: AppTheme.textSecondary.withOpacity(0.6), size: 20),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => setState(() => _haritaGorunumu = !_haritaGorunumu),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _haritaGorunumu ? AppTheme.primaryGreen : AppTheme.cardDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.2)),
              ),
              child: Icon(
                _haritaGorunumu ? Icons.list_rounded : Icons.map_rounded,
                color: _haritaGorunumu ? AppTheme.backgroundDark : AppTheme.primaryGreen,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filtreler.length,
        itemBuilder: (context, index) {
          final isSelected = _seciliFiltre == index;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => setState(() => _seciliFiltre = index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppTheme.buttonGradient : null,
                  color: isSelected ? null : AppTheme.cardDark,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected ? null : Border.all(color: AppTheme.primaryGreen.withOpacity(0.06)),
                ),
                alignment: Alignment.center,
                child: Text(
                  _filtreler[index],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppTheme.backgroundDark : AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHata() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, color: AppTheme.errorRed.withOpacity(0.6), size: 48),
          const SizedBox(height: 16),
          Text(_hata ?? 'Bir hata oluştu', style: const TextStyle(color: AppTheme.textSecondary)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _sahalariYukle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: AppTheme.buttonGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('Tekrar Dene', style: TextStyle(color: AppTheme.backgroundDark, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBos() {
    final aramaVar = _aramaController.text.trim().isNotEmpty;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.stadium_outlined, color: AppTheme.textSecondary.withOpacity(0.3), size: 64),
          const SizedBox(height: 16),
          Text(
            aramaVar
                ? '"${_aramaController.text.trim()}" için sonuç bulunamadı'
                : 'Henüz saha bulunamadı',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 15),
            textAlign: TextAlign.center,
          ),
          if (aramaVar) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () { _aramaController.clear(); _sahalariYukle(); },
              child: Text(
                'Aramayı temizle',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationColor: AppTheme.primaryGreen,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSahaItem(Saha saha) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SahaDetayScreen(sahaId: saha.id))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                gradient: AppTheme.glassGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: saha.fotografUrl != null && saha.fotografUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        saha.fotografUrl!,
                        fit: BoxFit.cover,
                        width: 64,
                        height: 64,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.stadium_rounded, color: AppTheme.primaryGreen, size: 28),
                      ),
                    )
                  : const Icon(Icons.stadium_rounded, color: AppTheme.primaryGreen, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(saha.sahaAdi,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(saha.sahaFormati,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.primaryGreen)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 13, color: AppTheme.textSecondary.withOpacity(0.6)),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(saha.adres,
                          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary.withOpacity(0.7)),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: AppTheme.amber, size: 15),
                      const SizedBox(width: 4),
                      Text(saha.puanOrtalamasi.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                      Text('  (${saha.yorumSayisi})',
                        style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                      const Spacer(),
                      Text('₺${saha.saatlikUcret.toStringAsFixed(0)}/saat',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.primaryGreen)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _aramaController.dispose();
    super.dispose();
  }
}
