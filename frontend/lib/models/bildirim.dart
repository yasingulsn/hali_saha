class Bildirim {
  final String id;
  final String baslik;
  final String mesaj;
  final String bildirimTipi;
  final String? hedefId;
  final String? aksiyonId;
  final bool okunduMu;
  final String olusturulmaTarihi;

  Bildirim({
    required this.id,
    required this.baslik,
    required this.mesaj,
    required this.bildirimTipi,
    this.hedefId,
    this.aksiyonId,
    required this.okunduMu,
    required this.olusturulmaTarihi,
  });

  factory Bildirim.fromJson(Map<String, dynamic> json) {
    return Bildirim(
      id: json['id'] ?? '',
      baslik: json['baslik'] ?? '',
      mesaj: json['mesaj'] ?? '',
      bildirimTipi: json['bildirimTipi'] ?? '',
      hedefId: json['hedefId'],
      aksiyonId: json['aksiyonId'],
      okunduMu: json['okunduMu'] ?? false,
      olusturulmaTarihi: json['olusturulmaTarihi'] ?? '',
    );
  }

  String get zamanMetni {
    try {
      final date = DateTime.parse(olusturulmaTarihi).toLocal();
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 60) return '${diff.inMinutes} dk önce';
      if (diff.inHours < 24) return '${diff.inHours} sa önce';
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return '';
    }
  }
}
