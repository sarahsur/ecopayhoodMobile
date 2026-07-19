import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_textstyle.dart';
import '../models/app_user.dart';
import '../models/pickup_request.dart';
import '../services/auth_service.dart';
import '../services/collector_service.dart';
import '../services/user_service.dart';
import 'collector_scan_page.dart';

class CollectorDashboardPage extends StatefulWidget {
  const CollectorDashboardPage({super.key});

  @override
  State<CollectorDashboardPage> createState() => _CollectorDashboardPageState();
}

class _CollectorDashboardPageState extends State<CollectorDashboardPage> {
  final CollectorService _collectorService = CollectorService();
  final UserService _userService = UserService();

  late Future<AppUser?> _profileFuture;
  late Future<List<PickupRequest>> _scheduledFuture;
  late Future<List<PickupRequest>> _completedFuture;
  late Future<int> _rewardFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    _profileFuture = _userService.getCurrentUserProfile();
    _scheduledFuture = _collectorService.getScheduledPickups();
    _completedFuture = _collectorService
        .getCompletedPickupsByCurrentCollector();
    _rewardFuture = _collectorService.getCurrentCollectorRewardPoints();
  }

  Future<void> _openScanner() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CollectorScanPage()),
    );

    if (!mounted) return;
    setState(_refreshData);
  }

  Future<void> _logout() async {
    await AuthService().logout();

    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/landing', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FBF4),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => setState(_refreshData),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              FutureBuilder<AppUser?>(
                future: _profileFuture,
                builder: (context, profileSnapshot) {
                  return FutureBuilder<List<PickupRequest>>(
                    future: _scheduledFuture,
                    builder: (context, scheduledSnapshot) {
                      return FutureBuilder<List<PickupRequest>>(
                        future: _completedFuture,
                        builder: (context, completedSnapshot) {
                          return FutureBuilder<int>(
                            future: _rewardFuture,
                            builder: (context, rewardSnapshot) {
                              final profile = profileSnapshot.data;
                              final scheduled = scheduledSnapshot.data ?? [];
                              final completed = completedSnapshot.data ?? [];
                              final rewardPoints = rewardSnapshot.data ?? 0;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _CollectorHero(
                                    profile: profile,
                                    scheduledCount: scheduled.length,
                                    completedCount: completed.length,
                                    rewardPoints: rewardPoints,
                                    onLogout: _logout,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      20,
                                      18,
                                      20,
                                      0,
                                    ),
                                    child: _ScanActionCard(onTap: _openScanner),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      20,
                                      22,
                                      20,
                                      0,
                                    ),
                                    child: _TodayMissionCard(
                                      scheduledCount: scheduled.length,
                                      completedCount: completed.length,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      20,
                                      24,
                                      20,
                                      12,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Antrian Penjemputan',
                                          style: AppTextStyle.poppins(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.darkGreen,
                                          ),
                                        ),
                                        Text(
                                          '${scheduled.length} request',
                                          style: AppTextStyle.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black45,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      20,
                                      0,
                                      20,
                                      28,
                                    ),
                                    child: _PickupQueue(
                                      isLoading:
                                          scheduledSnapshot.connectionState ==
                                          ConnectionState.waiting,
                                      requests: scheduled,
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CollectorHero extends StatelessWidget {
  final AppUser? profile;
  final int scheduledCount;
  final int completedCount;
  final int rewardPoints;
  final VoidCallback onLogout;

  const _CollectorHero({
    required this.profile,
    required this.scheduledCount,
    required this.completedCount,
    required this.rewardPoints,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = profile?.name.trim().isNotEmpty == true
        ? profile!.name
        : 'Greenie Penjemput';
    final progress = (completedCount / 8).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.local_shipping_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Halo, $displayName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Siap jemput sampah warga hari ini',
                      style: AppTextStyle.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.82),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onLogout,
                icon: const Icon(Icons.logout, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _HeroMetric(
                  label: 'Menunggu',
                  value: scheduledCount.toString(),
                  icon: Icons.route_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeroMetric(
                  label: 'Selesai',
                  value: completedCount.toString(),
                  icon: Icons.task_alt,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeroMetric(
                  label: 'Reward',
                  value: rewardPoints.toString(),
                  icon: Icons.stars_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Target pickup hari ini',
                      style: AppTextStyle.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '$completedCount/8',
                      style: AppTextStyle.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    color: const Color(0xFFFFF5C4),
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _HeroMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(height: 10),
          Text(
            value,
            style: AppTextStyle.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: AppTextStyle.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.78),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanActionCard extends StatelessWidget {
  final VoidCallback onTap;

  const _ScanActionCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.qr_code_scanner,
              color: AppColors.darkGreen,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scan QR warga',
                  style: AppTextStyle.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkGreen,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Konfirmasi pickup dan kirim poin otomatis.',
                  style: AppTextStyle.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Mulai'),
          ),
        ],
      ),
    );
  }
}

class _TodayMissionCard extends StatelessWidget {
  final int scheduledCount;
  final int completedCount;

  const _TodayMissionCard({
    required this.scheduledCount,
    required this.completedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5C4),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.eco, color: AppColors.darkGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scheduledCount == 0
                      ? 'Belum ada antrian baru'
                      : '$scheduledCount antrian siap dijemput',
                  style: AppTextStyle.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sudah selesai $completedCount pickup. Refresh halaman untuk cek request terbaru.',
                  style: AppTextStyle.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PickupQueue extends StatelessWidget {
  final bool isLoading;
  final List<PickupRequest> requests;

  const _PickupQueue({required this.isLoading, required this.requests});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 28),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (requests.isEmpty) {
      return const _EmptyPickupList();
    }

    return Column(
      children: requests
          .map((request) => _PickupRequestCard(request: request))
          .toList(),
    );
  }
}

class _PickupRequestCard extends StatelessWidget {
  final PickupRequest request;

  const _PickupRequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.lightGreen),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.recycling, color: AppColors.darkGreen),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${request.amount} ${request.unit} • ${_formatStatus(request.status)}',
                  style: AppTextStyle.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID warga: ${_shortId(request.userId)}',
                  style: AppTextStyle.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.black38,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.darkGreen),
        ],
      ),
    );
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'scheduled':
        return 'Menunggu pickup';
      case 'picked_up':
        return 'Sudah diambil';
      default:
        return status;
    }
  }

  String _shortId(String id) {
    if (id.length <= 8) return id;
    return '${id.substring(0, 8)}...';
  }
}

class _EmptyPickupList extends StatelessWidget {
  const _EmptyPickupList();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.lightGreen),
      ),
      child: Column(
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: AppColors.darkGreen,
              size: 38,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Antrian masih kosong',
            style: AppTextStyle.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.darkGreen,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Nanti request warga yang sudah menjadwalkan penjemputan akan muncul di sini.',
            textAlign: TextAlign.center,
            style: AppTextStyle.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
