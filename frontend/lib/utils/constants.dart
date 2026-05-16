class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  // Auth endpoints
  static const String kullaniciKayit = '/api/auth/kayit';
  static const String kullaniciGiris = '/api/auth/giris';
  static const String isletmeKayit = '/api/auth/isletme/kayit';
  static const String isletmeGiris = '/api/auth/isletme/giris';
  static const String tokenYenile = '/api/auth/token-yenile';
  static const String cikis = '/api/auth/cikis';
  static const String tumCihazlardanCikis = '/api/auth/tum-cihazlardan-cikis';
  static const String profil = '/api/auth/profil';
  static const String profilGuncelle = '/api/auth/profil';
  static const String konumGuncelle = '/api/auth/profil/konum';
  static const String sifreSifirlamaIstegi = '/api/auth/sifre-sifirlama-istegi';
  static const String sifreSifirla = '/api/auth/sifre-sifirla';

  // Saha endpoints
  static const String sahalar = '/api/sahalar';
  static const String sahalarAra = '/api/sahalar/ara';

  // Maç endpoints
  static const String maclar = '/api/maclar';
  static const String benimMaclarim = '/api/maclar/benim';
  static const String benimGecmisMaclarim = '/api/maclar/benim/gecmis';
  static const String maclarAra = '/api/maclar/ara';
  static String macPuanla(String macId) => '/api/maclar/$macId/puanla';
  static String macSkor(String macId) => '/api/maclar/$macId/skor';

  // Arama endpoint
  static const String birlesikArama = '/api/arama';

  // Rezervasyon endpoints
  static const String rezervasyonlar = '/api/rezervasyonlar';
  static const String benimRezervasyonlarim = '/api/rezervasyonlar/benim';
  static const String isletmeRezervasyonlari = '/api/rezervasyonlar/isletme';
  static String sahaRezervasyonlari(String sahaId) => '/api/rezervasyonlar/saha/$sahaId';
  static String sahaGunlukRezervasyonlar(String sahaId) => '/api/rezervasyonlar/saha/$sahaId/gun';
  static String rezervasyonIptal(String id) => '/api/rezervasyonlar/$id/iptal';
  static String rezervasyonOnayla(String id) => '/api/rezervasyonlar/$id/onayla';
  static String rezervasyonReddet(String id) => '/api/rezervasyonlar/$id/reddet';

  // Bildirim endpoints
  static const String bildirimler = '/api/bildirimler';
  static const String bildirimOkunmamisSayisi = '/api/bildirimler/okunmamis-sayisi';
  static const String bildirimHepsiniOku = '/api/bildirimler/hepsini-oku';
  static String bildirimOku(String id) => '/api/bildirimler/$id/oku';
  static String bildirimSil(String id) => '/api/bildirimler/$id';
}

class StorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String kullaniciTipi = 'kullanici_tipi';
  static const String kullaniciBilgi = 'kullanici_bilgi';
  static const String beniHatirla = 'beni_hatirla';
  static const String seciliKonum = 'secili_konum'; // il|ilce formatında
}
