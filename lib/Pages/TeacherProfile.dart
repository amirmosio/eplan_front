import 'package:flutter/material.dart';

class TeacherProfile extends StatefulWidget {
  final String teacherName;
  final String teacherBio;
  final String teacherProFileURL;

  TeacherProfile(
      {Key key,
      @required this.teacherName,
      @required this.teacherBio,
      @required this.teacherProFileURL})
      : super(key: key);

  @override
  _TeacherProfileState createState() =>
      _TeacherProfileState(teacherName, teacherBio, teacherProFileURL);
}

class _TeacherProfileState extends State<TeacherProfile>
    with TickerProviderStateMixin {
  bool toggle;
  String name;
  String bio;
  String profileURL;

  _TeacherProfileState(this.name, this.bio, this.profileURL);

  @override
  void initState() {
    super.initState();
    toggle = true;
  }

  BoxDecoration getBackGroundBoxDecor() {
    return BoxDecoration(
        image: DecorationImage(
            image: AssetImage("assets/img/start_page.jpg"), fit: BoxFit.cover));
  }

  Widget build(BuildContext context) {
    return new Column(
      verticalDirection: VerticalDirection.down,
      children: <Widget>[
        getTeacherProfile(profileURL),
        getTeacherName(name),
        getTeacherBio(bio)
      ],
    );
  }

  Widget getTeacherProfile(String url) {
    return new Center(
      child: new Container(
        padding: EdgeInsets.all(20),
        child: new CircleAvatar(
          radius: 80,
          child:Image.network(url)
//          child: Image.asset('assets/img/pro.'),
        ),
      ),
    );
  }

  Widget getTeacherName(String name) {
    return new Container(
      padding: EdgeInsets.all(20),
      child: Center(
        child: new Text(
          name,
          style: new TextStyle(color: Colors.black, fontSize: 20),
        ),
      ),
    );
  }

  Widget getTeacherBio(String bio) {
    return new Padding(
      padding: EdgeInsets.all(20),
      child: new Center(
        child: new Container(
          padding: EdgeInsets.all(20),
          child: Text(
            bio,
            textDirection: TextDirection.rtl,
            style: new TextStyle(color: Colors.black, fontSize: 15),
          ),
          decoration: new BoxDecoration(
              borderRadius: new BorderRadius.all(Radius.circular(10)),
              color: Colors.blueGrey),
        ),
      ),
    );
  }
}
