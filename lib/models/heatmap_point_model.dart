/// Model representasi titik Heatmap dari API.
///
/// Digunakan oleh `getHeatmap` di [ApiService] untuk menampilkan
/// peta panas lokasi penjualan.
class HeatmapPoint {
  final double latitude;
  final double longitude;
  final int totalSales;
  final int transactionCount;

  const HeatmapPoint({
    required this.latitude,
    required this.longitude,
    required this.totalSales,
    required this.transactionCount,
  });

  /// Parse dari JSON response API.
  factory HeatmapPoint.fromJson(Map<String, dynamic> json) {
    return HeatmapPoint(
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      totalSales: json['total_sales'] ?? 0,
      transactionCount: json['transaction_count'] ?? 0,
    );
  }

  /// Konversi ke Map.
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'total_sales': totalSales,
      'transaction_count': transactionCount,
    };
  }

  @override
  String toString() =>
      'HeatmapPoint(lat: $latitude, lng: $longitude, sales: $totalSales, count: $transactionCount)';
}
