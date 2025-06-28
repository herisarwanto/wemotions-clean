// RecordButton.dart
import 'package:socialverse/export.dart';

class RecordButton extends StatefulWidget {
  const RecordButton({Key? key}) : super(key: key);

  @override
  State<RecordButton> createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CameraProvider>(
      builder: (_, __, ___) {
        return GestureDetector(
          onTap: () async {
            if (__ .isVideoRecord) {
              await __.stopRecording();
              __.isRecordingLocked=false;

            }else if(__.videoController==null){
              __.shouldStartRecording=true;
              await __.startRecording();
            }
          },
          child: CircularPercentIndicator(
            radius: __.isRecording?45:40,
            lineWidth: 4.0,
            backgroundColor:
                __.isRecordStart ? Colors.white : Theme.of(context).hintColor,
            percent: __.recordPercentage,
            progressColor: const Color(0xFFA858F4),
            animation: true,
            addAutomaticKeepAlive: true,
            animationDuration: 1000,
            animateFromLastPercent: true,
            center: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 86,
                  width: 86,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white10,
                        Colors.white12,
                        Colors.white38,
                      ],
                      stops: [0.5, 0.6, 0.7, 1.0],
                    ),
                  ),
                ),



                AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  height: __.isRecording?52:48,
                  width: __.isRecording?52:48,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: __.isRecording? Constants.primaryColor:Colors.white,
                    borderRadius: __.isRecording?BorderRadius.all(Radius.circular(20)):BorderRadius.all(Radius.circular(50)),
                  ),
                ),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 400),
                    height: __.isRecording?0:18,
                    width: __.isRecording?0:18,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: __.isRecordStart?BorderRadius.all(Radius.circular(50)):BorderRadius.all(Radius.circular(2)),
                      color: Theme.of(context).hintColor,
                    ),
                  ),

              ],
            ),
          ),
        );
      },
    );
  }
}