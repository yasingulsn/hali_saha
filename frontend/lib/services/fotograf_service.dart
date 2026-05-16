import 'dart:io';
import 'package:dio/dio.dart';
import '../models/token_response.dart';
import 'api_client.dart';

class FotografService {
  final ApiClient _apiClient;

  FotografService(this._apiClient);

  Future<ApiResponse<String>> profilFotoYukle(File dosya) async {
    try {
      final formData = FormData.fromMap({
        'dosya': await MultipartFile.fromFile(
          dosya.path,
          filename: dosya.path.split('/').last,
        ),
      });
      final response = await _apiClient.dio.post(
        '/api/upload/profil-foto',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      final data = response.data;
      final url = data['veri']?['url'] as String?;
      return ApiResponse(
        basarili: data['basarili'] ?? false,
        mesaj: data['mesaj'] ?? '',
        veri: url,
      );
    } on DioException catch (e) {
      String mesaj = 'Fotoğraf yüklenemedi';
      if (e.response?.data != null && e.response?.data is Map) {
        mesaj = e.response?.data['mesaj'] ?? mesaj;
      }
      return ApiResponse(basarili: false, mesaj: mesaj);
    }
  }

  Future<ApiResponse<String>> sahaFotoYukle(File dosya, String sahaId) async {
    try {
      final formData = FormData.fromMap({
        'dosya': await MultipartFile.fromFile(
          dosya.path,
          filename: dosya.path.split('/').last,
        ),
      });
      final response = await _apiClient.dio.post(
        '/api/upload/saha-foto/$sahaId',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      final data = response.data;
      final url = data['veri']?['url'] as String?;
      return ApiResponse(
        basarili: data['basarili'] ?? false,
        mesaj: data['mesaj'] ?? '',
        veri: url,
      );
    } on DioException catch (e) {
      String mesaj = 'Fotoğraf yüklenemedi';
      if (e.response?.data != null && e.response?.data is Map) {
        mesaj = e.response?.data['mesaj'] ?? mesaj;
      }
      return ApiResponse(basarili: false, mesaj: mesaj);
    }
  }
}
