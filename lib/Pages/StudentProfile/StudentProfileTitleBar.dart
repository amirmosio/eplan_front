import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:mhamrah/ConnectionService/HTTPService.dart';
import 'package:mhamrah/ConnectionService/UserSRV.dart';
import 'package:mhamrah/Models/UserMV.dart';
import 'package:mhamrah/Pages/ConsultantTable/DayDetail.dart';
import 'package:mhamrah/Pages/StudentMainPage.dart';
import 'package:mhamrah/Pages/StudentProfile/SettingPage.dart';
import 'package:mhamrah/Pages/StudentProfile/StudentProfile.dart';
import 'package:mhamrah/Pages/User/FirstPage.dart';
import 'package:mhamrah/Pages/User/LoginPage.dart';
import 'package:mhamrah/Utils/LocalFileUtils.dart';
import 'package:mhamrah/Utils/SnackAnFlushBarUtils.dart';
import 'package:mhamrah/Values/Utils.dart';
import 'package:mhamrah/Values/string.dart';
import 'package:mhamrah/Values/style.dart' as prefix0;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileTitlePart extends StatefulWidget {
  final StudentMainPageState s;
  final StudentProfileState studentProfileState;

  ProfileTitlePart(this.s, this.studentProfileState);

  @override
  _ProfileTitleBarState createState() =>
      _ProfileTitleBarState(s, studentProfileState);
}

class _ProfileTitleBarState extends State<ProfileTitlePart> {
  ConnectionService httpRequestService = ConnectionService();
  StudentMainPageState s;
  final StudentProfileState studentProfileState;

  _ProfileTitleBarState(this.s, this.studentProfileState);

  int userType = 0;
  bool logoutLoading = false;
  double ySize;

  String imageUrl = "";
  ImageProvider imageProvider;

  @override
  void initState() {
    super.initState();
    setImage();
    LSM.getUserMode().then((value) {
      setState(() {
        userType = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ySize = MediaQuery.of(context).size.height;
    if (userType == 1) {
      Student student = LSM.getStudentSync();
      String username = student.username;
      imageUrl = httpRequestService.getStudentImageURL(username);
      if (imageProvider != null) {
        imageProvider.evict().then((value) {
          imageProvider = new NetworkImage(imageUrl);
        });
      } else {
        imageProvider = new NetworkImage(imageUrl);
      }
    } else {
      String username = StudentMainPage.studentUsername;
      imageUrl = httpRequestService.getStudentImageURL(username);
      if (imageProvider != null) {
        imageProvider.evict().then((value) {
          imageProvider = new NetworkImage(imageUrl);
        });
      } else {
        imageProvider = new NetworkImage(imageUrl);
      }
    }

    return new Column(
      children: <Widget>[
        new Container(
          height: max(0, 25 - 35 / 2 + FirstPage.androidTitleBarHeight / 2),
          width: MediaQuery.of(context).size.height,
          decoration: new BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [prefix0.Theme.titleBar2, prefix0.Theme.titleBar1]),
            color: prefix0.Theme.titleBar1,
          ),
        ),
        getConsultantAvatar()
      ],
    );
  }

  Widget getConsultantAvatar() {
    double imageSize = ySize * (15 / 100);
    return new Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
        new Container(
          width: MediaQuery.of(context).size.width,
          height: imageSize * (60 / 100) -
              35 / 2 +
              FirstPage.androidTitleBarHeight / 2,
          decoration: new BoxDecoration(
              color: prefix0.Theme.titleBar1,
              borderRadius: new BorderRadius.only(
                  bottomRight: Radius.circular(35),
                  bottomLeft: Radius.circular(35))),
          child: userType == 0
              ? SizedBox()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    GestureDetector(
                      child: Padding(
                        padding: EdgeInsets.only(top: 5, right: 15, left: 15),
                        child: Icon(
                          Icons.exit_to_app,
                          color: prefix0.Theme.onTitleBarText,
                          size: 35,
                        ),
                      ),
                      onTap: () {
                        showLogOutConfirm();
                      },
                    ),
                    GestureDetector(
                      child: Padding(
                        padding: EdgeInsets.only(top: 5, right: 15),
                        child: Icon(
                          Icons.settings,
                          color: prefix0.Theme.onTitleBarText,
                          size: 35,
                        ),
                      ),
                      onTap: () {
                        showConsultantSetting();
                      },
                    )
                  ],
                ),
        ),
        GestureDetector(
          child: new Container(
            decoration: new BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: new Padding(
                padding: EdgeInsets.all(10),
                child: new Container(
                  width: imageSize,
                  decoration: new BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: imageProvider == null
                          ? NetworkImage("")
                          : imageProvider,
                    ),
                  ),
                  child: new SizedBox(
                    width: imageSize,
                    height: imageSize,
                  ),
                )),
          ),
          onTap: () {
            LSM.getUserMode().then((value) {
              if (value == 1) {
                showFlutterToastWithFlushBar(profilePicGuide);
              }
            });
          },
        )
      ],
    );
  }

  void showConsultantSetting() {
    Widget d = BackdropFilter(
      filter: prefix0.Theme.fragmentBGFilter,
      child: new AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(25),
            ),
          ),
          backgroundColor: Color.fromARGB(0, 0, 0, 0),
          content: StudentSettingFrag(studentProfileState)),
    );
    showDialog(context: context, child: d, barrierDismissible: true);
  }

  void showLogOutConfirm() {
    Widget d = BackdropFilter(
        filter: prefix0.Theme.fragmentBGFilter,
        child: new AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(25),
            ),
          ),
          backgroundColor: Color.fromARGB(0, 0, 0, 0),
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setstate) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 250,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(25),
                      ),
                      color: prefix0.Theme.settingBg),
