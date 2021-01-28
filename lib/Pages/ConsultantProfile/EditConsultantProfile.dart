import 'dart:io' as io;
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:mhamrah/ConnectionService/ConsultantProfileSRV.dart';
import 'package:mhamrah/ConnectionService/HTTPService.dart';
import 'package:mhamrah/ConnectionService/SMSSRV.dart';
import 'package:mhamrah/ConnectionService/UserSRV.dart';
import 'package:mhamrah/Models/ChatMV.dart';
import 'package:mhamrah/Models/UserMV.dart';
import 'package:mhamrah/Pages/TImer/CountDownTimer.dart';
import 'package:mhamrah/Utils/AutoTextUtils.dart';
import 'package:mhamrah/Utils/LocalFileUtils.dart';
import 'package:mhamrah/Utils/SnackAnFlushBarUtils.dart';
import 'package:mhamrah/Values/Utils.dart';
import 'package:mhamrah/Values/string.dart';
import 'package:mhamrah/Values/style.dart';
import 'package:mhamrah/Values/style.dart' as prefix0;
import 'package:flutter/material.dart' as prefix1;
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

import '../SharedProfile/ConsultantSelection.dart';

class EditConsultantProfile extends StatefulWidget {
  EditConsultantProfile({Key key}) : super(key: key);

  @override
  EditConsultantProfileState createState() => EditConsultantProfileState();
}

class EditConsultantProfileState extends State<EditConsultantProfile> {
  ConsultantProfileSRV consultantProfileSRV = ConsultantProfileSRV();
  ConnectionService httpRequestService = ConnectionService();
  SMSSRV smsSRV = SMSSRV();
  UserSRV userSRV = UserSRV();
  bool _passwordObscure = true;
  CustomFile imageFile;
  NetworkImage oldImage;
  Image image;

//  ConsultantSelection bossConsultantSelection;

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
  TextEditingController _bossConsUsernameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
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
  bool registerLoading = false;
  bool registerPhoneError = false;

  bool bossConsFlag = false;

  @override
  void initState() {
    super.initState();
    LSM.getConsultant().then((consultant) {
      setState(() {
        String username = consultant.username;
        String imageUrl = httpRequestService.getConsultantImageURL(username);
        if (consultant.boss_consultant_username == "" ||
            consultant.boss_consultant_username == null) {
          bossConsFlag = true;
        } else {
          bossConsFlag = false;
        }
        try {
          oldImage = new NetworkImage(imageUrl);
        } catch (Exception) {
          oldImage = null;
        }
        _firstNameController.text = consultant.first_name;
        _lastNameController.text = consultant.last_name;
        _bossConsUsernameController.text = consultant.boss_consultant_username;
        _phoneController.text = consultant.phone;
        _descriptionController.text = consultant.description;
      });
    });
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      child: MaterialApp(
        home: new Scaffold(
            resizeToAvoidBottomPadding: false,
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
      ),
      onWillPop: () async {
        Navigator.maybePop(context);
        return false;
      },
    );
  }

  Widget getFirstPageRegister() {
    return Column(
      children: <Widget>[
        getFirstNameTextField(firstName, 4, TextInputType.text),
        getLastNameTextField(lastName, 5, TextInputType.text),
        getDescriptionTextField(description, -1, TextInputType.multiline),
        getFirstPageButtons(nextRegisterPage)
      ],
    );
  }

