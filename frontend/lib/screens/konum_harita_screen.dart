import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/konum_service.dart';
import '../utils/theme.dart';

class KonumHaritaScreen extends StatelessWidget {
  final KonumBilgi konum;
  const KonumHaritaScreen({super.key, required this.konum});

  @override
  Widget build(BuildContext context) {
    final center = LatLng(konum.enlem, konum.boylam);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 24, 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Konumdan Ara',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.22)),
                  ),
                  child: Text(
                    konum.acikAdres ?? konum.etiket,
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: center,
                        initialZoom: 14,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.halisaha_app',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: center,
                              width: 40,
                              height: 40,
                              child: const Icon(Icons.location_on_rounded, color: AppTheme.errorRed, size: 36),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context, konum.aramaMetni),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(gradient: AppTheme.buttonGradient, borderRadius: BorderRadius.circular(14)),
                    child: Center(
                      child: Text(
                        '"${konum.aramaMetni.isEmpty ? konum.etiket : konum.aramaMetni}" için ara',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.backgroundDark),
                      ),
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
}
