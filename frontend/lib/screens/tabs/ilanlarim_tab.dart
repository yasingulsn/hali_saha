import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/mac.dart';
import '../../models/takim_ilani.dart';
import '../../models/token_response.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_client.dart';
import '../../services/mac_service.dart';
import '../../services/takim_ilani_service.dart';
import '../../utils/theme.dart';
import '../mac_detay_screen.dart';
import '../takim_ilanlari_screen.dart';

class IlanlarimTab extends StatefulWidget {
  const IlanlarimTab({super.key});

  @override
  State<IlanlarimTab> createState() => _IlanlarimTabState();
}

class _IlanlarimTabState extends State<IlanlarimTab> with TickerProviderStateMixin {
  final _apiClient = ApiClient();
  late final MacService _macService = MacService(_apiClient);
  late final TakimIlaniService _takimIlaniService = TakimIlaniService(_apiClient);

  List<TakimIlani> _kaliciOyuncuIlanlari = [];
  List<Mac> _rakipIlanlari = [];
  List<Mac> _eksikOyuncuIlanlari = [];
  bool _isLoading = true;
  String? _hata;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _hata = null; });

    try {
      final ilanFuture = _takimIlaniService.benimIlanlarim();
      final macFuture = _macService.benimMaclarim();
      final ilanRes = await ilanFuture;
      final macRes = await macFuture;

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (ilanRes.basarili && ilanRes.veri != null) {
            _kaliciOyuncuIlanlari = ilanRes.veri!;
          }
          if (macRes.basarili && macRes.veri != null) {
            _rakipIlanlari = macRes.veri!.where((m) => m.macTipi == 'RAKIP_ARANIYOR').toList();
            _eksikOyuncuIlanlari = macRes.veri!.where((m) => m.macTipi == 'EKSIK_OYUNCU').toList();
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() { _isLoading = false; _hata = 'Veriler yüklenemedi. Yenilemek için çekin.'; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
                : _hata != null
                    ? _buildHata()
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildIlanList(_kaliciOyuncuIlanlari, 'kalici'),
                          _buildIlanList(_rakipIlanlari, 'rakip'),
                          _buildIlanList(_eksikOyuncuIlanlari, 'eksik'),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'İlanlarım',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tüm ilanlarınızı buradan yönetebilirsiniz',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.04)),
            ),
            child: Icon(Icons.campaign_rounded, color: AppTheme.primaryGreen, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.cardDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: AppTheme.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryGreen.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.textSecondary,
        tabs: const [
          Tab(text: 'Kalıcı Oyuncu'),
          Tab(text: 'Rakip'),
          Tab(text: 'Eksik Oyuncu'),
        ],
      ),
    );
  }

  Widget _buildHata() {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppTheme.primaryGreen,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 400,
            child: Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.wifi_off_rounded, color: AppTheme.lightOrange.withOpacity(0.5), size: 48),
                const SizedBox(height: 16),
                Text(_hata!, textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.7), fontSize: 14)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIlanList(List<dynamic> items, String type) {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppTheme.primaryGreen,
      backgroundColor: AppTheme.cardDark,
      child: items.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: 400,
                  child: Center(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.campaign_outlined, size: 64,
                          color: AppTheme.textSecondary.withOpacity(0.1)),
                      const SizedBox(height: 16),
                      Text('Henüz ilanınız yok',
                          style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.5),
                              fontSize: 15, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                if (type == 'kalici') {
                  return _buildKaliciIlanCard(item as TakimIlani);
                } else {
                  return _buildMacIlanCard(item as Mac);
                }
              },
            ),
    );
  }

  Widget _buildKaliciIlanCard(TakimIlani ilan) {
    return GestureDetector(
      onTap: () {
        final userId = context.read<AuthProvider>().currentUser?.id;
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => TakimIlaniDetaySheet(
            ilan: ilan,
            benimMi: ilan.olusturanId == userId,
            onDegisti: _loadData,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.accentPurple.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: AppTheme.accentPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.groups_rounded, color: AppTheme.accentPurple, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ilan.ilanBasligi,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _badge(ilan.takimAdi, AppTheme.accentBlue),
                      const SizedBox(width: 6),
                      _badge(ilan.pozisyonText, AppTheme.lightOrange),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }

  Widget _buildMacIlanCard(Mac mac) {
    final isRakip = mac.macTipi == 'RAKIP_ARANIYOR';
    final color = isRakip ? AppTheme.accentCoral : AppTheme.accentBlue;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MacDetayScreen(macId: mac.id))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isRakip ? Icons.sports_mma_rounded : Icons.person_add_rounded,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mac.macBasligi,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _badge(mac.macTarihi, AppTheme.textSecondary.withOpacity(0.5)),
                      const SizedBox(width: 6),
                      _badge(mac.baslangicSaati, AppTheme.textSecondary.withOpacity(0.5)),
                      const Spacer(),
                      _badge(
                        isRakip ? 'Rakip Aranıyor' : '${mac.mevcutOyuncuSayisi}/${mac.maxOyuncuSayisi}',
                        color,
                      ),
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

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color.withOpacity(1.0),
        ),
      ),
    );
  }
}
