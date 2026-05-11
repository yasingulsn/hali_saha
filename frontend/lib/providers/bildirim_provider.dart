import 'package:flutter/material.dart';
import '../models/bildirim.dart';
import '../services/api_client.dart';
import '../services/bildirim_service.dart';

class BildirimProvider extends ChangeNotifier {
  final BildirimService _service = BildirimService(ApiClient());

  List<Bildirim> _bildirimler = [];
  int _okunmamisSayisi = 0;
  bool _yukleniyor = false;

  List<Bildirim> get bildirimler => _bildirimler;
  int get okunmamisSayisi => _okunmamisSayisi;
  bool get yukleniyor => _yukleniyor;

  Future<void> yukle() async {
    _yukleniyor = true;
    notifyListeners();

    final res = await _service.getBildirimler();
    if (res.basarili && res.veri != null) {
      _bildirimler = res.veri!;
      _okunmamisSayisi = _bildirimler.where((b) => !b.okunduMu).length;
    }

    _yukleniyor = false;
    notifyListeners();
  }

  Future<void> sayiGuncelle() async {
    final res = await _service.getOkunmamisSayisi();
    if (res.basarili && res.veri != null) {
      _okunmamisSayisi = res.veri!;
      notifyListeners();
    }
  }

  Future<void> oku(String id) async {
    final res = await _service.okunduIsaretle(id);
    if (res.basarili) {
      final index = _bildirimler.indexWhere((b) => b.id == id);
      if (index != -1) {
        final b = _bildirimler[index];
        _bildirimler[index] = Bildirim(
          id: b.id,
          baslik: b.baslik,
          mesaj: b.mesaj,
          bildirimTipi: b.bildirimTipi,
          hedefId: b.hedefId,
          aksiyonId: b.aksiyonId,
          okunduMu: true,
          olusturulmaTarihi: b.olusturulmaTarihi,
        );
        _okunmamisSayisi = _bildirimler.where((b) => !b.okunduMu).length;
        notifyListeners();
      }
    }
  }

  Future<void> hepsiniOku() async {
    final res = await _service.hepsiniOkunduIsaretle();
    if (res.basarili) {
      _bildirimler = _bildirimler.map((b) => Bildirim(
        id: b.id,
        baslik: b.baslik,
        mesaj: b.mesaj,
        bildirimTipi: b.bildirimTipi,
        hedefId: b.hedefId,
        aksiyonId: b.aksiyonId,
        okunduMu: true,
        olusturulmaTarihi: b.olusturulmaTarihi,
      )).toList();
      _okunmamisSayisi = 0;
      notifyListeners();
    }
  }

  Future<void> sil(String id) async {
    // Önce listeden kaldır (UI'da gecikme olmasın ve Dismissible hatası olmasın)
    final index = _bildirimler.indexWhere((b) => b.id == id);
    if (index != -1) {
      _bildirimler.removeAt(index);
      _okunmamisSayisi = _bildirimler.where((b) => !b.okunduMu).length;
      notifyListeners();
      
      // Sonra API'ye gönder
      await _service.sil(id);
    }
  }
}
