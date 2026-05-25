/// Model representasi Produk dari API.
///
/// Field diambil dari parameter `createProduct` dan `updateProduct`
/// di [ApiService].
class Product {
  final int id;
  final String name;
  final int price;
  final int stock;
  final String? barcode;
  final int minStock;
  final String? category;
  final String? imageUrl;
  final String? createdAt;
  final String? updatedAt;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.barcode,
    this.minStock = 5,
    this.category,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  /// Parse dari JSON response API.
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: json['price'] ?? 0,
      stock: json['stock'] ?? 0,
      barcode: json['barcode'],
      minStock: json['min_stock'] ?? 5,
      category: json['category'],
      imageUrl: json['image_url'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  /// Konversi ke Map untuk pengiriman ke API.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'stock': stock,
      if (barcode != null) 'barcode': barcode,
      'min_stock': minStock,
      if (category != null) 'category': category,
      if (imageUrl != null) 'image_url': imageUrl,
    };
  }

  /// Apakah stok di bawah batas minimum.
  bool get isLowStock => stock <= minStock;

  /// Buat salinan dengan field tertentu di-override.
  Product copyWith({
    int? id,
    String? name,
    int? price,
    int? stock,
    String? barcode,
    int? minStock,
    String? category,
    String? imageUrl,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      barcode: barcode ?? this.barcode,
      minStock: minStock ?? this.minStock,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  String toString() => 'Product(id: $id, name: $name, price: $price, stock: $stock)';
}
