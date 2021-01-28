import 'package:mhamrah/Pages/ConsultantTable/DayDetail.dart';
import 'package:mhamrah/Pages/StudentMainPage.dart';
import 'package:mhamrah/Pages/User/FirstPage.dart';
import 'package:mhamrah/Values/string.dart';
import 'package:mhamrah/Values/style.dart' as prefix0;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatContactTitlePart extends StatefulWidget {
//  final StudentListPageState studentListPageState;

  ChatContactTitlePart();

  @override
  _ChatContactTitlePartState createState() => _ChatContactTitlePartState();
}

class _ChatContactTitlePartState extends State<ChatContactTitlePart> {
  _ChatContactTitlePartState();

  @override
  Widget build(BuildContext context) {
    double ySize = MediaQuery.of(context).size.height;
    return new Container(
      height: 15 +
          ySize * (15 / 100) * (60 / 100) -
          35 +
          FirstPage.androidTitleBarHeight,
      width: MediaQuery.of(context).size.height,
      decoration: new BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [prefix0.Theme.titleBar2, prefix0.Theme.titleBar1]),
        color: prefix0.Theme.titleBar1,        borderRadius: new BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
      ),
      alignment: Alignment.bottomCenter,
//      child: getSearchTextField(),
    );
  }

  Widget getSearchTextField() {
    return new Padding(
      padding: EdgeInsets.all(10),
      child: new Container(
        width: MediaQuery.of(context).size.width * (80 / 100),
        height: 45,
        alignment: Alignment.center,
        decoration: new BoxDecoration(
            color: prefix0.Theme.transWhiteText,
            borderRadius: new BorderRadius.all(Radius.circular(20))),
        child: TextField(
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
          onSubmitted: (value) {
//            studentListPageState.fetchStudentList(value);
          },
          style: TextStyle(fontSize: 17),
          decoration: new InputDecoration(
              border: InputBorder.none,
              hintText: "جستجو",
              suffixIcon: Icon(
                Icons.search,
                color: Colors.black,
              )),
        ),
      ),
    );
  }
}
