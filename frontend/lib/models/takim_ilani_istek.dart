class TakimIlaniIstek {
  final String id;
  final String ilanId;
  final String ilanBasligi;
  final String gonderenId;
  final String gonderenAdSoyad;
  final String mesaj;
  final String durum;
  final String olusturulmaTarihi;

  TakimIlaniIstek({
    required this.id,
    required this.ilanId,
    required this.ilanBasligi,
    required this.gonderenId,
    required this.gonderenAdSoyad,
    required this.mesaj,
    required this.durum,
    required this.olusturulmaTarihi,
  });

  factory TakimIlaniIstek.fromJson(Map<String, dynamic> json) {
    return TakimIlaniIstek(
      id: json['id'] ?? '',
      ilanId: json['ilanId'] ?? '',
      ilanBasligi: json['ilanBasligi'] ?? '',
      gonderenId: json['gonderenId'] ?? '',
      gonderenAdSoyad: json['gonderenAdSoyad'] ?? '',
      mesaj: json['mesaj'] ?? '',
      durum: json['durum'] ?? '',
      olusturulmaTarihi: json['olusturulmaTarihi'] ?? '',
    );
  }
}
