import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/mac.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_client.dart';
import '../../services/mac_service.dart';
import '../../utils/theme.dart';
import '../mac_detay_screen.dart';
import '../mac_olustur_screen.dart';

class MaclarTab extends StatefulWidget {
  const MaclarTab({super.key});

  @override
  State<MaclarTab> createState() => _MaclarTabState();
}

class _MaclarTabState extends State<MaclarTab> {
  final _apiClient = ApiClient();
  late final MacService _macService = MacService(_apiClient);

  List<Mac> _acikMaclar = [];
  List<Mac> _benimMaclarim = [];
  bool _yukleniyor = true;
  String? _hata;
  int _seciliTab = 0;

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<void> _yukle() async {
    setState(() { _yukleniyor = true; _hata = null; });

    final acikRes = await _macService.acikMaclar();
    if (mounted) {
      setState(() {
        if (acikRes.basarili && acikRes.veri != null) {
          _acikMaclar = acikRes.veri!;
        } else {
          _hata = acikRes.mesaj;
        }
      });
    }

    final benimRes = await _macService.benimMaclarim();
    if (mounted && benimRes.basarili && benimRes.veri != null) {
      setState(() => _benimMaclarim = benimRes.veri!);
    }

    if (mounted) setState(() => _yukleniyor = false);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _yukle,
      color: AppTheme.primaryGreen,
      backgroundColor: AppTheme.cardDark,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(child: _buildToggle()),
          SliverToBoxAdapter(child: _buildCreateBanner()),
          if (_yukleniyor)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen)))
          else if (_seciliTab == 0)
            _buildMacListeSliver(_acikMaclar, 'Henüz açık maç yok', Icons.sports_soccer_outlined)
          else
            _buildMacListeSliver(_benimMaclarim, 'Henüz maçınız yok', Icons.event_busy_rounded),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildToggle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Container(
        height: 48, padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppTheme.cardDark, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.04)),
        ),
        child: Row(children: [
          _buildToggleItem(0, 'Açık Maçlar', _acikMaclar.length),
          _buildToggleItem(1, 'Maçlarım', _benimMaclarim.length),
        ]),
      ),
    );
  }

  Widget _buildToggleItem(int index, String label, int count) {
    final sel = _seciliTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _seciliTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            gradient: sel ? AppTheme.buttonGradient : null,
            borderRadius: BorderRadius.circular(11),
          ),
          alignment: Alignment.center,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(label, style: TextStyle(fontSize: 13, fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
              color: sel ? const Color(0xFF080C0A) : AppTheme.textSecondary)),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: sel ? const Color(0xFF080C0A).withOpacity(0.15) : AppTheme.primaryGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8)),
                child: Text('$count', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                  color: sel ? const Color(0xFF080C0A) : AppTheme.primaryGreen)),
              ),
            ],
          ]),
        ),
      ),
    );
  }

  Widget _buildCreateBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: GestureDetector(
        onTap: () async {
          final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => const MacOlusturScreen()));
          if (r == true) _yukle();
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [AppTheme.primaryGreen.withOpacity(0.12), AppTheme.primaryGreen.withOpacity(0.03)]),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.12)),
          ),
          child: Row(children: [
            Container(width: 40, height: 40,
              decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 22)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Yeni Maç Oluştur', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              Text('Takımını kur ve sahaya çık!', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary.withOpacity(0.7))),
            ])),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppTheme.primaryGreen.withOpacity(0.5)),
          ]),
        ),
      ),
    );
  }

  Widget _buildMacListeSliver(List<Mac> maclar, String bosText, IconData bosIcon) {
    if (maclar.isEmpty) {
      return SliverFillRemaining(
        child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: AppTheme.cardDark, shape: BoxShape.circle),
            child: Icon(bosIcon, color: AppTheme.textSecondary.withOpacity(0.25), size: 40),
          ),
          const SizedBox(height: 20),
          Text(bosText, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Maç oluşturmak için yukarıdaki butonu kullanın',
            style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.5), fontSize: 13)),
        ])),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(delegate: SliverChildBuilderDelegate(
        (context, index) => _buildMatchItem(maclar[index]),
        childCount: maclar.length,
      )),
    );
  }

  Widget _buildMatchItem(Mac mac) {
    final renk = mac.doluMu ? AppTheme.accentCoral : AppTheme.primaryGreen;
    final userId = context.read<AuthProvider>().currentUser?.id;
    final benOlusturdum = mac.olusturanId == userId;

    return GestureDetector(
      onTap: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (_) => MacDetayScreen(macId: mac.id)));
        _yukle();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardDark, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: benOlusturdum
            ? AppTheme.primaryGreen.withOpacity(0.12)
            : Colors.white.withOpacity(0.03)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            _buildBadge(mac.format, renk),
            const SizedBox(width: 6),
            _buildBadge(mac.seviyeText, AppTheme.accentPurple),
            if (mac.macTipi != 'NORMAL') ...[
              const SizedBox(width: 6),
              _buildBadge(mac.macTipiText, const Color(0xFF42A5F5)),
            ],
            if (benOlusturdum) ...[
              const SizedBox(width: 6),
              _buildBadge('Sizin', AppTheme.primaryGreen),
            ],
            const Spacer(),
            Text(mac.baslangicSaati, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary.withOpacity(0.6))),
          ]),
          const SizedBox(height: 12),
          Text(mac.macBasligi, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          if (mac.sahaAdi != null) ...[
            const SizedBox(height: 4),
            Row(children: [
              Icon(Icons.location_on_outlined, size: 14, color: AppTheme.textSecondary.withOpacity(0.5)),
              const SizedBox(width: 4),
              Expanded(child: Text(mac.sahaAdi!, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary.withOpacity(0.6)),
                maxLines: 1, overflow: TextOverflow.ellipsis)),
            ]),
          ],
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: _buildProgressSection(mac, renk)),
            const SizedBox(width: 16),
            if (mac.ucretPerKisi > 0)
              Padding(padding: const EdgeInsets.only(right: 12),
                child: Text('₺${mac.ucretPerKisi.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primaryGreen))),
            _buildActionButton(mac),
          ]),
          if (_seciliTab == 1 && benOlusturdum) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _kartActionButton(
                    text: 'Düzenle',
                    icon: Icons.edit_rounded,
                    color: AppTheme.accentBlue,
                    onTap: () => _macDuzenle(mac),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _kartActionButton(
                    text: 'Sil',
                    icon: Icons.delete_outline_rounded,
                    color: AppTheme.errorRed,
                    onTap: () => _macSil(mac),
                  ),
                ),
              ],
            ),
          ],
        ]),
      ),
    );
  }

  Widget _buildProgressSection(Mac mac, Color renk) {
    if (mac.eksikOyuncuMu && mac.eksikOyuncuSayisi != null) {
      final eksikKalan = mac.eksikOyuncuSayisi! - (mac.mevcutOyuncuSayisi - 1);
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.person_search_rounded, size: 14, color: const Color(0xFF42A5F5)),
          const SizedBox(width: 6),
          Text(eksikKalan > 0 ? '$eksikKalan oyuncu aranıyor' : 'Tamamlandı',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
              color: eksikKalan > 0 ? const Color(0xFF42A5F5) : AppTheme.primaryGreen)),
        ]),
      ]);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ClipRRect(borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: mac.maxOyuncuSayisi > 0 ? mac.mevcutOyuncuSayisi / mac.maxOyuncuSayisi : 0,
          minHeight: 5, backgroundColor: AppTheme.backgroundDark,
          valueColor: AlwaysStoppedAnimation<Color>(renk))),
      const SizedBox(height: 5),
      Text('${mac.mevcutOyuncuSayisi}/${mac.maxOyuncuSayisi} oyuncu',
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppTheme.textSecondary.withOpacity(0.6))),
    ]);
  }

  Widget _buildActionButton(Mac mac) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        gradient: mac.acikMi && !mac.doluMu ? AppTheme.buttonGradient : null,
        color: !mac.acikMi || mac.doluMu ? AppTheme.textSecondary.withOpacity(0.1) : null,
        borderRadius: BorderRadius.circular(12)),
      child: Text(mac.doluMu ? 'Dolu' : mac.acikMi ? 'Detay' : mac.macDurumu,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
          color: mac.acikMi && !mac.doluMu ? AppTheme.backgroundDark : AppTheme.textSecondary)),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    );
  }

  Future<void> _macDuzenle(Mac mac) async {
    final sonuc = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MacOlusturScreen(mac: mac)),
    );
    if (sonuc == true) _yukle();
  }

  Future<void> _macSil(Mac mac) async {
    final onay = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDarkElevated,
        title: const Text('Maç silinsin mi?', style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text('Bu işlem geri alınamaz.', style: TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sil', style: TextStyle(color: AppTheme.errorRed)),
          ),
        ],
      ),
    );
    if (onay != true) return;

    final res = await _macService.macSil(mac.id);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(res.basarili ? 'Maç silindi' : res.mesaj),
        backgroundColor: res.basarili ? AppTheme.primaryGreen : AppTheme.errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    if (res.basarili) _yukle();
  }

  Widget _kartActionButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }
}
