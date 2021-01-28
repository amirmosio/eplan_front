import 'package:vibration/vibration.dart';

void doVibrate({int durationMilliSec = 200}) async {
  if (await Vibration.hasVibrator()) {
    if (await Vibration.hasCustomVibrationsSupport()) {
      Vibration.vibrate(duration: durationMilliSec);
    } else {
      Vibration.vibrate(duration: durationMilliSec);
    }
  }
}
