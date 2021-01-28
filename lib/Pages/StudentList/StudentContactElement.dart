import 'package:mhamrah/ConnectionService/HTTPService.dart';
import 'package:mhamrah/ConnectionService/StudentListSRV.dart';
import 'package:mhamrah/Models/StudentListPageMV.dart';
import 'package:mhamrah/Models/UserMV.dart';
import 'package:mhamrah/Pages/SlideMainPage.dart';
import 'package:mhamrah/Utils/LocalFileUtils.dart';
import 'package:mhamrah/Utils/PaymentUtils.dart';
import 'package:mhamrah/Values/Utils.dart';
import 'package:mhamrah/Values/string.dart';
import 'package:mhamrah/Values/style.dart' as prefix0;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../StudentMainPage.dart';
import 'StudentList.dart';

class StudentElement extends StatefulWidget {
  final ContactElement studentContactElement;
  final StudentListPageState listPage;
  final SlideMainPageState s;
  final Consultant consultant;

  StudentElement(
    this.studentContactElement,
    this.s,
    this.listPage,
    this.consultant, {
    Key key,
  }) : super(key: key);

  @override
  _StudentElementState createState() =>
      _StudentElementState(studentContactElement, s, listPage, consultant);
}

class _StudentElementState extends State<StudentElement> {
  ConnectionService httpRequestService = ConnectionService();
  StudentListSRV studentListSRV = StudentListSRV();
  ContactElement studentContactElement;
  SlideMainPageState slideMainPage;
  StudentListPageState listPage;
  double xSize;
  double ySize;
  String imageURL = "";
  Consultant consultant;

  final columns = 7;
  final rows = 13;
  bool deleteToggle = false;
  bool descriptionToggle = false;

  bool _deletedFlag = true;
  bool deleteLoading = false;

