import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';

class HeatmapScreen extends StatefulWidget {
  const HeatmapScreen({super.key});

  @override
  State<HeatmapScreen> createState() => _HeatmapScreenState();
}

class _HeatmapScreenState extends State<HeatmapScreen> {
  static const _green = Color(0xFF1D9E75);
  static const _greenDark = Color(0xFF157A5A);
  static const _darkText = Color(0xFF1A1A1A);
  static const _subtleText = Color(0xFF6B7280);

  final MapController _mapController = MapController();
  final StreamController<void> _rebuildStream =
      StreamController<void>.broadcast();

  bool _isLoading = true;
  String? _errorMessage;
  List<WeightedLatLng> _heatmapPoints = [];

  // Default coordinate: Jember, Indonesia
  LatLng _mapCenter = const LatLng(-8.1724, 113.6995);
  final double _mapZoom = 13.0;

  // Map Basemaps configuration
  String _currentStyle = 'positron'; // 'positron', 'dark', 'osm'
  final Map<String, String> _tileUrls = {
    'positron': 'https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
    'dark': 'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
    'osm': 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  };

  @override
  void initState() {
    super.initState();
    _loadHeatmapData();
  }

  @override
  void dispose() {
    _rebuildStream.close();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _loadHeatmapData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Fetch heatmap data points from API
      final rawData = await ApiService.getHeatmap();
      final List<WeightedLatLng> points = [];
      LatLng? firstLatLng;

      for (var item in rawData) {
        final lat = item['lat'];
        final lng = item['lng'];
        final intensity = item['intensity'] ?? 1.0;
        if (lat != null && lng != null) {
          final latLng = LatLng(
            (lat as num).toDouble(),
            (lng as num).toDouble(),
          );
          firstLatLng ??= latLng;
          points.add(WeightedLatLng(latLng, (intensity as num).toDouble()));
        }
      }

      // 2. Fetch device location if permitted (optional fallback for map center)
      LatLng? userLocation;
      try {
        final permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always) {
          final position = await Geolocator.getCurrentPosition(
            timeLimit: const Duration(seconds: 3),
          );
          userLocation = LatLng(position.latitude, position.longitude);
        }
      } catch (e) {
        debugPrint('Failed to get device location: $e');
      }

      if (mounted) {
        setState(() {
          _heatmapPoints = points;

          // Determine best initial center
          if (points.isNotEmpty && firstLatLng != null) {
            // Center on the first hotspot point
            _mapCenter = firstLatLng;
          } else if (userLocation != null) {
            _mapCenter = userLocation;
          }

          _isLoading = false;
        });

        // Trigger HeatMapLayer rebuild stream
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _rebuildStream.add(null);
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

  Future<void> _moveToCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar('Izin lokasi ditolak');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackBar(
          'Izin lokasi ditolak secara permanen. Silakan aktifkan di Pengaturan.',
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      final target = LatLng(position.latitude, position.longitude);

      _mapController.move(target, 14.0);
      _showSnackBar('Menampilkan lokasi Anda');
    } catch (e) {
      _showSnackBar('Gagal mendapatkan lokasi GPS: $e');
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _loadHeatmapData,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(_green),
            ),
            SizedBox(height: 16),
            Text(
              'Menyusun peta panas penjualan...',
              style: TextStyle(fontSize: 14, color: _subtleText),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.map_outlined, size: 64, color: Colors.red.shade400),
              const SizedBox(height: 16),
              const Text(
                'Gagal Memuat Peta',
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
                style: const TextStyle(fontSize: 14, color: _subtleText),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _loadHeatmapData,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        // 1. The Interactive Leaflet Map
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _mapCenter,
            initialZoom: _mapZoom,
            minZoom: 4,
            maxZoom: 18,
          ),
          children: [
            // Map Tile Provider Layer
            TileLayer(
              urlTemplate: _tileUrls[_currentStyle]!,
              userAgentPackageName: 'com.titikcuan.app',
            ),

            // Heatmap Layer Overlay
            if (_heatmapPoints.isNotEmpty)
              HeatMapLayer(
                heatMapDataSource: InMemoryHeatMapDataSource(
                  data: _heatmapPoints,
                ),
                heatMapOptions: HeatMapOptions(
                  gradient: HeatMapOptions.defaultGradient,
                  minOpacity: 0.15,
                ),
                reset: _rebuildStream.stream,
              ),
          ],
        ),

        // 2. Statistics Overlay (Top Left)
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${_heatmapPoints.length} Lokasi Transaksi',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: _darkText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Kepadatan penjualan berdasarkan GPS',
                  style: TextStyle(fontSize: 11, color: _subtleText),
                ),
              ],
            ),
          ),
        ),

        // 3. Basemap Style Toggles (Top Right Floating Stack)
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStyleButton('positron', Icons.wb_sunny_rounded, 'Light'),
                Container(width: 24, height: 1, color: Colors.grey.shade200),
                _buildStyleButton('dark', Icons.nights_stay_rounded, 'Dark'),
                Container(width: 24, height: 1, color: Colors.grey.shade200),
                _buildStyleButton('osm', Icons.map_rounded, 'OSM'),
              ],
            ),
          ),
        ),

        // 4. GPS Centering & Zoom Controls (Bottom Right Floating Stack)
        Positioned(
          bottom: 24,
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Zoom In
              _buildFloatingControl(
                icon: Icons.add_rounded,
                onPressed: () {
                  final newZoom = _mapController.camera.zoom + 1;
                  _mapController.move(_mapController.camera.center, newZoom);
                },
              ),
              const SizedBox(height: 8),
              // Zoom Out
              _buildFloatingControl(
                icon: Icons.remove_rounded,
                onPressed: () {
                  final newZoom = _mapController.camera.zoom - 1;
                  _mapController.move(_mapController.camera.center, newZoom);
                },
              ),
              const SizedBox(height: 8),
              // GPS Location Center
              _buildFloatingControl(
                icon: Icons.my_location_rounded,
                color: _green,
                iconColor: Colors.white,
                onPressed: _moveToCurrentLocation,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStyleButton(String style, IconData icon, String tooltip) {
    final isSelected = _currentStyle == style;
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(
          icon,
          color: isSelected ? _greenDark : const Color(0xFF9E9E9E),
          size: 20,
        ),
        onPressed: () {
          setState(() {
            _currentStyle = style;
          });
        },
      ),
    );
  }

  Widget _buildFloatingControl({
    required IconData icon,
    required VoidCallback onPressed,
    Color color = Colors.white,
    Color iconColor = _darkText,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Icon(icon, color: iconColor, size: 22),
        ),
      ),
    );
  }
}
