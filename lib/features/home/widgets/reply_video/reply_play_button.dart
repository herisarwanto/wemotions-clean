import 'package:socialverse/export.dart';

class ReplyPlayButton extends StatelessWidget {
  const ReplyPlayButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ReplyProvider>(
      builder: (_, __, ___) {
        if (__.posts.isEmpty || __.index >= __.posts.length) {
          return shrink;
        }

        final controller = __.videoController(__.index);
        if (controller == null || !controller.value.isInitialized) {
          return shrink;
        }

        return controller.value.isPlaying
            ? shrink
            : Center(
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white.withOpacity(0.4),
                  size: 65,
                ),
              );
      },
    );
  }
}
