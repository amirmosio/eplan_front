/// Bar chart example
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:eplanfront/Values/Models.dart';
import 'package:flutter/material.dart';

class SimpleBarChart extends StatelessWidget {
  final bool animate;
  final List<OrdinalSales> data;

  SimpleBarChart(this.data, {this.animate});

  factory SimpleBarChart.withSampleData(List<OrdinalSales> data) {
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
      animate: animate,
      defaultRenderer: new charts.BarRendererConfig(),
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<OrdinalSales, String>> _createSampleData(
      List<OrdinalSales> data) {
    return [
      new charts.Series<OrdinalSales, String>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: data,
      )
    ];
  }
}

/// Sample ordinal data type.