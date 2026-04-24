import 'package:flutter/material.dart';
import '../utils/theme.dart';

class KonumSecim {
  final String ulke;
  final String il;
  final String ilce;

  const KonumSecim({
    required this.ulke,
    required this.il,
    required this.ilce,
  });

  bool get mevcutKonumSecildi => ulke == '__MEVCUT__';
  String get etiket => '$ulke / $il / $ilce';
  String get aramaMetni => '$il $ilce';
}

const Map<String, Map<String, List<String>>> kKonumVerisi = {
  'Turkiye': {
    'Istanbul': ['Kadikoy', 'Besiktas', 'Uskudar', 'Sisli', 'Fatih'],
    'Ankara': ['Cankaya', 'Kecioren', 'Yenimahalle', 'Mamak', 'Etimesgut'],
    'Izmir': ['Konak', 'Bornova', 'Karsiyaka', 'Buca', 'Bayrakli'],
    'Sivas': ['Merkez', 'Suşehri', 'Zara', 'Yildizeli', 'Kangal'],
    'Bursa': ['Osmangazi', 'Nilufer', 'Yildirim', 'Gursu', 'Mudanya'],
  },
  'Almanya': {
    'Berlin': ['Mitte', 'Kreuzberg', 'Neukolln'],
    'Munih': ['Altstadt', 'Schwabing', 'Sendling'],
  },
  'Ingiltere': {
    'Londra': ['Camden', 'Westminster', 'Hackney'],
    'Manchester': ['Salford', 'Didsbury', 'Ancoats'],
  },
};

Future<KonumSecim?> showKonumSecimSheet(
  BuildContext context, {
  String? initialUlke,
  String? initialIl,
  String? initialIlce,
  bool showCurrentLocationButton = false,
}) async {
  String ulke = initialUlke ?? kKonumVerisi.keys.first;
  String il = initialIl ?? kKonumVerisi[ulke]!.keys.first;
  String ilce = initialIlce ?? kKonumVerisi[ulke]![il]!.first;

  return showModalBottomSheet<KonumSecim>(
    context: context,
    backgroundColor: AppTheme.cardDarkElevated,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setLocal) {
        final iller = kKonumVerisi[ulke]!.keys.toList();
        final ilceler = kKonumVerisi[ulke]![il]!;
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Konum Sec',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: ulke,
                dropdownColor: AppTheme.cardDarkElevated,
                decoration: const InputDecoration(
                  labelText: 'Ulke',
                  prefixIcon: Icon(Icons.public_rounded),
                ),
                items: kKonumVerisi.keys
                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setLocal(() {
                    ulke = v;
                    il = kKonumVerisi[ulke]!.keys.first;
                    ilce = kKonumVerisi[ulke]![il]!.first;
                  });
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: il,
                dropdownColor: AppTheme.cardDarkElevated,
                decoration: const InputDecoration(
                  labelText: 'Sehir',
                  prefixIcon: Icon(Icons.location_city_rounded),
                ),
                items: iller.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setLocal(() {
                    il = v;
                    ilce = kKonumVerisi[ulke]![il]!.first;
                  });
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: ilce,
                dropdownColor: AppTheme.cardDarkElevated,
                decoration: const InputDecoration(
                  labelText: 'Ilce',
                  prefixIcon: Icon(Icons.map_outlined),
                ),
                items: ilceler.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setLocal(() => ilce = v);
                },
              ),
              const SizedBox(height: 14),
              if (showCurrentLocationButton) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(
                          ctx,
                          const KonumSecim(ulke: '__MEVCUT__', il: '', ilce: ''),
                        ),
                        icon: const Icon(Icons.my_location_rounded),
                        label: const Text('Mevcut Konumum'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Vazgec'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, KonumSecim(ulke: ulke, il: il, ilce: ilce)),
                      child: const Text('Uygula'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ),
  );
}
