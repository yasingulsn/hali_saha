class TokenResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenTipi;
  final int accessTokenSuresi;
  final String kullaniciTipi;
  final KullaniciBilgi kullaniciBilgi;

  TokenResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenTipi,
    required this.accessTokenSuresi,
    required this.kullaniciTipi,
    required this.kullaniciBilgi,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      tokenTipi: json['tokenTipi'] ?? 'Bearer',
      accessTokenSuresi: json['accessTokenSuresi'] ?? 900,
      kullaniciTipi: json['kullaniciTipi'] ?? '',
      kullaniciBilgi: KullaniciBilgi.fromJson(json['kullaniciBilgi'] ?? {}),
    );
  }
}

class KullaniciBilgi {
  final String id;
  final String adSoyad;
  final String email;
  final String? profilFotoUrl;
  final String? telefon;
  final String? tercihEdilenPozisyon;
  final double? disiplinPuani;
  final double? puanOrtalamasi;
  final int? yorumSayisi;
  final String? dogumTarihi;
  final String? kayitTarihi;
  final String? hesapDurumu;
  final String? il;
  final String? ilce;
  final int toplamMacSayisi;
  final int olusturduguMacSayisi;
  final int toplamIlanSayisi;

  KullaniciBilgi({
    required this.id,
    required this.adSoyad,
    required this.email,
    this.profilFotoUrl,
    this.telefon,
    this.tercihEdilenPozisyon,
    this.disiplinPuani,
    this.puanOrtalamasi,
    this.yorumSayisi,
    this.dogumTarihi,
    this.kayitTarihi,
    this.hesapDurumu,
    this.il,
    this.ilce,
    this.toplamMacSayisi = 0,
    this.olusturduguMacSayisi = 0,
    this.toplamIlanSayisi = 0,
  });

  factory KullaniciBilgi.fromJson(Map<String, dynamic> json) {
    return KullaniciBilgi(
      id: json['id'] ?? '',
      adSoyad: json['adSoyad'] ?? '',
      email: json['email'] ?? '',
      profilFotoUrl: json['profilFotoUrl'],
      telefon: json['telefon'],
      tercihEdilenPozisyon: json['tercihEdilenPozisyon'],
      disiplinPuani: json['disiplinPuani'] != null
          ? (json['disiplinPuani'] as num).toDouble()
          : null,
      puanOrtalamasi: json['puanOrtalamasi'] != null
          ? (json['puanOrtalamasi'] as num).toDouble()
          : null,
      yorumSayisi: json['yorumSayisi'],
      dogumTarihi: json['dogumTarihi'],
      kayitTarihi: json['kayitTarihi'],
      hesapDurumu: json['hesapDurumu'],
      il: json['il'],
      ilce: json['ilce'],
      toplamMacSayisi: json['toplamMacSayisi'] ?? 0,
      olusturduguMacSayisi: json['olusturduguMacSayisi'] ?? 0,
      toplamIlanSayisi: json['toplamIlanSayisi'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'adSoyad': adSoyad,
      'email': email,
      'profilFotoUrl': profilFotoUrl,
      'telefon': telefon,
      'tercihEdilenPozisyon': tercihEdilenPozisyon,
      'disiplinPuani': disiplinPuani,
      'puanOrtalamasi': puanOrtalamasi,
      'yorumSayisi': yorumSayisi,
      'dogumTarihi': dogumTarihi,
      'kayitTarihi': kayitTarihi,
      'hesapDurumu': hesapDurumu,
      'il': il,
      'ilce': ilce,
      'toplamMacSayisi': toplamMacSayisi,
      'olusturduguMacSayisi': olusturduguMacSayisi,
      'toplamIlanSayisi': toplamIlanSayisi,
    };
  }
}

class ApiResponse<T> {
  final bool basarili;
  final String mesaj;
  final T? veri;

  ApiResponse({
    required this.basarili,
    required this.mesaj,
    this.veri,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>)? fromJsonT,
  ) {
    return ApiResponse(
      basarili: json['basarili'] ?? false,
      mesaj: json['mesaj'] ?? '',
      veri: json['veri'] != null && fromJsonT != null
          ? fromJsonT(json['veri'])
          : null,
    );
  }
}
