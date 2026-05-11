import 'package:dio/dio.dart';
import '../models/token_response.dart';
import '../utils/constants.dart';
import 'api_client.dart';
import 'secure_storage_service.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();
  final SecureStorageService _storage = SecureStorageService();

  // ─── KULLANICI GİRİŞ ─────────────────────────────────────────

  Future<ApiResponse<TokenResponse>> kullaniciGiris({
    required String email,
    required String sifre,
    bool beniHatirla = false,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.kullaniciGiris,
        data: {
          'email': email,
          'sifre': sifre,
          'cihazBilgisi': 'Flutter Mobile App',
          'beniHatirla': beniHatirla,
        },
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => TokenResponse.fromJson(json),
      );

      if (apiResponse.basarili && apiResponse.veri != null) {
        await _storage.saveTokens(apiResponse.veri!);
        await _storage.saveBeniHatirla(beniHatirla);
      }

      return apiResponse;
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  // ─── KULLANICI KAYIT ──────────────────────────────────────────

  Future<ApiResponse<TokenResponse>> kullaniciKayit({
    required String adSoyad,
    required String email,
    required String sifre,
    String? telefon,
    String? dogumTarihi,
  }) async {
    try {
      final data = <String, dynamic>{
        'adSoyad': adSoyad,
        'email': email,
        'sifre': sifre,
        'cihazBilgisi': 'Flutter Mobile App',
      };
      if (telefon != null && telefon.isNotEmpty) data['telefon'] = telefon;
      if (dogumTarihi != null) data['dogumTarihi'] = dogumTarihi;

      final response = await _apiClient.dio.post(
        ApiConstants.kullaniciKayit,
        data: data,
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => TokenResponse.fromJson(json),
      );

      if (apiResponse.basarili && apiResponse.veri != null) {
        await _storage.saveTokens(apiResponse.veri!);
      }

      return apiResponse;
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  // ─── İŞLETME GİRİŞ ───────────────────────────────────────────

  Future<ApiResponse<TokenResponse>> isletmeGiris({
    required String email,
    required String sifre,
    bool beniHatirla = false,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.isletmeGiris,
        data: {
          'email': email,
          'sifre': sifre,
          'cihazBilgisi': 'Flutter Mobile App',
          'beniHatirla': beniHatirla,
        },
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => TokenResponse.fromJson(json),
      );

      if (apiResponse.basarili && apiResponse.veri != null) {
        await _storage.saveTokens(apiResponse.veri!);
        await _storage.saveBeniHatirla(beniHatirla);
      }

      return apiResponse;
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  // ─── İŞLETME KAYIT ───────────────────────────────────────────

  Future<ApiResponse<TokenResponse>> isletmeKayit({
    required String isletmeAdi,
    required String yetkiliAdSoyad,
    required String email,
    required String sifre,
    required String telefon,
    String? vergiNo,
    String? adres,
  }) async {
    try {
      final data = <String, dynamic>{
        'isletmeAdi': isletmeAdi,
        'yetkiliAdSoyad': yetkiliAdSoyad,
        'email': email,
        'sifre': sifre,
        'telefon': telefon,
        'cihazBilgisi': 'Flutter Mobile App',
      };
      if (vergiNo != null) data['vergiNo'] = vergiNo;
      if (adres != null) data['adres'] = adres;

      final response = await _apiClient.dio.post(
        ApiConstants.isletmeKayit,
        data: data,
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => TokenResponse.fromJson(json),
      );

      if (apiResponse.basarili && apiResponse.veri != null) {
        await _storage.saveTokens(apiResponse.veri!);
      }

      return apiResponse;
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  // ─── ÇIKIŞ ────────────────────────────────────────────────────

  Future<void> cikis() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken != null) {
        await _apiClient.dio.post(
          ApiConstants.cikis,
          data: {'refreshToken': refreshToken},
        );
      }
    } catch (_) {
      // Çıkış hatası olsa bile storage temizlenir
    } finally {
      await _storage.clearAll();
    }
  }

  // ─── ŞİFRE SIFIRLAMA ────────────────────────────────────────

  Future<ApiResponse<void>> sifreSifirlamaIstegi(String email, String kullaniciTipi) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.sifreSifirlamaIstegi,
        data: {'email': email, 'kullaniciTipi': kullaniciTipi},
      );
      return ApiResponse(
        basarili: response.data['basarili'] ?? false,
        mesaj: response.data['mesaj'] ?? '',
      );
    } on DioException catch (e) {
      return ApiResponse(basarili: false, mesaj: _handleDioError(e).mesaj);
    }
  }

  Future<ApiResponse<void>> sifreSifirla(String token, String yeniSifre) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.sifreSifirla,
        data: {'token': token, 'yeniSifre': yeniSifre},
      );
      return ApiResponse(
        basarili: response.data['basarili'] ?? false,
        mesaj: response.data['mesaj'] ?? '',
      );
    } on DioException catch (e) {
      return ApiResponse(basarili: false, mesaj: _handleDioError(e).mesaj);
    }
  }

  // ─── OTURUM KONTROLÜ ─────────────────────────────────────────

  Future<bool> isLoggedIn() async {
    return await _storage.hasTokens();
  }

  Future<KullaniciBilgi?> getCurrentUser() async {
    return await _storage.getKullaniciBilgi();
  }

  Future<String?> getKullaniciTipi() async {
    return await _storage.getKullaniciTipi();
  }

  Future<void> saveKullaniciBilgi(KullaniciBilgi bilgi) async {
    await _storage.saveKullaniciBilgi(bilgi);
  }

  // ─── HATA YÖNETİMİ ───────────────────────────────────────────

  ApiResponse<TokenResponse> _handleDioError(DioException e) {
    String mesaj = 'Bağlantı hatası oluştu';

    if (e.response != null && e.response?.data != null) {
      try {
        final data = e.response!.data;
        if (data is Map<String, dynamic> && data.containsKey('mesaj')) {
          mesaj = data['mesaj'];
        }
      } catch (_) {}
    } else if (e.type == DioExceptionType.connectionTimeout) {
      mesaj = 'Sunucuya bağlanılamadı, lütfen internet bağlantınızı kontrol ediniz';
    } else if (e.type == DioExceptionType.connectionError) {
      mesaj = 'Sunucu ile bağlantı kurulamadı';
    }

    return ApiResponse(basarili: false, mesaj: mesaj);
  }
}
