import 'dart:async';
import 'dart:math' as math;

import 'package:mhamrah/Values/Utils.dart';
import 'package:mhamrah/Values/style.dart' as s;
import 'package:mhamrah/Values/style.dart';
import 'package:flutter/material.dart';

class CountDownTimer extends StatefulWidget {
  final Duration d;
  Timer timer;

  CountDownTimer(this.d);

  @override
  _CountDownTimerState createState() => _CountDownTimerState(d);
}

class _CountDownTimerState extends State<CountDownTimer>
    with TickerProviderStateMixin {
  Duration d;
  int passSeconds = 0;

  _CountDownTimerState(this.d);

  String get timerString {
    Duration duration = Duration(seconds: d.inSeconds - passSeconds);
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    getTimer();
  }

  void getTimer() {
    widget.timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (passSeconds >= d.inSeconds) {
        Navigator.of(context, rootNavigator: true).maybePop();
      } else {
        setState(() {
          passSeconds += 1;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        replaceEnglishWithPersianNumber(timerString),
        style: getTextStyle(20, s.Theme.darkText),
      ),
    );
  }

  @override
  void dispose() {
    try{
      widget.timer.cancel();
    }catch(e){}
    super.dispose();
  }
}
