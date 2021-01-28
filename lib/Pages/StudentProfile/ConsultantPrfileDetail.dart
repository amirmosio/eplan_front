import 'dart:ui';

import 'package:android_intent/android_intent.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:device_apps/device_apps.dart';
import 'package:mhamrah/ConnectionService/ConsultantProfileSRV.dart';
import 'package:mhamrah/ConnectionService/HTTPService.dart';
import 'package:mhamrah/ConnectionService/UserSRV.dart';
import 'package:mhamrah/Models/UserMV.dart';
import 'package:mhamrah/Pages/ConsultantProfile/ConsultantProfile.dart';
import 'package:mhamrah/Pages/StudentProfile/StudentProfile.dart';
import 'package:mhamrah/Utils/LocalFileUtils.dart';
import 'package:mhamrah/Values/string.dart';
import 'package:mhamrah/Values/style.dart' as prefix0;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../ConsultantMainPage.dart';
import '../StudentMainPage.dart';

class ConsultantProfileDetail extends StatefulWidget {
  final StudentProfileState s;
  final String conUsername;

  ConsultantProfileDetail.Student(this.s, this.conUsername);

  @override
  _ConsultantProfileDetailState createState() {
    return _ConsultantProfileDetailState.Student(s, conUsername);
  }
}

class _ConsultantProfileDetailState extends State<ConsultantProfileDetail> {
  ConsultantProfileSRV consultantProfileSRV = ConsultantProfileSRV();
  ConnectionService httpRequestService = ConnectionService();

  //size things
  static double xSize;
  static double ySize;
  StudentProfileState s;
  String consUsername;
  Consultant c;
  String consDescription = "";
  String phone = "";
  String consFullName = "";
  String imageURL = "";
  bool pageLoadingToggle = false;

  _ConsultantProfileDetailState.Student(this.s, this.consUsername);

  @override
  void initState() {
    fetchConsultantDetailsFromServer();
    imageURL = httpRequestService.getConsultantImageURL(consUsername);
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    xSize = MediaQuery.of(context).size.width * (70 / 100);
    ySize = MediaQuery.of(context).size.width * (95 / 100);
    double minScreenSize = 250;
    return GestureDetector(
      child: new Container(
        height: MediaQuery.of(context).size.height -
            ConsultantMainPageState.tabHeight,
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.center,
        color: prefix0.Theme.fragmentBlurBackGround,
        child: new BackdropFilter(
            filter: prefix0.Theme.fragmentBGFilter,
            child: GestureDetector(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Stack(
                    children: <Widget>[getConsultantAvatar()],
                  ),
                  new Container(
                    width: xSize,
                    decoration: new BoxDecoration(
                        borderRadius: new BorderRadius.only(
                            bottomLeft: Radius.circular(15),
                            bottomRight: Radius.circular(15)),
                        color: prefix0.Theme.settingBg),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: pageLoadingToggle
                          ? [getLoadingBar()]
                          : <Widget>[
                              Row(
                                children: <Widget>[
                                  getConsultantPhone(),
                                  getTitleText(),
                                ],
                              ),
                              getDescriptionText(),
                              getSplitLine(),
//                getContactIcons()
                            ],
                    ),
                  ),
                ],
              ),
              onTap: () {},
            )),
      ),
      onTap: () {
        s.closeConsultantDetail();
      },
    );
  }

  Widget getConsultantAvatar() {
    double imageSize = ySize * (30 / 100);
    return new Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        new Container(
          width: xSize,
          height: imageSize * (60 / 100),
          decoration: new BoxDecoration(
              color: prefix0.Theme.settingBg,
              borderRadius: new BorderRadius.only(
                  topLeft: Radius.circular(15), topRight: Radius.circular(15))),
        ),
        new Container(
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
                    image: new NetworkImage(imageURL),
                  ),
                ),
                child: new SizedBox(
                  width: imageSize,
                  height: imageSize,
                ),
              )),
        ),
      ],
    );
  }

  Widget getTitleText() {
    return Padding(
      padding: EdgeInsets.only(right: 15, left: 15, top: 15, bottom: 20),
      child: Container(
        child: AutoSizeText(
          consFullName,
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: prefix0.getTextStyle(25, prefix0.Theme.onSettingText1),
        ),
      ),
    );
  }

  Widget getConsultantPhone() {
    return Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              child: ImageIcon(
                AssetImage("assets/img/27.png"),
                color: prefix0.Theme.onSettingText2,
                size: 30,
              ),
              onTap: () {
                openDialer();
              },
            ),
