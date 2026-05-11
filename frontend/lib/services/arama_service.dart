import 'package:dio/dio.dart';
import '../models/mac.dart';
import '../models/saha.dart';
import '../models/takim_ilani.dart';
import '../models/token_response.dart';
import '../utils/constants.dart';
import 'api_client.dart';

class AramaSonuc {
  final List<Saha> sahalar;
  final List<Mac> maclar;
  final List<OyuncuSonuc> oyuncular;
  final List<TakimIlani> ilanlar;

  AramaSonuc({
    required this.sahalar,
    required this.maclar,
    required this.oyuncular,
    required this.ilanlar,
  });

  factory AramaSonuc.fromJson(Map<String, dynamic> json) {
    return AramaSonuc(
      sahalar: json['sahalar'] != null
          ? (json['sahalar'] as List).map((e) => Saha.fromJson(e)).toList()
          : [],
      maclar: json['maclar'] != null
          ? (json['maclar'] as List).map((e) => Mac.fromJson(e)).toList()
          : [],
      oyuncular: json['oyuncular'] != null
          ? (json['oyuncular'] as List).map((e) => OyuncuSonuc.fromJson(e)).toList()
          : [],
      ilanlar: json['ilanlar'] != null
          ? (json['ilanlar'] as List).map((e) => TakimIlani.fromJson(e)).toList()
          : [],
    );
  }

  int get toplamSonuc => sahalar.length + maclar.length + oyuncular.length + ilanlar.length;
}

class OyuncuSonuc {
  final String id;
  final String adSoyad;
  final String? profilFotoUrl;
  final double puanOrtalamasi;
  final double disiplinPuani;
  final String? tercihEdilenPozisyon;

  OyuncuSonuc({
    required this.id,
    required this.adSoyad,
    this.profilFotoUrl,
    this.puanOrtalamasi = 0,
    this.disiplinPuani = 0,
    this.tercihEdilenPozisyon,
  });

  factory OyuncuSonuc.fromJson(Map<String, dynamic> json) {
    return OyuncuSonuc(
      id: json['id'] ?? '',
      adSoyad: json['adSoyad'] ?? '',
      profilFotoUrl: json['profilFotoUrl'],
      puanOrtalamasi: (json['puanOrtalamasi'] as num?)?.toDouble() ?? 0,
      disiplinPuani: (json['disiplinPuani'] as num?)?.toDouble() ?? 0,
      tercihEdilenPozisyon: json['tercihEdilenPozisyon'],
    );
  }
}

class AramaService {
  final ApiClient _apiClient;

  AramaService(this._apiClient);

  Future<ApiResponse<AramaSonuc>> birlesikArama(String query, {String? tip, String? il, String? ilce}) async {
    try {
      final params = <String, dynamic>{};
      if (query.isNotEmpty) params['q'] = query;
      if (tip != null) params['tip'] = tip;
      if (il != null && il.isNotEmpty) params['il'] = il;
      if (ilce != null && ilce.isNotEmpty) params['ilce'] = ilce;

      final response = await _apiClient.dio.get(
        ApiConstants.birlesikArama,
        queryParameters: params,
      );
      final data = response.data;
      return ApiResponse(
        basarili: data['basarili'] ?? false,
        mesaj: data['mesaj'] ?? '',
        veri: data['veri'] != null ? AramaSonuc.fromJson(data['veri']) : null,
      );
    } on DioException catch (e) {
      String mesaj = 'Bağlantı hatası';
      if (e.response?.data != null && e.response?.data is Map) {
        mesaj = e.response?.data['mesaj'] ?? mesaj;
      }
      return ApiResponse(basarili: false, mesaj: mesaj);
    }
  }
}
