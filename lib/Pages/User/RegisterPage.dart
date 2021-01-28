import 'dart:io' as io;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:mhamrah/ConnectionService/SMSSRV.dart';
import 'package:mhamrah/ConnectionService/UserSRV.dart';
import 'package:mhamrah/Models/UserMV.dart';
import 'package:mhamrah/Pages/TImer/CountDownTimer.dart';
import 'package:mhamrah/Pages/User/FirstPage.dart';
import 'package:mhamrah/Pages/User/LoginPage.dart';
import 'package:mhamrah/Utils/AutoTextUtils.dart';
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

class RegisterPage extends StatefulWidget {
  RegisterPage(this.registerType, {Key key}) : super(key: key);

  final int registerType;

  @override
  _RegisterPageState createState() => _RegisterPageState(registerType);
}

class _RegisterPageState extends State<RegisterPage> {
  UserSRV userSRV = UserSRV();
  SMSSRV smsSRV = SMSSRV();
  bool _passwordObscure = true;
  io.File imageFile = null;
  CountDownTimer countDownTimer;

  bool _firstPage = true;
  bool _firstPageAnim = true;
  bool _secondPage = false;
  bool _secondPageAnim = false;
  bool _thirdPage = false;
  bool _thirdPageAnim = false;

  int registerType;

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

  List<int> consErrors = [0, 0, 0, 0, 0, 0, 0];

  //firstname,lastname,phone,bosscons,username,pass,confpass

  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _fatherPhoneController = TextEditingController();
  TextEditingController _motherPhoneController = TextEditingController();
  TextEditingController _homePhoneController = TextEditingController();
  TextEditingController _schoolNameController = TextEditingController();
  TextEditingController _subConsUsernameController = TextEditingController();
  TextEditingController _bossConsUsernameController = TextEditingController();
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
  bool phoneCodeLoading = false;
  bool registerPhoneError = false;
  bool registerLoading = false;

