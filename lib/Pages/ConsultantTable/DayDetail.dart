import 'package:mhamrah/Pages/BlueTable1/BlueTable1.dart';
import 'package:mhamrah/Pages/BlueTable2/BlueTable2.dart';
import 'package:mhamrah/Pages/ConsultantTable/ConsultantTable.dart';
import 'package:mhamrah/Values/string.dart';
import 'package:mhamrah/Values/style.dart' as prefix0;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';

class DayDetail extends StatefulWidget {
  final ConsultantTableState c;
  final BlueTable1State b1;
  final BlueTable2State b2;
  final int dayIndex;

  const DayDetail(this.c, this.b1, this.b2, this.dayIndex, {Key key})
      : super(key: key);

  @override
  _DayDetailState createState() {
    return _DayDetailState(c, b1, b2, dayIndex);
  }
}

class _DayDetailState extends State<DayDetail> {
  ConsultantTableState c;
  BlueTable1State b1;
  BlueTable2State b2;
  int dayIndex;
  double xSize;
  double ySize;

  _DayDetailState(this.c, this.b1, this.b2, this.dayIndex);

  @override
  Widget build(BuildContext context) {
    int selectedDay = 0;
    if (c != null) {
      selectedDay = c.selectedDay;
    } else if (b1 != null) {
      selectedDay = b1.selectedDay;
    } else if (b2 != null) {
      selectedDay = b2.selectedDay;
    }
    int percent = 0;
    try {
      percent = c
          .consultantTableData.daysSchedule[daysType2.length - dayIndex - 1]
          .getCompletePercent();
    } catch (e) {}

    String dayName = daysType2[daysType2.length - dayIndex - 1];
    String dayDate = "";
    try {
      dayDate =
          c.consultantTableData.getDaysDate()[daysType2.length - dayIndex - 1];
    } catch (e) {}
    try {
      dayDate =
          b1.blueTable1Data.getDaysDate()[daysType2.length - dayIndex - 1];
    } catch (e) {}
    try {
      dayDate =
          b2.blueTable2Data.getDaysDate()[daysType2.length - dayIndex - 1];
    } catch (e) {}
    xSize = MediaQuery.of(context).size.width;
    ySize = MediaQuery.of(context).size.height;
    return new Padding(
      padding: EdgeInsets.all(3),
      child: Column(
        children: <Widget>[
          new Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              new Container(
                height: (MediaQuery.of(context).size.height * (9.3 / 100)) +
                    (((6 - selectedDay) == dayIndex) ? 10 : 0),
                width: (dayIndex == 6 || dayIndex == 0)
                    ? xSize / 7.6 + ((6 - selectedDay == dayIndex) ? 5 : 0)
                    : xSize / 10 + ((6 - selectedDay == dayIndex) ? 5 : 0),
                decoration: new BoxDecoration(
                  color: prefix0.Theme.dayDetailBG,
                  borderRadius: new BorderRadius.all(
                    Radius.circular(15),
                  ),
                ),
              ),
              Column(
                children: <Widget>[
                  new Container(
                    padding: EdgeInsets.all(1),
                    height: (ySize * (8.5 / 100) +
                            ((6 - selectedDay == dayIndex) ? 10 : 0)) *
                        (percent / 100),
                    width: (dayIndex == 6 || dayIndex == 0)
                        ? xSize / 8.5 + ((6 - selectedDay == dayIndex) ? 5 : 0)
                        : xSize / 11 + ((6 - selectedDay == dayIndex) ? 5 : 0),
                    decoration: new BoxDecoration(
                      color: prefix0.Theme.dayDetailHighlight,
                      borderRadius: new BorderRadius.all(
                        Radius.circular(15),
                      ),
                    ),
                  ),
                  Container(
                    height: 3,
                  ),
                ],
              ),
              new Container(
                height: (MediaQuery.of(context).size.height * (9.3 / 100)) +
                    ((6 - selectedDay == dayIndex) ? 10 : 0),
                width: (dayIndex == 6 || dayIndex == 0)
                    ? xSize / 7 + ((6 - selectedDay == dayIndex) ? 5 : 0)
                    : xSize / 9.5 + ((6 - selectedDay == dayIndex) ? 5 : 0),
                decoration: new BoxDecoration(
                  borderRadius: new BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    new Padding(
                      padding: EdgeInsets.only(top: 0, bottom: 0),
                      child: AutoSizeText(
                        dayName,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.fade,
                        softWrap: true,
                        wrapWords: true,
                        style: prefix0.getTextStyle(
                            (dayIndex == 6 || dayIndex == 0)
                                ? (kIsWeb ? 17 : 19)
                                : (kIsWeb ? 22 : 25),
                            prefix0.Theme.onTitleBarText),
                      ),
                    ),
                    new Padding(
                      padding:
                          EdgeInsets.only(top: 0, bottom: 0, right: 5, left: 5),
                      child: AutoSizeText(
                        dayDate,
                        style: prefix0.getTextStyle(
                            12, prefix0.Theme.onTitleBarText),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
          selectedDay == 6 - dayIndex
              ? Padding(
                  padding: EdgeInsets.only(top: 2, bottom: 5),
                  child: Icon(
                    Icons.done,
                    size: 17,
                    color: prefix0.Theme.onTitleBarText,
                  ),
                )
              : SizedBox(),
        ],
      ),
    );
  }
}
