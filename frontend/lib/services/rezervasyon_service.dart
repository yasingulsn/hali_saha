import 'package:dio/dio.dart';
import '../models/rezervasyon.dart';
import '../models/token_response.dart';
import '../utils/constants.dart';
import 'api_client.dart';

class RezervasyonService {
  final ApiClient _apiClient;

  RezervasyonService(this._apiClient);

  Future<ApiResponse<List<Rezervasyon>>> benimRezervasyonlarim() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.benimRezervasyonlarim);
      return _parseList(response);
    } on DioException catch (e) {
      return _hata(e);
    }
  }

  Future<ApiResponse<List<Rezervasyon>>> sahaGunlukDolu(String sahaId, String tarih) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.sahaGunlukRezervasyonlar(sahaId),
        queryParameters: {'tarih': tarih},
      );
      return _parseList(response);
    } on DioException catch (e) {
      return _hata(e);
    }
  }

  Future<ApiResponse<Rezervasyon>> rezervasyonOlustur({
    required String sahaId,
    required String tarih,
    required String baslangic,
    required String bitis,
    String? notlar,
  }) async {
    try {
      final response = await _apiClient.dio.post(ApiConstants.rezervasyonlar, data: {
        'sahaId': sahaId,
        'rezervasyonTarihi': tarih,
        'baslangicSaati': baslangic,
        'bitisSaati': bitis,
        if (notlar != null && notlar.isNotEmpty) 'notlar': notlar,
      });
      final data = response.data;
      return ApiResponse(
        basarili: data['basarili'] ?? false,
        mesaj: data['mesaj'] ?? '',
        veri: data['veri'] != null ? Rezervasyon.fromJson(data['veri']) : null,
      );
    } on DioException catch (e) {
      return _hata(e);
    }
  }

  Future<ApiResponse<List<Rezervasyon>>> isletmeRezervasyonlari() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.isletmeRezervasyonlari);
      return _parseList(response);
    } on DioException catch (e) {
      return _hata(e);
    }
  }

  Future<ApiResponse<void>> onayla(String rezervasyonId) async {
    try {
      final response = await _apiClient.dio.post(ApiConstants.rezervasyonOnayla(rezervasyonId));
      return ApiResponse(basarili: response.data['basarili'] ?? false, mesaj: response.data['mesaj'] ?? '');
    } on DioException catch (e) {
      return _hata(e);
    }
  }

  Future<ApiResponse<void>> reddet(String rezervasyonId) async {
    try {
      final response = await _apiClient.dio.post(ApiConstants.rezervasyonReddet(rezervasyonId));
      return ApiResponse(basarili: response.data['basarili'] ?? false, mesaj: response.data['mesaj'] ?? '');
    } on DioException catch (e) {
      return _hata(e);
    }
  }

  Future<ApiResponse<void>> iptalEt(String rezervasyonId) async {
    try {
      final response = await _apiClient.dio.post(ApiConstants.rezervasyonIptal(rezervasyonId));
      return ApiResponse(basarili: response.data['basarili'] ?? false, mesaj: response.data['mesaj'] ?? '');
    } on DioException catch (e) {
      return _hata(e);
    }
  }

  ApiResponse<List<Rezervasyon>> _parseList(Response response) {
    final data = response.data;
    final List<Rezervasyon> liste = data['veri'] != null
        ? (data['veri'] as List).map((e) => Rezervasyon.fromJson(e)).toList()
        : [];
    return ApiResponse(basarili: data['basarili'] ?? false, mesaj: data['mesaj'] ?? '', veri: liste);
  }

  ApiResponse<T> _hata<T>(DioException e) {
    String mesaj = 'Bağlantı hatası';
    if (e.response?.data != null && e.response?.data is Map) {
      mesaj = e.response?.data['mesaj'] ?? mesaj;
    }
    return ApiResponse(basarili: false, mesaj: mesaj);
  }
}
