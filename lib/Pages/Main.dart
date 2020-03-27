import 'package:eplanfront/Pages/TeacherTable/TeacherTableRowFields.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'FirstPage.dart';

MyApp myApp = MyApp();

void main() => runApp(myApp);

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FirstPage(title: 'Flutter Demo Home Page'),
//      home: TeacherTableRows(dayName: "شنبه"),
    );
  }
}
