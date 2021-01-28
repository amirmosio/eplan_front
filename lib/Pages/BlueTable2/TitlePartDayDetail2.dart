import 'package:auto_size_text/auto_size_text.dart';
import 'package:mhamrah/Pages/BlueTable2/BlueTable2.dart';
import 'package:mhamrah/Values/string.dart';
import 'package:mhamrah/Values/style.dart' as prefix0;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class Blue2DayDetail extends StatefulWidget {
  final int dayIndex;
  final String dayDate;
  final BlueTable2State b2;

  const Blue2DayDetail(this.dayIndex, this.dayDate, this.b2, {Key key})
      : super(key: key);

  @override
  _Blue2DayDetailState createState() {
    return _Blue2DayDetailState(dayIndex, dayDate, b2);
  }
}

class _Blue2DayDetailState extends State<Blue2DayDetail> {
  int dayIndex;
  String dayDate;
  BlueTable2State b;
  double xSize;
  double ySize;

  _Blue2DayDetailState(this.dayIndex, this.dayDate, this.b);

  @override
  Widget build(BuildContext context) {
    xSize = MediaQuery.of(context).size.width;
    ySize = MediaQuery.of(context).size.height;
    String dayName = daysType2[daysType2.length - dayIndex - 1];
    return new Padding(
      padding: EdgeInsets.all(3),
      child:  Column(
        children: <Widget>[
          new Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              new Container(
                height: (MediaQuery.of(context).size.height * (9.3 / 100)) +
                    ((6 - b.selectedDay == dayIndex) ? 10 : 0),
                width: (dayIndex == 6 || dayIndex == 0)
                    ? xSize / 7.6 + ((6 - b.selectedDay == dayIndex) ? 5 : 0)
                    : xSize / 10 + ((6 - b.selectedDay == dayIndex) ? 5 : 0),
                decoration: new BoxDecoration(
                  color: prefix0.Theme.dayDetailBG,
                  borderRadius: new BorderRadius.all(
                    Radius.circular(15),
                  ),
                ),
              ),
              new Container(
                height: (MediaQuery.of(context).size.height * (9.3 / 100)) +
                    ((6 - b.selectedDay == dayIndex) ? 10 : 0),
                width: (dayIndex == 6 || dayIndex == 0)
                    ? xSize / 7 + ((6 - b.selectedDay == dayIndex) ? 5 : 0)
                    : xSize / 9.5 + ((6 - b.selectedDay == dayIndex) ? 5 : 0),
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
                        style: prefix0.getTextStyle(
                            (dayIndex == 6 || dayIndex == 0)
                                ? (kIsWeb ? 17 : 19)
                                : (kIsWeb ? 22 : 25),
                            prefix0.Theme.onTitleBarText),
                      )
                    ),
                    new Padding(
                      padding: EdgeInsets.only(top: 0, right: 5, left: 5),
                      child: AutoSizeText(
                        dayDate,
                        style:
                            prefix0.getTextStyle(12, prefix0.Theme.onTitleBarText),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
          b.selectedDay == 6 - dayIndex
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
    ;
  }
}
