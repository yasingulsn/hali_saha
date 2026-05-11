import 'package:flutter/material.dart';
import '../models/takim_ilani_istek.dart';
import '../services/api_client.dart';
import '../services/takim_ilani_service.dart';
import '../utils/theme.dart';

class TakimIstekleriScreen extends StatefulWidget {
  const TakimIstekleriScreen({super.key});

  @override
  State<TakimIstekleriScreen> createState() => _TakimIstekleriScreenState();
}

class _TakimIstekleriScreenState extends State<TakimIstekleriScreen> {
  final TakimIlaniService _service = TakimIlaniService(ApiClient());
  List<TakimIlaniIstek> _istekler = [];
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<void> _yukle() async {
    setState(() => _yukleniyor = true);
    final res = await _service.gelenIstekler();
    if (mounted) {
      setState(() {
        _yukleniyor = false;
        if (res.basarili) _istekler = res.veri ?? [];
      });
    }
  }

  Future<void> _onayla(TakimIlaniIstek istek) async {
    final res = await _service.istekOnayla(istek.id);
    if (mounted) {
      if (res.basarili) {
        _showSnackBar('İstek onaylandı!', AppTheme.primaryGreen);
        _yukle();
      } else {
        _showSnackBar(res.mesaj, AppTheme.errorRed);
      }
    }
  }

  Future<void> _reddet(TakimIlaniIstek istek) async {
    final res = await _service.istekReddet(istek.id);
    if (mounted) {
      if (res.basarili) {
        _showSnackBar('İstek reddedildi.', AppTheme.accentCoral);
        _yukle();
      } else {
        _showSnackBar(res.mesaj, AppTheme.errorRed);
      }
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Takım İstekleri', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
          : _istekler.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _yukle,
                  color: AppTheme.primaryGreen,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: _istekler.length,
                    itemBuilder: (context, index) {
                      final b = _istekler[index];
                      return _buildIstekItem(b);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.handshake_outlined, size: 64, color: AppTheme.textSecondary.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text('Gelen bir katılma isteği bulunmuyor',
              style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.5))),
        ],
      ),
    );
  }

  Widget _buildIstekItem(TakimIlaniIstek istek) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppTheme.cardDarkElevated,
            child: const Icon(Icons.person, color: AppTheme.primaryGreen, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(istek.gonderenAdSoyad,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.textPrimary)),
                const SizedBox(height: 2),
                Text(istek.ilanBasligi,
                    style: TextStyle(fontSize: 13, color: AppTheme.textSecondary.withOpacity(0.8))),
                if (istek.mesaj.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('"${istek.mesaj}"',
                      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppTheme.textSecondary.withOpacity(0.6))),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          _actionButton(
            text: 'Onayla',
            color: AppTheme.primaryGreen,
            onTap: () => _onayla(istek),
          ),
          const SizedBox(width: 8),
          _actionButton(
            text: 'Sil',
            color: AppTheme.cardDarkElevated,
            textColor: AppTheme.textPrimary,
            onTap: () => _reddet(istek),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String text,
    required Color color,
    required VoidCallback onTap,
    Color textColor = Colors.black,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
