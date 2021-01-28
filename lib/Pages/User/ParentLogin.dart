import 'dart:async';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:mhamrah/ConnectionService/NotificationSRV.dart';
import 'package:mhamrah/ConnectionService/SMSSRV.dart';
import 'package:mhamrah/ConnectionService/UserSRV.dart';
import 'package:mhamrah/Models/UserMV.dart';
import 'package:mhamrah/Pages/SlideMainPage.dart';
import 'package:mhamrah/Pages/StudentMainPage.dart';
import 'package:mhamrah/Pages/TImer/CountDownTimer.dart';
import 'package:mhamrah/Pages/User/RegisterPage.dart';
import 'package:mhamrah/Utils/LocalFileUtils.dart';
import 'package:mhamrah/Values/Utils.dart';
import 'package:mhamrah/Values/string.dart';
import 'package:mhamrah/Values/style.dart';
import 'package:mhamrah/Values/style.dart' as prefix0;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../ConsultantMainPage.dart';
import 'ForgetPassword.dart';

class ParentLogin extends StatefulWidget {
  ParentLogin({Key key}) : super(key: key);

  @override
  _ParentLoginState createState() => _ParentLoginState();
}

class _ParentLoginState extends State<ParentLogin> {
  bool _passwordObscure = true;
  UserSRV userSRV = UserSRV();
  SMSSRV smsSRV = SMSSRV();
  PushNotificationsManager pushNotificationsManager =
  PushNotificationsManager();

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _parentPhoneController = TextEditingController();
  TextEditingController _registerPhoneController = TextEditingController();

  bool _wrongPhoneToggle = false;
  bool _pendingToggle = false;
  bool loadingToggle = false;
  bool registerPhoneError = false;
  bool registerLoading = false;
  bool invalidPhone = false;

  int registerAnimationStatus = 0;


