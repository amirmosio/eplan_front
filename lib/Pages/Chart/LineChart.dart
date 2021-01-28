/// Bar chart example
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:mhamrah/Values/Models.dart';
import 'package:mhamrah/Values/style.dart';
import 'package:flutter/material.dart';

class LineChart extends StatelessWidget {
  final bool animate;
  final List<BarAndLineChartDataPart> data;

  LineChart(this.data, {this.animate});

  factory LineChart.withSampleData(List<BarAndLineChartDataPart> data) {
    return new LineChart(
      data,
      // Disable animations for image tests.
      animate: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return charts.LineChart(
      _createSampleData(data),
      animationDuration: new Duration(milliseconds: 500),
      animate: animate,
      primaryMeasureAxis: new charts.NumericAxisSpec(
        renderSpec: charts.GridlineRendererSpec(
            labelStyle: charts.TextStyleSpec(
                fontSize: 15, color: charts.MaterialPalette.white),
            lineStyle: charts.LineStyleSpec(
              thickness: 0
            )),
      ),
      domainAxis: new charts.NumericAxisSpec(
        renderSpec: charts.GridlineRendererSpec(
            labelStyle: charts.TextStyleSpec(
                fontSize: 15, color: charts.MaterialPalette.white),
            lineStyle: charts.LineStyleSpec(
              thickness: 0
            )),
      ),
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<BarAndLineChartDataPart, int>> _createSampleData(
      List<BarAndLineChartDataPart> data) {
    return [
      new charts.Series<BarAndLineChartDataPart, int>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (BarAndLineChartDataPart sales, _) => int.parse(sales.year),
        measureFn: (BarAndLineChartDataPart sales, _) => sales.sales,
        data: data,
      )
    ];
  }
}

/// Sample ordinal data type.
