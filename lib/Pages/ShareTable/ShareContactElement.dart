import 'package:mhamrah/ConnectionService/HTTPService.dart';
import 'package:mhamrah/ConnectionService/StudentListSRV.dart';
import 'package:mhamrah/Models/StudentListPageMV.dart';
import 'package:mhamrah/Pages/SlideMainPage.dart';
import 'package:mhamrah/Utils/LocalFileUtils.dart';
import 'package:mhamrah/Values/Utils.dart';
import 'package:mhamrah/Values/string.dart';
import 'package:mhamrah/Values/style.dart' as prefix0;
import 'package:flutter/material.dart';

import '../StudentMainPage.dart';

class ShareContactElement extends StatefulWidget {
  final ContactElement studentContactElement;
  bool selecterdToggle = false;

  ShareContactElement(
    this.studentContactElement, {
    Key key,
  }) : super(key: key);

  @override
  _ShareContactState createState() => _ShareContactState(studentContactElement);
}

class _ShareContactState extends State<ShareContactElement> {
  ConnectionService httpRequestService = ConnectionService();
  StudentListSRV studentListSRV = StudentListSRV();
  ContactElement studentContactElement;
  double xSize;
  double ySize;
  String imageURL = "";

  final columns = 7;
  final rows = 13;

  _ShareContactState(this.studentContactElement);

  Widget build(BuildContext context) {
    String username = studentContactElement.username;
    imageURL = httpRequestService.getStudentImageURL(username);
    xSize = MediaQuery.of(context).size.width;
    ySize = MediaQuery.of(context).size.height;
    return Visibility(
      child: new Padding(
        padding: EdgeInsets.only(
            left: xSize * (5 / 100), right: xSize * (5 / 100), top: 10),
        child: new Container(
            decoration: new BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(35)),
              color: prefix0.Theme.blueBR,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: prefix0.Theme.spreadRadius,
                  blurRadius: prefix0.Theme.blurRadius,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: new Column(
              children: <Widget>[
                getStudentContact(),
              ],
            )),
      ),
      visible: true,
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
            color: !widget.selecterdToggle
                ? prefix0.Theme.startEndTimeItemsBG
                : prefix0.Theme.blueBR,
            borderRadius: BorderRadius.all(Radius.circular(35))),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            widget.selecterdToggle
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
        setState(() {
          widget.selecterdToggle = !widget.selecterdToggle;
        });
      },
    );
  }

  List<List<String>> _makeData() {
    final List<List<String>> output = [];
    for (int i = 0; i < columns; i++) {
      final List<String> row = [];
      for (int j = 0; j < rows; j++) {
        row.add('T$i : L$j');
      }
      output.add(row);
    }
    return output;
  }

  Widget getUnReadOrTrash() {
    return AnimatedCrossFade(
      firstChild: SizedBox(),
      secondChild: getSelectIcon(),
      duration: const Duration(milliseconds: 500),
      crossFadeState: !widget.selecterdToggle
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
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

  Widget getSelectIcon() {
    return new Container(
      alignment: Alignment.bottomLeft,
      padding: EdgeInsets.only(left: 2, right: 2, bottom: 5),
      child: new Container(
          decoration: new BoxDecoration(
              shape: BoxShape.circle, color: prefix0.Theme.applyButton),
          width: 20,
          height: 20,
          child: Icon(
            Icons.done,
            color: prefix0.Theme.onMainBGText,
            size: 18,
          )),
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
    return Stack(
      children: <Widget>[
        new Container(
          width: ySize * (7.5 / 100),
          height: ySize * (7.5 / 100),
          alignment: Alignment.bottomLeft,
          decoration: new BoxDecoration(
            shape: BoxShape.circle,
            image: new DecorationImage(
                fit: BoxFit.fill, image: new NetworkImage(imageURL)),
          ),
          child: getUnReadOrTrash(),
        ),
      ],
    );
  }

  Widget getContactDetail() {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.fromLTRB(10, 5, ySize * (4 / 100), 0),
      child: new Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Text(
              studentContactElement.name,
              style: prefix0.getTextStyle(18, prefix0.Theme.onMainBGText),
            ),
          ]),
    );
  }
}