  Widget build(BuildContext context) {
    return WillPopScope(
      child: MaterialApp(
        home: new Scaffold(
          body: Container(
            height: MediaQuery
                .of(context)
                .size
                .height,
            width: MediaQuery
                .of(context)
                .size
                .width,
            color: prefix0.Theme.mainBG,
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              child: new Container(
                height: MediaQuery
                    .of(context)
                    .size
                    .height * (75 / 100),
                decoration: new BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          prefix0.Theme.titleBar1,
                          prefix0.Theme.titleBar2
                        ]),
                    color: prefix0.Theme.titleBar1,
                    borderRadius: new BorderRadius.only(
                        topRight: Radius.circular(35),
                        topLeft: Radius.circular(35))),
                child: new Column(
                  verticalDirection: VerticalDirection.down,
                  children: <Widget>[
                    getUsernameTextField(),
                    getParentPhoneTextField(),
                    getWrongPhoneText(),
                    getLoginButton(sendRegisterCode, context),
                  ],
                ),
              ),
              onTap: () {
                Timer.periodic(Duration(milliseconds: 100), (Timer t) {
                  setState(() {
                    registerAnimationStatus -= 1;
                  });
                  if (registerAnimationStatus <= 0) {
                    setState(() {
                      registerAnimationStatus = 0;
                    });
                    t.cancel();
                  }
                });
              },
            ),
          ),
        ),
      ),
      onWillPop: () async {
        Navigator.of(context, rootNavigator: true).pop();
        return false;
      },
    );
  }

  void _toggle() {
    setState(() {
      _passwordObscure = !_passwordObscure;
    });
  }

  Widget getWrongPhoneText() {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: _wrongPhoneToggle
          ? Container(
        padding: EdgeInsets.only(right: 15),
        alignment: Alignment.centerRight,
        height: 10,
        child: AutoSizeText(
          wrongPhoneOrUsername,
          style: prefix0.getTextStyle(12, prefix0.Theme.onTitleBarText),
        ),
      )
          : SizedBox(
        height: 10,
      ),
    );
  }

  Widget getNotYetAccept() {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: _pendingToggle
          ? Container(
        padding: EdgeInsets.only(right: 15),
        alignment: Alignment.centerRight,
        height: 10,
        child: AutoSizeText(
          notAcceptedYet,
          style: prefix0.getTextStyle(12, prefix0.Theme.onTitleBarText),
        ),
      )
          : SizedBox(
        height: 10,
      ),
    );
  }

  Widget getParentPhoneTextField() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Container(
          height: 60,
          child: TextField(
              style: getTextStyle(15, prefix0.Theme.darkText),
              controller: _parentPhoneController,
              obscureText: false,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                fillColor: prefix0.Theme.registerTextFieldBg,
                suffixIcon: Icon(
                  Icons.phone,
                  color: prefix0.Theme.brightBlack,
                ),
                filled: true,
                border: OutlineInputBorder(
                    borderRadius: new BorderRadius.all(Radius.circular(25)),
                    borderSide: invalidPhone ? BorderSide() : BorderSide.none),
                hintText: phoneNumber,
              )),
        ));
  }

  void showPhoneRegisterCode() {
    _registerPhoneController.clear();
    registerPhoneError = false;
    CountDownTimer cdt = CountDownTimer(Duration(minutes: 1));
    Widget d = BackdropFilter(
      filter: prefix0.Theme.fragmentBGFilter,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(25),
          ),
        ),
        backgroundColor: prefix0.Theme.settingBg,
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setstate) {
            return Container(
              height: 200,
              width: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  AutoSizeText(
                    "کد برای شماره شما ارسال شد.",
                    textDirection: TextDirection.rtl,
                    style:
                    prefix0.getTextStyle(15, prefix0.Theme.onSettingText1),
                  ),
                  phoneRegisterCodeTextField(),
                  cdt,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      MaterialButton(
                        color: registerPhoneError
                            ? prefix0.Theme.titleBar1
                            : prefix0.Theme.applyButton,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        child: registerLoading
                            ? getLoadingProgress()
                            : AutoSizeText(
                          registerLabel,
                          style: prefix0.getTextStyle(
                              15, prefix0.Theme.onMainBGText),
                        ),
                        onPressed: () {
                          String registerCode = _registerPhoneController.text;
                          if (registerCode.length == 4) {
                            setstate(() {
                              registerLoading = true;
                            });
                            userSRV
                                .parentLogin(_usernameController.text,
                                _parentPhoneController.text, registerCode)
                                .then((student) {
                              setstate(() {
                                registerLoading = false;
                              });
                              if (student == null) {
                                setState(() {
                                  invalidPhone = true;

                                  Future.delayed(Duration(seconds: 2))
                                      .then((_) {
                                    setState(() {
                                      invalidPhone = false;
                                    });
                                  });
                                });
                                // ignore: unrelated_type_equality_checks
                              } else if (student.username != null) {
                                //login as parent
                                String childUsername =
                                getChildUsernameFromParentUsername(
                                    student.username);
                                String parentType =
                                matchParentUsername(student.username);
                                student.username = childUsername;
                                student.parent = parentType;
                                LSM.updateStudentInfo(student);
                                navigateToSubPage(context,
                                    new StudentMainPage(student.username));
                                try {
                                  cdt.timer.cancel();
                                } catch (e){}
                                pushNotificationsManager.init(student.username,
                                    student.authentication_string);
                              } else {
                                setState(() {
                                  invalidPhone = true;

                                  Future.delayed(Duration(seconds: 1))
                                      .then((_) {
                                    setState(() {
                                      invalidPhone = false;
                                    });
                                  });
                                });
                              }
                              setState(() {
                                loadingToggle = false;
                              });
                            });
                          }
                        },
                      )
                    ],
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
    showDialog(context: context, child: d, barrierDismissible: true);
  }

  Widget phoneRegisterCodeTextField() {
    return Padding(
      padding: EdgeInsets.all(5),
      child: Container(
        height: 60,
        child: TextField(
          style: TextStyle(
              letterSpacing: 15,
              fontFamily: 'traffic',
              fontWeight: FontWeight.w700,
              color: prefix0.Theme.darkText),
          keyboardType: TextInputType.number,
          controller: _registerPhoneController,
          textAlign: TextAlign.center,
          maxLengthEnforced: true,
          maxLength: 4,
          onChanged: (value) {},
          decoration: InputDecoration(
            filled: true,
            fillColor: prefix0.Theme.registerTextFieldBg,
            alignLabelWithHint: true,
            border: OutlineInputBorder(
//                borderSide: BorderSide.,
                borderRadius: new BorderRadius.all(Radius.circular(25))),
          ),
        ),
      ),
    );
  }

  Widget getUsernameTextField() {
    return new Padding(
      padding: EdgeInsets.fromLTRB(20, 40, 20, 20),
      child: new Container(
          height: 60,
          alignment: Alignment.center,
          child: new Container(
            height: 60,
            alignment: Alignment.center,
            child: TextField(
              style: getTextStyle(15, prefix0.Theme.darkText),
              keyboardType: TextInputType.text,
              controller: _usernameController,
              textAlign: TextAlign.center,
              obscureText: false,
              decoration: InputDecoration(
                filled: true,
                fillColor: prefix0.Theme.registerTextFieldBg,
                suffixIcon: Icon(
                  Icons.person,
                  color: prefix0.Theme.brightBlack,
                ),
                border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: new BorderRadius.all(Radius.circular(25))),
                hintText: childUsername,
              ),
            ),
          )),
    );
  }

  Widget getLoginButton(String text, context) {
    return new GestureDetector(
      child: new Container(
        decoration: new BoxDecoration(
            borderRadius: new BorderRadius.all(
              Radius.circular(25),
            ),
            color: Colors.green),
        child: new Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
          child: loadingToggle ? getLoadingProgress() : getButtonText(text),
        ),
      ),
      onTap: () {
        String username = _usernameController.text;
        String parentPhone = _parentPhoneController.text;
        print(username + " " + parentPhone);
        if (username != "" && validateNotAllowedEmptyPhone()) {
          setState(() {
            loadingToggle = true;
          });
          smsSRV.sendRegisterCode(username, parentPhone).then((status) {
            setState(() {
              loadingToggle = false;
            });
            if (status['success']) {
              if (status['status'] != "-1") {
                showPhoneRegisterCode();
              } else {
                setState(() {
                  _wrongPhoneToggle = true;
                });
                Future.delayed(Duration(seconds: 3)).then((_) {
                  setState(() {
                    _wrongPhoneToggle = false;
                  });
                });
              }
            } else {
              Fluttertoast.showToast(
                  msg: "خطا در ارسال پیامک", timeInSecForIosWeb: 3);
            }
          });
        } else {
          if (username == "") {} else {
            setState(() {
              invalidPhone = true;
            });
            Future.delayed(Duration(seconds: 2)).then((_) {
              setState(() {
                invalidPhone = false;
              });
            });
          }
        }
      },
    );
  }

  bool validateNotAllowedEmptyPhone() {
    String phone = _parentPhoneController.text;
    if (phone.trim() == "") {
      return false;
    } else {
      String engPhone = replacePersianWithEnglishNumber(phone);
      RegExp regex = RegExp(r"^[0][9][0-9]{9}$");
      if (!regex.hasMatch(engPhone)) {
        return false;
      } else {
        return true;
      }
    }
  }

  Widget getLoadingProgress() {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10),
      child: CircularProgressIndicator(),
      width: 50,
      height: 25,
    );
  }

  Widget getButtonText(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          alignment: Alignment.center,
          child: AutoSizeText(
            text,
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
            style: prefix0.getTextStyle(20, prefix0.Theme.onApplyButton),
          ),
          height: 25,
        )
      ],
    );
  }
}
