import 'package:mhamrah/Values/Models.dart';

/// Simple pie chart with outside labels example.
import 'package:flutter/material.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';

class Circular2Chart extends StatelessWidget {
  List<CircularChartModel> data;
  List<CircularStackEntry> chartData = [];
  final bool animate;
  final double size;

  Circular2Chart.withSampleData(this.data, this.size, {this.animate});

  @override
  Widget build(BuildContext context) {
    chartData = _cycleSamples();
    return new AnimatedCircularChart(
      key: ValueKey("circular"),
      size: Size(size, size),
      initialChartData: chartData,
      chartType: CircularChartType.Pie,
      percentageValues: true,
      duration: Duration(seconds: 0),
      labelStyle: new TextStyle(
        color: Colors.blueGrey[600],
        fontWeight: FontWeight.bold,
        fontSize: 24.0,
      ),
    );
  }

  List<CircularStackEntry> _cycleSamples() {
    List<CircularSegmentEntry> res = [];
    double total = 0;
    for (int i = 0; i < data.length; i++) {
      total += data[i].value;
    }
    if (total == 0) {
      this.data = [new CircularChartModel("", 1, Color.fromARGB(0, 0, 0, 0))];
      total = 1;
    }
    for (int i = 0; i < data.length; i++) {
      res.add(CircularSegmentEntry(
          data[i].value.toDouble() / total * 100, data[i].color));
    }
    List<CircularStackEntry> nextData = <CircularStackEntry>[
      new CircularStackEntry(
        res,
        rankKey: 'Quarterly Profits',
      ),
    ];
    return nextData;
  }
}
