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

  KullaniciBilgi({
    required this.id,
    required this.adSoyad,
    required this.email,
    this.profilFotoUrl,
  });

  factory KullaniciBilgi.fromJson(Map<String, dynamic> json) {
    return KullaniciBilgi(
      id: json['id'] ?? '',
      adSoyad: json['adSoyad'] ?? '',
      email: json['email'] ?? '',
      profilFotoUrl: json['profilFotoUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'adSoyad': adSoyad,
      'email': email,
      'profilFotoUrl': profilFotoUrl,
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
