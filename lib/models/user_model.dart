/// Model representasi User dari API.
///
/// Field diambil dari response login (`result['user']`) yang digunakan
/// di [LoginScreen] dan [AuthStorage].
class User {
  final int id;
  final String name;
  final String businessName;
  final String email;

  const User({
    required this.id,
    required this.name,
    required this.businessName,
    required this.email,
  });

  /// Parse dari JSON response API.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      businessName: json['business_name'] ?? '',
      email: json['email'] ?? '',
    );
  }

  /// Konversi ke Map untuk keperluan penyimpanan / pengiriman.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'business_name': businessName,
      'email': email,
    };
  }

  @override
  String toString() => 'User(id: $id, name: $name, email: $email)';
}
