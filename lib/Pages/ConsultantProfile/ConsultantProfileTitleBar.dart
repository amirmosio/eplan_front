import 'package:auto_size_text/auto_size_text.dart';
import 'package:mhamrah/ConnectionService/HTTPService.dart';
import 'package:mhamrah/ConnectionService/UserSRV.dart';
import 'package:mhamrah/Models/AccountDataAndSetting.dart';
import 'package:mhamrah/Models/UserMV.dart';
import 'package:mhamrah/Pages/ConsultantProfile/ConsultantProfile.dart';
import 'package:mhamrah/Pages/User/FirstPage.dart';
import 'package:mhamrah/Pages/User/LoginPage.dart';
import 'package:mhamrah/Utils/LocalFileUtils.dart';
import 'package:mhamrah/Utils/SnackAnFlushBarUtils.dart';
import 'package:mhamrah/Values/Utils.dart';
import 'package:mhamrah/Values/string.dart';
import 'package:mhamrah/Values/style.dart' as prefix0;
import 'package:mhamrah/Values/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'SettingPage.dart';

class ProfileTitlePart extends StatefulWidget {
  final ConsultantProfileState consultantProfileState;

  ProfileTitlePart(this.consultantProfileState);

  @override
  _ProfileTitleBarState createState() =>
      _ProfileTitleBarState(consultantProfileState);
}

class _ProfileTitleBarState extends State<ProfileTitlePart> {
  ConnectionService httpRequestService = ConnectionService();
  final ConsultantProfileState consultantProfileState;

  _ProfileTitleBarState(this.consultantProfileState);

  bool logoutLoading = false;

  String imageUrl = "";
  ConsultantSetting setting;
  ImageProvider imageProvider;

  @override
  void initState() {
    setImage();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Consultant consultant = LSM.getConsultantSync();
    if (consultant != null) {
      String username = consultant.username;
      imageUrl = httpRequestService.getConsultantImageURL(username);
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
          height: 30 - 35 / 2 + FirstPage.androidTitleBarHeight / 2,
          width: MediaQuery.of(context).size.width,
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
    double imageSize = 120;
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
            alignment: Alignment.centerRight,
            child: Row(
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
            )),
        GestureDetector(
          child: new Container(
            decoration: new BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromARGB(150, 100, 100, 100)),
            child: new Padding(
                padding: EdgeInsets.all(3),
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
              if (value == 0) {
                showFlutterToastWithFlushBar(profilePicGuide);
              }
            });
          },
        )
      ],
    );
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
                              color: prefix0.Theme.warningAndErrorBG),
                          child: logoutLoading
                              ? getButtonLoadingProgress(r: 22, stroke: 2.5)
                              : AutoSizeText(
                                  "تایید",
                                  style: prefix0.getTextStyle(
                                      18, prefix0.Theme.onWarningAndErrorBG),
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
          })),
    );
    showDialog(context: context, child: d, barrierDismissible: true);
  }

  void logoutUser(StateSetter stateSetter) {
    UserSRV userSRV = UserSRV();
    stateSetter(() {
      logoutLoading = true;
    });
    LSM.getConsultant().then((consultant) {
      userSRV
          .removeFirebaseTokenForUser(consultant.username,
              consultant.authentication_string, FBT.getFirebaseTokenSync())
          .then((status) {
        try {
          stateSetter(() {
            logoutLoading = true;
          });
        } catch (e) {}
        if (status) {
          LSM.clearWholeStorageExceptTheme();
          try {
            consultantProfileState.socketTimer.cancel();
          } catch (e) {}
          Navigator.of(context, rootNavigator: true).pop();
          Navigator.of(context, rootNavigator: true)
              .popUntil(ModalRoute.withName('/'));
//    navigateToSubPage(context, LoginPage());
          Navigator.of(context, rootNavigator: true)
              .push(MaterialPageRoute(builder: (context) => LoginPage()));
        }
      });
    });
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
          backgroundColor: prefix0.Theme.settingBg,
          content: ConsultantSettingFrag(consultantProfileState)),
    );
    showDialog(context: context, child: d, barrierDismissible: true);
  }

  void setImage() {
    LSM.getConsultant().then((consultant) {
      setState(() {
        if (consultant != null) {
          String username = consultant.username;
          imageUrl = httpRequestService.getConsultantImageURL(username);
        }
      });
    });
  }
}
