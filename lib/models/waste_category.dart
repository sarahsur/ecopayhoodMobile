import 'package:flutter/material.dart';

/// Data model representing a single waste category.
/// Used to drive both the Home page cards and the reusable
/// CategoryDetailPage (title, icon, and color all come from here).
class WasteCategory {
  final String title;
  final String imageAsset;
  final String imagePath;
  final Color backgroundColor;
  final int topEdge;
  final int rightEdge;
  final int bottomEdge;
  final int leftEdge;
  final bool isTextCurved;
  final bool isTextCurvedDownward;
  final bool isPlasticStyle;
  final double textRadius;
  final double textYOffset;
  final double imageYOffset;
  final double textSize;
  final double letterSpacing;
  final double startAngleOffset;

  /// When true, the puzzle piece overlaps the green banner on the right side
  /// (detail page layout). When false, it sits on the left.
  final bool bannerPuzzleOnRight;

  /// PNG puzzle image asset path (1.png, 2.png, 3.png, 4.png)
  final String puzzleImageAsset;

  /// PNG puzzle image asset path for Dashboard (1.1.png, 2.2.png, 3.3.png, 4.4.png)
  final String dashboardPuzzleImageAsset;

  const WasteCategory({
    required this.title,
    required this.imageAsset,
    required this.imagePath,
    required this.backgroundColor,
    required this.puzzleImageAsset,
    this.dashboardPuzzleImageAsset = '',
    this.topEdge = 0,
    this.rightEdge = 0,
    this.bottomEdge = 0,
    this.leftEdge = 0,
    this.isTextCurved = false,
    this.isTextCurvedDownward = false,
    this.isPlasticStyle = false,
    this.textRadius = 50,
    this.textYOffset = 0,
    this.imageYOffset = 0.0,
    this.textSize = 12,
    this.letterSpacing = 0,
    this.startAngleOffset = 0,
    this.bannerPuzzleOnRight = false,
  });
}
