class Saha {
  final String id;
  final String isletmeId;
  final String sahaAdi;
  final String adres;
  final double? enlem;
  final double? boylam;
  final String sahaFormati;
  final double saatlikUcret;
  final bool kapaliMi;
  final String? ozellikler;
  final double puanOrtalamasi;
  final int yorumSayisi;
  final String? fotografUrl;
  final String? isletmeAdi;

  Saha({
    required this.id,
    required this.isletmeId,
    required this.sahaAdi,
    required this.adres,
    this.enlem,
    this.boylam,
    required this.sahaFormati,
    required this.saatlikUcret,
    this.kapaliMi = false,
    this.ozellikler,
    this.puanOrtalamasi = 0,
    this.yorumSayisi = 0,
    this.fotografUrl,
    this.isletmeAdi,
  });

  factory Saha.fromJson(Map<String, dynamic> json) {
    return Saha(
      id: json['id'] ?? '',
      isletmeId: json['isletmeId'] ?? '',
      sahaAdi: json['sahaAdi'] ?? '',
      adres: json['adres'] ?? '',
      enlem: (json['enlem'] as num?)?.toDouble(),
      boylam: (json['boylam'] as num?)?.toDouble(),
      sahaFormati: json['sahaFormati'] ?? '',
      saatlikUcret: (json['saatlikUcret'] as num?)?.toDouble() ?? 0,
      kapaliMi: json['kapaliMi'] ?? false,
      ozellikler: json['ozellikler'],
      puanOrtalamasi: (json['puanOrtalamasi'] as num?)?.toDouble() ?? 0,
      yorumSayisi: json['yorumSayisi'] ?? 0,
      fotografUrl: json['fotografUrl'],
      isletmeAdi: json['isletmeAdi'],
    );
  }

  List<String> get ozellikListesi {
    if (ozellikler == null || ozellikler!.isEmpty) return [];
    return ozellikler!.split(',').map((e) => e.trim()).toList();
  }
}
