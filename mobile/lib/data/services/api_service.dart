import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_constants.dart';
import '../models/route_model.dart';
import '../models/place_model.dart';
import '../models/road_event_model.dart';
import '../models/poi_model.dart';
import '../models/offline_package_model.dart';

/// Central HTTP client wrapping the Rahnuma REST API.
///
/// Handles authentication headers, token refresh, and JSON deserialization.
class ApiService {
  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    _dio.interceptors.add(_AuthInterceptor(_dio));
  }

  late final Dio _dio;

  // ─── Auth ──────────────────────────────────────────────────────────────────

  Future<Map<String, String>> register({
    String? email,
    String? phone,
    required String password,
    String? name,
  }) async {
    final res = await _dio.post(ApiConstants.register, data: {
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      'password': password,
      if (name != null) 'name': name,
    });
    return {
      'accessToken': res.data['accessToken'] as String,
      'refreshToken': res.data['refreshToken'] as String,
    };
  }

  Future<Map<String, String>> login({
    String? email,
    String? phone,
    required String password,
  }) async {
    final res = await _dio.post(ApiConstants.login, data: {
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      'password': password,
    });
    return {
      'accessToken': res.data['accessToken'] as String,
      'refreshToken': res.data['refreshToken'] as String,
    };
  }

  // ─── Route ─────────────────────────────────────────────────────────────────

  /// Returns a list of routes (first is the recommended one).
  Future<List<RouteModel>> getRoute(
    List<LatLon> waypoints, {
    String profile = 'car',
    bool alternatives = false,
  }) async {
    final res = await _dio.post(ApiConstants.route, data: {
      'waypoints': waypoints.map((w) => w.toJson()).toList(),
      'profile': profile,
      'alternatives': alternatives,
    });
    final routes = (res.data['routes'] as List<dynamic>? ?? []);
    return routes
        .map((r) => RouteModel.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  // ─── Search ────────────────────────────────────────────────────────────────

  Future<List<PlaceModel>> search(
    String query, {
    double? lat,
    double? lon,
    int limit = 10,
    String? category,
  }) async {
    final res = await _dio.get(ApiConstants.search, queryParameters: {
      'q': query,
      'limit': limit,
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
      if (category != null) 'category': category,
    });
    final features = res.data['features'] as List<dynamic>? ?? [];
    return features
        .map((f) => PlaceModel.fromJson(f as Map<String, dynamic>))
        .toList();
  }

  Future<PlaceModel?> reverseGeocode(double lat, double lon) async {
    try {
      final res = await _dio.get(ApiConstants.searchReverse,
          queryParameters: {'lat': lat, 'lon': lon});
      return PlaceModel.fromJson(res.data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  // ─── Road Events ───────────────────────────────────────────────────────────

  Future<List<RoadEventModel>> getEvents({
    required double minLat,
    required double minLon,
    required double maxLat,
    required double maxLon,
    String? type,
  }) async {
    final res = await _dio.get(ApiConstants.events, queryParameters: {
      'minLat': minLat,
      'minLon': minLon,
      'maxLat': maxLat,
      'maxLon': maxLon,
      if (type != null) 'type': type,
    });
    final events = res.data['events'] as List<dynamic>? ?? [];
    return events
        .map((e) => RoadEventModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<int> submitEvents(List<RoadEventModel> events) async {
    final res = await _dio.post(ApiConstants.events, data: {
      'events': events.map((e) => e.toJson()).toList(),
    });
    return res.data['inserted'] as int? ?? 0;
  }

  // ─── Reports ───────────────────────────────────────────────────────────────

  Future<String> submitReport({
    required double lat,
    required double lon,
    required String reportType,
    String? description,
    String severity = 'moderate',
  }) async {
    final res = await _dio.post(ApiConstants.reports, data: {
      'lat': lat,
      'lon': lon,
      'report_type': reportType,
      if (description != null) 'description': description,
      'severity': severity,
    });
    return res.data['id'] as String;
  }

  Future<List<Map<String, dynamic>>> getReports({
    required double minLat,
    required double minLon,
    required double maxLat,
    required double maxLon,
    String? type,
  }) async {
    final res = await _dio.get(ApiConstants.reports, queryParameters: {
      'minLat': minLat,
      'minLon': minLon,
      'maxLat': maxLat,
      'maxLon': maxLon,
      if (type != null) 'type': type,
    });
    return (res.data['reports'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
  }

  // ─── POIs ──────────────────────────────────────────────────────────────────

  Future<List<PoiModel>> getPois({
    required double minLat,
    required double minLon,
    required double maxLat,
    required double maxLon,
    String? category,
    int limit = 50,
  }) async {
    final res = await _dio.get(ApiConstants.pois, queryParameters: {
      'minLat': minLat,
      'minLon': minLon,
      'maxLat': maxLat,
      'maxLon': maxLon,
      if (category != null) 'category': category,
      'limit': limit,
    });
    final pois = res.data['pois'] as List<dynamic>? ?? [];
    return pois
        .map((p) => PoiModel.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  // ─── Offline packages ──────────────────────────────────────────────────────

  Future<List<OfflinePackage>> listOfflinePackages() async {
    final res = await _dio.get(ApiConstants.offlinePackages);
    final packages = res.data['packages'] as List<dynamic>? ?? [];
    return packages
        .map((p) => OfflinePackage.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  Future<void> downloadPackage(
    String city,
    String savePath,
    void Function(int received, int total) onProgress,
  ) async {
    await _dio.download(
      '${ApiConstants.offlinePackages}/$city',
      savePath,
      onReceiveProgress: onProgress,
    );
  }

  // ─── Internals ─────────────────────────────────────────────────────────────

  Dio get dio => _dio;
}

/// Dio interceptor that injects the Bearer token and handles 401 refresh.
class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._dio);

  final Dio _dio;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.prefAccessToken);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      // Attempt silent token refresh
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(AppConstants.prefRefreshToken);
      if (refreshToken != null) {
        try {
          final res = await Dio().post(
            '${ApiConstants.baseUrl}${ApiConstants.refresh}',
            data: {'refreshToken': refreshToken},
          );
          final newToken = res.data['accessToken'] as String;
          await prefs.setString(AppConstants.prefAccessToken, newToken);
          // Retry original request
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          final response = await _dio.fetch(err.requestOptions);
          return handler.resolve(response);
        } catch (_) {
          // Refresh failed – clear tokens
          await prefs.remove(AppConstants.prefAccessToken);
          await prefs.remove(AppConstants.prefRefreshToken);
        }
      }
    }
    handler.next(err);
  }
}
