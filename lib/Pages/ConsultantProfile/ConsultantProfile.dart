import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:mhamrah/ConnectionService/ConsultantProfileSRV.dart';
import 'package:mhamrah/Models/UserMV.dart';
import 'package:mhamrah/Pages/ConsultantMainPage.dart';
import 'package:mhamrah/Pages/ConsultantProfile/EditConsultantProfile.dart';
import 'package:mhamrah/Pages/ConsultantProfile/PaymentPage.dart';
import 'package:mhamrah/Pages/SharedProfile/LeagueList.dart';
import 'package:mhamrah/Pages/Support/Support.dart';
import 'package:mhamrah/Pages/User/FirstPage.dart';
import 'package:mhamrah/Utils/LocalFileUtils.dart';
import 'package:mhamrah/Utils/SnackAnFlushBarUtils.dart';
import 'package:mhamrah/Utils/SocketUtils.dart';
import 'package:mhamrah/Values/Models.dart';
import 'package:mhamrah/Values/Utils.dart';
import 'package:mhamrah/Values/string.dart';
import 'package:mhamrah/Values/style.dart' as prefix0;
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import 'ConsultantProfileTitleBar.dart';

class ConsultantProfile extends StatefulWidget {
  ConsultantProfile({
    Key key,
  }) : super(key: key);

  @override
  ConsultantProfileState createState() => ConsultantProfileState();
}

class ConsultantProfileState extends State<ConsultantProfile>  with TickerProviderStateMixin {
  ConsultantProfileSRV consultantProfileSRV = ConsultantProfileSRV();
  String teacherName = "";
  String bio = "کارشناس مشاور";
  String description = "";
  double xSize;
  double ySize;
  List<BarAndLineChartDataPart> studentHistory = [];

  bool supportFragToggle = false;
  Timer socketTimer;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();

