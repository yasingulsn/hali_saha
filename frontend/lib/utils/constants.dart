class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:8080';

  // Auth endpoints
  static const String kullaniciKayit = '/api/auth/kayit';
  static const String kullaniciGiris = '/api/auth/giris';
  static const String isletmeKayit = '/api/auth/isletme/kayit';
  static const String isletmeGiris = '/api/auth/isletme/giris';
  static const String tokenYenile = '/api/auth/token-yenile';
  static const String cikis = '/api/auth/cikis';
  static const String tumCihazlardanCikis = '/api/auth/tum-cihazlardan-cikis';
  static const String profil = '/api/auth/profil';

  // Saha endpoints
  static const String sahalar = '/api/sahalar';
  static const String sahalarAra = '/api/sahalar/ara';

  // Maç endpoints
  static const String maclar = '/api/maclar';
  static const String benimMaclarim = '/api/maclar/benim';
  static const String maclarAra = '/api/maclar/ara';

  // Arama endpoint
  static const String birlesikArama = '/api/arama';
}

class StorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String kullaniciTipi = 'kullanici_tipi';
  static const String kullaniciBilgi = 'kullanici_bilgi';
  static const String beniHatirla = 'beni_hatirla';
}