//            Container(
//              child: AutoSizeText(
//                "شماره تماس: " + phone,
//                textAlign: TextAlign.center,
//                textDirection: TextDirection.rtl,
//                style: prefix0.getTextStyle(18, prefix0.Theme.blueIcon),
//              ),
//            ),
          ],
        ));
  }

  Widget getLoadingBar() {
    Widget w = new Padding(
      padding: EdgeInsets.only(top: 10),
      child: new Container(
        height: 150,
        width: 150,
        padding: EdgeInsets.all(20),
        child: CircularProgressIndicator(),
      ),
    );
    return w;
  }

  Widget getDescriptionText() {
    return Padding(
      padding: EdgeInsets.only(right: 15, left: 15, bottom: 10),
      child: Container(
        alignment: Alignment.topCenter,
        child: AutoSizeText(
          consDescription,
          textAlign: TextAlign.center,
          textScaleFactor: 0.9,
          textDirection: TextDirection.rtl,
          style: prefix0.getTextStyle(20, prefix0.Theme.onSettingText2),
        ),
      ),
    );
  }

  Widget getSplitLine() {
    return Padding(
      padding: EdgeInsets.only(top: 5, bottom: 5, right: 20, left: 20),
      child: Container(
        height: 1,
        color: prefix0.Theme.brightBlack,
      ),
    );
  }

  void fetchConsultantDetailsFromServer() {
    setState(() {
      pageLoadingToggle = true;
    });
    LSM.getUserMode().then((type) {
      if (type == 0) {
        LSM.getConsultant().then((consultant) {
          consultantProfileSRV
              .getConsultantDetail(
                  consultant.username,
                  consultant.authentication_string,
                  StudentMainPage.studentUsername,
                  consUsername)
              .then((consultant) {
            if (consultant != null) {
              setState(() {
                pageLoadingToggle = false;
                consDescription = consultant.description;
                consDescription =
                    consultant.description != null ? consDescription : "";
                consFullName = "";
                if (consultant.first_name != null) {
                  consFullName = consultant.first_name + " ";
                }
                if (consultant.last_name != null) {
                  consFullName += consultant.last_name;
                }
                phone = consultant.phone != null ? consultant.phone : "";
              });
            }
          });
        });
      } else if (type == 1) {
        LSM.getStudent().then((student) {
          consultantProfileSRV
              .getConsultantDetail(
                  student.username,
                  student.authentication_string,
                  StudentMainPage.studentUsername,
                  consUsername)
              .then((consultant) {
            if (consultant != null) {
              setState(() {
                pageLoadingToggle = false;
                consDescription = consultant.description;
                consDescription =
                    consultant.description != null ? consDescription : "";
                consFullName = "";
                if (consultant.first_name != null) {
                  consFullName = consultant.first_name + " ";
                }
                if (consultant.last_name != null) {
                  consFullName += consultant.last_name;
                }
                phone = consultant.phone != null ? consultant.phone : "";
              });
            }
          });
        });
      }
    });
  }

  void openDialer() async {
    String dt = 'tel:' + phone;
    bool isInstalled =
        await DeviceApps.isAppInstalled('com.google.android.dialer');
    if (isInstalled != false) {
      AndroidIntent intent = AndroidIntent(action: 'action_view', data: dt);
      await intent.launch();
    } else {
      String url = dt;
      if (await canLaunch(url))
        await launch(url);
      else {
        throw 'Could not launch $url';
      }
    }
  }
//
//  Widget getContactIcons() {
//    return Padding(
//      padding: EdgeInsets.all(10),
//      child: Container(
//        child: Row(
//          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//          children: <Widget>[
//            GestureDetector(
//              child: ImageIcon(
//                AssetImage("assets/img/25.png"),
//                color: prefix0.Theme.blueIcon,
//                size: 40,
//              ),
//              onTap: () {
//                openInstagram();
//              },
//            ),
//            GestureDetector(
//              child: ImageIcon(
//                AssetImage("assets/img/27.png"),
//                color: prefix0.Theme.blueIcon,
//                size: 40,
//              ),
//              onTap: () {
//                openDialer();
//              },
//            ),
//            GestureDetector(
//              child: ImageIcon(
//                AssetImage("assets/img/30.png"),
//                color: prefix0.Theme.blueIcon,
//                size: 40,
//              ),
//              onTap: () {
//                openTelegram();
//              },
//            ),
//            GestureDetector(
//              child: ImageIcon(
//                AssetImage("assets/img/31.png"),
//                color: prefix0.Theme.blueIcon,
//                size: 40,
//              ),
//              onTap: () {
//                openWhatsApp();
//              },
//            )
//          ],
//        ),
//      ),
//    );
//  }
//
//  void openTelegram() async {
//    String dt = 'https://telegram.me/amirmosio';
//    bool isInstalled =
//        await DeviceApps.isAppInstalled('org.telegram.messenger');
//    if (isInstalled != false) {
//      AndroidIntent intent = AndroidIntent(action: 'action_view', data: dt);
//      await intent.launch();
//    } else {
//      String url = dt;
//      if (await canLaunch(url))
//        await launch(url);
//      else {
//        throw 'Could not launch $url';
//      }
//    }
//  }
//
//  void openWhatsApp() async {
//    String dt = 'https://api.whatsapp.com/send?phone=+989162461334';
//    bool isInstalled = await DeviceApps.isAppInstalled('com.whatsapp');
//    if (isInstalled != false) {
//      AndroidIntent intent = AndroidIntent(action: 'action_view', data: dt);
//      await intent.launch();
//    } else {
//      String url = dt;
//      if (await canLaunch(url))
//        await launch(url);
//      else {
//        throw 'Could not launch $url';
//      }
//    }
//  }
//
//  void openInstagram() async {
//    String dt = 'https://www.instagram.com/amir.mn.mosio';
//    bool isInstalled = await DeviceApps.isAppInstalled('com.instagram.android');
//    if (isInstalled != false) {
//      AndroidIntent intent = AndroidIntent(action: 'action_view', data: dt);
//      await intent.launch();
//    } else {
//      String url = dt;
//      if (await canLaunch(url))
//        await launch(url);
//      else {
//        throw 'Could not launch $url';
//      }
//    }
//  }
//
//  void openDialer() async {
//    String dt = 'tel:09162461334';
//    bool isInstalled =
//        await DeviceApps.isAppInstalled('com.google.android.dialer');
//    if (isInstalled != false) {
//      AndroidIntent intent = AndroidIntent(action: 'action_view', data: dt);
//      await intent.launch();
//    } else {
//      String url = dt;
//      if (await canLaunch(url))
//        await launch(url);
//      else {
//        throw 'Could not launch $url';
//      }
//    }
//  }
}
