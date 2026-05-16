import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/bildirim.dart';
import '../providers/auth_provider.dart';
import '../providers/bildirim_provider.dart';
import '../services/api_client.dart';
import '../services/takim_ilani_service.dart';
import '../utils/theme.dart';
import 'mac_detay_screen.dart';
import 'takim_ilanlari_screen.dart';
import 'takim_istekleri_screen.dart';

class BildirimlerScreen extends StatefulWidget {
  const BildirimlerScreen({super.key});

  @override
  State<BildirimlerScreen> createState() => _BildirimlerScreenState();
}

class _BildirimlerScreenState extends State<BildirimlerScreen> {
  final _takimIlaniService = TakimIlaniService(ApiClient());

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<BildirimProvider>().yukle());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirimler', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => context.read<BildirimProvider>().hepsiniOku(),
            icon: const Icon(Icons.done_all_rounded, color: AppTheme.primaryGreen),
            tooltip: 'Hepsini Okundu İşaretle',
          ),
        ],
      ),
      body: Consumer<BildirimProvider>(
        builder: (context, provider, child) {
          if (provider.yukleniyor && provider.bildirimler.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen));
          }

          if (provider.bildirimler.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none_rounded, size: 64, color: AppTheme.textSecondary.withOpacity(0.2)),
                  const SizedBox(height: 16),
                  Text('Henüz bildirim yok', style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.5))),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.yukle,
            color: AppTheme.primaryGreen,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.bildirimler.length,
              itemBuilder: (context, index) {
                final b = provider.bildirimler[index];
                return Dismissible(
                  key: Key(b.id),
                  direction: DismissDirection.horizontal,
                  onDismissed: (direction) {
                    provider.sil(b.id);
                  },
                  background: _buildDismissBackground(false),
                  secondaryBackground: _buildDismissBackground(true),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () => _onBildirimTap(b),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: b.okunduMu ? AppTheme.cardDark : AppTheme.cardDarkElevated,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: b.okunduMu ? Colors.transparent : AppTheme.primaryGreen.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                color: _getIconColor(b.bildirimTipi).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(_getIcon(b.bildirimTipi), size: 20, color: _getIconColor(b.bildirimTipi)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(b.baslik, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                      Text(b.zamanMetni, style: TextStyle(fontSize: 10, color: AppTheme.textSecondary.withOpacity(0.6))),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(b.mesaj, style: TextStyle(fontSize: 13, color: AppTheme.textSecondary.withOpacity(0.8))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildDismissBackground(bool secondary) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: secondary ? Alignment.centerRight : Alignment.centerLeft,
      decoration: BoxDecoration(
        color: AppTheme.errorRed.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(Icons.delete_outline_rounded, color: AppTheme.errorRed, size: 24),
    );
  }

  Future<void> _onBildirimTap(Bildirim b) async {
    if (!b.okunduMu) context.read<BildirimProvider>().oku(b.id);

    if (b.hedefId == null) return;

    if (b.bildirimTipi == 'MAC_KATILIM' || b.bildirimTipi == 'YAKIN_MAC') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => MacDetayScreen(macId: b.hedefId!)));
    } else if (b.bildirimTipi == 'MAC_ISTEK') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const TakimIstekleriScreen()));
    } else if (b.bildirimTipi == 'YAKIN_TAKIM') {
      _showTakimIlaniDetay(b.hedefId!);
    }
  }

  Future<void> _showTakimIlaniDetay(String id) async {
    final res = await _takimIlaniService.ilanDetay(id);
    
    if (!mounted) return;

    if (res.basarili && res.veri != null) {
      final userId = context.read<AuthProvider>().currentUser?.id;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => TakimIlaniDetaySheet(
          ilan: res.veri!,
          benimMi: res.veri!.olusturanId == userId,
          onDegisti: () => context.read<BildirimProvider>().yukle(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(res.mesaj.isNotEmpty ? res.mesaj : 'İlan bulunamadı veya silinmiş.'),
        backgroundColor: AppTheme.errorRed,
      ));
    }
  }

  IconData _getIcon(String tip) {
    switch (tip) {
      case 'MAC_KATILIM': return Icons.person_add_rounded;
      case 'MAC_ISTEK': return Icons.handshake_rounded;
      case 'YAKIN_MAC': return Icons.sports_soccer_rounded;
      case 'YAKIN_TAKIM': return Icons.groups_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Color _getIconColor(String tip) {
    switch (tip) {
      case 'MAC_KATILIM': return AppTheme.primaryGreen;
      case 'MAC_ISTEK': return AppTheme.accentBlue;
      case 'YAKIN_MAC': return AppTheme.primaryGreen;
      case 'YAKIN_TAKIM': return AppTheme.accentPurple;
      default: return AppTheme.textSecondary;
    }
  }
}
