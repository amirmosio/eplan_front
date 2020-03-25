import 'package:flutter/cupertino.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

TextStyle buttonTextStyle = TextStyle(fontSize: 22.0, color: Colors.black);

charts.TextStyleSpec chartLabelTextStyle = new charts.TextStyleSpec(
    fontSize: 14,color: charts.MaterialPalette.black);


Widget getTitleText(String title) {
  return new Padding(
      padding: EdgeInsets.fromLTRB(30, 50, 30, 50),
      child: new Center(
          child: Text(title,
              style: TextStyle(fontSize: 25, color: Colors.black))));
}
