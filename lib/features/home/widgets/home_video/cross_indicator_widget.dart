import 'package:flutter/material.dart';

class CrossIndicatorWidget extends StatelessWidget {
  final int currentIndex; // index of current replay
  final int totalCount; // total replay count
  final bool hasChild; // does this replay have child replay?
  final bool isRoot; // is this the root replay (first child of feed)?
  final bool isLast; // is this the last replay?
  final int childCount; // number of child replay (if any)

  const CrossIndicatorWidget({
    Key? key,
    required this.currentIndex,
    required this.totalCount,
    required this.hasChild,
    required this.isRoot,
    required this.isLast,
    this.childCount = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color yellowDot = Color(0xFFFFD600);
    const Color dotBg = Colors.white;
    const double dotSize = 24;
    const double textSize = 14;

    return SizedBox(
      width: 90,
      height: hasChild ? 120 : 90,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Top: home indicator with label 'H'
          if (currentIndex > 0)
            Positioned(
              left: 28,
              top: 2,
              child: _buildLabelDot(
                label: 'H',
                isActive: false,
                activeColor: yellowDot,
                dotSize: dotSize,
                textSize: textSize,
              ),
            ),

          // Left: Only 1 parent indicator with label 'P' if at first child
          if (currentIndex == 0)
            Positioned(
              left: 0,
              top: 33,
              child: _buildLabelDot(
                label: 'P',
                isActive: false,
                activeColor: dotBg,
                dotSize: dotSize,
                textSize: textSize,
              ),
            ),

          if (currentIndex > 0)
            Positioned(
              left: 0,
              top: 33,
              child: _buildLabelDot(
                label: (totalCount - currentIndex - 1).toString(),
                isActive: false,
                activeColor: yellowDot,
                dotSize: dotSize,
                textSize: textSize,
              ),
            ),

          // Center (active)
          Positioned(
            left: 28,
            top: 33,
            child: _buildLabelDot(
              label: '',
              isActive: true,
              activeColor: yellowDot,
              dotSize: dotSize,
              textSize: textSize,
            ),
          ),
          // Right: if there are remaining child after current, show 1 dot with label (remaining count)
          if (!isLast)
            Positioned(
              right: 0,
              top: 33,
              child: _buildLabelDot(
                label: (totalCount - currentIndex - 1).toString(),
                isActive: false,
                activeColor: dotBg,
                dotSize: dotSize,
                textSize: textSize,
              ),
            ),
          // Bottom: if current has child, show 1 dot with label (child count)
          if (hasChild)
            Positioned(
              top: 32,
              bottom: 0,
              left: 28,
              child: _buildLabelDot(
                label: childCount.toString(),
                isActive: false,
                activeColor: dotBg,
                dotSize: dotSize,
                textSize: textSize,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLabelDot({
    required String label,
    required bool isActive,
    required Color activeColor,
    required double dotSize,
    required double textSize,
  }) {
    return Container(
      width: dotSize,
      height: dotSize,
      decoration: BoxDecoration(
        color: isActive ? activeColor : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive ? activeColor : Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: label.isNotEmpty
          ? Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.black : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: textSize,
              ),
            )
          : null,
    );
  }
}
