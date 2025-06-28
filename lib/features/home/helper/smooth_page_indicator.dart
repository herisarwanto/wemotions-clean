import 'package:socialverse/export.dart';
import 'dart:math' as math;

class SmoothPageIndicatorView extends StatelessWidget {
  const SmoothPageIndicatorView({
    Key? key,
  }) : super(key: key);

  List<Widget> _buildDots({
    required SmoothPageIndicatorProvider provider,
    required int totalCount,
    required int currentIndex,
    required bool isHorizontal,
    required int visibleDots,
  }) {
    List<Widget> dots = [];

    if (totalCount == 0) {
      dots.clear();
      return dots;
    }

    // Limit visible dots to max 3
    int maxDots = 3;
    int start = currentIndex - 1;
    int end = currentIndex + 1;
    if (totalCount <= maxDots) {
      start = 0;
      end = totalCount - 1;
    } else {
      if (currentIndex == 0) {
        start = 0;
        end = 2;
      } else if (currentIndex == totalCount - 1) {
        start = totalCount - 3;
        end = totalCount - 1;
      } else {
        start = currentIndex - 1;
        end = currentIndex + 1;
      }
    }

    for (int i = start; i <= end; i++) {
      final isLastDot = (i == end);
      if (!isHorizontal) {
        // Vertical dots (main feed)
        dots.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Indicator(
                isActive: i == currentIndex,
                isHorizontal: isHorizontal,
                makeTransparent: false,
                label: isLastDot
                    ? totalCount.toString()
                    : null, // Only last dot has label
                isCurrentVideo: i == currentIndex,
                forceSize: 20, // force all dots to same size
              ),
              // Custom horizontal indicator: only 1 dot with replay count if has replay
              if (provider.totalHorizontalPages > 0 && i == currentIndex)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Indicator(
                    isActive: true,
                    isHorizontal: true,
                    makeTransparent: false,
                    label: provider.totalHorizontalPages
                        .toString(), // Show replay count
                    isCurrentVideo: true,
                    forceSize: 20, // force all dots to same size
                  ),
                ),
            ],
          ),
        );
      } else {
        // Horizontal dots (replies)
        dots.add(
          Indicator(
            isActive: i == currentIndex,
            isHorizontal: isHorizontal,
            label: isLastDot
                ? totalCount.toString()
                : null, // Only last dot has label
            isCurrentVideo: i == currentIndex,
            forceSize: 20, // force all dots to same size
          ),
        );
      }
    }
    return dots;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SmoothPageIndicatorProvider>(
      builder: (_, provider, ___) {
        // Ensure we have valid data before building
        if (provider.totalVerticalPages == -1 ||
            provider.currentVerticalIndex == -1) {
          return SizedBox.shrink();
        }

        // Calculate offset to ensure horizontal indicator overlaps vertical active indicator
        double verticalOffset = 0;
        if (provider.currentVerticalIndex != -1) {
          // Calculate position based on current index (accounting for more indicators)
          // int visibleVerticalPosition = 0;
          // if (provider.currentVerticalIndex > 0) {
          //   visibleVerticalPosition++; // Account for leading more indicator
          // }
          verticalOffset = (provider.currentVerticalIndex == 0 ? 0 : 1) +
              (provider.currentVerticalIndex -
                  math.max(0, provider.currentVerticalIndex - 1));
        }

        return Container(
          // width: 72,
          height: 82,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Vertical indicators
              Padding(
                padding: EdgeInsets.only(
                    left: provider.totalHorizontalPages >= 2
                        ? (cs.width(context) / 4.5) / (3.2)
                        : (cs.width(context) / 4.5) / (1.9)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildDots(
                    provider: provider,
                    totalCount: provider.totalVerticalPages,
                    currentIndex: provider.currentVerticalIndex,
                    isHorizontal: false,
                    visibleDots: provider.verticalVisibleDots,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class Indicator extends StatelessWidget {
  final bool isActive;
  final bool isHorizontal;
  final bool isMoreIndicator;
  final bool makeTransparent;
  final String? label; // For label in last dot
  final bool isCurrentVideo;
  final double? forceSize; // new: force all dots to same size

  const Indicator({
    Key? key,
    required this.isActive,
    required this.isHorizontal,
    this.isMoreIndicator = false,
    this.makeTransparent = false,
    this.label,
    this.isCurrentVideo = false,
    this.forceSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use forceSize for all dots
    double indicatorWidth = forceSize ??
        (isHorizontal
            ? (isMoreIndicator ? 6 : (isActive ? 9 : 8))
            : (isMoreIndicator ? 6 : 8));
    double indicatorHeight = forceSize ??
        (isHorizontal
            ? (isMoreIndicator ? 6 : 8)
            : (isMoreIndicator ? 6 : (isActive ? 9 : 8)));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: EdgeInsets.symmetric(
        horizontal: isHorizontal ? 3 : 0,
        vertical: isHorizontal ? 0 : 4,
      ),
      width: indicatorWidth,
      height: indicatorHeight,
      decoration: BoxDecoration(
        color: makeTransparent
            ? Colors.transparent
            : isActive && !isHorizontal
                ? Constants.primaryColor
                : (isMoreIndicator
                    ? Constants.lightPrimary.withOpacity(0.3)
                    : Constants.lightPrimary.withOpacity(0.5)),
        shape: BoxShape.circle,
        border: isCurrentVideo && !isHorizontal
            ? Border.all(color: Constants.primaryColor, width: 2)
            : null,
      ),
      child: label != null
          ? Center(
              child: Text(
                label!,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }
}


//
//
// class SmoothPageIndicatorView extends StatelessWidget {
//   // final int maxHorizontal;
//   // final int maxVertical;
//   // final VoidCallback onHorizontalIndexChange;
//   // final VoidCallback onVerticalIndexChange;
//   //
//   // DotScrollingView({required this.maxHorizontal, required this.maxVertical, required this.onHorizontalIndexChange,required this.onVerticalIndexChange});
//   @override
//   Widget build(BuildContext context) {
//     double horizontalPadding=8;
//     double verticalPadding=8;
//     return Consumer<SmoothPageIndicatorProvider>(
//       builder: (_, __, ___) {
//         return SizedBox(
//           width: MediaQuery.of(context).size.width,
//           child: Stack(
//             alignment: Alignment.center,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   __.hidePlaceHorizontal==0?CircularDot(horizontalPadding: horizontalPadding, verticalPadding: 0, clr:Colors.transparent,onFocus: false,)
//                       :
//                   CircularDot(horizontalPadding: horizontalPadding, verticalPadding: 0, clr: Colors.grey,onFocus: false,),
//
//                   __.hidePlaceHorizontal==1?CircularDot(horizontalPadding: horizontalPadding, verticalPadding: 0, clr:Colors.transparent,onFocus: true, )
//                       :
//                   CircularDot(horizontalPadding: horizontalPadding, verticalPadding: 0, clr: Constants.primaryColor,onFocus: true,),
//
//                   __.hidePlaceHorizontal==2?CircularDot(horizontalPadding: horizontalPadding, verticalPadding: 0, clr:Colors.transparent,onFocus: false, )
//                       :
//                   CircularDot(horizontalPadding: horizontalPadding, verticalPadding: 0, clr: Colors.grey,onFocus: false,),
//
//                 ],
//               ),
//               Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   // height,
//                   __.hidePlaceVertical==0? CircularDot(horizontalPadding: 0, verticalPadding: verticalPadding, clr: Colors.transparent,onFocus: false,)
//                       :
//                   CircularDot(horizontalPadding: 0, verticalPadding: verticalPadding, clr: Colors.grey,onFocus: false,),
//
//
//                   __.hidePlaceVertical==1? CircularDot(horizontalPadding: 0, verticalPadding: verticalPadding, clr: Colors.transparent,onFocus: true,)
//                       :
//                   CircularDot(horizontalPadding: 0, verticalPadding: verticalPadding, clr: Constants.primaryColor,onFocus: false,),
//
//
//                   __.hidePlaceVertical==2? CircularDot(horizontalPadding: 0, verticalPadding: verticalPadding, clr: Colors.transparent,onFocus: false,)
//                       :
//                   CircularDot(horizontalPadding: 0, verticalPadding: verticalPadding, clr: Colors.grey,onFocus: false,)
//
//                 ],
//               ),
//               height2
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
//