  _RegisterPageState(this.registerType);

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 0)).then((_) {
      showMaintainingInfoDialog();
    });
  }

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
                      child: Stack(
                    children: <Widget>[
                      Visibility(
                        child: AnimatedOpacity(
                          child: getFirstPageRegister(),
                          opacity: _firstPageAnim ? 1.0 : 0.0,
                          duration: Duration(milliseconds: 500),
                        ),
                        visible: _firstPage,
                      ),
                      Visibility(
                        child: AnimatedOpacity(
                          child: getSecondPageRegister(),
                          opacity: _secondPageAnim ? 1.0 : 0.0,
                          duration: Duration(milliseconds: 500),
                        ),
                        visible: _secondPage,
                      ),
                      Visibility(
                        child: AnimatedOpacity(
                          child: getThirdPageRegister(),
                          opacity: _thirdPageAnim ? 1.0 : 0.0,
                          duration: Duration(milliseconds: 500),
                        ),
                        visible: _thirdPage,
                      )
                    ],
                  )),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }

  Widget getFirstPageRegister() {
    return Column(
      children: <Widget>[
        registerType == 2
            ? SizedBox()
            : getFirstNameTextField(firstName, 4, TextInputType.text),
        registerType == 2
            ? SizedBox()
            : getLastNameTextField(lastName, 5, TextInputType.text),
        getPhoneTextField(phoneNumber, 6, TextInputType.phone),
//        registerType == 2
//            ? getFatherPhoneTextField(fatherPhoneNumber, 0, TextInputType.phone)
//            : new SizedBox(
//                width: 0,
//                height: 0,
//              ),
//        registerType == 2
//            ? getMotherPhoneTextField(motherPhoneNumber, 1, TextInputType.phone)
//            : new SizedBox(
//                width: 0,
//                height: 0,
//              ),
//        registerType == 2
//            ? getHomeNumberTextField(homePhoneNumber, 2, TextInputType.phone)
//            : new SizedBox(
//                width: 0,
//                height: 0,
//              ),
        getFirstPageButtons(nextRegisterPage)
      ],
    );
  }

  Widget getSecondPageRegister() {
    return Column(
      children: <Widget>[
        registerType == 2
            ? getDropDownButton(validateEduLevel)
            : SizedBox(
                width: 0,
                height: 0,
              ),
        registerType == 2
            ? getSchoolTextField(schoolName, 12, TextInputType.text)
            : SizedBox(
                height: 0,
                width: 0,
              ),
        registerType != 1
            ? SizedBox()
            : getBossConsultantTextField(
                bossConsultantUserName, 7, TextInputType.text),
        getSecondPageButtons()
      ],
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
            password, [0.0, 10.0], _passwordController, validatePassword, 9),
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

  Widget getDropDownButton(Function f) {
    return new Padding(
        padding: EdgeInsets.fromLTRB(20, 5, 20, 40),
        child: new Column(
          children: <Widget>[
            new Container(
//        width: MediaQuery.of(context).size.width * (50 / 100),
              height: 50,
              alignment: Alignment.center,
              decoration: new BoxDecoration(
                  color: prefix0.Theme.registerTextFieldBg,
                  borderRadius: new BorderRadius.all(Radius.circular(20))),
              child: new prefix1.Theme(
                  data: prefix1.Theme.of(context).copyWith(
                    canvasColor: prefix0.Theme.titleBar1,
                  ),
                  child: new DropdownButtonHideUnderline(
                    child: ButtonTheme(
                      alignedDropdown: true,
                      child: DropdownButton(
                        value: _selectedValueForDropDown,
                        elevation: 2,
                        onChanged: (newValue) {
                          setState(() {
                            if (newValue == "+++") {
                            } else {
                              _selectedValueForDropDown = newValue;
                            }
                          });
                        },
                        isExpanded: false,
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: prefix0.Theme.titleBar1,
                        ),
                        items: (edu_level_majors).map((String value) {
                          return new DropdownMenuItem<String>(
                            value: value,
                            key: ValueKey(value),
                            child: new Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                  width: 150,
                                  height: 40,
                                  alignment: Alignment.center,
                                  child: new AutoSizeText(
                                    value,
                                    style: getTextStyle(
                                        15, prefix0.Theme.darkText),
                                  ),
                                ),
                                Container(
                                  height: 0.5,
                                  color: Colors.black,
                                )
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  )),
            ),
            Container(
              padding: EdgeInsets.only(right: 15, top: 5),
              alignment: Alignment.topRight,
              child: AutoSizeText(
                f(),
                style: getTextStyle(12, prefix0.Theme.onTitleBarText),
              ),
              height: 15,
            )
          ],
        ));
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

  Widget getFirstNameTextField(
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
                  controller: _firstNameController,
                  textAlign: TextAlign.center,
                  obscureText: false,
                  onChanged: (value) {
                    setState(() {
                      onTextFieldTouch[index] = true;
                      validateNotEmptyFirstName();
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
                  error_texts[4],
                  style: getTextStyle(12, prefix0.Theme.onTitleBarText),
                ),
              )
            ],
          )),
    );
  }

  Widget getLastNameTextField(
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
                  controller: _lastNameController,
                  textAlign: TextAlign.center,
                  obscureText: false,
                  onChanged: (value) {
                    setState(() {
                      onTextFieldTouch[index] = true;
                      validateNotEmptyLastName();
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
                  error_texts[5],
                  style: getTextStyle(12, prefix0.Theme.onTitleBarText),
                ),
              )
            ],
          )),
    );
  }

  Widget getPhoneTextField(
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
                  controller: _phoneController,
                  textAlign: TextAlign.center,
                  obscureText: false,
                  onChanged: (value) {
                    setState(() {
                      onTextFieldTouch[index] = true;
                      validateNotAllowedEmptyPhone();
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
                  error_texts[6],
                  style: getTextStyle(12, prefix0.Theme.onTitleBarText),
                ),
              )
            ],
          )),
    );
  }

  Widget getFatherPhoneTextField(
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
                  controller: _fatherPhoneController,
                  textAlign: TextAlign.center,
                  obscureText: false,
                  onChanged: (value) {
                    setState(() {
                      onTextFieldTouch[index] = true;
                      validateNotAllowedEmptyFatherPhone();
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
                  error_texts[0],
                  style: getTextStyle(12, prefix0.Theme.onTitleBarText),
                ),
              )
            ],
          )),
    );
  }

  Widget getMotherPhoneTextField(
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
                  controller: _motherPhoneController,
                  textAlign: TextAlign.center,
                  obscureText: false,
                  onChanged: (value) {
                    setState(() {
                      onTextFieldTouch[index] = true;
                      validateNotAllowedEmptyMotherPhone();
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
                  error_texts[1],
                  style: getTextStyle(12, prefix0.Theme.onTitleBarText),
                ),
              )
            ],
          )),
    );
  }

  Widget getHomeNumberTextField(
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
                  controller: _homePhoneController,
                  textAlign: TextAlign.center,
                  obscureText: false,
                  onChanged: (value) {
                    setState(() {
                      onTextFieldTouch[index] = true;
                      validHomeNumber();
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
                  error_texts[2],
                  style: getTextStyle(12, prefix0.Theme.onTitleBarText),
                ),
              )
            ],
          )),
    );
  }

  Widget getSchoolTextField(
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
                  controller: _schoolNameController,
                  textAlign: TextAlign.center,
                  obscureText: false,
                  onChanged: (value) {
                    setState(() {
                      onTextFieldTouch[index] = true;
                      validateSchoolName();
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
                  error_texts[2],
                  style: getTextStyle(12, prefix0.Theme.onTitleBarText),
                ),
              )
            ],
          )),
    );
  }

  Widget getSubConsultantTextField(
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
                  controller: _subConsUsernameController,
                  textAlign: TextAlign.center,
                  obscureText: false,
                  onChanged: (value) {
                    setState(() {
                      onTextFieldTouch[index] = true;
                      validateStuSubConsUsername();
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
                child: getAutoSizedDirectionText(
                  error_texts[3],
                  style: getTextStyle(12, prefix0.Theme.onTitleBarText),
                ),
              )
            ],
          )),
    );
  }

  Widget getBossConsultantTextField(
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
                  controller: _bossConsUsernameController,
                  textAlign: TextAlign.center,
                  obscureText: false,
                  onChanged: (value) {
                    setState(() {
                      onTextFieldTouch[index] = true;
                      validateStuAndConsBossConsUsername();
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
                child: getAutoSizedDirectionText(
                  error_texts[7],
                  style: getTextStyle(12, prefix0.Theme.onTitleBarText),
                ),
              )
            ],
          )),
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
                  style: prefix0.getTextStyle(12, prefix0.Theme.onTitleBarText),
                ),
              )
            ],
          )),
    );
  }

  Widget getFirstPageButtons(String text) {
    return new GestureDetector(
      key: ValueKey("1-0"),
      child: new Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: new Container(
          padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
          decoration: new BoxDecoration(
              borderRadius: new BorderRadius.all(Radius.circular(25)),
              color: emptyFieldError
                  ? prefix0.Theme.grey
                  : prefix0.Theme.applyButton),
          child: getButtonText(text),
        ),
      ),
      onTap: () {
        setState(() {
          int errorCount = 0;

          if (registerType == 0 || registerType == 1) {
            onTextFieldTouch[4] = true;
            validateNotEmptyFirstName();
            errorCount += consErrors[0];
            onTextFieldTouch[5] = true;
            validateNotEmptyLastName();
            errorCount += consErrors[1];
            onTextFieldTouch[6] = true;
            validateNotAllowedEmptyPhone();
            errorCount += consErrors[2];
          } else if (registerType == 2) {
//            onTextFieldTouch[0] = true;
//            validateNotAllowedEmptyFatherPhone();
//            errorCount += stuErrors[0];
//            onTextFieldTouch[1] = true;
//            validateNotAllowedEmptyMotherPhone();
//            errorCount += stuErrors[1];
//            onTextFieldTouch[2] = true;
//            validHomeNumber();
//            errorCount += stuErrors[2];
//            onTextFieldTouch[4] = true;
//            validateNotEmptyFirstName();
//            errorCount += stuErrors[4];
//            onTextFieldTouch[5] = true;
//            validateNotEmptyLastName();
//            errorCount += stuErrors[5];
            onTextFieldTouch[6] = true;
            validateNotAllowedEmptyPhone();
            errorCount += stuErrors[6];
          }
          if (errorCount == 0) {
            if (registerType == 0 || registerType == 2) {
              _firstPageAnim = false;
              _secondPageAnim = false;
              _thirdPage = true;

              Future.delayed(Duration(milliseconds: 250)).then((_) {
                setState(() {
                  _firstPage = false;
                  _secondPage = false;
                  _thirdPageAnim = true;
                });
              });
            } else {
              _firstPageAnim = false;
              _secondPage = true;
              _thirdPageAnim = false;
              Future.delayed(Duration(milliseconds: 150)).then((_) {
                setState(() {
                  _firstPage = false;
                  _secondPageAnim = true;
                  _thirdPage = false;
                });
              });
            }
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
        });
      },
    );
  }

  Widget getSecondPageButtons() {
    return new Padding(
      padding: EdgeInsets.only(top: 10, left: 20, right: 20),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          new GestureDetector(
            key: ValueKey("2-0"),
            child: new Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 10, 20),
              child: new Container(
                padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                decoration: new BoxDecoration(
                    borderRadius: new BorderRadius.all(Radius.circular(25)),
                    color: prefix0.Theme.applyButton),
                child: getButtonText(previousRegisterPage),
              ),
            ),
            onTap: () {
              setState(() {
                _firstPage = true;
                _secondPageAnim = false;
                _thirdPage = false;

                Future.delayed(Duration(milliseconds: 250)).then((_) {
                  setState(() {
                    _firstPageAnim = true;
                    _secondPage = false;
                    _thirdPageAnim = false;
                  });
                });
              });
            },
          ),
          new GestureDetector(
            key: ValueKey("2-1"),
            child: new Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: new Container(
                padding: EdgeInsets.fromLTRB(20, 5, 10, 5),
                decoration: new BoxDecoration(
                    borderRadius: new BorderRadius.all(Radius.circular(25)),
                    color: emptyFieldError
                        ? prefix0.Theme.grey
                        : prefix0.Theme.applyButton),
                child: getButtonText(nextRegisterPage),
              ),
            ),
            onTap: () {
              int errorCount = 0;
              if (registerType == 0 || registerType == 1) {
                onTextFieldTouch[7] = true;
                validateStuAndConsBossConsUsername();
                errorCount += consErrors[3];
              } else if (registerType == 2) {
                onTextFieldTouch[12] = true;
                validateSchoolName();
                errorCount += stuErrors[12];
                onTextFieldTouch[11] = true;
                validateEduLevel();
                errorCount += stuErrors[11];
//                onTextFieldTouch[3] = true;
//                validateStuSubConsUsername();
//                errorCount += stuErrors[3];
//                onTextFieldTouch[7] = true;
//                validateStuAndConsBossConsUsername();
//                errorCount += stuErrors[7];
              }
              if (errorCount == 0) {
                _firstPageAnim = false;
                _secondPageAnim = false;
                _thirdPage = true;

                Future.delayed(Duration(milliseconds: 250)).then((_) {
                  setState(() {
                    _firstPage = false;
                    _secondPage = false;
                    _thirdPageAnim = true;
                  });
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

  Widget getThirdPageButtons() {
    return new Padding(
      padding: EdgeInsets.only(top: 10, left: 20, right: 20),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          new GestureDetector(
            key: ValueKey("3-0"),
            child: new Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 10, 20),
              child: new Container(
                padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                decoration: new BoxDecoration(
                    borderRadius: new BorderRadius.all(Radius.circular(25)),
                    color: prefix0.Theme.applyButton),
                child: getButtonText(previousRegisterPage),
              ),
            ),
            onTap: () {
              setState(() {
                if (registerType == 0 || registerType == 2) {
                  _firstPage = true;
                  _secondPageAnim = false;
                  _thirdPage = false;

                  Future.delayed(Duration(milliseconds: 250)).then((_) {
                    setState(() {
                      _firstPageAnim = true;
                      _secondPage = false;
                      _thirdPageAnim = false;
                    });
                  });
                } else {
                  _firstPageAnim = false;
                  _secondPage = true;
                  _thirdPageAnim = false;

                  Future.delayed(Duration(milliseconds: 250)).then((_) {
                    setState(() {
                      _firstPage = false;
                      _secondPageAnim = true;
                      _thirdPage = false;
                    });
                  });
                }
              });
            },
          ),
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
                child: phoneCodeLoading
                    ? getLoadingProgess()
                    : getButtonText(registerLabel),
              ),
            ),
            onTap: () {
              int errorCount = 0;
              if (registerType == 0 || registerType == 1) {
                onTextFieldTouch[8] = true;
                validateUsername();
                errorCount += consErrors[4];
                onTextFieldTouch[9] = true;
                validatePassword();
                errorCount += consErrors[5];
                onTextFieldTouch[10] = true;
                validateConfirmPassWord();
                errorCount += consErrors[6];
              } else if (registerType == 2) {
                onTextFieldTouch[8] = true;
                validateUsername();
                errorCount += stuErrors[8];
                onTextFieldTouch[9] = true;
                validatePassword();
                errorCount += stuErrors[9];
                onTextFieldTouch[10] = true;
                validateConfirmPassWord();
                errorCount += stuErrors[10];
              }
              if (errorCount == 0) {
                setState(() {
                  phoneCodeLoading = true;
                });
                smsSRV
                    .sendRegisterCode("", _phoneController.text)
                    .then((status) {
                  setState(() {
                    phoneCodeLoading = false;
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

  Widget getLoadingProgess() {
    return Padding(
      child: prefix1.CircularProgressIndicator(),
      padding: EdgeInsets.only(right: 10, left: 10),
    );
  }

  Widget getButtonText(String text) {
    return Container(
      alignment: Alignment.center,
      child: Text(
        text,
        textDirection: TextDirection.ltr,
        style: prefix0.getTextStyle(18, prefix0.Theme.onMainBGText),
      ),
      width: 100,
      height: 35,
    );
  }

  void showLoadingDialog(context) {
    AlertDialog d = new AlertDialog(
      content: new Container(
        alignment: Alignment.center,
        height: MediaQuery.of(context).size.width / 2,
        width: MediaQuery.of(context).size.width / 2,
        child: new Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[new CircularProgressIndicator()],
        ),
        decoration: new BoxDecoration(
          shape: BoxShape.circle,
        ),
      ),
    );
    showDialog(context: context, child: d, barrierDismissible: false);
  }

  String validatePassword() {
    if (!onTextFieldTouch[9]) {
      return "";
    }
    String text = _passwordController.text;
    text = replacePersianWithEnglishNumber(text);
    if (text.length < 8) {
      stuErrors[9] = 1;
      consErrors[5] = 1;
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
        consErrors[5] = 1;
        return minCharNumber;
      }
    }
    stuErrors[9] = 0;
    consErrors[5] = 0;
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
      consErrors[6] = 1;
      return confirmPassWordMissMatch;
    }
    stuErrors[10] = 0;
    consErrors[6] = 0;
    return "";
  }

  String validateNotEmptyFirstName() {
    if (!onTextFieldTouch[4]) {
      error_texts[4] = "";
    } else {
      String text = _firstNameController.text;
      if (text.trim() == "") {
        stuErrors[4] = 1;
        consErrors[0] = 1;
        error_texts[4] = emptyNotAllowed;
      } else if (!checkPersianCharsAndSpaceOnly(text)) {
        stuErrors[4] = 1;
        consErrors[0] = 1;
        error_texts[4] = firstLastNameCharsOnly;
      } else {
        stuErrors[4] = 0;
        consErrors[0] = 0;
        error_texts[4] = "";
      }
    }
  }

  String validateSchoolName() {
    if (!onTextFieldTouch[12]) {
      error_texts[2] = "";
    } else {
      String text = _schoolNameController.text;
      if (text.trim() == "") {
        stuErrors[12] = 1;
        error_texts[2] = emptyNotAllowed;
      } else {
        stuErrors[12] = 0;
        error_texts[2] = "";
      }
    }
  }

  String validateNotEmptyLastName() {
    if (!onTextFieldTouch[5]) {
      error_texts[5] = "";
    } else {}
    String text = _lastNameController.text;
    if (text.trim() == "") {
      stuErrors[5] = 1;
      consErrors[1] = 1;
      error_texts[5] = emptyNotAllowed;
    } else if (!checkPersianCharsAndSpaceOnly(text)) {
      stuErrors[5] = 1;
      consErrors[1] = 1;
      error_texts[5] = firstLastNameCharsOnly;
    } else {
      stuErrors[5] = 0;
      consErrors[1] = 0;
      error_texts[5] = "";
    }
  }

  String validateEduLevel() {
    if (!onTextFieldTouch[11]) {
      return "";
    } else {
      if (_selectedValueForDropDown == edu_level_majors[0]) {
        stuErrors[11] = 1;
        return emptyNotAllowed;
      }
      stuErrors[11] = 0;
      return "";
    }
  }

  String validateStuSubConsUsername() {
    if (!onTextFieldTouch[3]) {
      error_texts[3] = "";
    } else {
      String username = _subConsUsernameController.text;
      RegExp regex = RegExp(r"^[a-z|A-Z|.|0-9]+$", caseSensitive: true);
      if (username.trim() == "") {
        stuErrors[3] = 1;
        error_texts[3] = emptyNotAllowed;
      } else if (!regex.hasMatch(username)) {
        error_texts[3] = invalidCharacterUsername;
      } else {
        error_texts[3] = "...";
        userSRV.get_consultant_name(username).then((value) {
          setState(() {
            if (!value['success']) {
              if (value['suggestedUsername'] != "") {
                stuErrors[3] = 1;
                error_texts[3] = getSuggestedString(value['suggestedUsername']);
              } else {
                stuErrors[3] = 1;
                error_texts[3] = invalidConsUsername;
              }
            } else {
              stuErrors[3] = 0;
              error_texts[3] = value['name'];
            }
          });
        });
      }
    }
  }

  String validateStuAndConsBossConsUsername() {
    if (!onTextFieldTouch[7]) {
      stuErrors[7] = 0;
      consErrors[3] = 0;
      error_texts[7] = "";
    } else {
      String boss_username = _bossConsUsernameController.text;
      RegExp regex = RegExp(r"^[a-z|A-Z|.|0-9]{3,}$", caseSensitive: true);
      if (boss_username.trim() == "") {
        if (registerType == 1) {
          stuErrors[7] = 1;
          consErrors[3] = 1;

          error_texts[7] = emptyNotAllowed;
        } else {
          stuErrors[7] = 0;
          consErrors[3] = 0;
        }
      } else if (!regex.hasMatch(boss_username)) {
        stuErrors[7] = 1;
        consErrors[3] = 1;
        error_texts[7] = invalidCharacterUsername;
      } else {
        error_texts[7] = "...";
        userSRV.get_consultant_name(boss_username).then((value) {
          setState(() {
            if (!value['success']) {
              if (value['suggestedUsername'] != "") {
                stuErrors[7] = 1;
                consErrors[3] = 1;
                error_texts[7] = getSuggestedString(value['suggestedUsername']);
              } else {
                stuErrors[7] = 1;
                consErrors[3] = 1;
                error_texts[7] = invalidConsUsername;
              }
            } else {
              stuErrors[7] = 0;
              consErrors[3] = 0;
              error_texts[7] = value['name'];
            }
          });
        });
      }
    }
  }

  String validateNotAllowedEmptyPhone() {
    if (!onTextFieldTouch[6]) {
      error_texts[6] = "";
    } else {
      String phone = _phoneController.text;
      if (phone.trim() == "") {
        stuErrors[6] = 1;
        consErrors[2] = 1;
        error_texts[6] = emptyNotAllowed;
      } else {
        String engPhone = replacePersianWithEnglishNumber(phone);
        RegExp regex = RegExp(r"^[0][9][0-9]{9}$");
        if (!regex.hasMatch(engPhone)) {
          stuErrors[6] = 1;
          consErrors[2] = 1;
          error_texts[6] = invalidPhone;
        } else {
          if (registerType != 2) {
            stuErrors[6] = 0;
            consErrors[2] = 0;
            error_texts[6] = "";
          } else {
            error_texts[6] = "...";
            userSRV.check_valid_new_phone(engPhone).then((status) {
              setState(() {
                if (status) {
                  stuErrors[6] = 0;
                  consErrors[2] = 0;
                  error_texts[6] = "";
                } else {
                  stuErrors[6] = 1;
                  consErrors[2] = 1;
                  error_texts[6] = takenStudentPhone;
                }
              });
            });
          }
        }
      }
    }
  }

  String validateNotAllowedEmptyFatherPhone() {
    if (!onTextFieldTouch[0]) {
      error_texts[0] = "";
    } else {
      String phone = _fatherPhoneController.text;
      if (phone.trim() == "") {
        stuErrors[0] = 1;
        error_texts[0] = emptyNotAllowed;
      } else {
        String engPhone = replacePersianWithEnglishNumber(phone);
        RegExp regex = RegExp(r"^[0][9][0-9]{9}$");
        if (!regex.hasMatch(engPhone)) {
          stuErrors[0] = 1;
          error_texts[0] = invalidPhone;
        } else {
          stuErrors[0] = 0;
          error_texts[0] = "";
        }
      }
    }
  }

  String validateNotAllowedEmptyMotherPhone() {
    if (!onTextFieldTouch[1]) {
      error_texts[1] = "";
    } else {
      String phone = _motherPhoneController.text;
      if (phone.trim() == "") {
        stuErrors[1] = 1;
        error_texts[1] = emptyNotAllowed;
      } else {
        String engPhone = replacePersianWithEnglishNumber(phone);
        RegExp regex = RegExp(r"^[0][9][0-9]{9}$");
        if (!regex.hasMatch(engPhone)) {
          stuErrors[1] = 1;
          error_texts[1] = invalidPhone;
        } else {
          stuErrors[1] = 0;
          error_texts[1] = "";
        }
      }
    }
  }

  String validHomeNumber() {
    if (!onTextFieldTouch[2]) {
      error_texts[2] = "";
    } else {
      String homeNumber = _homePhoneController.text;
      if (homeNumber.trim() == "") {
        stuErrors[2] = 1;
        error_texts[2] = emptyNotAllowed;
      } else {
        String engPhone = replacePersianWithEnglishNumber(homeNumber);
        RegExp regex = RegExp(r"^[0][0-9]{10}$");
        if (!regex.hasMatch(engPhone)) {
          stuErrors[2] = 1;
          error_texts[2] = invalidHomeNumber;
        } else {
          stuErrors[2] = 0;
          error_texts[2] = "";
        }
      }
    }
  }

  String validateUsername() {
    if (!onTextFieldTouch[8]) {
      error_texts[8] = "";
    } else {
      String username = _usernameController.text;
      RegExp regex = RegExp(r"^[a-z|A-Z|.|0-9]+$", caseSensitive: true);
      if (username == "") {
        stuErrors[8] = 1;
        consErrors[4] = 1;
        error_texts[8] = emptyNotAllowed;
      } else if (!regex.hasMatch(username)) {
        stuErrors[8] = 1;
        consErrors[4] = 1;
        error_texts[8] = invalidCharacterUsername;
      } else {
        if (registerType == 2) {
          error_texts[8] = "...";
          userSRV.check_valid_new_student_username(username).then((value) {
            setState(() {
              if (value) {
                stuErrors[8] = 0;
                consErrors[4] = 0;
                error_texts[8] = "";
              } else {
                stuErrors[8] = 1;
                consErrors[4] = 1;
                error_texts[8] = takenUsername;
              }
            });
          });
        } else {
          error_texts[8] = "...";
          userSRV.check_valid_new_consultant_username(username).then((value) {
            setState(() {
              if (value) {
                stuErrors[8] = 0;
                consErrors[4] = 0;
                error_texts[8] = "";
              } else {
                stuErrors[8] = 1;
                consErrors[4] = 1;
                error_texts[8] = takenUsername;
              }
            });
          });
        }
      }
    }
  }

  Student getStudentInf() {
    List<String> type1 = [
      "کنکوری تجربی",
      "کنکوری ریاضی",
      "کنکوری انسانی",
      "یازدهم تجربی",
      "یازدهم ریاضی",
      "یازدهم انسانی",
      "دهم تجربی",
      "دهم ریاضی",
      "دهم انسانی",
    ];
    List<String> type2 = [
      "کنکور پایه تجربی",
      "کنکور پایه ریاضی",
    ];
    List<String> type3 = [
      "نهم",
      "هشتم",
      "هفتم",
      "ششم",
    ];
    Student s = Student();
    s.username = _usernameController.text.toLowerCase();
    s.authentication_string = _passwordController.text;
    s.first_name = _firstNameController.text;
    s.last_name = _lastNameController.text;
    s.phone = replacePersianWithEnglishNumber(_phoneController.text);
    s.phone_code =
        replacePersianWithEnglishNumber(_registerPhoneController.text);
    s.father_phone =
        replacePersianWithEnglishNumber(_fatherPhoneController.text);
    s.mother_phone =
        replacePersianWithEnglishNumber(_motherPhoneController.text);
    s.home_number = replacePersianWithEnglishNumber(_homePhoneController.text);
    s.sub_consultant_username = _subConsUsernameController.text;
    s.boss_consultant_username = _bossConsUsernameController.text;
    if (s.boss_consultant_username == "") {
      s.boss_consultant_username = s.sub_consultant_username;
    }
    String levelMajor = _selectedValueForDropDown;
    if (type1.contains(levelMajor)) {
      s.student_major = levelMajor.split(" ")[1];
      s.student_edu_level = levelMajor.split(" ")[0];
    } else if (type2.contains(levelMajor)) {
      s.student_major = levelMajor.split(" ")[2];
      s.student_edu_level =
          levelMajor.split(" ")[0] + " " + levelMajor.split(" ")[1];
    } else if (type3.contains(levelMajor)) {
      s.student_edu_level = levelMajor;
      s.student_major = "";
    } else {
      s.student_edu_level = "";
      s.student_major = "";
    }
    s.school = _schoolNameController.text;
    return s;
  }

  Consultant getConsultantInf() {
    Consultant c = Consultant();
    c.username = _usernameController.text.toLowerCase();
    c.authentication_string = _passwordController.text;
    c.first_name = _firstNameController.text;
    c.last_name = _lastNameController.text;
    c.phone = replacePersianWithEnglishNumber(_phoneController.text);
    c.phone_code =
        replacePersianWithEnglishNumber(_registerPhoneController.text);
    c.boss_consultant_username = _bossConsUsernameController.text;
    return c;
  }

  void sendRegistrationData(StateSetter stateSetter) {
    stateSetter(() {
      registerLoading = true;
    });
    if (registerType == 2) {
      Student student = getStudentInf();
      userSRV.registerStudent(student).then((status) {
        stateSetter(() {
          registerLoading = false;
        });

        Navigator.of(context, rootNavigator: true).pop();
        try {
          countDownTimer.timer.cancel();
        } catch (e) {}
        if (status['success']) {
          navigateToSubPage(context, new FirstPage());
        } else {
          Fluttertoast.showToast(msg: status['error'], timeInSecForIosWeb: 3);
          stateSetter(() {
            registerPhoneError = true;
          });
        }
      });
    } else {
      Consultant consultant = getConsultantInf();
      userSRV.registerConsultant(consultant).then((status) {
        stateSetter(() {
          registerLoading = false;
        });
        Navigator.of(context, rootNavigator: true).pop();
        try {
          countDownTimer.timer.cancel();
        } catch (e) {}
        if (status['success']) {
          navigateToSubPage(context, new FirstPage());
        } else {
          Fluttertoast.showToast(msg: status['error'], timeInSecForIosWeb: 3);
          stateSetter(() {
            registerPhoneError = false;
          });
        }
      });
    }
  }

  void showPhoneRegisterCode() {
    _registerPhoneController.clear();
    registerPhoneError = false;
    countDownTimer = CountDownTimer(Duration(minutes: 1));
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
                    "ارسال کد به شماره همراه " + _phoneController.text,
                    textDirection: TextDirection.rtl,
                    style:
                        prefix0.getTextStyle(15, prefix0.Theme.onSettingText1),
                  ),
                  phoneRegisterCodeTextField(),
                  countDownTimer,
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
                            ? getLoadingProgess()
                            : AutoSizeText(
                                registerLabel,
                                style: prefix0.getTextStyle(
                                    15, prefix0.Theme.onApplyButton),
                              ),
                        onPressed: () {
                          if (_registerPhoneController.text.length == 4) {
                            sendRegistrationData(setstate);
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

  void showMaintainingInfoDialog() {
    Widget w = BackdropFilter(
      filter: prefix0.Theme.fragmentBGFilter,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(25),
          ),
        ),
        backgroundColor: Color.fromARGB(0, 0, 0, 0),
        content: Container(
//          height: MediaQuery.of(context).size.height * (80 / 100),
          width: MediaQuery.of(context).size.width * (90 / 100),
          color: Color.fromARGB(0, 0, 0, 0),
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: prefix0.Theme.settingBg,
                borderRadius: BorderRadius.all(Radius.circular(15))),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  getAutoSizedDirectionText(privacyAndPolicyTitle,
                      style: getTextStyle(19, prefix0.Theme.onSettingText1)),
                  SizedBox(
                    height: 10,
                  ),
                  getAutoSizedDirectionText(privacyAndPolicyString,
                      style: getTextStyle(15, prefix0.Theme.onSettingText2,height: 1.5),),
                  prefix1.RaisedButton(
                    onPressed: () {
                      Navigator.of(context).maybePop();
                    },
                    color: prefix0.Theme.applyButton,
                    child: AutoSizeText(applyLabel),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
    showDialog(context: context, child: w, barrierDismissible: false);
  }
}
