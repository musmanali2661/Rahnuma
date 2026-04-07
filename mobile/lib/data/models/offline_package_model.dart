/// Represents an available offline map package (city MBTiles).
class OfflinePackage {
  const OfflinePackage({
    required this.city,
    required this.displayName,
    required this.sizeMb,
    this.isDownloaded = false,
    this.downloadProgress,
  });

  final String city;
  final String displayName;
  final double sizeMb;
  final bool isDownloaded;

  /// 0.0 – 1.0 while downloading; null when idle.
  final double? downloadProgress;

  factory OfflinePackage.fromJson(Map<String, dynamic> json) => OfflinePackage(
        city: json['city'] as String? ?? '',
        displayName: json['display_name'] as String? ??
            (json['city'] as String? ?? ''),
        sizeMb: (json['size_mb'] as num?)?.toDouble() ?? 0,
      );

  OfflinePackage copyWith({
    bool? isDownloaded,
    double? downloadProgress,
  }) =>
      OfflinePackage(
        city: city,
        displayName: displayName,
        sizeMb: sizeMb,
        isDownloaded: isDownloaded ?? this.isDownloaded,
        downloadProgress: downloadProgress,
      );
}
