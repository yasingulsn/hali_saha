class TakimIlani {
  final String id;
  final String olusturanId;
  final String? olusturanAdi;
  final String takimAdi;
  final String ilanBasligi;
  final String? aciklama;
  final String arananPozisyon;
  final int arananOyuncuSayisi;
  final double? minDisiplinPuani;
  final String seviye;
  final String? konum;
  final String ilanDurumu;
  final String? olusturulmaTarihi;

  TakimIlani({
    required this.id,
    required this.olusturanId,
    this.olusturanAdi,
    required this.takimAdi,
    required this.ilanBasligi,
    this.aciklama,
    this.arananPozisyon = 'FARKETMEZ',
    this.arananOyuncuSayisi = 1,
    this.minDisiplinPuani,
    this.seviye = 'KARMA',
    this.konum,
    this.ilanDurumu = 'AKTIF',
    this.olusturulmaTarihi,
  });

  factory TakimIlani.fromJson(Map<String, dynamic> json) {
    return TakimIlani(
      id: json['id'] ?? '',
      olusturanId: json['olusturanId'] ?? '',
      olusturanAdi: json['olusturanAdi'],
      takimAdi: json['takimAdi'] ?? '',
      ilanBasligi: json['ilanBasligi'] ?? '',
      aciklama: json['aciklama'],
      arananPozisyon: json['arananPozisyon'] ?? 'FARKETMEZ',
      arananOyuncuSayisi: json['arananOyuncuSayisi'] ?? 1,
      minDisiplinPuani: (json['minDisiplinPuani'] as num?)?.toDouble(),
      seviye: json['seviye'] ?? 'KARMA',
      konum: json['konum'],
      ilanDurumu: json['ilanDurumu'] ?? 'AKTIF',
      olusturulmaTarihi: json['olusturulmaTarihi']?.toString(),
    );
  }

  String get pozisyonText {
    switch (arananPozisyon) {
      case 'KALECI': return 'Kaleci';
      case 'DEFANS': return 'Defans';
      case 'ORTASAHA': return 'Orta Saha';
      case 'FORVET': return 'Forvet';
      default: return 'Farketmez';
    }
  }

  String get seviyeText {
    switch (seviye) {
      case 'BASLANGIC': return 'Başlangıç';
      case 'ORTA': return 'Orta';
      case 'ILERI': return 'İleri';
      default: return 'Karma';
    }
  }
}
