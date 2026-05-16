import 'package:dio/dio.dart';
import '../models/saha.dart';
import '../models/saha_yorum.dart';
import '../models/token_response.dart';
import '../utils/constants.dart';
import 'api_client.dart';

class SahaService {
  final ApiClient _apiClient;

  SahaService(this._apiClient);

  Future<ApiResponse<List<Saha>>> tumSahalar({int page = 0, int size = 0}) async {
    try {
      final queryParams = size > 0 ? {'page': page, 'size': size} : null;
      final response = await _apiClient.dio.get(ApiConstants.sahalar, queryParameters: queryParams);
      return _parseListResponse(response);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<ApiResponse<Saha>> sahaDetay(String sahaId) async {
    try {
      final response = await _apiClient.dio.get('${ApiConstants.sahalar}/$sahaId');
      final data = response.data;
      return ApiResponse(
        basarili: data['basarili'] ?? false,
        mesaj: data['mesaj'] ?? '',
        veri: data['veri'] != null ? Saha.fromJson(data['veri']) : null,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<ApiResponse<List<Saha>>> sahalarAra(String query) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.sahalarAra,
        queryParameters: {'q': query},
      );
      return _parseListResponse(response);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<ApiResponse<List<SahaYorum>>> sahaYorumlari(String sahaId) async {
    try {
      final response = await _apiClient.dio.get('${ApiConstants.sahalar}/$sahaId/yorumlar');
      final data = response.data;
      final List<SahaYorum> yorumlar = data['veri'] != null
          ? (data['veri'] as List).map((e) => SahaYorum.fromJson(e)).toList()
          : [];
      return ApiResponse(basarili: data['basarili'] ?? false, mesaj: data['mesaj'] ?? '', veri: yorumlar);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<ApiResponse<SahaYorum>> yorumEkle(String sahaId, int puan, String? yorum) async {
    try {
      final response = await _apiClient.dio.post(
        '${ApiConstants.sahalar}/$sahaId/yorum',
        data: {'puan': puan, if (yorum != null && yorum.isNotEmpty) 'yorum': yorum},
      );
      final data = response.data;
      return ApiResponse(
        basarili: data['basarili'] ?? false,
        mesaj: data['mesaj'] ?? '',
        veri: data['veri'] != null ? SahaYorum.fromJson(data['veri']) : null,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<ApiResponse<Saha>> sahaEkle(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post(ApiConstants.sahalar, data: data);
      final respData = response.data;
      return ApiResponse(
        basarili: respData['basarili'] ?? false,
        mesaj: respData['mesaj'] ?? '',
        veri: respData['veri'] != null ? Saha.fromJson(respData['veri']) : null,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  ApiResponse<List<Saha>> _parseListResponse(Response response) {
    final data = response.data;
    final List<Saha> sahalar = data['veri'] != null
        ? (data['veri'] as List).map((e) => Saha.fromJson(e)).toList()
        : [];
    return ApiResponse(
      basarili: data['basarili'] ?? false,
      mesaj: data['mesaj'] ?? '',
      veri: sahalar,
    );
  }

  ApiResponse<T> _handleError<T>(DioException e) {
    String mesaj = 'Bağlantı hatası';
    if (e.response?.data != null && e.response?.data is Map) {
      mesaj = e.response?.data['mesaj'] ?? mesaj;
    }
    return ApiResponse(basarili: false, mesaj: mesaj);
  }
}
