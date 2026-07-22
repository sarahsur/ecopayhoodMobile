import '../constants/app_colors.dart';
import '../models/waste_category.dart';

/// Single source of truth for all waste categories (home grid + detail pages).
const List<WasteCategory> wasteCategories = [
  // Top-left grid / pengiriman 5 — puzzle banner on LEFT
  WasteCategory(
    title: 'Minyak Sisa Masak',
    imageAsset: 'lib/Assets/images/mascot_oil.png',
    imagePath: 'oil.png',
    puzzleImageAsset: 'lib/Assets/images/1.png',
    dashboardPuzzleImageAsset: 'lib/Assets/images/1.1.png',
    backgroundColor: AppColors.yellow,
    topEdge: 0,
    rightEdge: 1,
    bottomEdge: 1,
    leftEdge: 0,
    textSize: 12,
    bannerPuzzleOnRight: false,
  ),

  // Top-right grid / pengiriman 6 — puzzle banner on RIGHT
  WasteCategory(
    title: 'Karton / Kertas Daur Ulang',
    imageAsset: 'lib/Assets/images/mascot_paper.png',
    imagePath: 'paper.png',
    puzzleImageAsset: 'lib/Assets/images/2.png',
    dashboardPuzzleImageAsset: 'lib/Assets/images/2.2.png',
    backgroundColor: AppColors.pastelGreen,
    topEdge: 0,
    rightEdge: 0,
    bottomEdge: -1,
    leftEdge: -1,
    isTextCurved: true,
    isTextCurvedDownward: false,
    textRadius: 74,
    textYOffset: -28,
    imageYOffset: -8,
    textSize: 11.5,
    letterSpacing: -0.5,
    startAngleOffset: 4,
    bannerPuzzleOnRight: true,
  ),

  // Bottom-left grid / pengiriman 7 — puzzle banner on LEFT
  WasteCategory(
    title: 'Plastik Daur Ulang',
    imageAsset: 'lib/Assets/images/mascot_plastic.png',
    imagePath: 'plastic.png',
    puzzleImageAsset: 'lib/Assets/images/3.png',
    dashboardPuzzleImageAsset: 'lib/Assets/images/3.3.png',
    backgroundColor: AppColors.orange,
    topEdge: -1,
    rightEdge: 1,
    bottomEdge: 0,
    leftEdge: 0,
    textSize: 12.5,
    bannerPuzzleOnRight: false,
  ),

  // Bottom-right grid / pengiriman 8 — puzzle banner on RIGHT
  WasteCategory(
    title: 'Sampah Organik',
    imageAsset: 'lib/Assets/images/mascot_organic.png',
    imagePath: 'organic.png',
    puzzleImageAsset: 'lib/Assets/images/4.png',
    dashboardPuzzleImageAsset: 'lib/Assets/images/4.4.png',
    backgroundColor: AppColors.pink,
    topEdge: 1,
    rightEdge: 0,
    bottomEdge: 0,
    leftEdge: -1,
    textSize: 12,
    bannerPuzzleOnRight: true,
  ),
];