//                height: MediaQuery.of(context).size.height * (20 / 100),
                  child: Column(
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.all(10),
                          child: Container(
                            height: 70,
                            width: double.maxFinite - 20,
                            child: AutoSizeText(
                              "ایا از خروج از حساب کاربری خود مطمین هستید؟",
                              maxLines: 3,
                              textAlign: TextAlign.center,
                              style: prefix0.getTextStyle(
                                  20, prefix0.Theme.onSettingText1),
                            ),
                          )),
                      GestureDetector(
                        child: Container(
                          width: double.maxFinite,
                          height: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(25),
                                bottomLeft: Radius.circular(25),
                              ),
                              color: prefix0.Theme.titleBar1),
                          child: logoutLoading
                              ? getButtonLoadingProgress(r: 22, stroke: 2.5)
                              : AutoSizeText(
                                  "تایید",
                                  style: prefix0.getTextStyle(
                                      18, prefix0.Theme.onMainBGText),
                                ),
                        ),
                        onTap: () {
                          logoutUser(setstate);
                        },
                      )
                    ],
                  ),
                )
              ],
            );
          }),
        ));
    showDialog(context: context, child: d, barrierDismissible: true);
  }

  void logoutUser(StateSetter stateSetter) {
    UserSRV userSRV = UserSRV();
    stateSetter(() {
      logoutLoading = true;
    });
    LSM.getStudent().then((student) {
      userSRV
          .removeFirebaseTokenForUser(student.username,
              student.authentication_string, FBT.getFirebaseTokenSync())
          .then((status) {
        stateSetter(() {
          logoutLoading = true;
        });
        if (status) {
          LSM.clearWholeStorageExceptTheme();
          try {
            studentProfileState.socketTimer.cancel();
          } catch (e) {}
          Navigator.of(context, rootNavigator: true).pop();
          Navigator.of(context, rootNavigator: true)
              .popUntil(ModalRoute.withName('/'));
          Navigator.of(context, rootNavigator: true)
              .push(MaterialPageRoute(builder: (context) => LoginPage()));
        }
      });
    });
  }

  void setImage() {
    LSM.getUserMode().then((type) {
      if (type == 0) {
        setState(() {
          String username = StudentMainPage.studentUsername;
          imageUrl = httpRequestService.getConsultantImageURL(username);
        });
      } else if (type == 1) {
        LSM.getStudent().then((student) {
          setState(() {
            String username = student.username;
            imageUrl = httpRequestService.getStudentImageURL(username);
          });
        });
      }
    });
  }
}