  _StudentElementState(this.studentContactElement, this.slideMainPage,
      this.listPage, this.consultant);

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Widget build(BuildContext context) {
    String username = studentContactElement.username;
    imageURL = httpRequestService.getStudentImageURL(username);
    xSize = MediaQuery.of(context).size.width;
    ySize = MediaQuery.of(context).size.height;
    return Visibility(
      key: ValueKey(studentContactElement.username),
      child: new Padding(
        padding: EdgeInsets.only(
            left: xSize * (5 / 100), right: xSize * (5 / 100), top: 10),
        child: new Container(
            decoration: new BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(35)),
//                boxShadow: [
//                  BoxShadow(
//                    color: prefix0.Theme.shadowColor,
//                    spreadRadius: prefix0.Theme.spreadRadius,
//                    blurRadius: prefix0.Theme.blurRadius,
//                    offset: Offset(0, 3), // changes position of shadow
//                  ),
//                ],
                color: prefix0.Theme.blueBR),
            child: new Column(
              children: <Widget>[
                getStudentContact(),
                descriptionToggle
                    ? getStudentDescription()
                    : SizedBox(
                        width: 0,
                        height: 0,
                      )
              ],
            )),
      ),
      visible: _deletedFlag,
    );
  }

  Widget getStudentDescription() {
    return new Container(
      alignment: Alignment.centerRight,
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              getTextDescription(studentContactElement.studentEduLevel, true),
              getTextDescription(studentContactElement.studentMajor, true),
              getTextDescription(studentContactElement.studentSchool, true),
            ],
          ),
          getTextDescription(
              "تلفن پدر: " + studentContactElement.fatherPhone, false),
          getTextDescription("تلفن: " + studentContactElement.phone, false),
          getTextDescription(
              "پشتیبان: " + studentContactElement.subConsName, false),
          getStudentMainPageButton()
        ],
      ),
    );
  }

  Widget getStudentMainPageButton() {
    return new GestureDetector(
      child: Container(
        height: 45,
        width: double.infinity,
        child: Text(
          "مشاهده",
          style: prefix0.getTextStyle(20, prefix0.Theme.onMainBGText),
        ),
        alignment: Alignment.center,
        decoration: new BoxDecoration(
            color: prefix0.Theme.applyButton,
            borderRadius: new BorderRadius.only(
                bottomLeft: Radius.circular(35),
                bottomRight: Radius.circular(35))),
      ),
      onTap: () {
        navigateToSubPage(
            context, StudentMainPage(studentContactElement.username));
      },
    );
  }

  Widget getTextDescription(String text, bool) {
    return new Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: 10, bottom: 5),
      child: new Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            text,
            textDirection: TextDirection.rtl,
            style: prefix0.getTextStyle(18, prefix0.Theme.onMainBGText),
          ),
          bool
              ? Icon(
                  Icons.fiber_manual_record,
                  size: 10,
                  color: Colors.white,
                )
              : new SizedBox(
                  width: 0,
                  height: 0,
                )
        ],
      ),
    );
  }

  Widget getStudentContact() {
    return new GestureDetector(
      child: new Container(
        height: ySize * (8 / 100),
        decoration: new BoxDecoration(
            color: !deleteToggle
                ? prefix0.Theme.startEndTimeItemsBG
                : prefix0.Theme.blueBR,
            borderRadius: BorderRadius.all(Radius.circular(35))),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            getUnReadOrTrash(),
            deleteToggle
                ? new Expanded(
                    child: new SizedBox(
                      width: 0,
                      height: 0,
                    ),
                  )
                : getLastSeenTime(),
            getContactDetail(),
            getContactAvatar()
          ],
        ),
      ),
      onTap: () {
        LSM.getConsultant().then((consultant) {
          if (!consultant.paymentStatus.access) {
            checkPaymentAndShowNotification(consultant.paymentStatus);
          } else {
            slideMainPage.changePage(studentContactElement.username);
          }
        });
      },
      onLongPress: () {
        setState(() {
          descriptionToggle = false;
          deleteToggle = !deleteToggle;
        });
      },
    );
  }

  Widget getUnReadOrTrash() {
    return AnimatedCrossFade(
      firstChild: studentContactElement.unseenMessageCount == 0
          ? SizedBox()
          : getUnreadText(),
      secondChild: getTrashIcon(),
      duration: const Duration(milliseconds: 500),
      crossFadeState:
          !deleteToggle ? CrossFadeState.showFirst : CrossFadeState.showSecond,
    );
  }

  Widget getLastSeenTime() {
    return new Expanded(
//      child: new Text(
//        studentContactElement.lastSeenTime,
//        style: TextStyle(fontSize: 18,color: prefix0.Theme.whiteText),
//      ),
      child: Container(),
    );
  }

  Widget getDeleteForLogPressText() {
    return new Expanded(
      child: new Text("مطمینی؟",
          style: prefix0.getTextStyle(18, prefix0.Theme.onMainBGText)),
    );
  }

  Widget getTrashIcon() {
    return new Container(
      decoration: new BoxDecoration(
        borderRadius: new BorderRadius.all(Radius.circular(35)),
      ),
      child: new Row(
        children: <Widget>[
          GestureDetector(
            child: new Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(
                left: 5,
                right: 2,
              ),
              child: new Container(
                  alignment: Alignment.center,
                  decoration: new BoxDecoration(
                      shape: BoxShape.circle, color: prefix0.Theme.applyButton),
                  width: 50,
                  padding: EdgeInsets.all(deleteLoading ? 0 : 10),
                  child: deleteLoading
                      ? getLoadingProgress()
                      : Icon(Icons.delete)),
            ),
            onTap: () {
              deleteStudent();
            },
          ),
//          GestureDetector(
//            child: new Container(
//              alignment: Alignment.centerLeft,
//              padding: EdgeInsets.only(left: 2, right: 5),
//              child: new Container(
//                  alignment: Alignment.center,
//                  decoration: new BoxDecoration(
//                      shape: BoxShape.circle, color: prefix0.Theme.greenButton),
//                  width: 50,
//                  padding: EdgeInsets.all(10),
//                  child: Icon(Icons.notifications_off)),
//            ),
//            onTap: () {
//              //TODO
//            },
//          )//TODO
        ],
      ),
    );
  }

  Widget getUnreadText() {
    return new Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.all(10),
      child: new Container(
        alignment: Alignment.center,
        decoration: new BoxDecoration(
            shape: BoxShape.circle, color: prefix0.Theme.applyButton),
        width: 50,
        padding: EdgeInsets.all(10),
        child: new Text(
          studentContactElement.unseenMessageCount.toString(),
          style: prefix0.getTextStyle(17, prefix0.Theme.onMainBGText),
        ),
      ),
    );
  }

  Widget getLoadingProgress() {
    return Padding(
      child: CircularProgressIndicator(),
      padding: EdgeInsets.only(right: 10, left: 10),
    );
  }

  Widget getContactAvatar() {
    return new Container(
      width: ySize * (7.5 / 100),
      height: ySize * (7.5 / 100),
      decoration: new BoxDecoration(
          shape: BoxShape.circle,
          image: new DecorationImage(
              fit: BoxFit.fill, image: new NetworkImage(imageURL))),
    );
  }

  Widget getContactDetail() {
    String subConsName =
        (consultant.username == studentContactElement.subConsUsername)
            ? " - "
            : studentContactElement.subConsUsername;
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.fromLTRB(10, 0, ySize * (4 / 100), 0),
      child: new Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Container(
              child: new Text(
                studentContactElement.name.trim(),
                textAlign: TextAlign.right,
                style: prefix0.getTextStyle(18, prefix0.Theme.onContactItemBg),
              ),
            ),
            Container(
              child: new Text(
                "پشتیبان: " + subConsName,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: prefix0.getTextStyle(14, prefix0.Theme.onContactItemBg),
              ),
            )
          ]),
    );
  }

  void deleteStudent() {
    setState(() {
      deleteLoading = true;
    });
    studentListSRV
        .deleteFromStudentListAddToPending(consultant.username,
            consultant.authentication_string, studentContactElement.username)
        .then((value) {
      if (value) {
        listPage.removeItemByUserName(studentContactElement.username);
        setState(() {
          deleteLoading = false;
        });
        StudentListData data = StudentListData();
        data.studentList = listPage.studentListData;
        data.subConsList = listPage.subConsListData;
        LSM.setAcceptedStudentListData(data);
      }
    });
  }
}
