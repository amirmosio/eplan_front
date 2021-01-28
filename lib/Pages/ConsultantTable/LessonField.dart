import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:custom_switch/custom_switch.dart';
import 'package:mhamrah/ConnectionService/ConsultantTableSRV.dart';
import 'package:mhamrah/ConnectionService/HTTPService.dart';
import 'package:mhamrah/Models/ConsultantTableMV.dart';
import 'package:mhamrah/Models/UserMV.dart';
import 'package:mhamrah/Pages/StudentMainPage.dart';
import 'package:mhamrah/Utils/LocalFileUtils.dart';
import 'package:mhamrah/Values/Utils.dart';
import 'package:mhamrah/Values/string.dart';
import 'package:mhamrah/Values/string.dart';
import 'package:mhamrah/Values/style.dart' as prefix0;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'ConsultantTable.dart';

class LessonFieldRow extends StatefulWidget {
  final ConsultantTableState consultantTableState;
  final CLessonPlanPerDay l;

  LessonFieldRow(this.l, this.consultantTableState);

  @override
  _LessonFieldRowState createState() =>
      _LessonFieldRowState(l, consultantTableState);
}

class _LessonFieldRowState extends State<LessonFieldRow> {
  final ConsultantTableState consultantTableState;
  final CLessonPlanPerDay l;
  bool canBeVolumeTable = true;
  int userType = 0;
  ConsultantSetting consultantSettingOrDefault = ConsultantSetting();
  double xSize;
  double ySize;

  bool type = false;

  _LessonFieldRowState(this.l, this.consultantTableState);

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    LSM.getConsultantSetting().then((value) {
      setState(() {
        this.consultantSettingOrDefault = value;
      });
    });
    LSM.getUserMode().then((userType) {
      setState(() {
        this.userType = userType;
      });
      canBeVolumeTable =
          consultantTableState.consultantTableData.canBeVolumeBaseTable();
      type = (userType == 1
          ? !canBeVolumeTable
          : (consultantSettingOrDefault.timeVolumeConsultantTableMode ||
              !canBeVolumeTable));
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      key: ValueKey(l.key),
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        LessonName(l, consultantTableState),
        getTimeWidget(type
            ? "" +
                l.endTime +
                (l.startTime == "" ? "" : " تا ") +
                (l.startTime == "" ? "" : (l.startTime))
            : l.endTime)
      ],
    );
  }

  Widget getTimeWidget(String time) {
    ySize = MediaQuery.of(context).size.height;
    xSize = MediaQuery.of(context).size.width;
    return new Padding(
      padding: EdgeInsets.only(
          top: ySize * (2 / 100), right: (4 / 100) * xSize, left: 2, bottom: 5),
      child: new Container(
          height: ySize * (4 / 100),
          width: xSize * (33 / 100),
          decoration: new BoxDecoration(
            color: prefix0.Theme.startEndTimeItemsBG,
            borderRadius: new BorderRadius.all(
              Radius.circular(25),
            ),
          ),
          alignment: Alignment.centerRight,
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              new Container(
                width: (25 / 100) * xSize,
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: 2, left: 0, right: 0),
                child: AutoSizeText(
                  replaceEnglishWithPersianNumber(time)
                      .replaceAll(":", " : ")
                      .replaceAll("تا", "-"),
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'traffic',
//                      fontWeight: FontWeight.w800,
                      color: prefix0.Theme.onMainBGText),
                ),
              ),
              new Padding(
                padding: EdgeInsets.only(
                    right: ((1.7 / 575) * xSize - 0.08) / 100 * xSize),
                child: Icon(
                  Icons.fiber_manual_record,
                  color: l.importance
                      ? prefix0.Theme.importantYellow
                      : prefix0.Theme.onMainBGText,
                ),
              ),
            ],
          )),
    );
  }
}

class LessonName extends StatefulWidget {
  final ConsultantTableState consultantTableState;
  final CLessonPlanPerDay cLessonPlanPerDay;

