import 'dart:io' as io;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:mhamrah/ConnectionService/HTTPService.dart';
import 'package:mhamrah/ConnectionService/SMSSRV.dart';
import 'package:mhamrah/ConnectionService/StudentProfileSRV.dart';
import 'package:mhamrah/ConnectionService/UserSRV.dart';
import 'package:mhamrah/Models/ChatMV.dart';
import 'package:mhamrah/Models/UserMV.dart';
import 'package:mhamrah/Pages/StudentMainPage.dart';
import 'package:mhamrah/Pages/TImer/CountDownTimer.dart';
import 'package:mhamrah/Pages/User/LoginPage.dart';
import 'package:mhamrah/Utils/AutoTextUtils.dart';
import 'package:mhamrah/Utils/LocalFileUtils.dart';
import 'package:mhamrah/Utils/SnackAnFlushBarUtils.dart';
import 'package:mhamrah/Values/Utils.dart';
import 'package:mhamrah/Values/string.dart';
import 'package:mhamrah/Values/style.dart';
import 'package:mhamrah/Values/style.dart' as prefix0;
import 'package:flutter/material.dart' as prefix1;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../SharedProfile/ConsultantSelection.dart';
//import 'package:image_picker_web/image_picker_web.dart';

class RequestNewConsultant extends StatefulWidget {
  RequestNewConsultant({Key key}) : super(key: key);

  @override
  _RequestNewConsultantState createState() => _RequestNewConsultantState();
}

class _RequestNewConsultantState extends State<RequestNewConsultant> {
  SMSSRV smsSRV = SMSSRV();
  StudentProfileSRV studentProfileSRV = StudentProfileSRV();
  ConnectionService httpRequestService = ConnectionService();

//  ConsultantSelection bossConsultantSelection;
  ConsultantSelection subConsultantSelection;

  UserSRV userSRV = UserSRV();
  bool _passwordObscure = true;
  CustomFile imageFile;
  NetworkImage oldImage;

  bool _firstPage = true;
  bool _firstPageAnim = true;
  bool _secondPage = false;
  bool _secondPageAnim = false;

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
  bool registerLoading = false;
  bool registerPhoneError = false;

  _RequestNewConsultantState();

  @override
  void initState() {
    super.initState();

    LSM.getStudent().then((student) {
      setState(() {
        String username = student.username;
        String imageUrl = httpRequestService.getStudentImageURL(username);
        try {
          oldImage = new NetworkImage(imageUrl);
        } catch (Exception) {
          oldImage = null;
        }
        _firstNameController.text = student.first_name;
        _lastNameController.text = student.last_name;
        _bossConsUsernameController.text = student.boss_consultant_username;
        _phoneController.text = student.phone;
        _fatherPhoneController.text = student.father_phone;
        _motherPhoneController.text = student.mother_phone;
        _homePhoneController.text = student.home_number;
        _schoolNameController.text = student.school;
        _subConsUsernameController.text = student.sub_consultant_username;
        _selectedValueForDropDown =
            student.student_edu_level + " " + student.student_major;
      });
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
              Expanded(
                child: new Container(
                  padding: EdgeInsets.only(top: 25, left: 8),
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: prefix0.Theme.onMainBGText,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
              getUserAvatarImage(),
              new Container(
                height: MediaQuery.of(context).size.height * (70 / 100),
                padding: EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        prefix0.Theme.titleBar1,
                        prefix0.Theme.titleBar2
                      ]),
                  color: prefix0.Theme.titleBar1,
                ),
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
        getBossConsultantTextField(
            bossConsultantUserName, 7, TextInputType.text),
        getSubConsultantTextField(subConsultantUserName, 3, TextInputType.text),
        getFirstPageButtons(applyLabel)
      ],
    );
  }

