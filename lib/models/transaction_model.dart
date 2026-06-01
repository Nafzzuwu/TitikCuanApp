int _parseInt(dynamic val) {
  if (val == null) return 0;
  if (val is num) return val.toInt();
  if (val is String) {
    return int.tryParse(val) ?? double.tryParse(val)?.toInt() ?? 0;
  }
  return 0;
}

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
    final quantity = _parseInt(json['quantity'] ?? json['qty']);
    final price = _parseInt(json['price']);
    final subtotal = _parseInt(json['subtotal']);
    return TransactionItem(
      productId: _parseInt(json['product_id']),
      productName: json['product_name'] ?? json['name'] ?? '',
      quantity: quantity,
      price: price,
      subtotal: subtotal == 0 ? (quantity * price) : subtotal,
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
    final items = (json['items'] as List<dynamic>?)
            ?.map((e) => TransactionItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList() ??
        [];

    int totalAmount = _parseInt(json['total_amount'] ??
        json['total'] ??
        json['total_price'] ??
        json['amount'] ??
        json['totalAmount']);

    if (totalAmount == 0 && items.isNotEmpty) {
      totalAmount = items.fold(0, (sum, item) => sum + item.subtotal);
    }

    return Transaction(
      id: _parseInt(json['id']),
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      paymentMethod: json['payment_method'] ?? '',
      totalAmount: totalAmount,
      items: items,
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
