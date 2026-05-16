class Rezervasyon {
  final String id;
  final String sahaId;
  final String? sahaAdi;
  final String? sahaAdresi;
  final String kullaniciId;
  final String? kullaniciAdSoyad;
  final String rezervasyonTarihi;
  final String baslangicSaati;
  final String bitisSaati;
  final double? toplamUcret;
  final String durum;
  final String? notlar;
  final String? olusturulmaTarihi;

  Rezervasyon({
    required this.id,
    required this.sahaId,
    this.sahaAdi,
    this.sahaAdresi,
    required this.kullaniciId,
    this.kullaniciAdSoyad,
    required this.rezervasyonTarihi,
    required this.baslangicSaati,
    required this.bitisSaati,
    this.toplamUcret,
    required this.durum,
    this.notlar,
    this.olusturulmaTarihi,
  });

  factory Rezervasyon.fromJson(Map<String, dynamic> json) {
    return Rezervasyon(
      id: json['id'] ?? '',
      sahaId: json['sahaId'] ?? '',
      sahaAdi: json['sahaAdi'],
      sahaAdresi: json['sahaAdresi'],
      kullaniciId: json['kullaniciId'] ?? '',
      kullaniciAdSoyad: json['kullaniciAdSoyad'],
      rezervasyonTarihi: json['rezervasyonTarihi'] ?? '',
      baslangicSaati: json['baslangicSaati'] ?? '',
      bitisSaati: json['bitisSaati'] ?? '',
      toplamUcret: (json['toplamUcret'] as num?)?.toDouble(),
      durum: json['durum'] ?? 'BEKLEMEDE',
      notlar: json['notlar'],
      olusturulmaTarihi: json['olusturulmaTarihi'],
    );
  }

  bool get beklemede => durum == 'BEKLEMEDE';
  bool get onaylandi => durum == 'ONAYLANDI';
  bool get iptal => durum == 'IPTAL';
  bool get tamamlandi => durum == 'TAMAMLANDI';

  String get durumText {
    switch (durum) {
      case 'BEKLEMEDE': return 'Beklemede';
      case 'ONAYLANDI': return 'Onaylandı';
      case 'IPTAL': return 'İptal';
      case 'TAMAMLANDI': return 'Tamamlandı';
      default: return durum;
    }
  }
}
