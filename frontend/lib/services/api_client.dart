import 'package:dio/dio.dart';
import '../models/token_response.dart';
import '../utils/constants.dart';
import 'secure_storage_service.dart';

class ApiClient {
  late final Dio _dio;
  final SecureStorageService _storage = SecureStorageService();
  bool _isRefreshing = false;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onError: _onError,
      ),
    );
  }

  Dio get dio => _dio;

  Future<void> _onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  Future<void> _onError(
      DioException error, ErrorInterceptorHandler handler) async {
    if (error.response?.statusCode != 401 || _isRefreshing) {
      handler.next(error);
      return;
    }

    _isRefreshing = true;
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        await _storage.clearAll();
        handler.next(error);
        return;
      }

      final response = await Dio(
        BaseOptions(baseUrl: ApiConstants.baseUrl),
      ).post(
        ApiConstants.tokenYenile,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data['basarili'] == true) {
        final veri = response.data['veri'] as Map<String, dynamic>;
        final tokenResponse = TokenResponse.fromJson(veri);

        await _storage.saveTokens(tokenResponse);

        final retryOptions = error.requestOptions;
        retryOptions.headers['Authorization'] =
            'Bearer ${tokenResponse.accessToken}';

        final retryResponse = await _dio.fetch(retryOptions);
        handler.resolve(retryResponse);
      } else {
        await _storage.clearAll();
        handler.next(error);
      }
    } catch (e) {
      await _storage.clearAll();
      handler.next(error);
    } finally {
      _isRefreshing = false;
    }
  }
}
