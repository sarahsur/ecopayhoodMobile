import 'package:flutter/material.dart';
import 'models/waste_category.dart';

/// Reusable puzzle widget that uses PNG images instead of CustomPainter.
/// Displays a puzzle piece with category icon and text overlay.
class PuzzleWidget extends StatefulWidget {
  final WasteCategory category;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final bool useDashboardImage;
  final bool removeEffects;

  const PuzzleWidget({
    super.key,
    required this.category,
    this.onTap,
    this.width,
    this.height,
    this.useDashboardImage = false,
    this.removeEffects = false,
  });

  @override
  State<PuzzleWidget> createState() => _PuzzleWidgetState();
}

class _PuzzleWidgetState extends State<PuzzleWidget> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isActive = _isHovered || _isPressed;
    final double translateY = isActive ? -6.0 : 0.0;
    final bool shouldRemoveEffects = widget.useDashboardImage || widget.removeEffects;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          if (widget.onTap != null) widget.onTap!();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, shouldRemoveEffects ? 0.0 : translateY, 0),
          width: widget.width,
          height: widget.height,
          decoration: shouldRemoveEffects
              ? null
              : BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isActive ? 0.18 : 0.12),
                      blurRadius: isActive ? 22 : 18,
                      offset: Offset(0, isActive ? 10 : 6),
                      spreadRadius: 0,
                    ),
                  ],
                ),
          child: Stack(
            children: [
              // Puzzle PNG image - no clipping, let PNG define the shape
              Positioned.fill(
                child: Image.asset(
                  widget.useDashboardImage && widget.category.dashboardPuzzleImageAsset.isNotEmpty
                      ? widget.category.dashboardPuzzleImageAsset
                      : widget.category.puzzleImageAsset,
                  fit: BoxFit.fill,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: widget.category.backgroundColor,
                      child: const Center(
                        child: Icon(
                          Icons.error_outline,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Highlight effect on top (only when effects are enabled)
              if (!shouldRemoveEffects)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: widget.height != null ? widget.height! * 0.3 : 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.25),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

