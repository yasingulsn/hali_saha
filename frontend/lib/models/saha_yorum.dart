class SahaYorum {
  final String id;
  final String kullaniciId;
  final String? kullaniciAdSoyad;
  final int puan;
  final String? yorum;
  final String? tarih;

  SahaYorum({
    required this.id,
    required this.kullaniciId,
    this.kullaniciAdSoyad,
    required this.puan,
    this.yorum,
    this.tarih,
  });

  factory SahaYorum.fromJson(Map<String, dynamic> json) {
    return SahaYorum(
      id: json['id'] ?? '',
      kullaniciId: json['kullaniciId'] ?? '',
      kullaniciAdSoyad: json['kullaniciAdSoyad'],
      puan: (json['puan'] as num?)?.toInt() ?? 0,
      yorum: json['yorum'],
      tarih: json['tarih'],
    );
  }
}
