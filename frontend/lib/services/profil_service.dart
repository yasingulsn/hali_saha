import 'package:dio/dio.dart';
import '../models/token_response.dart';
import '../utils/constants.dart';
import 'api_client.dart';

class ProfilService {
  final ApiClient _apiClient = ApiClient();

  // ─── PROFİL DETAY ───────────────────────────────────────────

  Future<ApiResponse<KullaniciBilgi>> getProfilDetay() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.profil);

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => KullaniciBilgi.fromJson(json),
      );

      return apiResponse;
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  // ─── PROFİL GÜNCELLE ────────────────────────────────────────

  Future<ApiResponse<KullaniciBilgi>> profilGuncelle({
    required String adSoyad,
    String? telefon,
    String? tercihEdilenPozisyon,
    String? dogumTarihi,
    String? il,
    String? ilce,
    String? profilFotoUrl,
  }) async {
    try {
      final response = await _apiClient.dio.put(
        ApiConstants.profilGuncelle,
        data: {
          'adSoyad': adSoyad,
          'telefon': telefon,
          'tercihEdilenPozisyon': tercihEdilenPozisyon,
          'dogumTarihi': dogumTarihi,
          'il': il,
          'ilce': ilce,
          if (profilFotoUrl != null) 'profilFotoUrl': profilFotoUrl,
        },
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => KullaniciBilgi.fromJson(json),
      );

      return apiResponse;
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  Future<ApiResponse<void>> konumGuncelle({
    required String il,
    required String ilce,
  }) async {
    try {
      final response = await _apiClient.dio.put(
        ApiConstants.konumGuncelle,
        data: {
          'il': il,
          'ilce': ilce,
        },
      );

      return ApiResponse(
        basarili: response.data['basarili'] ?? false,
        mesaj: response.data['mesaj'] ?? '',
      );
    } on DioException catch (e) {
      return ApiResponse(basarili: false, mesaj: 'Konum güncellenemedi');
    }
  }

  // ─── HATA YÖNETİMİ ─────────────────────────────────────────

  ApiResponse<KullaniciBilgi> _handleDioError(DioException e) {
    String mesaj = 'Bağlantı hatası oluştu';

    // Debug: konsola detaylı hata bas
    print('=== PROFİL SERVİS HATA ===');
    print('Tip: ${e.type}');
    print('Status: ${e.response?.statusCode}');
    print('Data: ${e.response?.data}');
    print('Message: ${e.message}');
    print('===========================');

    if (e.response != null && e.response?.data != null) {
      try {
        final data = e.response!.data;
        if (data is Map<String, dynamic>) {
          if (data.containsKey('mesaj')) {
            mesaj = data['mesaj'];
          } else if (data.containsKey('message')) {
            mesaj = data['message'];
          } else if (data.containsKey('violations')) {
            // Bean validation hataları
            final violations = data['violations'] as List?;
            if (violations != null && violations.isNotEmpty) {
              mesaj = violations.map((v) => v['message'] ?? '').join(', ');
            }
          }
        } else if (data is String) {
          mesaj = data;
        }
      } catch (_) {}
    } else if (e.type == DioExceptionType.connectionTimeout) {
      mesaj = 'Sunucuya bağlanılamadı, internet bağlantınızı kontrol ediniz';
    } else if (e.type == DioExceptionType.connectionError) {
      mesaj = 'Sunucu ile bağlantı kurulamadı';
    } else if (e.type == DioExceptionType.receiveTimeout) {
      mesaj = 'Sunucu yanıt vermedi, lütfen tekrar deneyin';
    }

    return ApiResponse(basarili: false, mesaj: mesaj);
  }
}
