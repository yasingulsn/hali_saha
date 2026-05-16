import 'package:flutter/material.dart';
import '../services/takip_service.dart';
import '../utils/theme.dart';

class TakipListeScreen extends StatefulWidget {
  final int baslangicTab;
  const TakipListeScreen({super.key, this.baslangicTab = 0});

  @override
  State<TakipListeScreen> createState() => _TakipListeScreenState();
}

class _TakipListeScreenState extends State<TakipListeScreen>
    with SingleTickerProviderStateMixin {
  final TakipService _takipService = TakipService();
  late TabController _tabController;

  List<ProfilOzet> _takipEttiklerim = [];
  List<ProfilOzet> _takipcilerim = [];
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.baslangicTab);
    _yukle();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _yukle() async {
    setState(() => _yukleniyor = true);
    try {
      final results = await Future.wait([
        _takipService.takipEttiklerim(),
        _takipService.takipcilerim(),
      ]);
      if (mounted) {
        setState(() {
          _yukleniyor = false;
          _takipEttiklerim = results[0].veri ?? [];
          _takipcilerim = results[1].veri ?? [];
        });
      }
    } catch (_) {
      if (mounted) setState(() => _yukleniyor = false);
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
              _buildTabBar(),
              Expanded(
                child: _yukleniyor
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildListe(_takipEttiklerim, 'Henüz kimseyi takip etmiyorsunuz', takipEden: true),
                          _buildListe(_takipcilerim, 'Henüz takipçiniz yok', takipEden: false),
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
      child: Row(children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 8),
        const Text('Takip',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
      ]),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: AppTheme.backgroundDark,
        unselectedLabelColor: AppTheme.textSecondary,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        tabs: [
          Tab(text: 'Takip (${_takipEttiklerim.length})'),
          Tab(text: 'Takipçi (${_takipcilerim.length})'),
        ],
      ),
    );
  }

  Widget _buildListe(List<ProfilOzet> liste, String bosMetin, {required bool takipEden}) {
    return RefreshIndicator(
      onRefresh: _yukle,
      color: AppTheme.primaryGreen,
      child: liste.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: 400,
                  child: Center(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.people_outline_rounded,
                          color: AppTheme.textSecondary.withOpacity(0.3), size: 64),
                      const SizedBox(height: 16),
                      Text(bosMetin,
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 15)),
                    ]),
                  ),
                ),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: liste.length,
              itemBuilder: (_, i) => _buildKullaniciKart(liste[i], takipEden: takipEden),
            ),
    );
  }

  Widget _buildKullaniciKart(ProfilOzet profil, {required bool takipEden}) {
    final initials = profil.adSoyad
        .split(' ')
        .where((s) => s.isNotEmpty)
        .map((s) => s[0].toUpperCase())
        .take(2)
        .join();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: Row(children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            shape: BoxShape.circle,
          ),
          child: profil.profilFotoUrl != null && profil.profilFotoUrl!.isNotEmpty
              ? ClipOval(
                  child: Image.network(profil.profilFotoUrl!,
                      fit: BoxFit.cover, width: 52, height: 52,
                      errorBuilder: (_, __, ___) =>
                          Center(child: Text(initials, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)))))
              : Center(child: Text(initials, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white))),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(profil.adSoyad,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 3),
            Row(children: [
              if (profil.il != null) ...[
                Icon(Icons.location_on_rounded, size: 12, color: AppTheme.textSecondary.withOpacity(0.5)),
                const SizedBox(width: 2),
                Text('${profil.ilce ?? profil.il}',
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary.withOpacity(0.6))),
                const SizedBox(width: 8),
              ],
              if (profil.disiplinPuani != null) ...[
                Icon(Icons.stars_rounded, size: 12, color: AppTheme.amber.withOpacity(0.7)),
                const SizedBox(width: 2),
                Text(profil.disiplinPuani!.toStringAsFixed(1),
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary.withOpacity(0.6))),
              ],
            ]),
          ]),
        ),
        if (takipEden)
          GestureDetector(
            onTap: () => _takiptenCik(profil),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.errorRed.withOpacity(0.15)),
              ),
              child: const Text('Bırak',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.errorRed)),
            ),
          ),
      ]),
    );
  }

  Future<void> _takiptenCik(ProfilOzet profil) async {
    final ok = await _takipService.takiptenCik(profil.id);
    if (ok && mounted) {
      setState(() => _takipEttiklerim.removeWhere((p) => p.id == profil.id));
    }
  }
}
