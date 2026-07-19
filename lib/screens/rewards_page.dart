import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_textstyle.dart';
import '../models/app_user.dart';
import '../services/user_service.dart';

class RewardsPage extends StatefulWidget {
  const RewardsPage({super.key});

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  final UserService _userService = UserService();
  late Future<AppUser?> _profileFuture;
  bool _isRedeeming = false;

  final List<_RewardItem> _rewards = const [
    _RewardItem(
      title: 'Bibit Tanaman',
      description: 'Reward demo untuk warga yang aktif memilah sampah.',
      points: 25,
      icon: Icons.eco_outlined,
      color: Color(0xFFDDF3D8),
    ),
    _RewardItem(
      title: 'Voucher Minuman',
      description: 'Voucher statis untuk simulasi penukaran poin.',
      points: 50,
      icon: Icons.local_cafe_outlined,
      color: Color(0xFFFFF5C4),
    ),
    _RewardItem(
      title: 'Voucher Sembako',
      description: 'Contoh reward bernilai lebih besar untuk warga.',
      points: 75,
      icon: Icons.shopping_bag_outlined,
      color: Color(0xFFF2E5D7),
    ),
    _RewardItem(
      title: 'Tote Bag Greenie',
      description: 'Merchandise demo Ecopayhood untuk kelas.',
      points: 100,
      icon: Icons.card_giftcard_outlined,
      color: Color(0xFFDDEBFF),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    _profileFuture = _userService.getCurrentUserProfile();
  }

  Future<void> _redeemReward(_RewardItem reward, int currentPoints) async {
    if (_isRedeeming) return;

    if (currentPoints < reward.points) {
      _showSnackBar('Poin belum cukup untuk menukar ${reward.title}');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tukar poin?'),
          content: Text(
            '${reward.points} poin akan ditukar dengan ${reward.title}.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Tukar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() => _isRedeeming = true);

    try {
      await _userService.redeemCurrentUserPoints(
        points: reward.points,
        rewardName: reward.title,
      );

      if (!mounted) return;
      setState(_loadProfile);
      _showSnackBar('${reward.title} berhasil ditukar');
    } catch (error) {
      if (!mounted) return;
      _showSnackBar(error.toString());
    } finally {
      if (mounted) setState(() => _isRedeeming = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.darkGreen,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Tukar Poin',
          style: AppTextStyle.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.darkGreen,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<AppUser?>(
        future: _profileFuture,
        builder: (context, snapshot) {
          final profile = snapshot.data;
          final currentPoints = profile?.points ?? 0;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              _PointBalanceCard(points: currentPoints),
              const SizedBox(height: 20),
              Text(
                'Pilihan Reward',
                style: AppTextStyle.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkGreen,
                ),
              ),
              const SizedBox(height: 12),
              ..._rewards.map(
                (reward) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _RewardCard(
                    reward: reward,
                    currentPoints: currentPoints,
                    isLoading:
                        _isRedeeming ||
                        snapshot.connectionState == ConnectionState.waiting,
                    onRedeem: () => _redeemReward(reward, currentPoints),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PointBalanceCard extends StatelessWidget {
  final int points;

  const _PointBalanceCard({required this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGreen.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.stars_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$points poin',
                  style: AppTextStyle.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Poin aktif yang bisa ditukar',
                  style: AppTextStyle.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.82),
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

class _RewardCard extends StatelessWidget {
  final _RewardItem reward;
  final int currentPoints;
  final bool isLoading;
  final VoidCallback onRedeem;

  const _RewardCard({
    required this.reward,
    required this.currentPoints,
    required this.isLoading,
    required this.onRedeem,
  });

  @override
  Widget build(BuildContext context) {
    final enoughPoints = currentPoints >= reward.points;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: reward.color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(reward.icon, color: AppColors.darkGreen, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reward.title,
                  style: AppTextStyle.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reward.description,
                  style: AppTextStyle.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.stars_rounded,
                      color: enoughPoints
                          ? AppColors.primaryGreen
                          : Colors.grey,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${reward.points} poin',
                      style: AppTextStyle.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: enoughPoints ? AppColors.darkGreen : Colors.grey,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: isLoading || !enoughPoints ? null : onRedeem,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkGreen,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(enoughPoints ? 'Tukar' : 'Kurang'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardItem {
  final String title;
  final String description;
  final int points;
  final IconData icon;
  final Color color;

  const _RewardItem({
    required this.title,
    required this.description,
    required this.points,
    required this.icon,
    required this.color,
  });
}
