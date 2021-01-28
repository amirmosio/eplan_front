import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mhamrah/Pages/User/FirstPage.dart';
import 'package:mhamrah/Utils/AutoTextUtils.dart';
import 'package:mhamrah/Values/Utils.dart';
import 'package:mhamrah/Values/style.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:mhamrah/Values/style.dart' as prefix0;

import 'VibrateUtils.dart';

void showTryingToConnectSnackBar(double snackContentHeight, double fontSize) {
  SnackBar snackBar = SnackBar(
    content: Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              removeSnackBars();
            },
            child: Padding(
              padding: EdgeInsets.only(right: 10, left: 10),
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      color: prefix0.Theme.onSnackBarButton),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: prefix0.Theme.onSnackBarButtonText,
                  )
//                AutoSizeText(
//                  "باشه",
//                  style: getTextStyle(
//                      fontSize, prefix0.Theme.onSnackBarButtonText),
//                ),
                  ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'تلاش برای اتصال ...',
                style: getTextStyle(fontSize, prefix0.Theme.onSnackBarText),
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
              ),
              Padding(
                padding: EdgeInsets.only(right: 0, left: 10),
                child: Container(
                  width: snackContentHeight * 6 / 10,
                  height: snackContentHeight * 6 / 10,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      height: snackContentHeight,
    ),
    duration: Duration(seconds: 10000),
    backgroundColor: prefix0.Theme.snackBarBG,
  );

  Scaffold.of(FirstPage.mainContext).showSnackBar(snackBar);
}

void showConnectedSnackBar(double snackContentHeight, double fontSize) {
  SnackBar snackBar = SnackBar(
    content: Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'اتصال برقرار شد.',
            style: getTextStyle(fontSize, prefix0.Theme.onSnackBarText),
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
          ),
          Padding(
            padding: EdgeInsets.only(right: 0, left: 10),
            child: Container(
              width: snackContentHeight,
              height: snackContentHeight,
              child: Icon(
                Icons.done,
                color: prefix0.Theme.onSnackBarText,
              ),
            ),
          ),
        ],
      ),
    ),
    duration: Duration(seconds: 1),
    backgroundColor: prefix0.Theme.snackBarBG,
  );
  Scaffold.of(FirstPage.mainContext).showSnackBar(snackBar);
}

void removeSnackBars() {
  Scaffold.of(FirstPage.mainContext).removeCurrentSnackBar();
}

void showNotificationFlushBar(String title, String message,
    {double snackContentHeight = 40,
    double fontSize = 15,
    FlushbarPosition flushbarPosition = FlushbarPosition.TOP,
    FlushbarDismissDirection flushbarDismissDirection =
        FlushbarDismissDirection.HORIZONTAL,
    bool ignoreOverflow = false,
    bool preventVibrate = false}) {
  if (!kIsWeb) {
    if (!preventVibrate) {
      doVibrate();
    }
  }

  if (!ignoreOverflow) {
    message = getStringCutForNotification(message);
  }

  Flushbar(
    titleText: AutoSizeText(
      title,
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
      style: getTextStyle(17, Color.fromARGB(255, 255, 255, 255)),
    ),
    messageText: AutoSizeText(
      message,
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
      style: getTextStyle(15, Color.fromARGB(255, 255, 255, 255)),
    ),
    duration: Duration(seconds: 15),
    isDismissible: true,
    borderRadius: 15,
    maxWidth: MediaQuery.of(FirstPage.mainContext).size.width * (95 / 100),
    dismissDirection: flushbarDismissDirection,
    flushbarPosition: flushbarPosition,
    flushbarStyle: FlushbarStyle.FLOATING,
    backgroundColor: Color.fromARGB(200, 100, 100, 100),
    margin: EdgeInsets.only(bottom: 10),
    forwardAnimationCurve: Curves.easeIn,
    reverseAnimationCurve: Curves.easeOut,
  )..show(FirstPage.mainContext);
}

void showNewAppVersion(String link,
    {double snackContentHeight = 40, double fontSize = 15}) {
  SnackBar snackBar = SnackBar(
    content: Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              lunchBrowser(link);
            },
            child: Padding(
              padding: EdgeInsets.only(right: 10, left: 10),
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      color: prefix0.Theme.onSnackBarButton),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 5, bottom: 5),
                        child: Icon(
                          Icons.update,
                          color: prefix0.Theme.onSnackBarButtonText,
                        ),
                      ),
                      AutoSizeText(
                        "بروزرسانی",
                        style: getTextStyle(
                            fontSize, prefix0.Theme.onSnackBarButtonText),
                      ),
                    ],
                  )),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'آپدیت جدید',
                style: getTextStyle(fontSize, prefix0.Theme.onSnackBarText),
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ],
      ),
      height: snackContentHeight,
    ),
    duration: Duration(seconds: 20),
    backgroundColor: prefix0.Theme.snackBarBG,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(10.0),
      ),
    ),
  );

  Scaffold.of(FirstPage.mainContext).showSnackBar(snackBar);
}

void showFlutterToastWithFlushBar(String message,
    {Color bgColor,
    double fontSize = 16,
    int secsForDurations = 4,
    bool loading = false,
    double snackContentHeight}) {
  if (FirstPage.mainContext != null) {
    try {
      bgColor = bgColor ?? Color.fromARGB(180, 100, 100, 100);

      double width = MediaQuery.of(FirstPage.mainContext).size.width * 90 / 100;
      removeSnackBars();
      SnackBar snackBar = SnackBar(
        width: width,
        content: Container(
          width: width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: getAutoSizedDirectionText(message,
                    style: getTextStyle(fontSize, prefix0.Theme.onSnackBarText),
                    textAlign: TextAlign.right,
                    width: width),
              ),
              loading
                  ? Padding(
                      padding: EdgeInsets.only(right: 0, left: 10),
                      child: Container(
                        width: snackContentHeight != null
                            ? snackContentHeight * 6 / 10
                            : null,
                        height: snackContentHeight != null
                            ? snackContentHeight * 6 / 10
                            : null,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : SizedBox(),
            ],
          ),
          height: snackContentHeight,
        ),
        duration: Duration(seconds: secsForDurations),
        backgroundColor: prefix0.Theme.snackBarBG,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
      );
      try {
        Scaffold.of(FirstPage.mainContext).showSnackBar(snackBar);
      } catch (e) {}
    } catch (e) {}
  }
}

void showFlutterToast(String message, {double fontSize = 18}) {
  Fluttertoast.showToast(
      msg: message,
      textColor: prefix0.Theme.onSnackBarText,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: prefix0.Theme.snackBarBG,
      fontSize: fontSize);
}
