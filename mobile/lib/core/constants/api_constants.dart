/// Base URL and path constants for the Rahnuma API.
class ApiConstants {
  ApiConstants._();

  /// Override via --dart-define=API_BASE_URL=https://… at build time.
  static const String baseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:4000');

  // ─── Auth ──────────────────────────────────────────────────────────────────
  static const String register = '/api/v1/auth/register';
  static const String login = '/api/v1/auth/login';
  static const String refresh = '/api/v1/auth/refresh';
  static const String logout = '/api/v1/auth/logout';

  // ─── Core ──────────────────────────────────────────────────────────────────
  static const String route = '/api/v1/route';
  static const String routeSnap = '/api/v1/route/snap';
  static const String search = '/api/v1/search';
  static const String searchReverse = '/api/v1/search/reverse';
  static const String events = '/api/v1/events';
  static const String reports = '/api/v1/reports';
  static const String pois = '/api/v1/pois';
  static const String offlinePackages = '/api/v1/offline/packages';

  // ─── WebSocket ─────────────────────────────────────────────────────────────
  static String get wsUrl =>
      baseUrl.replaceFirst(RegExp(r'^http'), 'ws') + '/ws';
}
