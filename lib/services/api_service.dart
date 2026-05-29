// ignore_for_file: use_null_aware_elements
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_storage.dart';

class ApiService {
  static const String _baseUrl = 'https://titik-cuan-api.vercel.app';

  // ── helper: header dengan token ──────────────────────────────
  static Future<Map<String, String>> _headers() async {
    final token = await AuthStorage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── helper: handle response ───────────────────────────────────
  static dynamic _handleResponse(http.Response res) {
    final body = jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    throw Exception(body['error'] ?? body['message'] ?? 'Terjadi kesalahan');
  }

  // ══════════════════════════════════════════════════════════════
  // AUTH
  // ══════════════════════════════════════════════════════════════

  static Future<Map<String, dynamic>> register({
    required String name,
    required String businessName,
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'business_name': businessName,
        'email': email,
        'password': password,
      }),
    );
    return _handleResponse(res);
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _handleResponse(res);
  }

  static Future<Map<String, dynamic>> reactivate({
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/auth/reactivate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _handleResponse(res);
  }

  static Future<void> logout() async {
    final headers = await _headers();
    await http.post(Uri.parse('$_baseUrl/auth/logout'), headers: headers);
    await AuthStorage.clear();
  }

  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    return _handleResponse(res);
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'otp': otp,
        'new_password': newPassword,
      }),
    );
    return _handleResponse(res);
  }

  static Future<void> deactivateAccount() async {
    final headers = await _headers();
    final res = await http.post(
      Uri.parse('$_baseUrl/auth/deactivate'),
      headers: headers,
    );
    _handleResponse(res);
    await AuthStorage.clear();
  }

  static Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? businessName,
  }) async {
    final headers = await _headers();
    final res = await http.put(
      Uri.parse('$_baseUrl/auth/update-profile'),
      headers: headers,
      body: jsonEncode({
        if (name != null) 'name': name,
        if (businessName != null) 'business_name': businessName,
      }),
    );
    return _handleResponse(res);
  }

  static Future<void> updateProfilePicture(String url) async {
    final res = await http.patch(
      Uri.parse('$_baseUrl/auth/profile-picture'),
      headers: await _headers(),
      body: jsonEncode({'profile_picture': url}),
    );
    _handleResponse(res);
  }

  static Future<Map<String, dynamic>> getProfile() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/auth/profile'),
      headers: await _headers(),
    );
    return _handleResponse(res);
  }

  // ── helper: Upload ke Supabase Storage ──────────────────────────
  static const String _supabaseUrl = 'https://onbcbwuxutnmirffkhks.supabase.co';
  static const String _supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9uYmNid3V4dXRubWlyZmZraGtzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg0OTI1OTgsImV4cCI6MjA5NDA2ODU5OH0.ORcaSBOe0f7rPMvEFwqFWz2zjWoCcKxfFpVu26hs7dE';
  static const String _bucketName = 'profile-pictures';

  static Future<String> uploadToSupabase({
    required List<int> fileBytes,
    required String fileName,
  }) async {
    final ext = fileName.contains('.') ? fileName.split('.').last : 'jpg';
    final cleanFileName =
        '${DateTime.now().millisecondsSinceEpoch}_${fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_')}';

    // Upload menggunakan simple upload (PUT)
    final uploadUri = Uri.parse(
      '$_supabaseUrl/storage/v1/object/$_bucketName/$cleanFileName',
    );

    final response = await http.put(
      uploadUri,
      headers: {
        'Authorization': 'Bearer $_supabaseAnonKey',
        'apikey': _supabaseAnonKey,
        'Content-Type': 'image/$ext',
        'x-upsert': 'true',
      },
      body: fileBytes,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Return URL publik gambar
      return '$_supabaseUrl/storage/v1/object/public/$_bucketName/$cleanFileName';
    } else {
      throw Exception('Gagal mengunggah foto: ${response.body}');
    }
  }

  // ══════════════════════════════════════════════════════════════
  // DASHBOARD
  // ══════════════════════════════════════════════════════════════

  static Future<Map<String, dynamic>> getDashboard() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/dashboard'),
      headers: await _headers(),
    );
    return _handleResponse(res);
  }

  // ══════════════════════════════════════════════════════════════
  // PRODUCTS
  // ══════════════════════════════════════════════════════════════

  static Future<List<dynamic>> getProducts() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/products'),
      headers: await _headers(),
    );
    return _handleResponse(res);
  }

  static Future<Map<String, dynamic>> getProductByBarcode(
    String barcode,
  ) async {
    final res = await http.get(
      Uri.parse('$_baseUrl/products/barcode/$barcode'),
      headers: await _headers(),
    );
    return _handleResponse(res);
  }

  static Future<Map<String, dynamic>> createProduct({
    required String name,
    required int price,
    required int stock,
    String? barcode,
    int minStock = 5,
    String? category,
    String? imageUrl,
  }) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/products'),
      headers: await _headers(),
      body: jsonEncode({
        'name': name,
        'price': price,
        'stock': stock,
        if (barcode != null) 'barcode': barcode,
        'min_stock': minStock,
        if (category != null) 'category': category,
        if (imageUrl != null) 'image_url': imageUrl,
      }),
    );
    return _handleResponse(res);
  }

  static Future<Map<String, dynamic>> updateProduct(
    int id, {
    String? name,
    int? price,
    int? stock,
    String? barcode,
    int? minStock,
    String? category,
    String? imageUrl,
  }) async {
    final res = await http.put(
      Uri.parse('$_baseUrl/products/$id'),
      headers: await _headers(),
      body: jsonEncode({
        if (name != null) 'name': name,
        if (price != null) 'price': price,
        if (stock != null) 'stock': stock,
        if (barcode != null) 'barcode': barcode,
        if (minStock != null) 'min_stock': minStock,
        if (category != null) 'category': category,
        if (imageUrl != null) 'image_url': imageUrl,
      }),
    );
    return _handleResponse(res);
  }

  static Future<void> updateStock(int id, int stock) async {
    final res = await http.patch(
      Uri.parse('$_baseUrl/products/$id/stock'),
      headers: await _headers(),
      body: jsonEncode({'stock': stock}),
    );
    _handleResponse(res);
  }

  static Future<void> deleteProduct(int id) async {
    final res = await http.delete(
      Uri.parse('$_baseUrl/products/$id'),
      headers: await _headers(),
    );
    _handleResponse(res);
  }

  // ══════════════════════════════════════════════════════════════
  // TRANSACTIONS
  // ══════════════════════════════════════════════════════════════

  static Future<Map<String, dynamic>> createTransaction({
    required double latitude,
    required double longitude,
    required String paymentMethod,
    required List<Map<String, dynamic>> items,
  }) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/transactions'),
      headers: await _headers(),
      body: jsonEncode({
        'latitude': latitude,
        'longitude': longitude,
        'payment_method': paymentMethod,
        'items': items,
      }),
    );
    return _handleResponse(res);
  }

  static Future<Map<String, dynamic>> createTransactionByBarcode({
    required double latitude,
    required double longitude,
    required String paymentMethod,
    required List<Map<String, dynamic>> items,
  }) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/transactions/barcode'),
      headers: await _headers(),
      body: jsonEncode({
        'latitude': latitude,
        'longitude': longitude,
        'payment_method': paymentMethod,
        'items': items,
      }),
    );
    return _handleResponse(res);
  }

  static Future<List<dynamic>> getTransactions() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/transactions'),
      headers: await _headers(),
    );
    return _handleResponse(res);
  }

  static Future<Map<String, dynamic>> getTransactionDetail(int id) async {
    final res = await http.get(
      Uri.parse('$_baseUrl/transactions/$id'),
      headers: await _headers(),
    );
    return _handleResponse(res);
  }

  // ══════════════════════════════════════════════════════════════
  // HEATMAP
  // ══════════════════════════════════════════════════════════════

  static Future<List<dynamic>> getHeatmap() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/heatmap'),
      headers: await _headers(),
    );
    return _handleResponse(res);
  }

  // ══════════════════════════════════════════════════════════════
  // STOCK ALERTS
  // ══════════════════════════════════════════════════════════════

  static Future<List<dynamic>> getStockAlerts() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/stock-alerts'),
      headers: await _headers(),
    );
    return _handleResponse(res);
  }

  static Future<void> markAlertAsRead(int id) async {
    final res = await http.patch(
      Uri.parse('$_baseUrl/stock-alerts/$id/read'),
      headers: await _headers(),
    );
    _handleResponse(res);
  }
}
