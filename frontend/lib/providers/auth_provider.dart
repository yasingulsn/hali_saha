import 'package:flutter/material.dart';
import '../models/token_response.dart';
import '../services/auth_service.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthState _state = AuthState.initial;
  String? _errorMessage;
  KullaniciBilgi? _currentUser;
  String? _kullaniciTipi;

  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  KullaniciBilgi? get currentUser => _currentUser;
  String? get kullaniciTipi => _kullaniciTipi;
  bool get isAuthenticated => _state == AuthState.authenticated;

  // ─── BAŞLANGIÇ KONTROLÜ ───────────────────────────────────────

  Future<void> checkAuthStatus() async {
    _state = AuthState.loading;
    notifyListeners();

    final loggedIn = await _authService.isLoggedIn();
    if (loggedIn) {
      _currentUser = await _authService.getCurrentUser();
      _kullaniciTipi = await _authService.getKullaniciTipi();
      _state = AuthState.authenticated;
    } else {
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }

  // ─── KULLANICI GİRİŞ ─────────────────────────────────────────

  Future<bool> kullaniciGiris(String email, String sifre,
      {bool beniHatirla = false}) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final response = await _authService.kullaniciGiris(
      email: email,
      sifre: sifre,
      beniHatirla: beniHatirla,
    );

    if (response.basarili && response.veri != null) {
      _currentUser = response.veri!.kullaniciBilgi;
      _kullaniciTipi = response.veri!.kullaniciTipi;
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.mesaj;
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  // ─── KULLANICI KAYIT ──────────────────────────────────────────

  Future<bool> kullaniciKayit({
    required String adSoyad,
    required String email,
    required String sifre,
    String? telefon,
    String? dogumTarihi,
  }) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final response = await _authService.kullaniciKayit(
      adSoyad: adSoyad,
      email: email,
      sifre: sifre,
      telefon: telefon,
      dogumTarihi: dogumTarihi,
    );

    if (response.basarili && response.veri != null) {
      _currentUser = response.veri!.kullaniciBilgi;
      _kullaniciTipi = response.veri!.kullaniciTipi;
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.mesaj;
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  // ─── İŞLETME GİRİŞ ───────────────────────────────────────────

  Future<bool> isletmeGiris(String email, String sifre,
      {bool beniHatirla = false}) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final response = await _authService.isletmeGiris(
      email: email,
      sifre: sifre,
      beniHatirla: beniHatirla,
    );

    if (response.basarili && response.veri != null) {
      _currentUser = response.veri!.kullaniciBilgi;
      _kullaniciTipi = response.veri!.kullaniciTipi;
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.mesaj;
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  // ─── İŞLETME KAYIT ───────────────────────────────────────────

  Future<bool> isletmeKayit({
    required String isletmeAdi,
    required String yetkiliAdSoyad,
    required String email,
    required String sifre,
    required String telefon,
    String? vergiNo,
    String? adres,
  }) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final response = await _authService.isletmeKayit(
      isletmeAdi: isletmeAdi,
      yetkiliAdSoyad: yetkiliAdSoyad,
      email: email,
      sifre: sifre,
      telefon: telefon,
      vergiNo: vergiNo,
      adres: adres,
    );

    if (response.basarili && response.veri != null) {
      _currentUser = response.veri!.kullaniciBilgi;
      _kullaniciTipi = response.veri!.kullaniciTipi;
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.mesaj;
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  // ─── ÇIKIŞ ────────────────────────────────────────────────────

  Future<void> cikis() async {
    await _authService.cikis();
    _currentUser = null;
    _kullaniciTipi = null;
    _state = AuthState.unauthenticated;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }
}
