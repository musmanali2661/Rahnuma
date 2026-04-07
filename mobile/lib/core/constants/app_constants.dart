/// App-wide constants for Rahnuma Navigation.
class AppConstants {
  AppConstants._();

  // ─── Map defaults ──────────────────────────────────────────────────────────
  /// Default centre: Lahore, Pakistan
  static const double defaultLat = 31.5204;
  static const double defaultLon = 74.3587;
  static const double defaultZoom = 13.0;

  // ─── OSM tile template ─────────────────────────────────────────────────────
  static const String osmTileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String osmTileAttribution =
      '© OpenStreetMap contributors';

  // ─── IMU thresholds ────────────────────────────────────────────────────────
  /// Acceleration magnitude (m/s²) above which a road event is classified.
  static const double imuPotholeThreshold = 15.0;
  static const double imuSpeedBumpThreshold = 10.0;
  /// Minimum speed (km/h) at which IMU events are recorded.
  static const double imuMinSpeedKmh = 5.0;
  /// Minimum interval between consecutive events at the same location (seconds).
  static const int imuEventCooldownSec = 5;
  /// Batch size before uploading IMU events to the server.
  static const int imuBatchSize = 20;

  // ─── Navigation ────────────────────────────────────────────────────────────
  /// Distance (metres) from a waypoint at which it is considered reached.
  static const double waypointReachedRadiusM = 30.0;
  /// Distance (metres) from the route at which re-routing is triggered.
  static const double offRouteThresholdM = 50.0;

  // ─── Offline packages ──────────────────────────────────────────────────────
  static const String offlineDbName = 'rahnuma_offline.db';

  // ─── Shared-prefs keys ─────────────────────────────────────────────────────
  static const String prefLanguageCode = 'language_code';
  static const String prefAccessToken = 'access_token';
  static const String prefRefreshToken = 'refresh_token';
  static const String prefRecentSearches = 'recent_searches';
}
