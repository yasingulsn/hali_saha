import 'package:dio/dio.dart';
import '../models/token_response.dart';
import 'api_client.dart';

class TakipDurumu {
  final bool takipEdiyorum;
  final bool beniTakipEdiyor;
  final int takipEdilenSayisi;
  final int takipciSayisi;

  TakipDurumu({
    required this.takipEdiyorum,
    required this.beniTakipEdiyor,
    required this.takipEdilenSayisi,
    required this.takipciSayisi,
  });

  factory TakipDurumu.fromJson(Map<String, dynamic> json) {
    return TakipDurumu(
      takipEdiyorum: json['takipEdiyorum'] ?? false,
      beniTakipEdiyor: json['beniTakipEdiyor'] ?? false,
      takipEdilenSayisi: json['takipEdilenSayisi'] ?? 0,
      takipciSayisi: json['takipciSayisi'] ?? 0,
    );
  }
}

class ProfilOzet {
  final String id;
  final String adSoyad;
  final String? profilFotoUrl;
  final String? tercihEdilenPozisyon;
  final double? disiplinPuani;
  final String? il;
  final String? ilce;
  final int takipEdilenSayisi;
  final int takipciSayisi;

  ProfilOzet({
    required this.id,
    required this.adSoyad,
    this.profilFotoUrl,
    this.tercihEdilenPozisyon,
    this.disiplinPuani,
    this.il,
    this.ilce,
    this.takipEdilenSayisi = 0,
    this.takipciSayisi = 0,
  });

  factory ProfilOzet.fromJson(Map<String, dynamic> json) {
    return ProfilOzet(
      id: json['id'] ?? '',
      adSoyad: json['adSoyad'] ?? '',
      profilFotoUrl: json['profilFotoUrl'],
      tercihEdilenPozisyon: json['tercihEdilenPozisyon'],
      disiplinPuani: json['disiplinPuani'] != null
          ? (json['disiplinPuani'] as num).toDouble()
          : null,
      il: json['il'],
      ilce: json['ilce'],
      takipEdilenSayisi: json['takipEdilenSayisi'] ?? 0,
      takipciSayisi: json['takipciSayisi'] ?? 0,
    );
  }
}

class TakipService {
  final ApiClient _api = ApiClient();

  Future<bool> takipEt(String kullaniciId) async {
    try {
      await _api.dio.post('/api/takip/$kullaniciId');
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> takiptenCik(String kullaniciId) async {
    try {
      await _api.dio.delete('/api/takip/$kullaniciId');
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<ApiResponse<TakipDurumu>> takipDurumu(String kullaniciId) async {
    try {
      final res = await _api.dio.get('/api/takip/durum/$kullaniciId');
      final json = res.data as Map<String, dynamic>;
      return ApiResponse(
        basarili: json['basarili'] ?? false,
        mesaj: json['mesaj'] ?? '',
        veri: json['veri'] != null ? TakipDurumu.fromJson(json['veri']) : null,
      );
    } catch (_) {
      return ApiResponse(basarili: false, mesaj: 'Hata', veri: null);
    }
  }

  Future<ApiResponse<List<ProfilOzet>>> takipEttiklerim() async {
    try {
      final res = await _api.dio.get('/api/takip/takip-ettiklerim');
      final json = res.data as Map<String, dynamic>;
      final liste = (json['veri'] as List?)
              ?.map((e) => ProfilOzet.fromJson(e))
              .toList() ??
          [];
      return ApiResponse(basarili: json['basarili'] ?? false, mesaj: '', veri: liste);
    } catch (_) {
      return ApiResponse(basarili: false, mesaj: 'Hata', veri: []);
    }
  }

  Future<ApiResponse<List<ProfilOzet>>> takipcilerim() async {
    try {
      final res = await _api.dio.get('/api/takip/takipcilerim');
      final json = res.data as Map<String, dynamic>;
      final liste = (json['veri'] as List?)
              ?.map((e) => ProfilOzet.fromJson(e))
              .toList() ??
          [];
      return ApiResponse(basarili: json['basarili'] ?? false, mesaj: '', veri: liste);
    } catch (_) {
      return ApiResponse(basarili: false, mesaj: 'Hata', veri: []);
    }
  }
}
