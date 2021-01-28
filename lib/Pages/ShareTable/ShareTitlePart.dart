import 'package:mhamrah/Pages/ConsultantTable/DayDetail.dart';
import 'package:mhamrah/Pages/StudentMainPage.dart';
import 'package:mhamrah/Values/string.dart';
import 'package:mhamrah/Values/style.dart' as prefix0;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'ShareTableContactList.dart';

class ShareTableContactListTitlePart extends StatefulWidget {
  final ShareStudentListPageState studentListPageState;

  ShareTableContactListTitlePart(this.studentListPageState);

  @override
  _ShareTableContactListTitlePartState createState() =>
      _ShareTableContactListTitlePartState(this.studentListPageState);
}

class _ShareTableContactListTitlePartState
    extends State<ShareTableContactListTitlePart> {
  final ShareStudentListPageState studentListPageState;

  _ShareTableContactListTitlePartState(this.studentListPageState);

  @override
  Widget build(BuildContext context) {
    return new Container(
      height: 100,
      width: MediaQuery.of(context).size.width,
      decoration: new BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [prefix0.Theme.titleBar2, prefix0.Theme.titleBar1]),
        color: prefix0.Theme.titleBar1,
        borderRadius: new BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
      ),
      alignment: Alignment.bottomCenter,
      child: getSearchTextField(),
    );
  }

  Widget getSearchTextField() {
    return new Padding(
      padding: EdgeInsets.all(10),
      child: new Container(
        width: MediaQuery.of(context).size.width * (60 / 100),
        height: 40,
        alignment: Alignment.center,
        decoration: new BoxDecoration(
            color: prefix0.Theme.searchBoxBg,
            borderRadius: new BorderRadius.all(Radius.circular(20))),
        child: TextField(
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
          onSubmitted: (value) {
            studentListPageState.fetchStudentList(true, false, value);
          },
          style: prefix0.getTextStyle(17, prefix0.Theme.darkText),
          decoration: new InputDecoration(
              border: InputBorder.none,
              hintText: "          جستجو",
              suffixIcon: Icon(
                Icons.search,
                color: Colors.black,
              )),
        ),
      ),
    );
  }
}