    /// fetching data
    fetchConsultantChartData();
    LSM.getConsultant().then((consultant) {
      /// Connection checker
      socketConnectionChecker(
              [consultant.username], this, () {}, fetchConsultantChartData)
          .then((value) {
        socketTimer = value;
      });

      /// setting data
      setState(() {
        teacherName = consultant.first_name + " " + consultant.last_name;
        description = consultant.description;
        if (description == null) {
          description = "";
        }
      });
    });
  }

  Widget build(BuildContext context) {
    xSize = MediaQuery.of(context).size.width;
    ySize = MediaQuery.of(context).size.height;
    Consultant consultant = LSM.getConsultantSync();
    if (consultant != null) {
      teacherName = consultant.first_name + " " + consultant.last_name;
      description = consultant.description;
    }
    if (description == null) {
      description = "";
    }

    double remainHeight = ySize -
        ConsultantMainPageState.tabHeight -
        (30 - 35 / 2 + FirstPage.androidTitleBarHeight / 2 + 126);
    return new Stack(
      children: <Widget>[
        new Container(
            color: prefix0.Theme.mainBG,
            height: MediaQuery.of(context).size.height -
                ConsultantMainPageState.tabHeight,
            width: MediaQuery.of(context).size.width,
            child: new Column(
              children: <Widget>[
                new ProfileTitlePart(this),
                Container(
                  height: remainHeight,
                  child: SingleChildScrollView(
                    child: new Container(
                      height: remainHeight + 2,
                      child: new SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: new Column(
                            verticalDirection: VerticalDirection.down,
                            children: <Widget>[
                              getConsultantName(),
                              getConsultantBio(),
                              getConsultantDescription(),
                              getEditButton(),
                              getItemIcons(),
//                    getStudentChart()
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
//            getBottomNavigationBar()
              ],
            )),
        Visibility(
          child: SupportFragment.Consultant(this),
          visible: supportFragToggle,
        )
      ],
    );
  }

  void closeSupportFragment() {
    setState(() {
      supportFragToggle = false;
    });
  }

//
//  Widget getStudentChart() {
//    return new Container(
//      child: LineChart.withSampleData(studentHistory),
//      height: 200,
//      width: MediaQuery.of(context).size.width,
//    );
//  }

  Widget getEditButton() {
    return Padding(
      padding: EdgeInsets.only(left: 50, right: 50, top: 10, bottom: 10),
      child: Container(
        child: new Row(
          children: <Widget>[
            new Expanded(
              child: Container(
                height: 2,
                color: Colors.white,
              ),
            ),
            GestureDetector(
              child: new Container(
                padding:
                    EdgeInsets.only(left: 10, right: 18, top: 5, bottom: 5),
                child: AutoSizeText(
                  "ویرایش",
                  style: prefix0.getTextStyle(18, prefix0.Theme.onApplyButton),
                ),
                decoration: new BoxDecoration(
                  color: prefix0.Theme.applyButton,
                  borderRadius: new BorderRadius.all(
                    Radius.circular(25),
                  ),
                ),
              ),
              onTap: () {
                navigateToSubPage(context, EditConsultantProfile());
              },
            ),
            new Expanded(
              child: Container(
                height: 2,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getItemIcons() {
    double iconsSize = xSize * (25 / 100);
    return Padding(
      padding: EdgeInsets.all(10),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          GestureDetector(
            child: new Container(
              decoration: new BoxDecoration(
                  borderRadius: new BorderRadius.all(Radius.circular(15)),
                  color: Colors.white),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                      child: ImageIcon(
                    AssetImage("assets/img/11.png"),
                    color: prefix0.Theme.blueIcon,
                    size: iconsSize,
                  )),
                  Container(
                      child: AutoSizeText(
                    contactUs,
                    style: prefix0.getTextStyle(15, prefix0.Theme.blueIcon),
                  ))
                ],
              ),
            ),
            onTap: () {
              setState(() {
                supportFragToggle = true;
              });
            },
          ),
          GestureDetector(
            child: new Container(
              decoration: new BoxDecoration(
                  borderRadius: new BorderRadius.all(Radius.circular(15)),
                  color: Colors.white),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                      child: ImageIcon(
                    AssetImage("assets/img/11.png"),
                    color: prefix0.Theme.blueIcon,
                    size: iconsSize,
                  )),
                  Container(
                      child: AutoSizeText(
                    leagueTitle,
                    style: prefix0.getTextStyle(15, prefix0.Theme.blueIcon),
                  ))
                ],
              ),
            ),
            onTap: () {
              showLeaguePage();
            },
          ),
//          GestureDetector(
//            child: new Container(
//              decoration: new BoxDecoration(
//                  borderRadius: new BorderRadius.all(Radius.circular(15)),
//                  color: Colors.white),
//              child: Column(
//                children: <Widget>[
//                  Container(
//                      child: ImageIcon(
//                    AssetImage("assets/img/14.png"),
//                    color: prefix0.Theme.blueIcon,
//                    size: iconsSize,
//                  )),
//                  Container(
//                    child: AutoSizeText(examTitle,
//                        style:
//                            prefix0.getTextStyle(15, prefix0.Theme.blueIcon)),
//                  )
//                ],
//              ),
//            ),
//            onTap: () {
//              showFlutterToastWithFlushBar("این قسمت بزودی اماده می شود.");
//            },
//          ),
//          GestureDetector(
//            child: new Container(
//                decoration: new BoxDecoration(
//                    borderRadius: new BorderRadius.all(Radius.circular(15)),
//                    color: Colors.white),
//                child: Column(
//                  crossAxisAlignment: CrossAxisAlignment.center,
//                  children: <Widget>[
//                    Container(
//                        child: ImageIcon(
//                      AssetImage("assets/img/14.png"),
//                      color: prefix0.Theme.blueIcon,
//                      size: iconsSize,
//                    )),
//                    Container(
//                      width: iconsSize,
//                      alignment: Alignment.center,
//                      child: AutoSizeText(
//                        "صورت حساب",
//                        style: prefix0.getTextStyle(15, prefix0.Theme.blueIcon),
//                      ),
//                    )
//                  ],
//                )),
//            onTap: showPaymentPage,
//          )
        ],
      ),
    );
  }

  void showLeaguePage() {
    LeagueList leagueList = LeagueList(context,this);
    leagueList.showLeagueListDialog();
  }

  void showPaymentPage() {
    Widget d = BackdropFilter(
      filter: prefix0.Theme.fragmentBGFilter,
      child: new AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(25),
            ),
          ),
          backgroundColor: Color.fromARGB(0, 0, 0, 0),
          content: StatefulBuilder(
            builder: (context, setState) {
              return PaymentPage();
            },
          )),
    );

    showDialog(context: context, child: d, barrierDismissible: true);
  }

  Widget getConsultantDescription() {
    return new Padding(
      padding: EdgeInsets.only(left: 50, right: 50, top: 20, bottom: 10),
      child: Container(
        child: AutoSizeText(
          description,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
          softWrap: true,
          textScaleFactor: 1.1,
          style: TextStyle(
              fontSize: 18,
              color: prefix0.Theme.onMainBGText,
              fontFamily: 'traffic',
              fontWeight: FontWeight.w700,
              height: 1.6),
        ),
      ),
    );
  }

  Widget getConsultantBio() {
    return new Padding(
      padding: EdgeInsets.all(10),
      child: Container(
        child: AutoSizeText(
          bio,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
          style: prefix0.getTextStyle(18, prefix0.Theme.onMainBGText),
        ),
      ),
    );
  }

  Widget getConsultantName() {
    return new Padding(
      padding: EdgeInsets.all(10),
      child: new Container(
        child: AutoSizeText(
          teacherName,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
          style: prefix0.getTextStyle(22, prefix0.Theme.onMainBGText),
        ),
      ),
    );
  }

  void fetchConsultantChartData() {
    LSM.getConsultant().then((consultant) {
      consultantProfileSRV
          .getStudentChartData(
              consultant.username, consultant.authentication_string)
          .then((chart_data_list) {
        List<BarAndLineChartDataPart> res = [];
        for (int index = 0; index < chart_data_list.length; index++) {
          BarAndLineChartDataPart b = BarAndLineChartDataPart(
              chart_data_list[index]['day_number'].toString(),
              chart_data_list[index]['student_count'],
              charts.Color.fromHex(code: "#505050"));

          res.add(b);
        }
        setState(() {
          studentHistory = res;
        });
      });
    });
  }

  @override
  void dispose() {
    if (socketTimer != null) {
      socketTimer.cancel();
    }
    super.dispose();
  }
}
