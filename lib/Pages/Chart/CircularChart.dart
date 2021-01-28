/// Simple pie chart with outside labels example.
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:mhamrah/Values/Models.dart';
import 'package:mhamrah/Values/Models.dart';
import 'package:mhamrah/Values/Models.dart';
import 'package:mhamrah/Values/Utils.dart';
import 'package:mhamrah/Values/style.dart';
import 'package:flutter/material.dart';

class PieOutsideLabelChart extends StatelessWidget {
  final List<CircularChartModel> data;
  final bool animate;

  PieOutsideLabelChart(this.data, {this.animate});

  /// Creates a [PieChart] with sample data and no transition.
  factory PieOutsideLabelChart.withSampleData(List<CircularChartModel> data) {
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
            labelPosition: charts.ArcLabelPosition.inside,
            insideLabelStyleSpec: chartLabelTextStyle,
            outsideLabelStyleSpec: chartLabelTextStyle),
      ]),
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<CircularChartModel, String>> _createSampleData(
      List<CircularChartModel> data) {
    return [
      new charts.Series<CircularChartModel, String>(
        id: 'Sales',
        domainFn: (CircularChartModel sales, _) => sales.title,
        colorFn: (CircularChartModel sales, _) => getChartColor(sales.color),
        measureFn: (CircularChartModel sales, _) => sales.value,
        data: data,
        // Set a label accessor to control the text of the arc label.
        labelAccessorFn: (CircularChartModel row, _) =>
            '${""}', //just in case you don't want show labels
      )
    ];
  }
}