  LessonName(this.cLessonPlanPerDay, this.consultantTableState);

  @override
  _LessonNameState createState() =>
      _LessonNameState(cLessonPlanPerDay, consultantTableState);
}

class _LessonNameState extends State<LessonName> with TickerProviderStateMixin {
  ConnectionService connectionService = ConnectionService();
  int userType = 1;
  ConsultantTableSRV consultantTableSRV = ConsultantTableSRV();
  ConsultantTableState consultantTableState;

  bool _toggle = false;
  bool _highlightedToggle = false;
  CLessonPlanPerDay cLessonPlanPerDay;
  double xSize;
  double ySize;
  bool switchLoading = false;

  /// voice stuff
  AudioPlayer audioPlayer;
  AudioPlayerState audioStatus = AudioPlayerState.STOPPED;
  Duration _duration = Duration();
  Duration _position = Duration();
  StreamSubscription _durationSubscription;
  StreamSubscription _positionSubscription;
  StreamSubscription _playerCompleteSubscription;
  StreamSubscription _playerErrorSubscription;
  StreamSubscription _playerStateSubscription;

  bool voiceDownloaded = false;

  double lessonHeight = null;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  _LessonNameState(this.cLessonPlanPerDay, this.consultantTableState);

  @override
  void initState() {
    super.initState();
    _highlightedToggle = cLessonPlanPerDay.isComplete;
    LSM.getUserMode().then((type) {
      setState(() {
        userType = type;
      });
    });
  }

