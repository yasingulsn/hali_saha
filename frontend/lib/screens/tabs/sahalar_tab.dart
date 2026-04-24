import 'package:flutter/material.dart';
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

  final _filtreler = ['Tümü', 'Kapalı', 'Açık', 'En Ucuz', 'En Pahalı'];

  @override
  void initState() {
    super.initState();
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
    setState(() { _yukleniyor = true; });
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.stadium_outlined, color: AppTheme.textSecondary.withOpacity(0.3), size: 64),
          const SizedBox(height: 16),
          const Text('Henüz saha bulunamadı', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
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
              child: const Icon(Icons.stadium_rounded, color: AppTheme.primaryGreen, size: 28),
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
