/// A place returned by the search API.
class SearchResult {
  final int placeId;
  final String name;
  final double lat;
  final double lon;
  final String? type;
  final String? category;
  final Map<String, dynamic> address;

  const SearchResult({
    required this.placeId,
    required this.name,
    required this.lat,
    required this.lon,
    this.type,
    this.category,
    this.address = const {},
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      placeId: (json['place_id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      type: json['type'] as String?,
      category: json['class'] as String?,
      address: (json['address'] as Map<String, dynamic>?) ?? {},
    );
  }

  @override
  String toString() => name;
}
