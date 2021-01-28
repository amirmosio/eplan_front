import 'dart:ui';

import 'package:android_intent/android_intent.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:device_apps/device_apps.dart';
import 'package:mhamrah/ConnectionService/AppService.dart';
import 'package:mhamrah/ConnectionService/ConsultantTableSRV.dart';
import 'package:mhamrah/Models/ConsultantTableMV.dart';
import 'package:mhamrah/Models/ContactUs.dart';
import 'package:mhamrah/Pages/ConsultantProfile/ConsultantProfile.dart';
import 'package:mhamrah/Pages/ConsultantTable/ConsultantTable.dart';
import 'package:mhamrah/Pages/StudentProfile/StudentProfile.dart';
import 'package:mhamrah/Utils/LocalFileUtils.dart';
import 'package:mhamrah/Values/string.dart';
import 'package:mhamrah/Values/style.dart' as prefix0;
import 'package:mhamrah/Values/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart' as prefix1;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../ConsultantMainPage.dart';
import '../StudentMainPage.dart';

class SupportFragment extends StatefulWidget {
  ConsultantProfileState c;
  StudentProfileState s;

  SupportFragment.Consultant(this.c);

  SupportFragment.Student(this.s);

  @override
  _SupportFragment createState() {
    if (c != null) {
      return _SupportFragment.Consultant(c);
    } else if (s != null) {
      return _SupportFragment.Student(s);
    }
    return null; //TODO
  }
}

class _SupportFragment extends State<SupportFragment> {
  AppSRV appSRV = new AppSRV();

  //size things
  static double xSize;
  static double ySize;
  ConsultantProfileState c;
  StudentProfileState s;
  ContactUs contactUs = ContactUs();

  bool loadingPageToggle = false;

  _SupportFragment.Consultant(this.c);

  _SupportFragment.Student(this.s);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchContactUsInfo();
  }

  @override
  Widget build(BuildContext context) {
    xSize = MediaQuery.of(context).size.width * (70 / 100);
    ySize = MediaQuery.of(context).size.width * (95 / 100);
    return GestureDetector(
      child: new Container(
        height: MediaQuery.of(context).size.height -
            ConsultantMainPageState.tabHeight,
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.center,
        color: prefix0.Theme.fragmentBlurBackGround,
        child: new BackdropFilter(
          filter: prefix0.Theme.fragmentBGFilter,
          child: new Container(
            width: xSize,
            decoration: new BoxDecoration(
                borderRadius: new BorderRadius.all(Radius.circular(15)),
                color: prefix0.Theme.settingBg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: loadingPageToggle
                  ? [getLoadingBar()]
                  : <Widget>[
                      getTitleText(),
                      getDescriptionText(),
                      getSplitLine(),
                      getContactIcons()
                    ],
            ),
          ),
        ),
      ),
      onTap: () {
        if (s != null) {
          s.closeSupportFragment();
        } else if (c != null) {
          c.closeSupportFragment();
        }
      },
    );
  }

  Widget getTitleText() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Container(
        child: AutoSizeText(
          AppTitle,
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: prefix0.getTextStyle(25, prefix0.Theme.onSettingText1),
        ),
      ),
    );
  }

  Widget getDescriptionText() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Container(
        child: AutoSizeText(
          "",
          textAlign: TextAlign.center,
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
        color: prefix0.Theme.onSettingText2,
      ),
    );
  }

  Widget getContactIcons() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            GestureDetector(
              child: Container(
                child: Image.asset("assets/img/instagram.png"),
                width: 40,
              ),
              onTap: () {
                openInstagram();
              },
            ),
            GestureDetector(
              child: ImageIcon(
                AssetImage("assets/img/27.png"),
                color: prefix0.Theme.blueIcon,
                size: 26,
              ),
              onTap: () {
                openDialer();
              },
            ),
            GestureDetector(
              child: Container(
                child: Image.asset("assets/img/telegram.png"),
                width: 40,
              ),
              onTap: () {
                openTelegram();
              },
            ),
            GestureDetector(
              child: Container(
                width: 40,
                child: Image.asset("assets/img/whatsapp.png"),
              ),
              onTap: () {
                openWhatsApp();
              },
            )
          ],
        ),
      ),
    );
  }

  void openTelegram() async {
    String dt = 'https://telegram.me/' + contactUs.telegram;
    bool isInstalled =
        await DeviceApps.isAppInstalled('org.telegram.messenger');
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

  void openWhatsApp() async {
    String dt = 'https://api.whatsapp.com/send?phone=' + contactUs.whatsapp;
    bool isInstalled = await DeviceApps.isAppInstalled('com.whatsapp');
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

  void openInstagram() async {
    String dt = 'https://www.instagram.com/' + contactUs.instagram;
    bool isInstalled = await DeviceApps.isAppInstalled('com.instagram.android');
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

  void openDialer() async {
    String dt = 'tel:' + contactUs.phone;
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

  void fetchContactUsInfo() {
    setState(() {
      loadingPageToggle = true;
    });
    appSRV.getContactUsInfo().then((contactUs) {
      if (contactUs != null) {
        setState(() {
          this.contactUs = contactUs;
          loadingPageToggle = false;
        });
      }
    });
  }
}
