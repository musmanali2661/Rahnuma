import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/constants/app_constants.dart';

/// Manages offline map package metadata in a local SQLite database.
///
/// The actual MBTiles files are stored in the app's documents directory.
/// This service tracks which cities have been downloaded and their file paths.
class OfflineDbService {
  OfflineDbService._();

  static final OfflineDbService instance = OfflineDbService._();

  Database? _db;

  Future<Database> get _database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/${AppConstants.offlineDbName}';
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, _) => db.execute('''
        CREATE TABLE offline_packages (
          city TEXT PRIMARY KEY,
          display_name TEXT NOT NULL,
          size_mb REAL NOT NULL,
          file_path TEXT NOT NULL,
          downloaded_at TEXT NOT NULL
        )
      '''),
    );
  }

  /// Mark a city as downloaded and record its file path.
  Future<void> markDownloaded({
    required String city,
    required String displayName,
    required double sizeMb,
    required String filePath,
  }) async {
    final db = await _database;
    await db.insert(
      'offline_packages',
      {
        'city': city,
        'display_name': displayName,
        'size_mb': sizeMb,
        'file_path': filePath,
        'downloaded_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Return a set of city slugs that have been downloaded.
  Future<Set<String>> downloadedCities() async {
    final db = await _database;
    final rows = await db.query('offline_packages', columns: ['city']);
    return rows.map((r) => r['city'] as String).toSet();
  }

  /// Return the file path for a downloaded city, or null if not found.
  Future<String?> pathForCity(String city) async {
    final db = await _database;
    final rows = await db.query(
      'offline_packages',
      columns: ['file_path'],
      where: 'city = ?',
      whereArgs: [city],
    );
    return rows.isEmpty ? null : rows.first['file_path'] as String;
  }

  /// Delete the MBTiles file and remove the record.
  Future<void> removePackage(String city) async {
    final filePath = await pathForCity(city);
    if (filePath != null) {
      final file = File(filePath);
      if (await file.exists()) await file.delete();
    }
    final db = await _database;
    await db.delete('offline_packages', where: 'city = ?', whereArgs: [city]);
  }

  /// Compute the file path where a city package should be saved.
  Future<String> packageSavePath(String city) async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/${city}.mbtiles';
  }
}
