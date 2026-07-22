import 'puzzle_widget.dart';
import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'constants/app_sizes.dart';
import 'constants/app_textstyle.dart';
import 'models/waste_category.dart';
import 'providers/notification_provider.dart';
import 'pickup_confirmation_page.dart';

/// Single reusable detail page for ALL waste categories.
/// Receives a [WasteCategory] and renders the icon, color and title
/// dynamically — never hardcoded, never duplicated per category.
class CategoryDetailPage extends StatelessWidget {
  final WasteCategory category;

  const CategoryDetailPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Custom Header with back button
                Padding(
                  padding: EdgeInsets.only(
                    left: AppSizes.headerMarginLeft,
                    right: AppSizes.headerMarginLeft,
                    top: AppSizes.headerMarginTop,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: AppColors.darkGreen,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppSizes.spacingBelowHeader),

                // Category Header (Puzzle Card + Green Banner)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CategoryHeader(
                    category: category,
                    screenWidth: screenWidth,
                  ),
                ),

                SizedBox(height: 40),

                // Address Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alamat',
                        style: AppTextStyle.alamatTitle,
                      ),
                      const SizedBox(height: AppSizes.spacingBelowAlamatTitle),
                      AddressCard(
                        name: 'Bima',
                        phone: '(+62) 863-7762-9900',
                        address: 'Rt.08/Rw.11,\nJalan Ayu Jalan Blok JA No.24,\nSukajaya, Kuningan',
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppSizes.spacingBelowAddressCard),

                // Schedule Pickup Button (moved up, no Spacer)
                Center(
                  child: PrimaryButton(
                    width: screenWidth * AppSizes.buttonWidthPercent,
                    height: AppSizes.primaryButtonHeight,
                    label: 'Jadwalkan Penjemputan',
                    onPressed: () {
                      final notificationProvider = NotificationProvider();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PickupConfirmationPage(
                            category: category.title,
                            amount: '2',
                            unit: 'kg',
                            onConfirm: () {
                              notificationProvider.addPickupNotification(
                                category: category.title,
                                amount: '2',
                                unit: 'kg',
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}


/// Reusable address card with an inset / concave (pressed-in) effect.
class AddressCard extends StatelessWidget {
  final String name;
  final String phone;
  final String address;

  const AddressCard({
    super.key,
    required this.name,
    required this.phone,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusAddressCard),
        gradient: AppColors.addressGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(name, style: AppTextStyle.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGreen,
                )),
                const SizedBox(width: 8),
                Text('|', style: AppTextStyle.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.darkGreen,
                )),
                const SizedBox(width: 8),
                const Icon(Icons.phone, size: 14, color: AppColors.darkGreen),
                const SizedBox(width: 4),
                Text(phone, style: AppTextStyle.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkGreen,
                )),
              ],
            ),
            const SizedBox(height: 10),
            Text(address, style: AppTextStyle.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.darkGreen,
              height: 1.4,
            )),
          ],
        ),
      ),
    );
  }
}

/// Category header widget for CategoryDetailPage.
/// Contains a Stack with puzzle card (square) overlapping green banner.
/// Puzzle placement and Kategori text position are dynamic based on category.
class CategoryHeader extends StatelessWidget {
  final WasteCategory category;
  final double screenWidth;

  const CategoryHeader({
    super.key,
    required this.category,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    // Match AddressCard horizontal padding (16px on each side)
    final availableWidth = screenWidth - 32;
    
    // Make puzzle more square-shaped and larger
    final puzzleHeight = 160.0;
    final puzzleWidth = availableWidth * 0.55;
    
    // Banner 75% of puzzle height, and overlaps 25-35% of puzzle body.
    // If banner takes up 75% of available width, there will be a nice overlap.
    final bannerWidth = availableWidth * 0.75; 
    final bannerHeight = puzzleHeight * 0.75;
    
    final isPuzzleOnRight = category.bannerPuzzleOnRight;

    return SizedBox(
      width: availableWidth,
      height: puzzleHeight,
      child: Stack(
        children: [
          // Banner (di belakang)
          Align(
            alignment: isPuzzleOnRight ? Alignment.centerLeft : Alignment.centerRight,
            child: Container(
              width: bannerWidth,
              height: bannerHeight,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColors.primaryGreen,
                    AppColors.darkGreen,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(AppSizes.radiusCard),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.darkGreen.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              // Posisikan text "Kategori" menjauhi Puzzle
              alignment: isPuzzleOnRight ? Alignment.centerLeft : Alignment.centerRight,
              padding: EdgeInsets.only(
                left: isPuzzleOnRight ? 32.0 : 0.0,
                right: isPuzzleOnRight ? 0.0 : 32.0,
              ),
              child: Text(
                'Kategori',
                style: AppTextStyle.kategoriTitle,
              ),
            ),
          ),
          
          // Puzzle Card (di depan) - using PNG image
          Align(
            alignment: isPuzzleOnRight ? Alignment.centerRight : Alignment.centerLeft,
            child: SizedBox(
              width: puzzleWidth,
              height: puzzleHeight,
              child: PuzzleWidget(
                category: category,
                width: puzzleWidth,
                height: puzzleHeight,
                removeEffects: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable primary button with green gradient and shadow.
class PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final double width;
  final double height;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.width = 290,
    this.height = 52,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppColors.primaryGreen,
              AppColors.darkGreen,
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusButton),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        transform: _pressed
            ? Matrix4.translationValues(0, 2, 0)
            : Matrix4.identity(),
        alignment: Alignment.center,
        child: Text(
          widget.label,
          style: AppTextStyle.buttonText,
        ),
      ),
    );
  }
}

