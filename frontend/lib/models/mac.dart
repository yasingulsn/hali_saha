class Mac {
  final String id;
  final String olusturanId;
  final String? olusturanAdi;
  final String? sahaId;
  final String? sahaAdi;
  final String macBasligi;
  final String macTarihi;
  final String baslangicSaati;
  final String bitisSaati;
  final String format;
  final int maxOyuncuSayisi;
  final int mevcutOyuncuSayisi;
  final String macDurumu;
  final String? aciklama;
  final String seviye;
  final double ucretPerKisi;
  final double? minDisiplinPuani;
  final String macTipi; // NORMAL, RAKIP_ARANIYOR, EKSIK_OYUNCU
  final int? eksikOyuncuSayisi;
  final String? takimAdi;
  final String? rakipNotu;
  final String? il;
  final String? ilce;
  final int? takim1Skor;
  final int? takim2Skor;
  final List<KatilimciBilgi>? katilimcilar;

  Mac({
    required this.id,
    required this.olusturanId,
    this.olusturanAdi,
    this.sahaId,
    this.sahaAdi,
    required this.macBasligi,
    required this.macTarihi,
    required this.baslangicSaati,
    required this.bitisSaati,
    required this.format,
    required this.maxOyuncuSayisi,
    this.mevcutOyuncuSayisi = 0,
    this.macDurumu = 'ACIK',
    this.aciklama,
    this.seviye = 'KARMA',
    this.ucretPerKisi = 0,
    this.minDisiplinPuani,
    this.macTipi = 'NORMAL',
    this.eksikOyuncuSayisi,
    this.takimAdi,
    this.rakipNotu,
    this.il,
    this.ilce,
    this.takim1Skor,
    this.takim2Skor,
    this.katilimcilar,
  });

  factory Mac.fromJson(Map<String, dynamic> json) {
    return Mac(
      id: json['id'] ?? '',
      olusturanId: json['olusturanId'] ?? '',
      olusturanAdi: json['olusturanAdi'],
      sahaId: json['sahaId'],
      sahaAdi: json['sahaAdi'],
      macBasligi: json['macBasligi'] ?? '',
      macTarihi: json['macTarihi'] ?? '',
      baslangicSaati: _parseTime(json['baslangicSaati']),
      bitisSaati: _parseTime(json['bitisSaati']),
      format: json['format'] ?? '',
      maxOyuncuSayisi: json['maxOyuncuSayisi'] ?? 0,
      mevcutOyuncuSayisi: json['mevcutOyuncuSayisi'] ?? 0,
      macDurumu: json['macDurumu'] ?? 'ACIK',
      aciklama: json['aciklama'],
      seviye: json['seviye'] ?? 'KARMA',
      ucretPerKisi: (json['ucretPerKisi'] as num?)?.toDouble() ?? 0,
      minDisiplinPuani: (json['minDisiplinPuani'] as num?)?.toDouble(),
      macTipi: json['macTipi'] ?? 'NORMAL',
      eksikOyuncuSayisi: json['eksikOyuncuSayisi'],
      takimAdi: json['takimAdi'],
      rakipNotu: json['rakipNotu'],
      il: json['il'],
      ilce: json['ilce'],
      takim1Skor: json['takim1Skor'],
      takim2Skor: json['takim2Skor'],
      katilimcilar: json['katilimcilar'] != null
          ? (json['katilimcilar'] as List)
              .map((k) => KatilimciBilgi.fromJson(k))
              .toList()
          : null,
    );
  }

  static String _parseTime(dynamic value) {
    if (value == null) return '';
    if (value is String) return value.substring(0, value.length >= 5 ? 5 : value.length);
    if (value is List && value.length >= 2) return '${value[0].toString().padLeft(2, '0')}:${value[1].toString().padLeft(2, '0')}';
    return value.toString();
  }

  bool get doluMu => mevcutOyuncuSayisi >= maxOyuncuSayisi;
  bool get acikMi => macDurumu == 'ACIK';
  bool get rakipAriyorMu => macTipi == 'RAKIP_ARANIYOR';
  bool get eksikOyuncuMu => macTipi == 'EKSIK_OYUNCU';

  String get seviyeText {
    switch (seviye) {
      case 'BASLANGIC': return 'Başlangıç';
      case 'ORTA': return 'Orta';
      case 'ILERI': return 'İleri';
      default: return 'Karma';
    }
  }

  String get macTipiText {
    switch (macTipi) {
      case 'RAKIP_ARANIYOR': return 'Rakip Aranıyor';
      case 'EKSIK_OYUNCU': return 'Eksik Oyuncu';
      default: return 'Normal Maç';
    }
  }
}

class KatilimciBilgi {
  final String id;
  final String adSoyad;
  final String? profilFotoUrl;
  final String katilimDurumu;
  final double? disiplinPuani;

  KatilimciBilgi({
    required this.id,
    required this.adSoyad,
    this.profilFotoUrl,
    required this.katilimDurumu,
    this.disiplinPuani,
  });

  factory KatilimciBilgi.fromJson(Map<String, dynamic> json) {
    return KatilimciBilgi(
      id: json['id'] ?? '',
      adSoyad: json['adSoyad'] ?? '',
      profilFotoUrl: json['profilFotoUrl'],
      katilimDurumu: json['katilimDurumu'] ?? '',
      disiplinPuani: (json['disiplinPuani'] as num?)?.toDouble(),
    );
  }
}
