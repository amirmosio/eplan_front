import 'package:mhamrah/ConnectionService/HTTPService.dart';
import 'package:mhamrah/Pages/StudentMainPage.dart';
import 'package:mhamrah/Pages/User/FirstPage.dart';
import 'package:mhamrah/Utils/LocalFileUtils.dart';
import 'package:mhamrah/Values/style.dart' as prefix0;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChannelChatTitle extends StatefulWidget {
  ChannelChatTitle();

  static double titleHeight = 100 - 35 + FirstPage.androidTitleBarHeight;

  @override
  _ChatRoomTitlePart createState() => _ChatRoomTitlePart();
}

class _ChatRoomTitlePart extends State<ChannelChatTitle> {
  ConnectionService httpRequestService = new ConnectionService();
  int userType = 0;
  String username = "کانال";
  String imageUrl = "";

  _ChatRoomTitlePart();

  @override
  void initState() {
    super.initState();
//    LSM.getUserMode().then((type) {
//      setState(() {
//        userType = type;
//      });
//      if (userType == 0) {
//        setState(() {
//          imageUrl = httpRequestService
//              .getStudentImageURL(StudentMainPage.studentUsername);
//          username = StudentMainPage.studentUsername;
//        });
//      } else if (userType == 1) {
//        LSM.getStudent().then((student) {
//          setState(() {
//            imageUrl = httpRequestService.getStudentImageURL(student.username);
//            username = student.sub_consultant_username;
//          });
//        });
//      }
//    });
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      height: ChannelChatTitle.titleHeight,
      width: MediaQuery.of(context).size.height,
      decoration: new BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [prefix0.Theme.titleBar2, prefix0.Theme.titleBar1]),
        color: prefix0.Theme.titleBar1,
        borderRadius: new BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      alignment: Alignment.bottomCenter,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          getNameText(),
//          getContactAvatar(),
        ],
      ),
    );
  }

  Widget getNameText() {
    return Expanded(
      child: new Padding(
        padding: EdgeInsets.only(top: 15),
        child: Container(
          alignment: Alignment.center,
          child: Text(
            username,
            style: prefix0.getTextStyle(22, prefix0.Theme.onMainBGText),
          ),
        ),
      ),
    );
  }

  Widget getContactAvatar() {
    return new Container(
      width: 80,
      height: 80,
      margin: const EdgeInsets.all(10),
      decoration: new BoxDecoration(
          shape: BoxShape.circle,
          color: prefix0.Theme.cloudyBlue,
          image: new DecorationImage(
              fit: BoxFit.fill, image: new NetworkImage(imageUrl))),
    );
  }
}
