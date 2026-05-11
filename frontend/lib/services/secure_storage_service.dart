import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/token_response.dart';
import '../utils/constants.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // ─── TOKEN İŞLEMLERİ ────────────────────────────────────────

  Future<void> saveTokens(TokenResponse tokenResponse) async {
    await Future.wait([
      _storage.write(
          key: StorageKeys.accessToken, value: tokenResponse.accessToken),
      _storage.write(
          key: StorageKeys.refreshToken, value: tokenResponse.refreshToken),
      _storage.write(
          key: StorageKeys.kullaniciTipi, value: tokenResponse.kullaniciTipi),
      _storage.write(
        key: StorageKeys.kullaniciBilgi,
        value: jsonEncode(tokenResponse.kullaniciBilgi.toJson()),
      ),
    ]);
  }

  Future<void> saveKullaniciBilgi(KullaniciBilgi bilgi) async {
    await _storage.write(
      key: StorageKeys.kullaniciBilgi,
      value: jsonEncode(bilgi.toJson()),
    );
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: StorageKeys.accessToken);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: StorageKeys.refreshToken);
  }

  Future<String?> getKullaniciTipi() async {
    return await _storage.read(key: StorageKeys.kullaniciTipi);
  }

  Future<KullaniciBilgi?> getKullaniciBilgi() async {
    final jsonStr = await _storage.read(key: StorageKeys.kullaniciBilgi);
    if (jsonStr == null) return null;
    return KullaniciBilgi.fromJson(jsonDecode(jsonStr));
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  Future<bool> hasTokens() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // ─── KONUM İŞLEMLERİ ──────────────────────────────────────

  Future<void> saveKonum(String il, String ilce) async {
    await _storage.write(
      key: StorageKeys.seciliKonum,
      value: '$il|$ilce',
    );
  }

  /// Kaydedilen konumu [il, ilce] listesi olarak döner. Yoksa null.
  Future<List<String>?> getKonum() async {
    final val = await _storage.read(key: StorageKeys.seciliKonum);
    if (val == null || val.isEmpty) return null;
    final parts = val.split('|');
    if (parts.length != 2) return null;
    return parts;
  }

  Future<void> clearKonum() async {
    await _storage.delete(key: StorageKeys.seciliKonum);
  }

  // ─── BENİ HATIRLA ──────────────────────────────────────────

  Future<void> saveBeniHatirla(bool value) async {
    await _storage.write(
        key: StorageKeys.beniHatirla, value: value.toString());
  }

  Future<bool> getBeniHatirla() async {
    final val = await _storage.read(key: StorageKeys.beniHatirla);
    return val == 'true';
  }
}
