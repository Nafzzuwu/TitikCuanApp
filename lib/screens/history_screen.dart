import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Riwayat Transaksi',
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
                color: const Color(0xFF6366F1).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history_rounded,
                size: 56,
                color: const Color(0xFF6366F1).withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Riwayat Transaksi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: _darkText,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Lihat semua riwayat\ntransaksi di sini',
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
