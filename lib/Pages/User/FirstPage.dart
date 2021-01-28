import 'package:mhamrah/ConnectionService/NotificationSRV.dart';
import 'package:mhamrah/ConnectionService/UserSRV.dart';
import 'package:mhamrah/Models/UserMV.dart';
import 'package:mhamrah/Pages/SlideMainPage.dart';
import 'package:flutter/material.dart';
import 'package:mhamrah/Utils/PaymentUtils.dart';
import 'package:splashscreen/splashscreen.dart';
import '../StudentMainPage.dart';
import 'LoginPage.dart';
import 'package:mhamrah/Values/style.dart' as prefix1;
import 'package:mhamrah/Pages/User/LoginPage.dart';
import 'package:mhamrah/Utils/LocalFileUtils.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class FirstPage extends StatefulWidget {
  FirstPage({Key key, this.title}) : super(key: key);
  static double androidTitleBarHeight = 35;

  final String title;
  static BuildContext mainContext;
  static State currentPageState;
  static Student studentAccount;
  static Consultant consultantAccount;
  static int userType;

//  static setAccountFromLocalFile() async {
//    LSM.getStudent().then((value) {
//      studentAccount = value;
//    });
//    LSM.getConsultant().then((value) {
//      consultantAccount = value;
//    });
//    LSM.getUserMode().then((value) {
//      userType = value;
//    });
//  }

  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> with TickerProviderStateMixin {
  PushNotificationsManager pushNotificationsManager =
      PushNotificationsManager();
  Widget afterSplashPage;

  @override
  void initState() {
    super.initState();
    LSM.getUserMode();
    LSM.getUserMode().then((type) {
      initialCheckAndSetup(context, type);
    });
    if (kIsWeb) {
      FirstPage.androidTitleBarHeight = 5;
    } else {
      FirstPage.androidTitleBarHeight = 35;
    }
  }

  Widget build(BuildContext context) {
    return new SplashScreen(
      seconds: 4,
      navigateAfterSeconds:
          afterSplashPage == null ? LoginPage() : afterSplashPage,
      title: new Text(
        'مشاور همراه',
        style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
      ),
      image: Image(image: AssetImage("assets/appIcon/4.png")),
      backgroundColor: Colors.white,
      styleTextUnderTheLoader: prefix1.getTextStyle(18, Colors.black),
      photoSize: 60,
      loaderColor: Colors.black,
    );
  }

  void initialCheckAndSetup(context, int type) {
    LSM.getTheme().then((theme) {
      if (theme == null || theme == "") {
        prefix1.Theme.changeDefault();
      } else {
        prefix1.Theme.changeThemeByName(theme);
      }
      if (type == -1) {
        setState(() {
          afterSplashPage = LoginPage();
        });
      } else if (type == 0) {
        LSM.getConsultant().then((consultant) {
          /// initial setting
          FirstPage.studentAccount = null;
          FirstPage.userType = 0;
          FirstPage.consultantAccount = consultant;
          setState(() {
            afterSplashPage = SlideMainPage();
          });

          try {
            pushNotificationsManager.init(
                consultant.username, consultant.authentication_string);
          } catch (e) {}

          updateAccountData(
              consultant.username, consultant.authentication_string);
        });
      } else if (type == 1) {
        LSM.getStudent().then((student) {
          /// initial setting
          FirstPage.studentAccount = student;
          FirstPage.userType = 1;
          FirstPage.consultantAccount = null;
          setState(() {
            afterSplashPage = StudentMainPage(student.username);
          });
          try {
            pushNotificationsManager.init(
                student.username, student.authentication_string);
          } catch (e) {}
          updateAccountData(student.username, student.authentication_string);
        });
      } else {
        setState(() {
          afterSplashPage = LoginPage();
        });
      }
    });
  }

  void updateAccountData(String username, String auth) {
    UserSRV userSRV = UserSRV();
    userSRV.validateUser(username, auth).then((accountData) {
      if (accountData == null) {
        // ignore: unrelated_type_equality_checks
      } else if (accountData.student.username == "pending") {
        //login as student
      } else if (accountData.student.username != null) {
        //login as student
        LSM.getStudent().then((student) {
          accountData.student.parent = student.parent;
          LSM.updateStudentInfo(accountData.student);
          LSM.setStudentSetting(accountData.studentSetting);
        });
      } else if (accountData.consultant.username != null) {
        //login as consultant
        LSM.updateConsultantInfo(accountData.consultant);
        LSM.setConsultantSetting(accountData.consultantSetting);
        Future.delayed(Duration(seconds: 7)).then((_) {
          checkPaymentAndShowNotification(accountData.consultant.paymentStatus);
        });
      } else {}
    });
  }
}