  Widget getSecondPageRegister() {
    return Column(
      children: <Widget>[
        !bossConsFlag
            ? getBossConsultantTextField(
                bossConsultantUserName, 7, TextInputType.text)
            : SizedBox(),
        getPhoneTextField(phoneNumber, 6, TextInputType.phone),
        getSecondPageButtons()
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
        new GestureDetector(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              new Container(
                decoration: new BoxDecoration(
                    shape: BoxShape.circle, color: prefix0.Theme.onMainBGText),
                child: new Padding(
                    padding: EdgeInsets.all(2),
                    child: new Container(
                      width: imageSize,
                      decoration: imageFile != null
                          ? new BoxDecoration(
                              color: prefix0.Theme.onMainBGText,
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                fit: BoxFit.fill,
                                image: MemoryImage(imageFile.fileBytes),
                              ),
                            )
                          : oldImage != null
                              ? new BoxDecoration(
                                  color: prefix0.Theme.onMainBGText,
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    fit: BoxFit.fill,
                                    image: oldImage,
                                  ),
                                )
                              : BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: prefix0.Theme.onMainBGText),
                      child: imageFile == null && oldImage == null
                          ? Container(
                              width: imageSize,
                              height: imageSize,
                              child: new Icon(
                                Icons.camera_alt,
                                size: imageSize * (70 / 100),
                                color: prefix0.Theme.darkText,
                              ),
                            )
                          : new SizedBox(
                              width: imageSize,
                              height: imageSize,
                            ),
                    )),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Container(
                  width: imageSize * (30 / 100),
                  height: imageSize * (30 / 100),
                  decoration: BoxDecoration(
                      color: Color.fromARGB(100, 0, 0, 0),
                      shape: BoxShape.circle),
                  child: new Icon(
                    Icons.camera_alt,
                    size: imageSize * (20 / 100),
                    color: prefix0.Theme.onMainBGText,
                  ),
                ),
              )
            ],
          ),
          onTap: () {
            picImageFromGallery();
          },
          onLongPress: () {
            setState(() {
              imageFile = null;
              oldImage = null;
            });
          },
        )
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
                    fillColor: prefix0.Theme.transWhiteText,
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
                child: AutoSizeText(f(),
                    style: getTextStyle(12, prefix0.Theme.darkText)),
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
                padding: EdgeInsets.only(right: 15),
                child: AutoSizeText(
                  error_texts[4],
                  style: getTextStyle(12, prefix0.Theme.onMainBGText),
                ),
              )
            ],
          )),
    );
  }

  Widget getDescriptionTextField(
      String title, int index, TextInputType textInputType) {
    return new Padding(
      padding: EdgeInsets.fromLTRB(20, 5, 20, 0),
      child: new Container(
          height: 150,
          alignment: Alignment.center,
          child: new Column(
            children: <Widget>[
              new Container(
                height: 150,
                child: TextField(
//                  style: prefix0.getTextStyle(15, prefix0.Theme.blackText),
                  style: TextStyle(
                    height: 1.6,
                    color: prefix0.Theme.darkText,
                    fontFamily: 'traffic',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 6,
                  keyboardType: textInputType,
                  controller: _descriptionController,
                  textDirection: TextDirection.rtl,
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
                padding: EdgeInsets.only(right: 15),
                child: AutoSizeText(
                  error_texts[5],
                  style: getTextStyle(12, prefix0.Theme.onMainBGText),
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
          height: 75,
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
                padding: EdgeInsets.only(right: 15),
                child: AutoSizeText(
                  error_texts[6],
                  style: getTextStyle(12, prefix0.Theme.onMainBGText),
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
                child: new Container(
                  height: 50,
                  child: TextField(
                    style: prefix0.getTextStyle(15, prefix0.Theme.darkText),
                    keyboardType: textInputType,
                    controller: _bossConsUsernameController,
                    textAlign: TextAlign.center,
                    obscureText: false,
                    enabled: true,
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
//                onTap: () {
//                  bossConsultantSelection = ConsultantSelection(
//                      _bossConsUsernameController, context, 0);
//                  bossConsultantSelection.showSelectionAlert();
//                },
              ),
              new Container(
                height: 20,
                alignment: Alignment.topRight,
                padding: EdgeInsets.only(right: 15),
                child: getAutoSizedDirectionText(
                  error_texts[7],
                  style: getTextStyle(12, prefix0.Theme.onMainBGText),
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
          child: getButtonText(text),
        ),
      ),
      onTap: () {
        setState(() {
          int errorCount = 0;

          onTextFieldTouch[4] = true;
          validateNotEmptyFirstName();
          errorCount += consErrors[0];
          onTextFieldTouch[5] = true;
          validateNotEmptyLastName();
          errorCount += consErrors[1];
          onTextFieldTouch[6] = true;
          validateNotAllowedEmptyPhone();
          errorCount += consErrors[2];
          if (errorCount == 0) {
            _firstPageAnim = false;
            _secondPage = true;
            Future.delayed(Duration(milliseconds: 150)).then((_) {
              setState(() {
                _firstPage = false;
                _secondPageAnim = true;
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
        });
      },
    );
  }

  Widget getSecondPageButtons() {
    return new Padding(
      padding: EdgeInsets.only(top: 10, left: 20, right: 20),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                child: loadingPhoneCode
                    ? getLoadingProgess()
                    : getButtonText(approveLabel),
              ),
            ),
            onTap: () {
              int errorCount = 0;

              onTextFieldTouch[7] = true;
              errorCount += consErrors[3];
              onTextFieldTouch[8] = true;
              errorCount += consErrors[4];
              onTextFieldTouch[9] = true;
              errorCount += consErrors[5];
              onTextFieldTouch[10] = true;
              errorCount += consErrors[6];
              if (errorCount == 0) {
                setState(() {
                  loadingPhoneCode = true;
                });
                smsSRV
                    .sendRegisterCode("", _phoneController.text)
                    .then((status) {
                  setState(() {
                    loadingPhoneCode = false;
                  });
                  if (status['success']) {
                    showPhoneRegisterCode();
                  } else {
                    showFlutterToastWithFlushBar("خطا در ارسال پیامک");
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
          ),
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

  /// Image
  Future picImageFromGallery() async {
    final imageSource = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(25),
          ),
        ),
        backgroundColor: prefix0.Theme.settingBg,
        content: Container(
          height: 80,
          width: 150,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              AutoSizeText(
                "منبع عکس را انتخاب کنید.",
                textDirection: TextDirection.rtl,
                style: prefix0.getTextStyle(15, prefix0.Theme.darkText),
              ),
              kIsWeb
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MaterialButton(
                            child: AutoSizeText(
                              "فایل ها",
                              style: prefix0.getTextStyle(
                                  15, prefix0.Theme.darkText),
                            ),
                            onPressed: () async {
                              /// web
//                              MediaInfo mediaData =
//                                  await ImagePickerWeb.getImageInfo;
//                              Navigator.maybePop(context);
//
//                              if (mediaData != null) {
//                                setState(() {
//                                  imageFile = CustomFile();
//                                  imageFile.fileBytes = mediaData.data;
//                                  imageFile.fileNameOrPath = mediaData.fileName;
//                                });
//                              }
                            })
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        MaterialButton(
                          child: AutoSizeText(
                            "Camera",
                            style: prefix0.getTextStyle(
                                15, prefix0.Theme.darkText),
                          ),
                          onPressed: () =>
                              Navigator.pop(context, ImageSource.camera),
                        ),
                        MaterialButton(
                          child: AutoSizeText(
                            "Gallery",
                            style: prefix0.getTextStyle(
                                15, prefix0.Theme.darkText),
                          ),
                          onPressed: () =>
                              Navigator.pop(context, ImageSource.gallery),
                        )
                      ],
                    )
            ],
          ),
        ),
      ),
    );
    if (imageSource != null) {
      io.File file = await ImagePicker.pickImage(
          source: imageSource, maxHeight: 500, maxWidth: 500);
      if (file != null) {
        setState(() {
          imageFile = CustomFile();
          imageFile.fileBytes = file.readAsBytesSync();
          imageFile.fileNameOrPath = file.path;
        });
      }
    }

//    Image image = await FlutterWebImagePicker.getImage.asStream();
//    File file = File(image.);
//    if (image != null) {
//    setState(() {
//    imageFile = image as io.File;
//    print(imageFile.toString());
//    });
//    }//TODO

    print("beffor");
//    File imageFile =
//        await ImagePickerWeb.getImage(outputType: ImageType.widget);
//    print("after");
//    setState(() {
//      print("befor");
//      this.imageFile = imageFile;
//      print("after");
//    });
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

  String validateStuAndConsBossConsUsername() {
    if (!onTextFieldTouch[7]) {
      stuErrors[7] = 0;
      consErrors[3] = 0;
      error_texts[7] = "";
    } else {
      String boss_username = _bossConsUsernameController.text;
      RegExp regex = RegExp(r"^[a-z|A-Z|.|0-9]{3,}$", caseSensitive: true);
      if (boss_username.trim() == "") {
        stuErrors[7] = 0;
        consErrors[3] = 0;
        error_texts[7] = "";
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

  Student getStudentInf() {
    List<String> type1 = [
      "دهم تجربی",
      "دهم ریاضی",
      "یازدهم ریاضی",
      "یازدهم تجربی",
      "دوازدهم تجربی",
      "دوازدهم ریاضی",
      "دهم انسانی"
    ];
    List<String> type2 = [
      "کنکور پایه تجربی",
      "کنکور پایه ریاضی",
    ];
    List<String> type3 = ["ششم", "هفتم", "هشتم", "نهم", "جمع بندی"];
    Student s = Student();
    s.first_name = _firstNameController.text;
    s.last_name = _lastNameController.text;
    s.phone = _phoneController.text;
    s.boss_consultant_username = _bossConsUsernameController.text;
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
    return s;
  }

  Consultant getConsultantInf() {
    Consultant c = Consultant();
    c.first_name = _firstNameController.text;
    c.last_name = _lastNameController.text;
    c.phone = replacePersianWithEnglishNumber(_phoneController.text);
    c.phone_code =
        replacePersianWithEnglishNumber(_registerPhoneController.text);
    c.boss_consultant_username = _bossConsUsernameController.text;
    c.description = _descriptionController.text;
    return c;
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
                    style: prefix0.getTextStyle(15, prefix0.Theme.darkText),
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
                            ? getButtonLoadingProgress()
                            : AutoSizeText(
                                registerLabel,
                                style: prefix0.getTextStyle(
                                    15, prefix0.Theme.onMainBGText),
                              ),
                        onPressed: () {
                          sendEditedData(setstate);
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

  void sendEditedData(StateSetter stateSetter) {
    stateSetter(() {
      registerLoading = true;
    });
    LSM.getConsultant().then((consultant) {
      Consultant editedConsultant = getConsultantInf();
      editedConsultant.authentication_string = "keep old image";
      consultantProfileSRV
          .editConsultant(consultant.username, consultant.authentication_string,
              editedConsultant, null)
          .then((status) {
        stateSetter(() {
          registerLoading = false;
        });
        Navigator.of(context, rootNavigator: true).pop();
        if (status['success']) {
          consultant.first_name = editedConsultant.first_name;
          consultant.last_name = editedConsultant.last_name;
          consultant.boss_consultant_username =
              editedConsultant.boss_consultant_username;
          consultant.phone = editedConsultant.phone;
          consultant.description = editedConsultant.description;
          LSM.updateConsultantInfo(consultant);

          Navigator.pop(context, true);
          if (oldImage != null && imageFile == null) {
            editedConsultant.authentication_string = "keep old image";
          } else {
            editedConsultant.authentication_string = "";
          }
          consultantProfileSRV
              .editConsultantAvatar(consultant.username,
                  consultant.authentication_string, editedConsultant, imageFile)
              .then((value) {});
        } else {
          showFlutterToastWithFlushBar(status['error']);
          stateSetter(() {
            registerPhoneError = true;
          });
        }
      });
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
