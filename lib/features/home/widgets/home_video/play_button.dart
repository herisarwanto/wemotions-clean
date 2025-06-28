import 'package:socialverse/export.dart';

class PlayButton extends StatelessWidget {
  final bool isFromVideoWidget;
  const PlayButton({this.isFromVideoWidget = false, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isFromVideoWidget) {
      return Consumer<VideoProvider>(
        builder: (_, __, ___) {
          final controller = __.videoController(__.index);

          if (controller == null) {
            return EmptyState();
          }
          if (!controller.value.isInitialized) {
            return EmptyState();
          }

          return __.videoController(__.index)!.value.isInitialized
              ? __.videoController(__.index)!.value.isPlaying
                  ? shrink
                  : Center(
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white.withOpacity(0.4),
                        size: 65,
                      ),
                    )
              : shrink;
        },
      );
    }
    return Consumer<HomeProvider>(
      builder: (_, __, ___) {
        final controller = __.videoController(__.index);

        if (controller == null) {
          return EmptyState();
        }
        if (!controller.value.isInitialized) {
          return EmptyState();
        }

        return __.videoController(__.index)!.value.isInitialized
            ? __.videoController(__.index)!.value.isPlaying
                ? shrink
                : Center(
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white.withOpacity(0.4),
                      size: 65,
                    ),
                  )
            : shrink;
      },
    );
  }
}
