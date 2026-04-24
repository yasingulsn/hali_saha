import 'package:dio/dio.dart';
import '../models/mac.dart';
import '../models/token_response.dart';
import '../utils/constants.dart';
import 'api_client.dart';

class MacService {
  final ApiClient _apiClient;

  MacService(this._apiClient);

  Future<ApiResponse<List<Mac>>> acikMaclar() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.maclar);
      return _parseListResponse(response);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<ApiResponse<Mac>> macDetay(String macId) async {
    try {
      final response = await _apiClient.dio.get('${ApiConstants.maclar}/$macId');
      final data = response.data;
      return ApiResponse(
        basarili: data['basarili'] ?? false,
        mesaj: data['mesaj'] ?? '',
        veri: data['veri'] != null ? Mac.fromJson(data['veri']) : null,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<ApiResponse<List<Mac>>> benimMaclarim() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.benimMaclarim);
      return _parseListResponse(response);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<ApiResponse<Mac>> macOlustur(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post(ApiConstants.maclar, data: data);
      final respData = response.data;
      return ApiResponse(
        basarili: respData['basarili'] ?? false,
        mesaj: respData['mesaj'] ?? '',
        veri: respData['veri'] != null ? Mac.fromJson(respData['veri']) : null,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<ApiResponse<Mac>> macGuncelle(String macId, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.put('${ApiConstants.maclar}/$macId', data: data);
      final respData = response.data;
      return ApiResponse(
        basarili: respData['basarili'] ?? false,
        mesaj: respData['mesaj'] ?? '',
        veri: respData['veri'] != null ? Mac.fromJson(respData['veri']) : null,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<ApiResponse<void>> macSil(String macId) async {
    try {
      final response = await _apiClient.dio.delete('${ApiConstants.maclar}/$macId');
      final data = response.data;
      return ApiResponse(
        basarili: data['basarili'] ?? false,
        mesaj: data['mesaj'] ?? '',
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<ApiResponse<Mac>> macaKatil(String macId) async {
    try {
      final response = await _apiClient.dio.post('${ApiConstants.maclar}/$macId/katil');
      final data = response.data;
      return ApiResponse(
        basarili: data['basarili'] ?? false,
        mesaj: data['mesaj'] ?? '',
        veri: data['veri'] != null ? Mac.fromJson(data['veri']) : null,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<ApiResponse<Mac>> mactanAyril(String macId) async {
    try {
      final response = await _apiClient.dio.post('${ApiConstants.maclar}/$macId/ayril');
      final data = response.data;
      return ApiResponse(
        basarili: data['basarili'] ?? false,
        mesaj: data['mesaj'] ?? '',
        veri: data['veri'] != null ? Mac.fromJson(data['veri']) : null,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<ApiResponse<List<Mac>>> maclarAra(String query) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.maclarAra,
        queryParameters: {'q': query},
      );
      return _parseListResponse(response);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<ApiResponse<List<Mac>>> sahaMaclari(String sahaId) async {
    try {
      final response = await _apiClient.dio.get('${ApiConstants.maclar}/saha/$sahaId');
      return _parseListResponse(response);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  ApiResponse<List<Mac>> _parseListResponse(Response response) {
    final data = response.data;
    final List<Mac> maclar = data['veri'] != null
        ? (data['veri'] as List).map((e) => Mac.fromJson(e)).toList()
        : [];
    return ApiResponse(
      basarili: data['basarili'] ?? false,
      mesaj: data['mesaj'] ?? '',
      veri: maclar,
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