  Widget getSecondPageRegister() {
    return Column(
      children: <Widget>[getSecondPageButtons()],
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
//          child: Stack(
//            alignment: Alignment.bottomCenter,
//            children: [
//              new Container(
//                decoration: new BoxDecoration(
//                    shape: BoxShape.circle,
//                    color: Color.fromARGB(150, 100, 100, 100)),
//                child: new Padding(
//                    padding: EdgeInsets.all(10),
//                    child: new Container(
//                      width: imageSize,
//                      decoration: imageFile != null
//                          ? new BoxDecoration(
//                              color: prefix0.Theme.onMainBGText,
//                              shape: BoxShape.circle,
//                              image: DecorationImage(
//                                fit: BoxFit.fill,
//                                image: MemoryImage(imageFile.fileBytes),
//                              ),
//                            )
//                          : oldImage != null
//                              ? new BoxDecoration(
//                                  color: prefix0.Theme.onMainBGText,
//                                  shape: BoxShape.circle,
//                                  image: DecorationImage(
//                                    fit: BoxFit.fill,
//                                    image: oldImage,
//                                  ),
//                                )
//                              : BoxDecoration(
//                                  shape: BoxShape.circle,
//                                  color: prefix0.Theme.onMainBGText),
//                      child: imageFile == null && oldImage == null
//                          ? Container(
//                              width: imageSize,
//                              height: imageSize,
//                              child: new Icon(
//                                Icons.camera_alt,
//                                size: imageSize * (70 / 100),
//                                color: prefix0.Theme.darkText,
//                              ),
//                            )
//                          : new SizedBox(
//                              width: imageSize,
//                              height: imageSize,
//                            ),
//                    )),
//              ),
//              Padding(
//                padding: EdgeInsets.only(bottom: 3),
//                child: Container(
//                  width: imageSize * (30 / 100),
//                  height: imageSize * (30 / 100),
//                  decoration: BoxDecoration(
//                      color: Color.fromARGB(100, 0, 0, 0),
//                      shape: BoxShape.circle),
//                  child: new Icon(
//                    Icons.camera_alt,
//                    size: imageSize * (20 / 100),
//                    color: prefix0.Theme.onMainBGText,
//                  ),
//                ),
//              )
//            ],
//          ),
//          onTap: () {
//            picImageFromGallery();
//          },
//          onLongPress: () {
//            setState(() {
//              imageFile = null;
//              oldImage = null;
//            });
//          },
//        )
      ],
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
              new GestureDetector(
                onTap: () {
                  subConsultantSelection = ConsultantSelection(
                      _subConsUsernameController, context, 1,
                      bossConsUsernameController: _bossConsUsernameController);
                  subConsultantSelection.showSelectionAlert();
                },
                child: Container(
                  height: 50,
                  child: TextField(
                    style: prefix0.getTextStyle(15, prefix0.Theme.darkText),
                    keyboardType: textInputType,
                    controller: _subConsUsernameController,
                    textAlign: TextAlign.center,
                    obscureText: false,
                    enabled: false,
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
              ),
              new Container(
                height: 20,
                alignment: Alignment.topRight,
                padding: EdgeInsets.only(right: 15),
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
              GestureDetector(
//                onTap: () {
//                  bossConsultantSelection = ConsultantSelection(
//                      _bossConsUsernameController, context, 0);
//                  bossConsultantSelection.showSelectionAlert();
//                },
                child: new Container(
                  height: 50,
                  child: TextField(
                    style: prefix0.getTextStyle(15, prefix0.Theme.darkText),
                    keyboardType: textInputType,
                    controller: _bossConsUsernameController,
                    enabled: true,
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
              ),
              new Container(
                height: 20,
                alignment: Alignment.topRight,
                padding: EdgeInsets.only(right: 15),
                child: getAutoSizedDirectionText(
                  error_texts[7],
                  style: getTextStyle(12, prefix0.Theme.onTitleBarText),
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
          padding: EdgeInsets.fromLTRB(20, 5, 10, 5),
          decoration: new BoxDecoration(
              borderRadius: new BorderRadius.all(Radius.circular(25)),
              color: emptyFieldError
                  ? prefix0.Theme.grey
                  : prefix0.Theme.applyButton),
          child: registerLoading ? getLoadingProgress() : getButtonText(text),
        ),
      ),
      onTap: () {
        int errorCount = 0;
        onTextFieldTouch[3] = true;
        validateStuSubConsUsername();
        errorCount += stuErrors[3];
        onTextFieldTouch[7] = true;
        validateStuAndConsBossConsUsername();
        errorCount += stuErrors[7];
        if (errorCount == 0) {
          setState(() {
            registerLoading = true;
          });
          sendEditedData((fn) {});
//          smsSRV.sendRegisterCode("", _phoneController.text).then((status) {
//            setState(() {
//              loadingPhoneCode = false;
//            });
//          });
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
    );
  }

  Widget getSecondPageButtons() {
    return new Padding(
      padding: EdgeInsets.only(top: 10, left: 20, right: 20),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new GestureDetector(
            key: ValueKey("2-0"),
            child: new Padding(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 20),
              child: new Container(
                padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
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

                Future.delayed(Duration(milliseconds: 250)).then((_) {
                  setState(() {
                    _firstPageAnim = true;
                    _secondPage = false;
                  });
                });
              });
            },
          ),
          new GestureDetector(
            key: ValueKey("2-1"),
            child: new Padding(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 20),
              child: new Container(
                padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                decoration: new BoxDecoration(
                    borderRadius: new BorderRadius.all(Radius.circular(25)),
                    color: emptyFieldError
                        ? prefix0.Theme.grey
                        : prefix0.Theme.applyButton),
                child: registerLoading
                    ? getLoadingProgess()
                    : getButtonText(approveLabel),
              ),
            ),
            onTap: () {},
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
      child: AutoSizeText(
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

  String validateStuSubConsUsername() {
    if (!onTextFieldTouch[3]) {
      error_texts[3] = "";
    } else {
      String username = _subConsUsernameController.text;
      RegExp regex = RegExp(r"^[a-z|A-Z|.|1-9]+$", caseSensitive: true);
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
      RegExp regex = RegExp(r"^[a-z|A-Z|.|1-9]{3,}$", caseSensitive: true);
      if (boss_username.trim() == "") {
        stuErrors[7] = 1;
        consErrors[3] = 1;
        error_texts[7] = emptyNotAllowed;
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

  String validateAllowedEmptyPhone() {
    if (!onTextFieldTouch[6]) {
      error_texts[6] = "";
    } else {
      String text = _phoneController.text;
      if (text.trim() == "") {
        error_texts[6] = "";
      } else {
        String engPhone = replacePersianWithEnglishNumber(text);
        RegExp regex = RegExp(r"^[0][9][0-9]{9}$");
        if (!regex.hasMatch(engPhone)) {
          stuErrors[6] = 1;
          consErrors[2] = 1;
          error_texts[6] = invalidPhone;
        } else {
          stuErrors[6] = 0;
          consErrors[2] = 0;
          error_texts[6] = "";
        }
      }
    }
  }

  String validateAllowedEmptyFatherPhone() {
    if (!onTextFieldTouch[0]) {
      error_texts[0] = "";
    } else {
      String text = _fatherPhoneController.text;
      if (text.trim() == "") {
        error_texts[0] = "";
      } else {
        String engPhone = replacePersianWithEnglishNumber(text);
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

  String validateAllowedEmptyMotherPhone() {
    if (!onTextFieldTouch[1]) {
      error_texts[1] = "";
    } else {
      String text = _motherPhoneController.text;
      if (text.trim() == "") {
        error_texts[1] = "";
      } else {
        String engPhone = replacePersianWithEnglishNumber(text);
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
          stuErrors[6] = 0;
          consErrors[2] = 0;
          error_texts[6] = "";
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
    if (s.sub_consultant_username == "") {
      s.sub_consultant_username = s.boss_consultant_username;
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

  void sendEditedData(StateSetter stateSetter) {
    stateSetter(() {
      registerLoading = true;
    });
    LSM.getStudent().then((student) {
      Student editedStudent = getStudentInf();
      editedStudent.authentication_string = "keep old image";
      studentProfileSRV
          .editStudentConsultants(student.username,
              student.authentication_string, editedStudent, null)
          .then((status) {
        stateSetter(() {
          registerLoading = false;
        });
        if (status['success']) {
          student.boss_consultant_username = student.boss_consultant_username;
          student.sub_consultant_username =
              editedStudent.sub_consultant_username;
          student.boss_consultant_username =
              editedStudent.boss_consultant_username;
          LSM.updateStudentInfo(student);
          Navigator.pop(context, true);
          if (oldImage != null && imageFile == null) {
            editedStudent.authentication_string = "keep old image";
          } else {
            editedStudent.authentication_string = "";
          }
          studentProfileSRV
              .editStudentAvatar(student.username,
                  student.authentication_string, editedStudent, imageFile)
              .then((value) {});
          showFlutterToastWithFlushBar(
              "منتظر تایید درخواست خود توسط مشاور باشید.");
        } else {
          if (status['error'] == "subcons and bosscons does not match") {
            showFlutterToastWithFlushBar("پشتیبان مورد تایید این مشاور نیست.");
            stateSetter(() {
              registerPhoneError = true;
            });
          } else {
            showFlutterToastWithFlushBar(status['error']);
            stateSetter(() {
              registerPhoneError = true;
            });
          }
        }
      });
    });
  }

//  void showPhoneRegisterCode() {
//    _registerPhoneController.clear();
//    registerPhoneError = false;
//    Widget d = BackdropFilter(
//      filter: prefix0.Theme.fragmentBGFilter,
//      child: AlertDialog(
//        shape: RoundedRectangleBorder(
//          borderRadius: BorderRadius.all(
//            Radius.circular(25),
//          ),
//        ),
//        backgroundColor: prefix0.Theme.settingBg,
//        content: StatefulBuilder(
//          builder: (BuildContext context, StateSetter setstate) {
//            return Container(
//              height: 200,
//              width: 100,
//              child: Column(
//                crossAxisAlignment: CrossAxisAlignment.center,
//                mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                children: <Widget>[
//                  AutoSizeText(
//                    "کد برای شماره شما ارسال شد.",
//                    textDirection: TextDirection.rtl,
//                    style:
//                        prefix0.getTextStyle(15, prefix0.Theme.onSettingText1),
//                  ),
//                  phoneRegisterCodeTextField(),
//                  CountDownTimer(Duration(minutes: 1)),
//                  Row(
//                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                    children: <Widget>[
//                      MaterialButton(
//                        color: registerPhoneError
//                            ? prefix0.Theme.titleBar1
//                            : prefix0.Theme.applyButton,
//                        shape: RoundedRectangleBorder(
//                            borderRadius: BorderRadius.circular(15)),
//                        child: registerLoading
//                            ? getLoadingProgress()
//                            : AutoSizeText(
//                                registerLabel,
//                                style: prefix0.getTextStyle(
//                                    15, prefix0.Theme.onMainBGText),
//                              ),
//                        onPressed: () {
//                          sendEditedData(setstate);
//                        },
//                      )
//                    ],
//                  )
//                ],
//              ),
//            );
//          },
//        ),
//      ),
//    );
//    showDialog(context: context, child: d, barrierDismissible: true);
//  }

  Widget getLoadingProgress() {
    return Container(
      child: prefix1.CircleAvatar(
        backgroundColor: Color.fromARGB(0, 0, 0, 0),
        child: prefix1.CircularProgressIndicator(),
      ),
      padding: EdgeInsets.only(right: 10, left: 10),
    );
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
