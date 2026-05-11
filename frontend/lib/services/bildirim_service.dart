import 'package:dio/dio.dart';
import '../models/bildirim.dart';
import '../models/token_response.dart';
import '../utils/constants.dart';
import 'api_client.dart';

class BildirimService {
  final ApiClient _apiClient;

  BildirimService(this._apiClient);

  Future<ApiResponse<List<Bildirim>>> getBildirimler() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.bildirimler);
      final data = response.data;
      final List<Bildirim> list = data['veri'] != null
          ? (data['veri'] as List).map((e) => Bildirim.fromJson(e)).toList()
          : [];
      return ApiResponse(basarili: data['basarili'] ?? false, mesaj: data['mesaj'] ?? '', veri: list);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<ApiResponse<int>> getOkunmamisSayisi() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.bildirimOkunmamisSayisi);
      final data = response.data;
      return ApiResponse(basarili: data['basarili'] ?? false, mesaj: data['mesaj'] ?? '', veri: data['veri'] as int?);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<ApiResponse<void>> okunduIsaretle(String id) async {
    try {
      final response = await _apiClient.dio.post(ApiConstants.bildirimOku(id));
      final data = response.data;
      return ApiResponse(basarili: data['basarili'] ?? false, mesaj: data['mesaj'] ?? '');
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<ApiResponse<void>> hepsiniOkunduIsaretle() async {
    try {
      final response = await _apiClient.dio.post(ApiConstants.bildirimHepsiniOku);
      final data = response.data;
      return ApiResponse(basarili: data['basarili'] ?? false, mesaj: data['mesaj'] ?? '');
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<ApiResponse<void>> sil(String id) async {
    try {
      final response = await _apiClient.dio.delete(ApiConstants.bildirimSil(id));
      final data = response.data;
      return ApiResponse(basarili: data['basarili'] ?? false, mesaj: data['mesaj'] ?? '');
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  ApiResponse<T> _handleError<T>(DioException e) {
    String mesaj = 'Bağlantı hatası';
    if (e.response?.data != null && e.response?.data is Map) {
      mesaj = e.response?.data['mesaj'] ?? mesaj;
    }
    return ApiResponse(basarili: false, mesaj: mesaj);
  }
}
