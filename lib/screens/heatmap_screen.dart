import 'package:flutter/material.dart';

class HeatmapScreen extends StatelessWidget {
  const HeatmapScreen({super.key});

  static const _green = Color(0xFF1D9E75);
  static const _darkText = Color(0xFF1A1A1A);
  static const _subtleText = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _green,
        surfaceTintColor: _green,
        elevation: 0,
        title: const Text(
          'Peta Penjualan',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _green.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.map_rounded,
                size: 56,
                color: _green.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Peta Penjualan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: _darkText,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Heatmap lokasi penjualan &\nalert stok di sini',
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
}
