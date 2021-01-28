import 'dart:io' as io;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:mhamrah/ConnectionService/SMSSRV.dart';
import 'package:mhamrah/ConnectionService/UserSRV.dart';
import 'package:mhamrah/Models/UserMV.dart';
import 'package:mhamrah/Pages/TImer/CountDownTimer.dart';
import 'package:mhamrah/Pages/User/LoginPage.dart';
import 'package:mhamrah/Utils/LocalFileUtils.dart';
import 'package:mhamrah/Values/Utils.dart';
import 'package:mhamrah/Values/string.dart';
import 'package:mhamrah/Values/style.dart';
import 'package:mhamrah/Values/style.dart' as prefix0;
import 'package:flutter/material.dart' as prefix1;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ForgetPassword extends StatefulWidget {
  ForgetPassword({Key key}) : super(key: key);

  @override
  _ForgetPasswordState createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  UserSRV userSRV = UserSRV();
  SMSSRV smsSRV = SMSSRV();
  bool _passwordObscure = true;
  io.File imageFile = null;

  List<bool> onTextFieldTouch = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];
  List<int> stuErrors = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

  //father mother home subcons,firstname,
  // lastname,phone,bosscons,username,
  // pass,confpass,edu majord  and level,school name

  //firstname,lastname,phone,bosscons,username,pass,confpass

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  TextEditingController _registerPhoneController = TextEditingController();

  List<String> error_texts = [
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    ""
  ];

  //father mother home subcons,firstname,
  // lastname,phone,bosscons,username,
  // pass,confpass,edu majord  and level,school name

  String _selectedValueForDropDown = edu_level_majors[0];
  bool emptyFieldError = false;
  bool loadingPhoneCode = false;
  bool registerPhoneError = false;
  bool registerLoading = false;

  Widget build(BuildContext context) {
    return MaterialApp(
      home: new Scaffold(
          body: new SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          color: prefix0.Theme.mainBG,
          alignment: Alignment.bottomCenter,
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              getUserAvatarImage(),
              new Container(
                height: MediaQuery.of(context).size.height * (70 / 100),
                padding: EdgeInsets.only(top: 20),
                color: prefix0.Theme.titleBar1,
                child: new Container(
                  child: new SingleChildScrollView(
                    child: getThirdPageRegister(),
                  ),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }

  Widget getThirdPageRegister() {
    return Column(
      children: <Widget>[
        getUsernameTextField(usernameLabel, 8, TextInputType.text),
        new Container(
          height: 20,
        ),
        getPasswordTextField(
            password + " جدید", [0.0, 10.0], _passwordController, validatePassword, 9),
        getPasswordTextField(rePassword, [0.0, 5.0], _confirmPasswordController,
            validateConfirmPassWord, 10),
        getThirdPageButtons(),
      ],
    );
  }

  void previousPage() {
    setState(() {});
  }

  void _toggle() {
    setState(() {
      _passwordObscure = !_passwordObscure;
    });
  }

  Widget getUserAvatarImage() {
    double imageSize = 120;
    return new Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        new Container(
          width: MediaQuery.of(context).size.width,
          height: imageSize * (60 / 100),
          decoration: new BoxDecoration(
              color: prefix0.Theme.titleBar1,
              borderRadius: new BorderRadius.only(
                  topRight: Radius.circular(35), topLeft: Radius.circular(35))),
        ),
//        new GestureDetector(
//          child: new Container(
//            decoration: new BoxDecoration(
//                shape: BoxShape.circle,
//                color: Color.fromARGB(150, 100, 100, 100)),
//            child: new Padding(
//                padding: EdgeInsets.all(10),
//                child: new Container(
//                  width: imageSize,
//                  decoration: imageFile != null
//                      ? new BoxDecoration(
//                          color: prefix0.Theme.whiteText,
//                          shape: BoxShape.circle,
//                          image: DecorationImage(
//                            fit: BoxFit.fill,
//                            image: FileImage(imageFile),
//                          ),
//                        )
//                      : BoxDecoration(
//                          shape: BoxShape.circle,
//                          color: prefix0.Theme.whiteText),
//                  child: imageFile == null
//                      ? Container(
//                          width: imageSize,
//                          height: imageSize,
//                          child: new Icon(
//                            Icons.camera_alt,
//                            size: imageSize * (70 / 100),
//                            color: prefix0.Theme.blackText,
//                          ),
//                        )
//                      : new SizedBox(
//                          width: imageSize,
//                          height: imageSize,
//                        ),
//                )),
//          ),
//          onTap: () {
//            picImageFromGallery();
//          },
//        )
      ],
    );
  }

  Widget getUsernameTextField(
      String title, int index, TextInputType textInputType) {
    return new Padding(
      padding: EdgeInsets.fromLTRB(20, 5, 20, 0),
      child: new Container(
          height: 70,
          alignment: Alignment.center,
          child: new Column(
            children: <Widget>[
              new Container(
                height: 50,
                child: TextField(
                  style: prefix0.getTextStyle(15, prefix0.Theme.darkText),
                  keyboardType: textInputType,
                  controller: _usernameController,
                  textAlign: TextAlign.center,
                  obscureText: false,
                  onChanged: (value) {
                    setState(() {
                      onTextFieldTouch[index] = true;
                      validateUsername();
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: prefix0.Theme.registerTextFieldBg,
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius:
                            new BorderRadius.all(Radius.circular(25))),
                    hintText: title,
                  ),
                ),
              ),
              new Container(
                height: 20,
                alignment: Alignment.topRight,
                padding: EdgeInsets.only(right: 15, top: 5),
                child: AutoSizeText(
                  error_texts[8],
                  style: prefix0.getTextStyle(12, prefix0.Theme.onMainBGText),
                ),
              )
            ],
          )),
    );
  }

  Widget getPasswordTextField(
      String text, List margin, controller, Function f, int index) {
    return new Container(
      padding: EdgeInsets.fromLTRB(20, margin[0], 20, margin[1]),
      child: new Container(
          height: 70,
          child: Column(
            children: <Widget>[
              new Container(
                height: 50,
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      onTextFieldTouch[index] = true;
                    });
                  },
                  style: prefix0.getTextStyle(15, prefix0.Theme.darkText),
                  controller: controller,
                  obscureText: _passwordObscure,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    prefixIcon: IconButton(
                        icon: Icon(!_passwordObscure
                            ? Icons.remove_red_eye
                            : Icons.remove),
                        onPressed: _toggle),
                    filled: true,
                    fillColor: prefix0.Theme.registerTextFieldBg,
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius:
                            new BorderRadius.all(Radius.circular(25))),
                    hintText: text,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(right: 15),
                alignment: Alignment.topRight,
                child: AutoSizeText(
                  f(),
                  style: getTextStyle(12, prefix0.Theme.onTitleBarText),
                ),
                height: 20,
              )
            ],
          )),
    );
  }

  Widget getThirdPageButtons() {
    return new Padding(
      padding: EdgeInsets.only(top: 10, left: 20, right: 20),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          new GestureDetector(
            key: ValueKey("3-1"),
            child: new Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: new Container(
                padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                decoration: new BoxDecoration(
                    borderRadius: new BorderRadius.all(Radius.circular(25)),
                    color: emptyFieldError
                        ? prefix0.Theme.grey
                        : prefix0.Theme.applyButton),
                child: loadingPhoneCode
                    ? getLoadingProgress()
                    : getButtonText("تایید"),
              ),
            ),
            onTap: () {
              int errorCount = 0;
              onTextFieldTouch[8] = true;
              validateUsername();
              errorCount += stuErrors[8];
              onTextFieldTouch[9] = true;
              validatePassword();
              errorCount += stuErrors[9];
              onTextFieldTouch[10] = true;
              validateConfirmPassWord();
              errorCount += stuErrors[10];
              if (errorCount == 0) {
                setState(() {
                  loadingPhoneCode = true;
                });
                smsSRV
                    .sendRegisterCode(_usernameController.text, "")
                    .then((status) {
                  setState(() {
                    loadingPhoneCode = false;
                  });
                  if (status['success']) {
                    showPhoneRegisterCode();
                  } else {
                    Fluttertoast.showToast(
                        msg: "خطا در ارسال پیامک", timeInSecForIosWeb: 3);
                  }
                });
              } else {
                setState(() {
                  emptyFieldError = true;
                });
                Future.delayed(Duration(seconds: 1)).then((_) {
                  setState(() {
                    emptyFieldError = false;
                  });
                });
              }
            },
          )
        ],
      ),
    );
  }

  Widget getLoadingProgress() {
    return Container(
      child: prefix1.CircleAvatar(
        backgroundColor: Color.fromARGB(0, 0, 0, 0),
        child: prefix1.CircularProgressIndicator(),
      ),
      padding: EdgeInsets.only(right: 10, left: 10),
    );
  }

  Widget getButtonText(String text) {
    return Container(
      alignment: Alignment.center,
      child: Text(
        text,
        textDirection: TextDirection.ltr,
        style: prefix0.getTextStyle(18, prefix0.Theme.onApplyButton),
      ),
      width: 100,
      height: 35,
    );
  }

  String validateUsername() {
    if (!onTextFieldTouch[8]) {
      error_texts[8] = "";
    } else {
      String username = _usernameController.text;
      RegExp regex = RegExp(r"^[a-z|A-Z|.|0-9]+$", caseSensitive: true);
      if (username == "") {
        stuErrors[8] = 1;
        error_texts[8] = emptyNotAllowed;
      } else if (!regex.hasMatch(username)) {
        stuErrors[8] = 1;
        error_texts[8] = invalidCharacterUsername;
      } else {
        stuErrors[8] = 0;
        error_texts[8] = "";
      }
    }
  }

  String validatePassword() {
    if (!onTextFieldTouch[9]) {
      return "";
    }
    String text = _passwordController.text;
    text = replacePersianWithEnglishNumber(text);
    if (text.length < 8) {
      stuErrors[9] = 1;
      return minLengthPassWord;
    } else {
      int countNumbers = 0;
      for (int i = 0; i < text.length; i++) {
        String char = text.substring(i, i + 1);
        try {
          int n = int.parse(char);
          countNumbers += 1;
        } catch (Exception) {}
      }
      if (countNumbers <= 0) {
        stuErrors[9] = 1;
        return minCharNumber;
      }
    }
    stuErrors[9] = 0;
    return "";
  }

  String validateConfirmPassWord() {
    if (!onTextFieldTouch[10]) {
      return "";
    }
    String p1 = _passwordController.text;
    String p2 = _confirmPasswordController.text;
    if (p1 != p2) {
      stuErrors[10] = 1;
      return confirmPassWordMissMatch;
    }
    stuErrors[10] = 0;
    return "";
  }

  Widget getLoadingProgess() {
    return Padding(
      child: prefix1.CircularProgressIndicator(),
      padding: EdgeInsets.only(right: 10, left: 10),
    );
  }

  void showPhoneRegisterCode() {
    _registerPhoneController.clear();
    registerPhoneError = false;
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
                    style: prefix0.getTextStyle(15, prefix0.Theme.onSettingText1),
                  ),
                  phoneRegisterCodeTextField(),
                  CountDownTimer(Duration(minutes: 1)),
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
                          sendChangePasswordData(setstate);
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

  void sendChangePasswordData(StateSetter stateSetter) {
    stateSetter(() {
      registerLoading = true;
    });
    userSRV
        .changeUserPassword(_usernameController.text, _passwordController.text,
            _registerPhoneController.text)
        .then((status) {
      stateSetter(() {
        registerLoading = false;
      });
      Navigator.of(context, rootNavigator: true).pop();

      if (status['success']) {
        navigateToSubPage(context, new LoginPage());
      } else {
        Fluttertoast.showToast(msg: status['error'], timeInSecForIosWeb: 3);
        setState(() {
          registerPhoneError = true;
        });
      }
    });
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
}
