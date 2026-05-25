/// Model representasi Stock Alert dari API.
///
/// Digunakan oleh `getStockAlerts` dan `markAlertAsRead` di [ApiService].
class StockAlert {
  final int id;
  final int productId;
  final String productName;
  final int currentStock;
  final int minStock;
  final bool isRead;
  final String? createdAt;

  const StockAlert({
    required this.id,
    required this.productId,
    required this.productName,
    required this.currentStock,
    required this.minStock,
    required this.isRead,
    this.createdAt,
  });

  /// Parse dari JSON response API.
  factory StockAlert.fromJson(Map<String, dynamic> json) {
    return StockAlert(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      productName: json['product_name'] ?? '',
      currentStock: json['current_stock'] ?? 0,
      minStock: json['min_stock'] ?? 0,
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'],
    );
  }

  /// Konversi ke Map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'current_stock': currentStock,
      'min_stock': minStock,
      'is_read': isRead,
    };
  }

  /// Buat salinan dengan isRead di-update (setelah markAsRead).
  StockAlert copyWith({bool? isRead}) {
    return StockAlert(
      id: id,
      productId: productId,
      productName: productName,
      currentStock: currentStock,
      minStock: minStock,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }

  @override
  String toString() =>
      'StockAlert(id: $id, product: $productName, stock: $currentStock/$minStock, read: $isRead)';
}
