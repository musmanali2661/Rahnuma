import 'package:latlong2/latlong.dart';

/// Base URL for the Rahnuma backend API.
/// Override with RAHNUMA_API_URL environment variable in production.
const String kApiBaseUrl =
    String.fromEnvironment('RAHNUMA_API_URL', defaultValue: 'http://localhost:4000');

/// Base URL for the ML classification service.
const String kMlServiceUrl =
    String.fromEnvironment('RAHNUMA_ML_URL', defaultValue: 'http://localhost:8000');

/// Default map center — geographic centre of Pakistan.
const LatLng kPakistanCenter = LatLng(30.3753, 69.3451);

/// Default zoom level when the app launches.
const double kDefaultZoom = 5.0;

/// Zoom level when the app zooms to the user's location.
const double kNavigationZoom = 16.0;

/// Distance in metres below which a turn announcement is triggered.
const double kAnnounceTurnDistanceM = 200.0;

/// IMU sampling interval in milliseconds (~20 Hz).
const int kImuSampleIntervalMs = 50;

/// Number of IMU readings to batch before sending to the ML service.
const int kImuBatchSize = 100;

/// Minimum distance change (metres) before a new GPS point is recorded.
const double kGpsDistanceFilterM = 10.0;
