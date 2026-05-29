import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_storage.dart';
import 'login_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'stock_alert_screen.dart';
import 'main_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  static const _green = Color(0xFF1D9E75);
  static const _darkGreen = Color(0xFF147A5B);
  static const _darkText = Color(0xFF1A1A1A);
  static const _subtleText = Color(0xFF6B7280);
  static const _cardBg = Color(0xFFF8FAF9);
  static const _warningOrange = Color(0xFFE8890C);

  bool _isLoading = true;
  String _userName = '';
  String? _profilePictureUrl;

  // Dashboard data
  int _salesToday = 0;
  int _salesMonth = 0;
  int _totalTransactions = 0;
  String _bestProduct = '-';
  int _lowStockCount = 0;
  List<Map<String, dynamic>> _lowStockProducts = [];
  List<Map<String, dynamic>> _heatmapPoints = [];

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _loadData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final userInfo = await AuthStorage.getUserInfo();
      _userName = userInfo['name'] ?? 'User';
      _profilePictureUrl = userInfo['profile_picture'];

      // Load dashboard, stock alerts, heatmap, and profile in parallel
      final results = await Future.wait([
        ApiService.getDashboard().catchError((_) => <String, dynamic>{}),
        ApiService.getStockAlerts().catchError((_) => <dynamic>[]),
        ApiService.getHeatmap().catchError((_) => <dynamic>[]),
        ApiService.getProfile().catchError((_) => <String, dynamic>{}),
      ]);

      final dashboard = results[0] as Map<String, dynamic>;
      final alerts = results[1] as List<dynamic>;
      final heatmap = results[2] as List<dynamic>;
      final profile = results[3] as Map<String, dynamic>;

      if (mounted) {
        setState(() {
          _salesToday =
              ((dashboard['today_sales'] ?? dashboard['sales_today'] ?? 0)
                      as num)
                  .toInt();
          _salesMonth =
              ((dashboard['monthly_sales'] ?? dashboard['sales_month'] ?? 0)
                      as num)
                  .toInt();
          _totalTransactions = ((dashboard['total_transactions'] ?? 0) as num)
              .toInt();
          _bestProduct =
              (dashboard['best_selling_product'] ??
                      dashboard['best_product'] ??
                      '-')
                  .toString();
          _lowStockCount = alerts.length;
          _lowStockProducts = alerts
              .take(5)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
          _heatmapPoints = heatmap
              .take(10)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();

          final picUrl = profile['profile_picture'] as String?;
          if (picUrl != null && picUrl.isNotEmpty) {
            _profilePictureUrl = picUrl;
          }
          _isLoading = false;
        });

        final picUrl = profile['profile_picture'] as String?;
        if (picUrl != null && picUrl.isNotEmpty) {
          await AuthStorage.saveProfilePicture(picUrl);
        }

        _fadeController.forward();
      }
    } catch (e) {
      debugPrint('Dashboard load error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        _fadeController.forward();
      }
    }
  }

  String _formatRupiah(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count == 3 && i > 0) {
        buffer.write('.');
        count = 0;
      }
    }
    return 'Rp ${buffer.toString().split('').reversed.join()}';
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading ? _buildShimmer() : _buildContent(),
    );
  }

  Widget _buildShimmer() {
    return CustomScrollView(
      slivers: [
        _buildAppBar(),
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation(_green),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Memuat data...',
                  style: TextStyle(fontSize: 14, color: _subtleText),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: RefreshIndicator(
        onRefresh: _loadData,
        color: _green,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting
                    _buildGreetingSection(),
                    const SizedBox(height: 24),

                    // Sales Cards
                    _buildSalesCards(),
                    const SizedBox(height: 20),

                    // Stats Card
                    _buildStatsCard(),
                    const SizedBox(height: 20),

                    // Heatmap Mini
                    _buildHeatmapMini(),
                    const SizedBox(height: 20),

                    // Quick Actions
                    _buildQuickActions(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: _green,
      surfaceTintColor: _green,
      elevation: 0,
      title: Row(
        children: [
          Image.asset(
            'assets/images/titikcuan_logo.png',
            width: 38,
            height: 38,
          ),
          const SizedBox(width: 10),
          const Text(
            'TitikCuan',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontSize: 20,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Badge(
            isLabelVisible: _lowStockCount > 0,
            label: Text('$_lowStockCount'),
            backgroundColor: Colors.red,
            textColor: Colors.white,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StockAlertScreen()),
            );
            _loadData();
          },
        ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.logout_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          onPressed: () => _showLogoutDialog(),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildGreetingSection() {
    final now = DateTime.now();
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final days = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
    ];
    final dateStr =
        '${days[now.weekday % 7]}, ${now.day} ${months[now.month - 1]} ${now.year}';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _green.withValues(alpha: 0.08),
            _green.withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _green.withValues(alpha: 0.12), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _darkGreen.withValues(alpha: 0.7),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$_userName 👋',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: _darkText,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: _green.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child:
                      _profilePictureUrl != null &&
                          _profilePictureUrl!.isNotEmpty
                      ? Image.network(
                          _profilePictureUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF1D9E75),
                                      Color(0xFF15C58E),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    _userName.isNotEmpty
                                        ? _userName[0].toUpperCase()
                                        : 'U',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                        )
                      : Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF1D9E75), Color(0xFF15C58E)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _userName.isNotEmpty
                                  ? _userName[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _green.withValues(alpha: 0.1)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 13,
                  color: _darkGreen.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 8),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _darkGreen.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4ADE80),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesCards() {
    return Row(
      children: [
        Expanded(
          child: _buildSalesCard(
            title: 'Penjualan Hari Ini',
            amount: _salesToday,
            icon: Icons.today_rounded,
            gradient: const [Color(0xFF1D9E75), Color(0xFF15C58E)],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSalesCard(
            title: 'Penjualan Bulan Ini',
            amount: _salesMonth,
            icon: Icons.calendar_month_rounded,
            gradient: const [Color(0xFF0B7A5E), Color(0xFF1D9E75)],
          ),
        ),
      ],
    );
  }

  Widget _buildSalesCard({
    required String title,
    required int amount,
    required IconData icon,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 16),
              ),
              const Spacer(),
              Icon(
                Icons.trending_up_rounded,
                color: Colors.white.withValues(alpha: 0.6),
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.85),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              _formatRupiah(amount),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EFEC), width: 1),
      ),
      child: Column(
        children: [
          _buildStatRow(
            icon: Icons.receipt_long_rounded,
            iconColor: const Color(0xFF3B82F6),
            iconBg: const Color(0xFFDBEAFE),
            label: 'Total Transaksi',
            value: '$_totalTransactions transaksi',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: const Color(0xFFE0E7E3)),
          ),
          _buildStatRow(
            icon: Icons.star_rounded,
            iconColor: const Color(0xFFF59E0B),
            iconBg: const Color(0xFFFEF3C7),
            label: 'Produk Terlaris',
            value: _bestProduct,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: const Color(0xFFE0E7E3)),
          ),
          _buildStatRow(
            icon: Icons.warning_amber_rounded,
            iconColor: _warningOrange,
            iconBg: const Color(0xFFFEF3CD),
            label: 'Stok Menipis',
            value: '$_lowStockCount produk',
            isWarning: _lowStockCount > 0,
            onTap: _lowStockCount > 0 ? _showLowStockDialog : null,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String value,
    bool isWarning = false,
    VoidCallback? onTap,
  }) {
    final content = Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: _subtleText,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isWarning ? _warningOrange : _darkText,
                ),
              ),
            ],
          ),
        ),
        if (isWarning)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _warningOrange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('⚠️', style: TextStyle(fontSize: 14)),
          ),
        if (onTap != null)
          const Padding(
            padding: EdgeInsets.only(left: 4),
            child: Icon(
              Icons.chevron_right_rounded,
              color: _subtleText,
              size: 20,
            ),
          ),
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: content,
      );
    }
    return content;
  }

  Widget _buildHeatmapMini() {
    return GestureDetector(
      onTap: () {
        // Navigate to Peta tab (index 3) via MainScreenState
        final mainState = context.findAncestorStateOfType<MainScreenState>();
        if (mainState != null && mainState.mounted) {
          mainState.setSelectedIndex(3);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8EFEC), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.map_rounded,
                    color: _darkGreen,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Peta Penjualan',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _darkText,
                        ),
                      ),
                      Text(
                        'Tap untuk buka peta lengkap',
                        style: TextStyle(fontSize: 11, color: _subtleText),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.open_in_new_rounded,
                  color: _subtleText,
                  size: 18,
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Mini heatmap visualization
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: _heatmapPoints.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_off_rounded,
                            color: _green.withValues(alpha: 0.4),
                            size: 28,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Belum ada data lokasi',
                            style: TextStyle(
                              fontSize: 11,
                              color: _green.withValues(alpha: 0.5),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : CustomPaint(
                      painter: _MiniHeatmapPainter(_heatmapPoints),
                      size: const Size(double.infinity, 100),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.history_rounded,
            label: 'History',
            subtitle: 'Riwayat transaksi',
            color: const Color(0xFF6366F1),
            bgColor: const Color(0xFFEEF2FF),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.person_rounded,
            label: 'Profil',
            subtitle: 'Pengaturan akun',
            color: const Color(0xFF8B5CF6),
            bgColor: const Color(0xFFF3E8FF),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
              _loadData();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.15), width: 1),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 10,
                        color: color.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: color.withValues(alpha: 0.4),
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    bool isLoggingOut = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext builderCtx, StateSetter setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Gradient header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 28),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red.shade500, Colors.red.shade700],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.logout_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Keluar dari Akun?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sesi kamu akan berakhir',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                      child: isLoggingOut
                          ? Column(
                              children: [
                                SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.red.shade500,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Sedang logout...',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: _subtleText,
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            )
                          : Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red.shade100),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline_rounded,
                                    color: Colors.red.shade400,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Text(
                                      'Kamu perlu login kembali untuk mengakses akunmu setelah keluar.',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: _darkText,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),

                    // Actions
                    if (!isLoggingOut)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(ctx),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  side: const BorderSide(
                                    color: Color(0xFFE5E7EB),
                                  ),
                                ),
                                child: const Text(
                                  'Batal',
                                  style: TextStyle(
                                    color: _subtleText,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  final navigator = Navigator.of(context);

                                  setDialogState(() {
                                    isLoggingOut = true;
                                  });

                                  try {
                                    await ApiService.logout();
                                    await AuthStorage.clear();
                                  } catch (e) {
                                    debugPrint('Logout error: $e');
                                  }

                                  if (!mounted) return;

                                  navigator.pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (_) => const LoginScreen(),
                                    ),
                                    (route) => false,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade600,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Ya, Keluar',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showLowStockDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.55,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text('⚠️', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 8),
                  Text(
                    'Stok Menipis',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _darkText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
                itemCount: _lowStockProducts.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final p = _lowStockProducts[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _warningOrange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.inventory_2_outlined,
                            color: _warningOrange,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p['product_name'] ?? '-',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: _darkText,
                                ),
                              ),
                              Text(
                                'Sisa: ${p['current_stock'] ?? 0} / Min: ${p['min_stock'] ?? 0}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: _subtleText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _warningOrange.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${p['current_stock'] ?? 0} pcs',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _warningOrange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// Mini heatmap painter for the dashboard preview
class _MiniHeatmapPainter extends CustomPainter {
  final List<Map<String, dynamic>> points;

  _MiniHeatmapPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    // Normalize coordinates to fit within the card
    double minLat = double.infinity, maxLat = -double.infinity;
    double minLng = double.infinity, maxLng = -double.infinity;

    for (final p in points) {
      final lat = ((p['lat'] ?? p['latitude'] ?? 0.0) as num).toDouble();
      final lng = ((p['lng'] ?? p['longitude'] ?? 0.0) as num).toDouble();
      if (lat < minLat) minLat = lat;
      if (lat > maxLat) maxLat = lat;
      if (lng < minLng) minLng = lng;
      if (lng > maxLng) maxLng = lng;
    }

    final latRange = maxLat - minLat;
    final lngRange = maxLng - minLng;
    final pad = 20.0;

    for (final p in points) {
      final lat = ((p['lat'] ?? p['latitude'] ?? 0.0) as num).toDouble();
      final lng = ((p['lng'] ?? p['longitude'] ?? 0.0) as num).toDouble();
      final sales =
          ((p['intensity'] ?? p['total_sales'] ?? p['sales'] ?? 1.0) as num)
              .toDouble();

      final x = lngRange == 0
          ? size.width / 2
          : pad + ((lng - minLng) / lngRange) * (size.width - pad * 2);
      final y = latRange == 0
          ? size.height / 2
          : pad + ((maxLat - lat) / latRange) * (size.height - pad * 2);

      final maxSales = points
          .map(
            (e) =>
                ((e['intensity'] ?? e['total_sales'] ?? e['sales'] ?? 1.0)
                        as num)
                    .toDouble(),
          )
          .reduce((a, b) => a > b ? a : b);
      final intensity = maxSales == 0
          ? 0.5
          : (sales / maxSales).clamp(0.3, 1.0);
      final radius = 8 + intensity * 14;

      // Outer glow
      final glowPaint = Paint()
        ..shader =
            RadialGradient(
              colors: [
                const Color(0xFF1D9E75).withValues(alpha: intensity * 0.3),
                const Color(0xFF1D9E75).withValues(alpha: 0),
              ],
            ).createShader(
              Rect.fromCircle(center: Offset(x, y), radius: radius * 2),
            );
      canvas.drawCircle(Offset(x, y), radius * 2, glowPaint);

      // Inner dot
      final dotPaint = Paint()
        ..color = Color.lerp(
          const Color(0xFF4ADE80),
          const Color(0xFF15803D),
          intensity,
        )!;
      canvas.drawCircle(Offset(x, y), radius * 0.4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
