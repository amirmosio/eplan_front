import 'package:mhamrah/Values/style.dart';
import 'package:flutter/cupertino.dart';

/// Bar chart example
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/src/material/theme.dart' as theme;

/// Example of a stacked bar chart with three series, each rendered with
/// different fill colors.
class PhoneUsageStackedFillChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  PhoneUsageStackedFillChart(this.seriesList, {this.animate});

  factory PhoneUsageStackedFillChart.withSampleData(
      Map<String, List<dynamic>> data) {
    return new PhoneUsageStackedFillChart(
      _processInitialData(data),
      // Disable animations for image tests.
      animate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    var labelColor = charts.Color.fromHex(code: '#FFFF7D');
    return new charts.BarChart(
      seriesList,
      animate: animate,
      primaryMeasureAxis: charts.NumericAxisSpec(
          renderSpec: charts.GridlineRendererSpec(
        labelStyle: charts.TextStyleSpec(
            fontSize: 10,
            color: labelColor), //chnage white color as per your requirement.
      )),
      domainAxis: new charts.OrdinalAxisSpec(
          renderSpec: charts.GridlineRendererSpec(
        labelStyle: charts.TextStyleSpec(
            fontSize: 10,
            color: labelColor), //chnage white color as per your requirement.
      )),
      defaultRenderer: new charts.BarRendererConfig(
          groupingType: charts.BarGroupingType.stacked, strokeWidthPx: 3.0),
    );
  }

  /// Create series list with multiple series
  static List<charts.Series<OrdinalSales, String>> _processInitialData(
      Map<String, List<dynamic>> data) {
    List<double> normalizeAppUsagePerDay(
        double myAppSec, double socialAppSec, double otherAppSec) {
      double myAppHours = (myAppSec / 3600);
      double socialAppHours = (socialAppSec / 3600);
      double otherAppHours = (otherAppSec / 3600);
      double totalHours = myAppHours + socialAppHours + otherAppHours;
      otherAppHours *= (85 / 100);

      if (totalHours > 18) {
        myAppHours *= (18 / totalHours);
        socialAppHours *= (18 / totalHours);
        otherAppHours *= (18 / totalHours);
      }
      return <double>[myAppHours, socialAppHours, otherAppHours];
    }

    List<OrdinalSales> myAppUsage = [];
    List<OrdinalSales> socialAppUsage = [];

    List<OrdinalSales> otherAppUsage = [];

    List keysList = data.keys.toList();
    for (int dateIndex = 0; dateIndex < keysList.length; dateIndex++) {
      String dateString = keysList[keysList.length - dateIndex - 1];
      List<double> hours = normalizeAppUsagePerDay(
          data[dateString][0], data[dateString][1], data[dateString][2]);
      double myAppMin = hours[0];
      double socialAppMin = hours[1];
      double otherAppsMin = hours[2];

      print(myAppMin);
      print(socialAppMin);
      print(otherAppsMin);
      print("&&");

      OrdinalSales myApp =
          OrdinalSales(dateString.split("/")[2], myAppMin.round());
      myAppUsage.add(myApp);

      OrdinalSales socialApp =
          OrdinalSales(dateString.split("/")[2], socialAppMin.round());
      socialAppUsage.add(socialApp);

      OrdinalSales otherApp =
          OrdinalSales(dateString.split("/")[2], otherAppsMin.round());
      otherAppUsage.add(otherApp);
    }

    return [
      // Blue bars with a lighter center color.
      new charts.Series<OrdinalSales, String>(
        id: 'Mhamrah',
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: myAppUsage,
        colorFn: (_, __) => charts.Color.transparent,
        fillColorFn: (_, __) =>
            charts.MaterialPalette.blue.shadeDefault.lighter,
      ),
      new charts.Series<OrdinalSales, String>(
        id: 'social',
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: socialAppUsage,
        colorFn: (_, __) => charts.Color.transparent,
        fillColorFn: (_, __) => charts.MaterialPalette.red.shadeDefault.lighter,
      ),
      new charts.Series<OrdinalSales, String>(
        id: 'Others',
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: otherAppUsage,
        colorFn: (_, __) => charts.Color.transparent,
        fillColorFn: (_, __) =>
            charts.MaterialPalette.gray.shadeDefault.lighter,
        domainFn: (OrdinalSales sales, _) => sales.year,
      ),
    ];
  }
}

/// Sample ordinal data type.
class OrdinalSales {
  final String year;
  final int sales;

  OrdinalSales(this.year, this.sales);
}
