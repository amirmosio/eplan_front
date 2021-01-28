import 'package:auto_size_text/auto_size_text.dart';
import 'package:mhamrah/ConnectionService/HTTPService.dart';
import 'package:mhamrah/Pages/StudentMainPage.dart';
import 'package:mhamrah/Pages/User/FirstPage.dart';
import 'package:mhamrah/Utils/LocalFileUtils.dart';
import 'package:mhamrah/Values/string.dart';
import 'package:mhamrah/Values/style.dart' as prefix0;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatRoomTitlePart extends StatefulWidget {
  List<String> usernames;
  StudentMainPageState studentMainPageState;

  ChatRoomTitlePart(this.usernames, this.studentMainPageState);

  @override
  _ChatRoomTitlePart createState() =>
      _ChatRoomTitlePart(usernames, studentMainPageState);
}

class _ChatRoomTitlePart extends State<ChatRoomTitlePart> {
  ConnectionService httpRequestService = new ConnectionService();
  int userType = 0;
  List<String> usernames;
  String chatRoomTitle = "";

  StudentMainPageState studentMainPageState;
  String imageUrl = "";

  _ChatRoomTitlePart(this.usernames, this.studentMainPageState);

  @override
  void initState() {
    super.initState();
    LSM.getUserMode().then((type) {
      setState(() {
        userType = type;
      });
      if (usernames.length == 1) {
        setState(() {
          chatRoomTitle = usernames[0];
        });
        if (userType == 0) {
          setState(() {
            imageUrl = httpRequestService.getStudentImageURL(usernames[0]);
          });
        } else if (userType == 1) {
          setState(() {
            imageUrl = httpRequestService.getConsultantImageURL(usernames[0]);
          });
        }
      } else if (usernames.length == 2) {
        if (userType == 0) {
          LSM.getConsultant().then((consultant) {
            int index = -1;
            if (usernames[0] == consultant.username) {
              index = 1;
            } else {
              index = 0;
            }
            setState(() {
              chatRoomTitle = usernames[index];
              imageUrl =
                  httpRequestService.getStudentImageURL(usernames[index]);
            });
          });
        } else if (userType == 1) {
          LSM.getStudent().then((consultant) {
            int index = -1;
            if (usernames[0] == consultant.username) {
              index = 1;
            } else {
              index = 0;
            }
            setState(() {
              chatRoomTitle = usernames[index];
              imageUrl =
                  httpRequestService.getConsultantImageURL(usernames[index]);
            });
          });
        }
      } else if (usernames.length == 3) {
        setState(() {
          imageUrl = "";
          chatRoomTitle = "گروه" + "\n" + "مشاور، پدر، مادر";
        });
      } else if (usernames.length == 4) {
        if (usernames.contains(StudentMainPage.studentUsername)) {
          setState(() {
            imageUrl = "";
            chatRoomTitle = "گروه" + "\n" + "مشاور، دانش آموز، پدر، مادر";
          });
        } else {
          setState(() {
            imageUrl = "";
            chatRoomTitle = "گروه" + "\n" + "مشاور، پشتیبان، پدر، مادر";
          });
        }
      } else if (usernames.length == 5) {
        setState(() {
          imageUrl = "";
          chatRoomTitle =
              "گروه" + "\n" + "مشاور، دانش آموز، پشتیبان" + "\n" + " پدر، مادر";
        });
      } else {
        setState(() {
          imageUrl = "";
          chatRoomTitle = "گروه";
        });
      }
//      if (userType == 0) {
//        setState(() {
//          imageUrl = httpRequestService
//              .getStudentImageURL(StudentMainPage.studentUsername);
//          chatRoomTitle = StudentMainPage.studentUsername;
//        });
//      } else if (userType == 1) {
//        LSM.getStudent().then((student) {
//          setState(() {
//            imageUrl = httpRequestService.getStudentImageURL(student.username);
//            chatRoomTitle = student.sub_consultant_username;
//          });
//        });
//      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      height: 100 - 35 / 2 + FirstPage.androidTitleBarHeight / 2,
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
//          getButtons(),
          getNameText(),
          getContactAvatar(),
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
          child: AutoSizeText(
            chatRoomTitle,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: prefix0.getTextStyle(20, prefix0.Theme.onMainBGText,height: 1.5),
          ),
        ),
      ),
    );
  }

  Widget getContactAvatar() {
    return new Container(
      width: 80,
      height: 80,
      margin: const EdgeInsets.all(5),
      decoration: new BoxDecoration(
          shape: BoxShape.circle,
          color: prefix0.Theme.cloudyBlue,
          image: new DecorationImage(
              fit: BoxFit.fill, image: new NetworkImage(imageUrl))),
    );
  }

  Widget getButtons() {
    return new Column(
      children: <Widget>[
        new Container(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              studentMainPageState.chatContactListPage();
            },
          ),
        ),
        new Row(
          children: <Widget>[
            new Container(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: Icon(Icons.call),
                onPressed: () {
                  studentMainPageState.chatContactListPage();
                },
              ),
            ),
            new Container(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: Icon(Icons.videocam),
                onPressed: () {
                  studentMainPageState.chatContactListPage();
                },
              ),
            )
          ],
        )
      ],
    );
  }
}
