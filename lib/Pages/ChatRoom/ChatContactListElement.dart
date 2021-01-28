import 'package:auto_size_text/auto_size_text.dart';
import 'package:mhamrah/ConnectionService/HTTPService.dart';
import 'package:mhamrah/Models/StudentListPageMV.dart';
import 'package:mhamrah/Pages/ChatRoom/ChatScreen.dart';
import 'package:mhamrah/Utils/LocalFileUtils.dart';
import 'package:mhamrah/Values/Utils.dart';
import 'package:mhamrah/Values/string.dart';
import 'package:mhamrah/Values/style.dart';
import 'package:mhamrah/Values/style.dart' as prefix0;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../StudentMainPage.dart';

class ChatContactElement extends StatefulWidget {
  final StudentMainPageState studentMainPageState;
  final List<ContactElement> users;
  final bool channel;

  ChatContactElement(this.studentMainPageState, this.users, this.channel);

  @override
  _ChatContactListElement createState() =>
      _ChatContactListElement(studentMainPageState, users, this.channel);
}

class _ChatContactListElement extends State<ChatContactElement> {
  ConnectionService httpRequestService = new ConnectionService();
  StudentMainPageState studentMainPageState;
  List<ContactElement> users;
  int userType = 0;
  bool channelFlag;

  final columns = 7;
  final rows = 13;

  _ChatContactListElement(
      this.studentMainPageState, this.users, this.channelFlag);

  @override
  void initState() {
    super.initState();
    LSM.getUserMode().then((type) {
      setState(() {
        userType = type;
      });
    });
  }

  Widget build(BuildContext context) {
    return new Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 10),
      child: new Container(
          decoration: new BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(35)),
            color: prefix0.Theme.contactItemBG,
            boxShadow: [
              BoxShadow(
                color: prefix0.Theme.shadowColor,
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
    );
  }

  Widget getStudentContact() {
    return new Container(
      height: 65,
      decoration: new BoxDecoration(
          color: prefix0.Theme.startEndTimeItemsBG,
          borderRadius: BorderRadius.all(Radius.circular(35))),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
//          getUnreadText(),
          getLastSeenTime(),
          getContactDetail(),
          getContactAvatar()
        ],
      ),
    );
  }

  Widget getLastSeenTime() {
    return new Expanded(
//      child: new Text(
//        user1.lastSeenTime,
//        style: TextStyle(fontSize: 15,color: prefix0.Theme.whiteText),
//      ),
      child: Container(),
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
        child: new AutoSizeText(
          "0", //TODO
          style: prefix0.getTextStyle(17, prefix0.Theme.onMainBGText),
        ),
      ),
    );
  }

  Widget getSingleAvatar(String username, String userType) {
    String url = "";
    if (channelFlag) {
      url = httpRequestService.getGroupImageURL();
    } else {
      if (userType == "00" || userType == "0") {
        url = httpRequestService.getConsultantImageURL(username);
      } else if (userType == "1") {
        url = httpRequestService.getStudentImageURL(username);
      } else if (url == null) {
        url = httpRequestService.getGroupImageURL();
      }
    }

    return url == ""
        ? Container(
            width: 60,
            height: 60,
          )
        : new Container(
            width: 60,
            height: 60,
            decoration: new BoxDecoration(
                shape: BoxShape.circle,
                image: new DecorationImage(
                    fit: BoxFit.fill, image: new NetworkImage(url))),
          );
  }

  Widget getContactAvatar() {
    double totalLength = 90;
    List<Positioned> avatars = [];
    for (int userIndex = 0; userIndex < users.length; userIndex++) {
      avatars.add(
        Positioned(
          child: getSingleAvatar(
              users[userIndex].username, users[userIndex].userType),
          right: users.length - 1 == 0
              ? 0
              : ((totalLength - 60) * (userIndex / (users.length - 1))),
        ),
      );
    }
    return new Container(
      width: totalLength,
      height: 60,
      child: new Stack(alignment: Alignment.center, children: avatars),
    );
  }

  Widget getContactDetail() {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
      child: new Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new AutoSizeText(
              getContactTitle(),
              style: prefix0.getTextStyle(16, prefix0.Theme.onContactItemBg),
            ),
          ]),
    );
  }

  String getContactTitle() {
    if (users.length >= 3) {
      if (checkUser(StudentMainPage.studentUsername)) {
        return "گروه";
      } else {
        return "گروه (بدون دانش آموز)";
      }
    } else if (users.length == 2) {
      if (userType == 0) {
        return "دانش اموز";
      }
      if (userType == 1) {
        return "مشاور";
      }
    } else if (users.length == 1) {
      if (users[0].userType == "0") {
        return "کانال" + " " + "پشتیبان";
      } else if (users[0].userType == "00") {
        return "کانال" + " " + "مشاور";
      }
      return "کانال ";
    } else {
      return "";
    }
  }

  bool checkUser(String username) {
    for (int i = 0; i < users.length; i++) {
      if (users[i].username == username) {
        return true;
      }
    }
    return false;
  }
}
