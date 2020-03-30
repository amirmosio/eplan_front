/// Simple pie chart with outside labels example.
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:eplanfront/Values/Models.dart';
import 'package:eplanfront/Values/Models.dart';
import 'package:eplanfront/Values/Models.dart';
import 'package:eplanfront/Values/style.dart';
import 'package:flutter/material.dart';

class PieOutsideLabelChart extends StatelessWidget {
  final List<LinearSales> data;
  final bool animate;

  PieOutsideLabelChart(this.data, {this.animate});

  /// Creates a [PieChart] with sample data and no transition.
  factory PieOutsideLabelChart.withSampleData(List<LinearSales> data) {
    return new PieOutsideLabelChart(
      data,
      // Disable animations for image tests.
      animate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new charts.PieChart(
      _createSampleData(data),
      animate: animate,
      defaultRenderer: new charts.ArcRendererConfig(arcRendererDecorators: [
        new charts.ArcLabelDecorator(
            labelPosition: charts.ArcLabelPosition.auto,
            insideLabelStyleSpec: chartLabelTextStyle,
            outsideLabelStyleSpec: chartLabelTextStyle),
      ]),
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<LinearSales, String>> _createSampleData(
      List<LinearSales> data) {
    return [
      new charts.Series<LinearSales, String>(
        id: 'Sales',
        domainFn: (LinearSales sales, _) => sales.year,
        colorFn: (LinearSales sales, _) => sales.color,
        measureFn: (LinearSales sales, _) => sales.sales,
        data: data,
        // Set a label accessor to control the text of the arc label.
        labelAccessorFn: (LinearSales row, _) => '${row.year}',
      )
    ];
  }
}
