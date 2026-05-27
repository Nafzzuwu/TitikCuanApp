import 'package:flutter/material.dart';
import '../services/api_service.dart';

class StockAlertScreen extends StatefulWidget {
  const StockAlertScreen({super.key});

  @override
  State<StockAlertScreen> createState() => _StockAlertScreenState();
}

class _StockAlertScreenState extends State<StockAlertScreen> {
  static const _green = Color(0xFF1D9E75);
  static const _darkText = Color(0xFF1A1A1A);
  static const _subtleText = Color(0xFF6B7280);
  static const _warningOrange = Color(0xFFE8890C);

  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _alerts = [];

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final rawAlerts = await ApiService.getStockAlerts();
      if (mounted) {
        setState(() {
          _alerts = rawAlerts
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markAsRead(int id) async {
    try {
      await ApiService.markAlertAsRead(id);
      // Remove from list or refresh
      setState(() {
        _alerts.removeWhere((alert) => alert['id'] == id);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Peringatan ditandai telah dibaca'),
            backgroundColor: _green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui status: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _formatDateTime(String? isoString) {
    if (isoString == null) return '-';
    try {
      final dateTime = DateTime.parse(isoString).toLocal();
      final day = dateTime.day.toString().padLeft(2, '0');
      final month = dateTime.month.toString().padLeft(2, '0');
      final year = dateTime.year;
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$day-$month-$year $hour:$minute';
    } catch (_) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _green,
        surfaceTintColor: _green,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Peringatan Stok',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadAlerts,
        color: _green,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(_green),
        ),
      );
    }

    if (_errorMessage != null) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height - 150,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 16),
              const Text(
                'Gagal Memuat Notifikasi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _darkText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: _subtleText,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _loadAlerts,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (_alerts.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height - 150,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _green.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 64,
                  color: _green,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Semua Stok Aman!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _darkText,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tidak ada produk yang berada di bawah\nbatas minimum stok saat ini.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: _subtleText,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.all(16),
      itemCount: _alerts.length,
      itemBuilder: (context, index) {
        final alert = _alerts[index];
        return _buildAlertCard(alert);
      },
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    final productName = alert['product_name'] ?? 'Produk';
    final barcode = alert['barcode'] ?? '-';
    final remainingStock = alert['stock_at_alert'] ?? 0;
    final date = _formatDateTime(alert['created_at']);
    final lat = alert['latitude'];
    final lng = alert['longitude'];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _warningOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: _warningOrange,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (barcode != '-')
                    Text(
                      'Barcode: $barcode',
                      style: const TextStyle(
                        fontSize: 12,
                        color: _subtleText,
                      ),
                    ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Text(
                        'Sisa Stok: ',
                        style: TextStyle(
                          fontSize: 13,
                          color: _subtleText,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$remainingStock item',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 14, color: _subtleText),
                      const SizedBox(width: 4),
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 12,
                          color: _subtleText,
                        ),
                      ),
                    ],
                  ),
                  if (lat != null && lng != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: _subtleText),
                        const SizedBox(width: 4),
                        Text(
                          'Lokasi: ${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: _subtleText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // Actions
            Column(
              children: [
                IconButton(
                  tooltip: 'Tandai telah dibaca',
                  style: IconButton.styleFrom(
                    backgroundColor: _green.withValues(alpha: 0.1),
                    foregroundColor: _green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.check_rounded, size: 20),
                  onPressed: () => _markAsRead(alert['id']),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
