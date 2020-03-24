import 'package:eplanfront/Pages/Chart/SimpleBarChart.dart';
import 'package:eplanfront/Pages/Chart/CircularChart.dart';
import 'package:eplanfront/Values/Models.dart';
import 'package:flutter/material.dart';

class StudentStudyChart extends StatefulWidget {
  final String title;
  final List<OrdinalSales> barChartData;
  final List<LinearSales> pieChartData;

  StudentStudyChart({Key key, this.title, this.barChartData, this.pieChartData})
      : super(key: key);

  @override
  _StudentChartState createState() => _StudentChartState(
      barChartData: barChartData, pieChartData: pieChartData);
}

class _StudentChartState extends State<StudentStudyChart> {
  final List<OrdinalSales> barChartData;
  final List<LinearSales> pieChartData;

  _StudentChartState({this.pieChartData, this.barChartData});

  Widget build(BuildContext context) {
    return Container(
      child: new SingleChildScrollView(
        child: new Column(
          verticalDirection: VerticalDirection.down,
          children: <Widget>[
            new Padding(
                padding: EdgeInsets.all(20),
                child: new Text("نمودار روزانه درسی؟؟؟",
                    style: TextStyle(color: Colors.black, fontSize: 15))),
            new Container(
              child: PieOutsideLabelChart.withSampleData(pieChartData),
              height: MediaQuery.of(context).size.width - 50,
              width: MediaQuery.of(context).size.width,
            ),
            new Padding(
                padding: EdgeInsets.all(20),
                child: new Text("نمودار روزانه ?؟؟؟",
                    style: TextStyle(color: Colors.black, fontSize: 15))),
            new Container(
              child: SimpleBarChart.withSampleData(barChartData),
              height: 300,
              width: MediaQuery.of(context).size.width,
            )
          ],
        ),
      ),
    );
  }

  Widget getTitleText(String title) {
    return new Padding(
        padding: EdgeInsets.fromLTRB(30, 50, 30, 50),
        child: new Center(
            child: Text(title,
                style: TextStyle(fontSize: 25, color: Colors.black))));
  }
}
