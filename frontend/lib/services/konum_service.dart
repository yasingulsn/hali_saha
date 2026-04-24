import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class KonumBilgi {
  final double enlem;
  final double boylam;
  final String? il;
  final String? ilce;
  final String? acikAdres;

  KonumBilgi({
    required this.enlem,
    required this.boylam,
    this.il,
    this.ilce,
    this.acikAdres,
  });

  String get etiket {
    if ((ilce ?? '').isNotEmpty && (il ?? '').isNotEmpty) return '$ilce, $il';
    if ((ilce ?? '').isNotEmpty) return ilce!;
    if ((il ?? '').isNotEmpty) return il!;
    return 'Konum bulundu';
  }

  String get aramaMetni {
    if ((ilce ?? '').isNotEmpty) return ilce!;
    if ((il ?? '').isNotEmpty) return il!;
    return '';
  }
}

class KonumService {
  Future<KonumBilgi> mevcutKonumuAl() async {
    final servisAcik = await Geolocator.isLocationServiceEnabled();
    if (!servisAcik) {
      throw Exception('Konum servisi kapalı. Lütfen cihaz konumunu açın.');
    }

    var izin = await Geolocator.checkPermission();
    if (izin == LocationPermission.denied) {
      izin = await Geolocator.requestPermission();
    }
    if (izin == LocationPermission.denied || izin == LocationPermission.deniedForever) {
      throw Exception('Konum izni verilmedi.');
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    String? il;
    String? ilce;
    String? adres;
    try {
      final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        il = p.administrativeArea;
        ilce = p.subAdministrativeArea ?? p.locality;
        adres = [p.street, p.subLocality, p.locality, p.administrativeArea]
            .where((e) => (e ?? '').trim().isNotEmpty)
            .join(', ');
      }
    } catch (_) {}

    return KonumBilgi(
      enlem: position.latitude,
      boylam: position.longitude,
      il: il,
      ilce: ilce,
      acikAdres: adres,
    );
  }
}
