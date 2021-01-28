//import 'package:mhamrah/Pages/Chart/SimpleBarChart.dart';
//import 'package:mhamrah/Pages/Chart/CircularChart.dart';
//import 'package:mhamrah/Values/Models.dart';
//import 'package:mhamrah/Values/style.dart';
//import 'package:flutter/material.dart';
//
//class StudentStudyChart extends StatefulWidget {
//  final List<BarAndLineChartDataPart> barChartData;
//  final List<LinearSales> pieChartData;
//
//  StudentStudyChart(
//    this.barChartData,
//    this.pieChartData, {
//    Key key,
//  }) : super(key: key);
//
//  @override
//  _StudentChartState createState() => _StudentChartState(
//      barChartData: barChartData, pieChartData: pieChartData);
//}
//
//class _StudentChartState extends State<StudentStudyChart> {
//  final List<BarAndLineChartDataPart> barChartData;
//  final List<LinearSales> pieChartData;
//
//  _StudentChartState({this.pieChartData, this.barChartData});
//
//  Widget build(BuildContext context) {
//    return Container(
//      child: new SingleChildScrollView(
//        child: new Column(
//          verticalDirection: VerticalDirection.down,
//          children: <Widget>[
//            new Padding(
//                padding: EdgeInsets.all(20),
//                child: new Text("نمودار روزانه درسی",
//                    style:
//                        TextStyle(color: CustomTheme.theme[3], fontSize: 15))),
//            new Container(
//              child: PieOutsideLabelChart.withSampleData(pieChartData),
//              height: MediaQuery.of(context).size.width - 50,
//              width: MediaQuery.of(context).size.width,
//            ),
//            new Padding(
//                padding: EdgeInsets.all(20),
//                child: new Text("نمودار هفتگی",
//                    style:
//                        TextStyle(color: CustomTheme.theme[3], fontSize: 15))),
//            new Container(
//              child: SimpleBarChart.withSampleData(barChartData),
//              height: 300,
//              width: MediaQuery.of(context).size.width,
//            )
//          ],
//        ),
//      ),
//    );
//  }
//
//  Widget getTitleText(String title) {
//    return new Padding(
//        padding: EdgeInsets.fromLTRB(30, 50, 30, 50),
//        child: new Center(
//            child: Text(title,
//                style: TextStyle(fontSize: 25, color: CustomTheme.theme[3]))));
//  }
//}
