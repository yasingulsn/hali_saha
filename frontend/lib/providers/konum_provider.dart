import 'package:flutter/material.dart';
import '../services/konum_service.dart';
import '../services/profil_service.dart';
import '../services/secure_storage_service.dart';
import '../widgets/konum_secim_sheet.dart';
import '../models/token_response.dart';

/// Uygulama genelinde konum state'ini yöneten provider.
/// Kullanıcı konum seçtikten sonra değiştirene kadar kalıcı kalır.
/// Konum hem local storage'a hem de backend'e kaydedilir.
class KonumProvider extends ChangeNotifier {
  final KonumService _konumService = KonumService();
  final ProfilService _profilService = ProfilService();
  final SecureStorageService _storageService = SecureStorageService();

  KonumSecim? _seciliKonum;
  String? _konumEtiketi;
  String? _aramaMetni;
  bool _yuklendi = false;

  // ── Getter'lar ──────────────────────────────────────────────
  KonumSecim? get seciliKonum => _seciliKonum;
  String? get konumEtiketi => _konumEtiketi;
  String? get aramaMetni => _aramaMetni;
  bool get konumSecildi => _seciliKonum != null;
  bool get yuklendi => _yuklendi;
  String? get seciliIl => _seciliKonum?.il;
  String? get seciliIlce => _seciliKonum?.ilce;

  // ── Local storage'dan ilklendir (uygulama başlangıcı) ──────
  Future<void> loadFromStorage() async {
    if (_yuklendi) return;
    try {
      final parts = await _storageService.getKonum();
      if (parts != null && parts[0].isNotEmpty) {
        final secim = KonumSecim(
          ulke: 'Turkiye',
          il: parts[0],
          ilce: parts[1],
        );
        _seciliKonum = secim;
        _konumEtiketi = secim.etiket;
        _aramaMetni = secim.aramaMetni.trim();
      }
    } catch (_) {}
    _yuklendi = true;
    notifyListeners();
  }

  // ── Konum güncelle ─────────────────────────────────────────
  void konumSec(KonumSecim secim, {bool syncBackend = true}) {
    _seciliKonum = secim;
    _konumEtiketi = secim.etiket;
    _aramaMetni = secim.aramaMetni.trim();
    notifyListeners();

    _saveToLocal();
    if (syncBackend) {
      _saveToBackend();
    }
  }

  // ── Profil bilgilerinden ilklendir (sadece local boşsa) ────
  void initializeFromProfile(KullaniciBilgi bilgi) {
    // Local storage'dan zaten yüklendiyse ve konum varsa, üzerine yazma
    if (_seciliKonum != null) return;

    if (bilgi.il != null && bilgi.il!.isNotEmpty) {
      final secim = KonumSecim(
        ulke: 'Turkiye',
        il: bilgi.il!,
        ilce: bilgi.ilce ?? '',
      );
      _seciliKonum = secim;
      _konumEtiketi = secim.etiket;
      _aramaMetni = secim.aramaMetni.trim();
      notifyListeners();
      _saveToLocal();
    }
  }

  Future<void> _saveToLocal() async {
    try {
      if (_seciliKonum != null) {
        await _storageService.saveKonum(
          _seciliKonum!.il,
          _seciliKonum!.ilce,
        );
      } else {
        await _storageService.clearKonum();
      }
    } catch (_) {}
  }

  Future<void> _saveToBackend() async {
    try {
      await _profilService.konumGuncelle(
        il: _seciliKonum?.il ?? '',
        ilce: _seciliKonum?.ilce ?? '',
      );
    } catch (_) {}
  }

  // ── GPS ile mevcut konum al ────────────────────────────────
  Future<bool> mevcutKonumdanSec() async {
    try {
      final k = await _konumService.mevcutKonumuAl();
      final il = (k.il ?? '').trim();
      final ilce = (k.ilce ?? '').trim();
      if (il.isEmpty && ilce.isEmpty) return false;

      final secim = KonumSecim(ulke: 'Turkiye', il: il, ilce: ilce);
      _seciliKonum = secim;
      _konumEtiketi = secim.etiket;
      _aramaMetni = secim.aramaMetni.trim();
      notifyListeners();
      _saveToLocal();
      _saveToBackend();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Konumu temizle ─────────────────────────────────────────
  void konumTemizle() {
    _seciliKonum = null;
    _konumEtiketi = null;
    _aramaMetni = null;
    notifyListeners();
    _saveToLocal();
    _saveToBackend();
  }
}
