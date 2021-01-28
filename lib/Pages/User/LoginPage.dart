import 'dart:async';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:mhamrah/ConnectionService/NotificationSRV.dart';
import 'package:mhamrah/ConnectionService/UserSRV.dart';
import 'package:mhamrah/Models/UserMV.dart';
import 'package:mhamrah/Pages/SlideMainPage.dart';
import 'package:mhamrah/Pages/StudentMainPage.dart';
import 'package:mhamrah/Pages/User/ParentLogin.dart';
import 'package:mhamrah/Pages/User/RegisterPage.dart';
import 'package:mhamrah/Utils/LocalFileUtils.dart';
import 'package:mhamrah/Utils/PaymentUtils.dart';
import 'package:mhamrah/Utils/SnackAnFlushBarUtils.dart';
import 'package:mhamrah/Values/Utils.dart';
import 'package:mhamrah/Values/string.dart';
import 'package:mhamrah/Values/style.dart';
import 'package:mhamrah/Values/style.dart' as prefix0;
import 'package:flutter/material.dart';

import '../ConsultantMainPage.dart';
import 'ForgetPassword.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _passwordObscure = true;
  UserSRV userSRV = UserSRV();
  PushNotificationsManager pushNotificationsManager =
      PushNotificationsManager();

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passController = TextEditingController();

  bool _wrongPassToggle = false;
  bool _pendingToggle = false;
  bool loadingToggle = false;

  int registerAnimationStatus = 0;

  static List<int> _pageQueue = [];

  Widget build(BuildContext context) {
    return WillPopScope(
      child: MaterialApp(
        home: new Scaffold(
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: prefix0.Theme.mainBG,
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              child: new Container(
                height: MediaQuery.of(context).size.height * (75 / 100),
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
                    getPasswordTextField(),
                    getWrongPassText(),
                    getNotYetAccept(),
                    getLoginButton(loginLabel, context),
                    getForgetPasswordAndRegisterText()
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
        if (_pageQueue.length > 0) {
          exit(0);
          return false;
        }
        _pageQueue.add(0);
        Future.delayed(Duration(seconds: 3)).then((_) {
          setState(() {
            _pageQueue.removeLast();
          });
        });

        showFlutterToast(doublePressExitWarning);
        return false;
      },
    );
  }

  void _toggle() {
    setState(() {
      _passwordObscure = !_passwordObscure;
    });
  }

  Widget getWrongPassText() {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: _wrongPassToggle
          ? Container(
              padding: EdgeInsets.only(right: 15),
              alignment: Alignment.centerRight,
              height: 10,
              child: AutoSizeText(
                wrongPassOrUsername,
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

  Widget getPasswordTextField() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Container(
          height: 60,
          child: TextField(
              style: getTextStyle(15, prefix0.Theme.darkText),
              controller: _passController,
              obscureText: _passwordObscure,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                fillColor: prefix0.Theme.registerTextFieldBg,
                suffixIcon: Icon(
                  Icons.lock,
                  color: prefix0.Theme.brightBlack,
                ),
                prefixIcon: IconButton(
                    icon: Icon(
                      !_passwordObscure ? Icons.remove_red_eye : Icons.link_off,
                      color: prefix0.Theme.brightBlack,
                    ),
                    onPressed: _toggle),
                filled: true,
                border: OutlineInputBorder(
                    borderRadius: new BorderRadius.all(Radius.circular(25)),
                    borderSide: BorderSide.none),
                hintText: 'رمز عبور',
              )),
        ));
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
                hintText: usernameLabel,
              ),
            ),
          )),
    );
  }

  Widget getForgetPasswordAndRegisterText() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(5),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                registerAnimationStatus < 1
                    ? SizedBox()
                    : new GestureDetector(
                        onTap: () {
                          navigateToSubPage(context, new RegisterPage(0));
                        },
                        child: Container(
                          height: 35,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              color: prefix0.Theme.ttTransWhiteText),
                          child: new Center(
                            child: new Padding(
                              padding: EdgeInsets.all(5),
                              child: AutoSizeText(consultantLabel,
                                  textDirection: TextDirection.rtl,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: 'traffic',
                                    fontWeight: FontWeight.w700,
                                    color: prefix0.Theme.onMainBGText,
                                  )),
                            ),
                          ),
                        ),
                      ),
                registerAnimationStatus < 1
                    ? SizedBox()
                    : SizedBox(
                        width: 10,
                      ),
                registerAnimationStatus < 2
                    ? SizedBox()
                    : new GestureDetector(
                        onTap: () {
                          navigateToSubPage(context, new RegisterPage(1));
                        },
                        child: Container(
                          height: 35,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              color: prefix0.Theme.ttTransWhiteText),
                          child: new Center(
                            child: new Padding(
                              padding: EdgeInsets.all(5),
                              child: AutoSizeText(subConsultantLabel,
                                  textDirection: TextDirection.rtl,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: 'traffic',
                                    fontWeight: FontWeight.w700,
                                    color: prefix0.Theme.onMainBGText,
                                  )),
                            ),
                          ),
                        )),