  void setListenerAndInitVoice() {
    if (cLessonPlanPerDay.hasVoiceFile && audioPlayer == null) {
      String voiceURL = connectionService.getLessonDescriptionVoiceURL(
          StudentMainPage.studentUsername,
          consultantTableState.consultantTableData.name,
          cLessonPlanPerDay.key);
      setState(() {
        audioPlayer = AudioPlayer();
        audioPlayer.setUrl(voiceURL);
        _durationSubscription =
            audioPlayer.onDurationChanged.listen((Duration d) {
          setState(() {
            _duration = d;
          });
        });

        _positionSubscription =
            audioPlayer.onAudioPositionChanged.listen((Duration d) {
          setState(() {
            _position = d;
            voiceDownloaded = true;
          });
        });
        _playerCompleteSubscription = audioPlayer.onSeekComplete.listen((t) {});

        _playerStateSubscription =
            audioPlayer.onPlayerStateChanged.listen((AudioPlayerState s) {
          if (s == AudioPlayerState.COMPLETED) {
            setState(() {
              s = AudioPlayerState.STOPPED;
              _position = Duration(seconds: 0);
            });
          }
          setState(() => audioStatus = s);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ySize = MediaQuery.of(context).size.height;
    xSize = MediaQuery.of(context).size.width;
    return new Padding(
      padding: EdgeInsets.only(top: 10, bottom: 2, left: 10, right: 5),
      child: new Container(
        height: lessonHeight,
        decoration: new BoxDecoration(
          color: prefix0.Theme.lessonNameBG,
          borderRadius: new BorderRadius.all(
            Radius.circular(25),
          ),
        ),
        child: new Column(
          children: <Widget>[
            new GestureDetector(
              child: new Container(
                decoration: new BoxDecoration(
                  color: cLessonPlanPerDay.isComplete
                      ? prefix0.Theme.lessonHighlight
                      : prefix0.Theme.lessonNameBG,
                  borderRadius: new BorderRadius.all(
                    Radius.circular(25),
                  ),
                ),
                alignment: Alignment.center,
                width: xSize * (58 / 100),
                height: ySize * (6 / 100),
                child: AutoSizeText(
                  cLessonPlanPerDay.lessonName,
                  style: prefix0.getTextStyle(
                      20, prefix0.Theme.onLessonNameBGText),
                ),
              ),
              onTap: () {
                setState(() {
                  _toggle = !_toggle;
                });
              },
            ),
            getDescription()
          ],
        ),
      ),
    );
  }

  Widget getLoadingProgress() {
    double r = 15;
    return Container(
      child: CircleAvatar(
        backgroundColor: Color.fromARGB(0, 0, 0, 0),
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
        radius: r,
      ),
      width: r,
      height: r,
    );
  }

  Widget getDescription() {
    return AnimatedSize(
        duration: Duration(milliseconds: 200),
        vsync: this,
        curve: Curves.ease,
        child: Container(
          height: _toggle ? null : 0,
          child: new Padding(
            padding: EdgeInsets.all(xSize * (1 / 100)),
            child: new Container(
              width: 200,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: prefix0.Theme.descriptionBG,
                  borderRadius: BorderRadius.all(Radius.circular(25))),
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  new Container(
                      width: 200,
                      height: 20,
                      alignment: Alignment.centerRight,
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Container(
                            height: 0.5,
                            width: xSize * (30 / 100),
                            color: Colors.black,
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 5),
                            child: new AutoSizeText(
                              "توضیحات :  ",
                              textDirection: TextDirection.rtl,
                              style: prefix0.getTextStyle(
                                  14, prefix0.Theme.onDescriptionBg),
                            ),
                          )
                        ],
                      )),
                  Padding(
                    padding: EdgeInsets.only(
                        top: 10, bottom: 10, left: 20, right: 20),
                    child: Container(
                      child: new AutoSizeText(
                        cLessonPlanPerDay.description.replaceAll("\\n", "\n"),
                        textDirection: TextDirection.rtl,
                        maxLines: 20,
                        textScaleFactor: 1,
                        textAlign: TextAlign.center,
                        style: prefix0.getTextStyle(
                            14, prefix0.Theme.descriptionBlue),
                      ),
                    ),
                  ),
                  !kIsWeb && cLessonPlanPerDay.hasVoiceFile
                      ? getVoiceWidget()
                      : SizedBox(),
                  userType == 1 && true
                      ? new Container(
                          height: 50,
                          alignment: Alignment.bottomCenter,
                          child: new Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              Container(
                                height: 0.5,
                                width: xSize * (40 / 100),
                                color: Colors.black,
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Switch(
                                    value: _highlightedToggle,
                                    activeTrackColor:
                                        prefix0.Theme.highlightActiveTrack,
                                    activeColor: prefix0.Theme.lessonHighlight,
                                    inactiveTrackColor:
                                        Color.fromARGB(255, 235, 235, 235),
                                    onChanged: (value) {
                                      update_is_completed();
                                    },
                                  ),
                                ],
                              ),
                              switchLoading ? getLoadingProgress() : SizedBox(),
                            ],
                          ),
                        )
                      : SizedBox()
                ],
              ),
            ),
          ),
        ));
  }

  void update_is_completed() {
    setState(() {
      switchLoading = true;
    });
    LSM.getStudent().then((student) {
      consultantTableSRV
          .change_complete_mark(
              student.username,
              student.authentication_string,
              !cLessonPlanPerDay.isComplete,
              consultantTableState.consultantTableData.name,
              cLessonPlanPerDay.key)
          .then((status) {
        setState(() {
          switchLoading = false;
        });
        if (status) {
          consultantTableState
              .notifyConsultantTable(consultantTableState.consultantTableData);
          setState(() {
            _highlightedToggle = !cLessonPlanPerDay.isComplete;
            cLessonPlanPerDay.isComplete = !cLessonPlanPerDay.isComplete;
            consultantTableState.notifyIsCompleteChangeIsLessonField();
          });
        }
        LSM.setConsultantAllTables(
            student.username, consultantTableState.totalPlans);
      });
    });
  }

  Widget getVoiceWidget() {
    return Padding(
        padding: EdgeInsets.only(top: 5, right: 5, left: 5),
        child: Container(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[getVoicePauseIcon(), getSoundSlider()],
          ),
          decoration: new BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
              border: Border.all(color: prefix0.Theme.greyTimeLine)),
        ));
  }

  Widget getVoicePauseIcon() {
    double voiceIconSize = 35 + xSize * (1 / 100);
    return Container(
      width: voiceIconSize,
      height: voiceIconSize,
      decoration: new BoxDecoration(
//        color: Colors.blue,
        borderRadius: BorderRadius.all(
          Radius.circular(5),
        ),
      ),
      alignment: Alignment.center,
      child: (audioStatus == AudioPlayerState.PAUSED ||
              audioStatus == AudioPlayerState.STOPPED)
          ? GestureDetector(
              child: Icon(
                Icons.play_arrow,
                color: prefix0.Theme.blueBR,
                size: voiceIconSize,
              ),
              onTap: () {
//                audioStream.start();
//                audioPlayer.stop();
                if (audioPlayer == null) {
                  setListenerAndInitVoice();
                }
                setState(() {
                  voiceDownloaded = true;
                });
                audioPlayer.resume().then((status) {
                  setState(() {
                    voiceDownloaded = false;
                    audioStatus = AudioPlayerState.PLAYING;
                  });
                });
              },
            )
          : (!voiceDownloaded
              ? getLoadingProgress()
              : GestureDetector(
                  child: Icon(
                    Icons.pause,
                    color: prefix0.Theme.titleBar1,
                    size: voiceIconSize,
                  ),
                  onTap: () {
//                audioStream.pause();
                    audioPlayer.pause();
                    audioPlayer.release();
                    setState(() {
                      audioStatus = AudioPlayerState.PAUSED;
                    });
                  },
                )),
    );
  }

  Widget getSoundSlider() {
    return Padding(
      padding: EdgeInsets.all(5),
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          activeTrackColor: prefix0.Theme.startEndTimeItemsBG,
          inactiveTrackColor: prefix0.Theme.greyTimeLine,
          trackShape: RoundedRectSliderTrackShape(),
          trackHeight: 5.0,
          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.0),
          thumbColor: prefix0.Theme.startEndTimeItemsBG,
          overlayColor: prefix0.Theme.startEndTimeItemsBG,
          overlayShape: RoundSliderOverlayShape(overlayRadius: 8.0),
          tickMarkShape: RoundSliderTickMarkShape(),
          activeTickMarkColor: prefix0.Theme.startEndTimeItemsBG,
          inactiveTickMarkColor: prefix0.Theme.startEndTimeItemsBG,
          valueIndicatorShape: PaddleSliderValueIndicatorShape(),
          valueIndicatorColor: prefix0.Theme.startEndTimeItemsBG,
          valueIndicatorTextStyle:
              TextStyle(color: prefix0.Theme.onMainBGText, fontSize: 10),
        ),
        child: Container(
          width: 200 - 35 - (2 / 100) * xSize - 20,
          padding: EdgeInsets.only(top: 10, right: 10, bottom: 10),
          child: Slider(
            value: _position.inSeconds.toDouble(),
            min: 0,
            max: _duration.inSeconds.toDouble(),
            divisions: max(_duration.inSeconds, 1),
            label: (_position.inSeconds).toInt().toString(),
            activeColor: prefix0.Theme.greyTimeLine,
            inactiveColor: prefix0.Theme.greyTimeLine,
            onChanged: (value) {
              setState(() {
                value = value;
                audioPlayer.seek(Duration(seconds: value.toInt()));
                audioPlayer.resume().then((status) {
                  setState(() {
                    voiceDownloaded = false;
                    audioStatus = AudioPlayerState.PLAYING;
                  });
                });
              });
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (audioPlayer != null) {
      try {
        _durationSubscription?.cancel();
        _positionSubscription?.cancel();
        _playerCompleteSubscription?.cancel();
        _playerStateSubscription?.cancel();
        _playerErrorSubscription?.cancel();
        audioPlayer.dispose();
      } catch (e) {}
      try {
        audioPlayer = null;
      } catch (e) {}
    }
    super.dispose();
  }
}
