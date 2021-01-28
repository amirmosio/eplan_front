/// Bar chart example
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:mhamrah/Values/Models.dart';
import 'package:mhamrah/Values/style.dart';
import 'package:flutter/material.dart';

class SimpleBarChart extends StatelessWidget {
  final bool animate;
  final List<BarAndLineChartDataPart> data;

  SimpleBarChart(this.data, {this.animate});

  factory SimpleBarChart.withSampleData(List<BarAndLineChartDataPart> data) {
    return new SimpleBarChart(
      data,
      // Disable animations for image tests.
      animate: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return charts.BarChart(
      _createSampleData(data),
      animationDuration: new Duration(milliseconds: 500),
      animate: animate,
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<BarAndLineChartDataPart, String>> _createSampleData(
      List<BarAndLineChartDataPart> data) {
    return [
      new charts.Series<BarAndLineChartDataPart, String>(
        id: 'Sales',
        insideLabelStyleAccessorFn: (BarAndLineChartDataPart sales, _) {
          final color = charts.MaterialPalette.white;
          return new charts.TextStyleSpec(color: color);
        },
        fillColorFn: (BarAndLineChartDataPart sales, _) => sales.color,
        domainFn: (BarAndLineChartDataPart sales, _) => sales.year,
        measureFn: (BarAndLineChartDataPart sales, _) => sales.sales,
        data: data,
      )
    ];
  }
}

/// Sample ordinal data type.
