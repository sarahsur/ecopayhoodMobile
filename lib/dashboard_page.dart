import 'puzzle_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constants/app_colors.dart';
import 'constants/app_textstyle.dart';
import 'constants/app_sizes.dart';
import 'data/waste_category_data.dart';
import 'models/waste_category.dart';
import 'providers/notification_provider.dart';
import 'category_detail_page.dart';
import 'notification_page.dart';
import 'profile_screen.dart';
import 'qr_generator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentNavIndex = 0;
  final NotificationProvider _notificationProvider = NotificationProvider();

  final List<WasteCategory> _categories = wasteCategories;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final double headerH = screenHeight * 0.13; // reduced header height
    final double buttonH = screenHeight * 0.075;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ─── Main unscrollable content ───────────────────────────────────
          SafeArea(
            top: false,
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header gradient ──
                SizedBox(
                  height: headerH + 30, // less overlap so card goes higher
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: headerH,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.darkGreen,
                              AppColors.primaryGreen,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.elliptical(screenWidth * 1.5, 40),
                          ),
                        ),
                      ),
                      Positioned(
                        left: AppSizes.paddingHorizontal,
                        right: AppSizes.paddingHorizontal,
                        bottom: 0,
                        child: const PickupScheduleCard(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // ── Greeting + Notification row ──
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingHorizontal,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Hi, Bima Sakti', style: AppTextStyle.greeting),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const NotificationPage(),
                                ),
                              );
                            },
                            child: ListenableBuilder(
                              listenable: _notificationProvider,
                              builder: (context, child) {
                                return Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    const Icon(
                                      Icons.notifications_none,
                                      color: AppColors.primaryGreen,
                                      size: 30,
                                    ),
                                    if (_notificationProvider.unreadCount > 0)
                                      Positioned(
                                        right: -2,
                                        top: -2,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white, width: 1.5),
                                          ),
                                          constraints: const BoxConstraints(
                                            minWidth: 18,
                                            minHeight: 18,
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${_notificationProvider.unreadCount}',
                                              style: AppTextStyle.poppins(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // ── Submit Waste Button ──
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingHorizontal,
                  ),
                  child: SizedBox(
                    height: buttonH,
                    child: SubmitWasteButton(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Membuka list sampah diajukan...'),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ── Category Title ──
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingHorizontal,
                  ),
                  child: Text(
                    'Kategori',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGreen,
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                // ── Jigsaw Puzzle 2×2 Grid (Fills remaining space) ──
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: Column(
                          children: [
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: PuzzleWidget(
                                      category: _categories[0],
                                      onTap: () => _onCategoryTap(_categories[0]),
                                      useDashboardImage: true,
                                    ),
                                  ),
                                  const SizedBox(width: 0),
                                  Expanded(
                                    child: PuzzleWidget(
                                      category: _categories[1],
                                      onTap: () => _onCategoryTap(_categories[1]),
                                      useDashboardImage: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 0),
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: PuzzleWidget(
                                      category: _categories[2],
                                      onTap: () => _onCategoryTap(_categories[2]),
                                      useDashboardImage: true,
                                    ),
                                  ),
                                  const SizedBox(width: 0),
                                  Expanded(
                                    child: PuzzleWidget(
                                      category: _categories[3],
                                      onTap: () => _onCategoryTap(_categories[3]),
                                      useDashboardImage: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom padding for the navbar
                const SizedBox(height: AppSizes.navbarHeight + 20),
              ],
            ),
          ),

          // ─── Floating Bottom Navigation Bar ──────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomBottomNavbar(
              selectedIndex: _currentNavIndex,
              onItemSelected: (index) {
                if (index == 0) {
                  setState(() => _currentNavIndex = 0);
                } else if (index == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const QrUserScreen(),
                    ),
                  );
                } else if (index == 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _onCategoryTap(WasteCategory category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryDetailPage(category: category),
      ),
    );
  }
}


class PickupScheduleCard extends StatelessWidget {
  const PickupScheduleCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.marginCard),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 88, 170, 70),
        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Text(
            'Jadwal Penjemputan',
            textAlign: TextAlign.center,
            style: AppTextStyle.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color.fromRGBO(255, 245, 196, 1),
            ),
          ),

          const SizedBox(height: 8),

          // Capsules Row
          Row(
            children: [
              Expanded(child: _buildCapsule('Selasa (09.00 - 16.00)')),
              const SizedBox(width: 8),
              Expanded(child: _buildCapsule('Sabtu (09.00 - 16.00)')),
            ],
          ),

          const SizedBox(height: 8),

          // Status text
          RichText(
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Status : ',
                  style: AppTextStyle.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                TextSpan(
                  text:
                      'Tidak ada penjemputan, Penjemputan berikutnya dalam 1 hari',
                  style: AppTextStyle.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapsule(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 245, 196, 1),
        borderRadius: BorderRadius.circular(AppSizes.radiusCapsule),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.calendar_today,
            size: 11,
            color: AppColors.darkGreen,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: AppTextStyle.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.darkGreen,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class SubmitWasteButton extends StatelessWidget {
  final VoidCallback onTap;

  const SubmitWasteButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.marginButton),
      height: AppSizes.buttonHeight,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primaryGreen,
            AppColors.darkGreen,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusButton),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusButton),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'List sampah diajukan',
                  style: AppTextStyle.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomBottomNavbar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const CustomBottomNavbar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Responsive width calculation
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        // Main Navigation Bar Container
        Container(
          height: AppSizes.navbarHeight,
          width: screenWidth,
          decoration: const BoxDecoration(
            color: AppColors.primaryGreen,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppSizes.radiusNavbar),
              topRight: Radius.circular(AppSizes.radiusNavbar),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Home Tab
              Expanded(
                child: InkWell(
                  onTap: () => onItemSelected(0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.home_outlined,
                        color: selectedIndex == 0 ? Colors.white : Colors.white.withValues(alpha: 0.7),
                        size: 26,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Home',
                        style: AppTextStyle.poppins(
                          fontSize: 12,
                          fontWeight: selectedIndex == 0 ? FontWeight.w700 : FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      if (selectedIndex == 0) ...[
                        const SizedBox(height: 4),
                        Container(
                          width: 36,
                          height: 2,
                          color: Colors.white,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              // Center Spacer for QR Code (Displays the "QR Code" label below the floating button)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Text(
                        'QR Code',
                        style: AppTextStyle.poppins(
                          fontSize: 12,
                          fontWeight: selectedIndex == 1 ? FontWeight.w700 : FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Profile Tab
              Expanded(
                child: InkWell(
                  onTap: () => onItemSelected(2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_outline,
                        color: selectedIndex == 2 ? Colors.white : Colors.white.withValues(alpha: 0.7),
                        size: 26,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Profil',
                        style: AppTextStyle.poppins(
                          fontSize: 12,
                          fontWeight: selectedIndex == 2 ? FontWeight.w700 : FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      if (selectedIndex == 2) ...[
                        const SizedBox(height: 4),
                        Container(
                          width: 36,
                          height: 2,
                          color: Colors.white,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Floating QR Code Scanner Button
        Positioned(
          bottom: 22, // Floating height offset
          child: GestureDetector(
            onTap: () => onItemSelected(1),
            child: Container(
              width: AppSizes.qrButtonDiameter,
              height: AppSizes.qrButtonDiameter,
              decoration: BoxDecoration(
                color: AppColors.darkGreen,
                borderRadius: BorderRadius.circular(24), // Squircle shape matching the design
                border: Border.all(
                  color: Colors.white,
                  width: 5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.qr_code_scanner,
                color: Colors.white,
                size: 34,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