//                registerAnimationStatus < 3
//                    ? SizedBox()
//                    : Text(
//                        " / ",
//                        style: TextStyle(
//                            fontSize: 22,
//                            fontWeight: FontWeight.w700,
//                            color: prefix0.Theme.whiteText),
//                      ),
                registerAnimationStatus < 1
                    ? SizedBox()
                    : SizedBox(
                        width: 10,
                      ),
                registerAnimationStatus < 3
                    ? SizedBox()
                    : new GestureDetector(
                        onTap: () {
                          navigateToSubPage(context, new RegisterPage(2));
                        }, //TODO
                        child: Container(
                          height: 35,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              color: prefix0.Theme.ttTransWhiteText),
                          child: new Center(
                            child: new Padding(
                              padding: EdgeInsets.all(10),
                              child: AutoSizeText(
                                studentLabel,
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'traffic',
                                  fontWeight: FontWeight.w700,
                                  color: prefix0.Theme.onMainBGText,
                                ),
                              ),
                            ),
                          ),
                        )),
                registerAnimationStatus != 0
                    ? SizedBox()
                    : new GestureDetector(
                        onTap: () {
                          navigateToSubPage(context, new ForgetPassword());
                        }, //TODO
                        child: Container(
//                          width: 200,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              color: prefix0.Theme.ttTransWhiteText),
                          child: new Center(
                            child: new Padding(
                              padding: EdgeInsets.all(5),
                              child: AutoSizeText(
                                forgetPassSentence,
                                textDirection: TextDirection.rtl,
                                style: getTextStyle(
                                    20, prefix0.Theme.onMainBGText),
                              ),
                            ),
                          ),
                        ),
                      ),
                registerAnimationStatus != 0
                    ? SizedBox()
                    : SizedBox(
                        width: 10,
                      ),
                registerAnimationStatus != 0
                    ? SizedBox()
                    : GestureDetector(
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              color: prefix0.Theme.ttTransWhiteText),
                          child: new Center(
                            child: new Padding(
                              padding: EdgeInsets.all(5),
                              child: AutoSizeText(registerLabel,
                                  textDirection: TextDirection.rtl,
                                  style: getTextStyle(
                                      20, prefix0.Theme.onMainBGText)),
                            ),
                          ),
                        ),
                        onTap: () {
                          Timer.periodic(Duration(milliseconds: 100),
                              (Timer t) {
                            setState(() {
                              registerAnimationStatus += 1;
                            });
                            if (registerAnimationStatus > 3) {
                              t.cancel();
                            }
                          });
                        },
                      ),
              ],
            ),
          ),
          new GestureDetector(
              onTap: () {
                navigateToSubPage(context, new ParentLogin());
              }, //TODO
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          color: prefix0.Theme.ttTransWhiteText),
                      child: new Center(
                        child: new Padding(
                          padding: EdgeInsets.all(5),
                          child: AutoSizeText(
                            parentLogin,
                            textDirection: TextDirection.rtl,
                            style: getTextStyle(20, prefix0.Theme.onMainBGText),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              )),
        ],
      ),
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
        String auth = _passController.text;
        print(username + " " + auth);
        if (username != "" && auth != "") {
          setState(() {
            loadingToggle = true;
          });
          userSRV.validateUser(username, auth).then((accountData) {
            if (accountData == null) {
              setState(() {
                _wrongPassToggle = true;

                Future.delayed(Duration(seconds: 2)).then((_) {
                  setState(() {
                    _wrongPassToggle = false;
                  });
                });
              });
              // ignore: unrelated_type_equality_checks
            } else if (accountData.student.username == "pending") {
              //login as student
              setState(() {
                _pendingToggle = true;
              });
              Future.delayed(Duration(seconds: 1)).then((_) {
                setState(() {
                  _pendingToggle = false;
                });
              });
            } else if (accountData.student.username != null) {
              //login as student
              LSM.updateStudentInfo(accountData.student);
              LSM.setStudentSetting(accountData.studentSetting);
              navigateToSubPage(
                  context, new StudentMainPage(accountData.student.username));
              try {
                pushNotificationsManager.init(accountData.student.username,
                    accountData.student.authentication_string);
              } catch (e) {}
            } else if (accountData.consultant.username != null) {
              //login as consultant
              LSM.updateConsultantInfo(accountData.consultant);
              LSM.setConsultantSetting(accountData.consultantSetting);
              navigateToSubPage(context, SlideMainPage());
              try {
                pushNotificationsManager.init(accountData.consultant.username,
                    accountData.consultant.authentication_string);
              } catch (e) {}
              Future.delayed(Duration(seconds: 7)).then((_) {
                checkPaymentAndShowNotification(
                    accountData.consultant.paymentStatus);
              });
            } else {
              setState(() {
                _wrongPassToggle = true;

                Future.delayed(Duration(seconds: 1)).then((_) {
                  setState(() {
                    _wrongPassToggle = false;
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
    );
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
    return Container(
      alignment: Alignment.center,
      child: AutoSizeText(
        text,
        textDirection: TextDirection.ltr,
        style: prefix0.getTextStyle(20, prefix0.Theme.onApplyButton),
      ),
      width: 55,
      height: 25,
    );
  }
}
