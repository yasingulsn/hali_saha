import 'package:dio/dio.dart';
import '../models/takim_ilani.dart';
import '../models/token_response.dart';
import 'api_client.dart';

class TakimIlaniService {
  final ApiClient _apiClient;
  static const _basePath = '/api/takim-ilanlari';

  TakimIlaniService(this._apiClient);

  Future<ApiResponse<List<TakimIlani>>> aktifIlanlar() async {
    try {
      final response = await _apiClient.dio.get(_basePath);
      return _parseList(response);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<ApiResponse<TakimIlani>> ilanDetay(String ilanId) async {
    try {
      final response = await _apiClient.dio.get('$_basePath/$ilanId');
      final data = response.data;
      return ApiResponse(
        basarili: data['basarili'] ?? false,
        mesaj: data['mesaj'] ?? '',
        veri: data['veri'] != null ? TakimIlani.fromJson(data['veri']) : null,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<ApiResponse<List<TakimIlani>>> benimIlanlarim() async {
    try {
      final response = await _apiClient.dio.get('$_basePath/benim');
      return _parseList(response);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<ApiResponse<TakimIlani>> ilanOlustur(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post(_basePath, data: data);
      final respData = response.data;
      return ApiResponse(
        basarili: respData['basarili'] ?? false,
        mesaj: respData['mesaj'] ?? '',
        veri: respData['veri'] != null ? TakimIlani.fromJson(respData['veri']) : null,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<ApiResponse<void>> ilanKapat(String ilanId) async {
    try {
      final response = await _apiClient.dio.post('$_basePath/$ilanId/kapat');
      final data = response.data;
      return ApiResponse(basarili: data['basarili'] ?? false, mesaj: data['mesaj'] ?? '');
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<ApiResponse<TakimIlani>> ilanGuncelle(String ilanId, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.put('$_basePath/$ilanId', data: data);
      final respData = response.data;
      return ApiResponse(
        basarili: respData['basarili'] ?? false,
        mesaj: respData['mesaj'] ?? '',
        veri: respData['veri'] != null ? TakimIlani.fromJson(respData['veri']) : null,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<ApiResponse<void>> ilanSil(String ilanId) async {
    try {
      final response = await _apiClient.dio.delete('$_basePath/$ilanId');
      final data = response.data;
      return ApiResponse(
        basarili: data['basarili'] ?? false,
        mesaj: data['mesaj'] ?? '',
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  ApiResponse<List<TakimIlani>> _parseList(Response response) {
    final data = response.data;
    final list = data['veri'] != null
        ? (data['veri'] as List).map((e) => TakimIlani.fromJson(e)).toList()
        : <TakimIlani>[];
    return ApiResponse(basarili: data['basarili'] ?? false, mesaj: data['mesaj'] ?? '', veri: list);
  }

  ApiResponse<T> _handleError<T>(DioException e) {
    String mesaj = 'Bağlantı hatası';
    if (e.response?.data != null && e.response?.data is Map) {
      mesaj = e.response?.data['mesaj'] ?? mesaj;
    }
    return ApiResponse(basarili: false, mesaj: mesaj);
  }
}
