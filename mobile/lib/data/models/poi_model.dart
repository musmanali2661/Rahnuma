/// A Point of Interest returned by the backend.
class PoiModel {
  const PoiModel({
    required this.id,
    required this.name,
    required this.lat,
    required this.lon,
    required this.category,
    this.nameUr,
    this.subcategory,
    this.ratingAvg,
    this.ratingCount,
    this.phone,
    this.openingHours,
  });

  final String id;
  final String name;
  final double lat;
  final double lon;
  final String category;
  final String? nameUr;
  final String? subcategory;
  final double? ratingAvg;
  final int? ratingCount;
  final String? phone;
  final String? openingHours;

  factory PoiModel.fromJson(Map<String, dynamic> json) => PoiModel(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        nameUr: json['name_ur'] as String?,
        lat: (json['lat'] as num?)?.toDouble() ?? 0,
        lon: (json['lon'] as num?)?.toDouble() ?? 0,
        category: json['category'] as String? ?? '',
        subcategory: json['subcategory'] as String?,
        ratingAvg: (json['rating_avg'] as num?)?.toDouble(),
        ratingCount: json['rating_count'] as int?,
        phone: json['phone'] as String?,
        openingHours: json['opening_hours'] as String?,
      );
}
