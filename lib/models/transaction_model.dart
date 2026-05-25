/// Model item dalam satu transaksi.
class TransactionItem {
  final int productId;
  final String productName;
  final int quantity;
  final int price;
  final int subtotal;

  const TransactionItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.subtotal,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      productId: json['product_id'] ?? 0,
      productName: json['product_name'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: json['price'] ?? 0,
      subtotal: json['subtotal'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'price': price,
      'subtotal': subtotal,
    };
  }
}

/// Model representasi Transaksi dari API.
///
/// Field diambil dari parameter `createTransaction` dan
/// `getTransactionDetail` di [ApiService].
class Transaction {
  final int id;
  final double latitude;
  final double longitude;
  final String paymentMethod;
  final int totalAmount;
  final List<TransactionItem> items;
  final String? createdAt;

  const Transaction({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.paymentMethod,
    required this.totalAmount,
    required this.items,
    this.createdAt,
  });

  /// Parse dari JSON response API.
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? 0,
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      paymentMethod: json['payment_method'] ?? '',
      totalAmount: json['total_amount'] ?? 0,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => TransactionItem.fromJson(e))
              .toList() ??
          [],
      createdAt: json['created_at'],
    );
  }

  /// Konversi ke Map untuk pengiriman ke API.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'payment_method': paymentMethod,
      'total_amount': totalAmount,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }

  /// Jumlah total item dalam transaksi.
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  @override
  String toString() =>
      'Transaction(id: $id, totalAmount: $totalAmount, items: ${items.length})';
}
