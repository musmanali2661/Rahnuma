import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../core/constants.dart';
import '../models/search_result.dart';
import '../models/route_model.dart';
import '../models/road_event.dart';

/// HTTP client for all Rahnuma backend API calls.
class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: kApiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }

  // ── Search ──────────────────────────────────────────────────────────────────

  /// Search for places by query.
  ///
  /// [q] may be English or Roman Urdu.
  /// Optionally provide [lat]/[lon] to bias results toward the user's location.
  Future<List<SearchResult>> search(
    String q, {
    double? lat,
    double? lon,
    int limit = 10,
    String? category,
  }) async {
    final queryParams = <String, dynamic>{'q': q, 'limit': limit};
    if (lat != null) queryParams['lat'] = lat;
    if (lon != null) queryParams['lon'] = lon;
    if (category != null) queryParams['category'] = category;

    final response = await _dio.get<List<dynamic>>(
      '/api/v1/search',
      queryParameters: queryParams,
    );
    return (response.data ?? [])
        .map((e) => SearchResult.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Reverse-geocode a coordinate to the nearest address.
  Future<SearchResult?> reverseGeocode(double lat, double lon) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/search/reverse',
      queryParameters: {'lat': lat, 'lon': lon},
    );
    if (response.data == null) return null;
    return SearchResult.fromJson(response.data!);
  }

  // ── Routing ─────────────────────────────────────────────────────────────────

  /// Calculate a route between [waypoints].
  ///
  /// Each waypoint is a map with 'lat' and 'lon' keys.
  Future<List<RouteModel>> getRoute(
    List<Map<String, double>> waypoints, {
    String profile = 'car',
    bool alternatives = false,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/route',
      data: {
        'waypoints': waypoints,
        'profile': profile,
        'alternatives': alternatives,
      },
    );
    final routes = response.data?['routes'] as List<dynamic>? ?? [];
    return routes
        .map((r) => RouteModel.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  // ── Road events ─────────────────────────────────────────────────────────────

  /// Fetch verified road events within a bounding box.
  Future<List<RoadEvent>> getEvents({
    required double minLat,
    required double minLon,
    required double maxLat,
    required double maxLon,
    String? type,
  }) async {
    final queryParams = <String, dynamic>{
      'minLat': minLat,
      'minLon': minLon,
      'maxLat': maxLat,
      'maxLon': maxLon,
    };
    if (type != null) queryParams['type'] = type;

    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/events',
      queryParameters: queryParams,
    );
    final events = response.data?['events'] as List<dynamic>? ?? [];
    return events
        .map((e) => RoadEvent.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Submit road events detected via IMU.
  ///
  /// Requires a valid [bearerToken].
  Future<void> submitEvents(
    List<RoadEvent> events, {
    required String bearerToken,
  }) async {
    await _dio.post<void>(
      '/api/v1/events',
      data: {'events': events.map((e) => e.toJson()).toList()},
      options: Options(headers: {'Authorization': 'Bearer $bearerToken'}),
    );
  }

  // ── Offline packages ─────────────────────────────────────────────────────────

  /// List available offline map packages.
  Future<List<OfflinePackage>> listOfflinePackages() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/offline/packages',
    );
    final packages = response.data?['packages'] as List<dynamic>? ?? [];
    return packages
        .map((p) => OfflinePackage.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  /// Download an offline map package for a city and save it to device storage.
  ///
  /// [onProgress] receives values from 0.0 to 1.0 as the download progresses.
  Future<String> downloadOfflinePackage(
    String cityId, {
    void Function(double progress)? onProgress,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final savePath = '${dir.path}/offline_$cityId.mbtiles';

    await _dio.download(
      '/api/v1/offline/packages/$cityId',
      savePath,
      onReceiveProgress: (received, total) {
        if (total > 0 && onProgress != null) {
          onProgress(received / total);
        }
      },
    );

    return savePath;
  }
}


/// HTTP client for all Rahnuma backend API calls.
class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: kApiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }

  // ── Search ──────────────────────────────────────────────────────────────────

  /// Search for places by query.
  ///
  /// [q] may be English or Roman Urdu.
  /// Optionally provide [lat]/[lon] to bias results toward the user's location.
  Future<List<SearchResult>> search(
    String q, {
    double? lat,
    double? lon,
    int limit = 10,
    String? category,
  }) async {
    final queryParams = <String, dynamic>{'q': q, 'limit': limit};
    if (lat != null) queryParams['lat'] = lat;
    if (lon != null) queryParams['lon'] = lon;
    if (category != null) queryParams['category'] = category;

    final response = await _dio.get<List<dynamic>>(
      '/api/v1/search',
      queryParameters: queryParams,
    );
    return (response.data ?? [])
        .map((e) => SearchResult.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Reverse-geocode a coordinate to the nearest address.
  Future<SearchResult?> reverseGeocode(double lat, double lon) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/search/reverse',
      queryParameters: {'lat': lat, 'lon': lon},
    );
    if (response.data == null) return null;
    return SearchResult.fromJson(response.data!);
  }

  // ── Routing ─────────────────────────────────────────────────────────────────

  /// Calculate a route between [waypoints].
  ///
  /// Each waypoint is a map with 'lat' and 'lon' keys.
  Future<List<RouteModel>> getRoute(
    List<Map<String, double>> waypoints, {
    String profile = 'car',
    bool alternatives = false,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/route',
      data: {
        'waypoints': waypoints,
        'profile': profile,
        'alternatives': alternatives,
      },
    );
    final routes = response.data?['routes'] as List<dynamic>? ?? [];
    return routes
        .map((r) => RouteModel.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  // ── Road events ─────────────────────────────────────────────────────────────

  /// Fetch verified road events within a bounding box.
  Future<List<RoadEvent>> getEvents({
    required double minLat,
    required double minLon,
    required double maxLat,
    required double maxLon,
    String? type,
  }) async {
    final queryParams = <String, dynamic>{
      'minLat': minLat,
      'minLon': minLon,
      'maxLat': maxLat,
      'maxLon': maxLon,
    };
    if (type != null) queryParams['type'] = type;

    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/events',
      queryParameters: queryParams,
    );
    final events = response.data?['events'] as List<dynamic>? ?? [];
    return events
        .map((e) => RoadEvent.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Submit road events detected via IMU.
  ///
  /// Requires a valid [bearerToken].
  Future<void> submitEvents(
    List<RoadEvent> events, {
    required String bearerToken,
  }) async {
    await _dio.post<void>(
      '/api/v1/events',
      data: {'events': events.map((e) => e.toJson()).toList()},
      options: Options(headers: {'Authorization': 'Bearer $bearerToken'}),
    );
  }

  // ── Offline packages ─────────────────────────────────────────────────────────

  /// List available offline map packages.
  Future<List<OfflinePackage>> listOfflinePackages() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/offline/packages',
    );
    final packages = response.data?['packages'] as List<dynamic>? ?? [];
    return packages
        .map((p) => OfflinePackage.fromJson(p as Map<String, dynamic>))
        .toList();
  }
}
