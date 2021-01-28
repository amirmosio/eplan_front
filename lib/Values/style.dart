import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class Theme {
  static Map<String, List> themes = {
    'dark': [255, 0, 0, 0],
    'red': [255, 226, 61, 85],
    'orange': [255, 249, 145, 49]
  };

  static String themeName = "orange";
  static Color titleBar1 = Color.fromARGB(255, 249, 145, 49);
  static Color titleBar2 = Color.fromARGB(255, 249, 180, 49);
  static Color onTitleBarText = Color.fromARGB(255, 255, 255, 255);
  static Color mainBG = Color.fromARGB(255, 245, 245, 245);
  static Color onMainBGText = Color.fromARGB(255, 0, 0, 0);
  static Color warningAndErrorBG = Color.fromARGB(255, 255, 200, 20);
  static Color onItemErrorTextBG = Color.fromARGB(255, 255, 76, 129);
  static Color onWarningAndErrorBG = Color.fromARGB(255, 255, 200, 20);
  static Color lessonNameBG = Color.fromARGB(255, 255, 255, 255);
  static Color descriptionBG = Color.fromARGB(255, 255, 255, 255);
  static Color onDescriptionBg = Color.fromARGB(255, 0, 0, 0);
  static Color onLessonNameBGText = Color.fromARGB(255, 0, 0, 0);
  static Color startEndTimeItemsBG = Color.fromARGB(255, 255, 255, 255);
  static Color onStartEndTimeItemBG = Color.fromARGB(255, 0, 0, 0);
  static Color onContactItemBg = Color.fromARGB(255, 0, 0, 0);
  static Color contactItemBG = Color.fromARGB(255, 255, 255, 255);
  static Color contactDetailText = Color.fromARGB(255, 255, 255, 255);
  static Color applyButton = Color.fromARGB(255, 79, 79, 79);
  static Color onApplyButton = Color.fromARGB(255, 255, 255, 255);
  static Color blueIcon = Color.fromARGB(255, 0, 49, 110);
  static Color blueBR = Color.fromARGB(255, 110, 49, 110);
  static Color dayDetailHighlight = Color.fromARGB(100, 255, 255, 255);
  static Color dayDetailBG = Color.fromARGB(0, 0, 0, 0);
  static Color lessonHighlight = Color.fromARGB(255, 189, 208, 255);
  static Color cloudyBlue = Color.fromARGB(255, 189, 208, 255);
  static Color searchBoxBg = Color.fromARGB(255, 255, 255, 255);
  static Color grey = Color.fromARGB(150, 150, 150, 150);
  static Color descriptionBlue = Color.fromARGB(255, 98, 98, 98);
  static Color mildGrey = Color.fromARGB(255, 215, 215, 215);
  static Color transWhiteText = Color.fromARGB(200, 255, 255, 255);
  static Color tTransWhiteText = Color.fromARGB(150, 255, 255, 255);
  static Color ttTransWhiteText = Color.fromARGB(100, 255, 255, 255);
  static Color darkText = Color.fromARGB(255, 0, 0, 0);
  static Color brightBlack = Color.fromARGB(100, 0, 50, 50);
  static Color redBright = Color.fromARGB(100, 150, 0, 0);
  static Color importantYellow = Color.fromARGB(255, 255, 204, 0);
  static Color greyTimeLine = Color.fromARGB(255, 149, 156, 168);
  static Color highlightActiveTrack = Color.fromARGB(255, 158, 248, 216);
  static Color fragmentBlurBackGround = Color.fromARGB(120, 0, 0, 0);
  static Color greyTimeDateColor = Color.fromARGB(200, 0, 0, 0);
  static Color settingBg = Color.fromARGB(255, 255, 255, 255);
  static Color onSettingText1 = Color.fromARGB(255, 255, 255, 255);
  static Color onSettingText2 = Color.fromARGB(255, 255, 255, 255);
  static Color blue2CellBG = Color.fromARGB(255, 255, 255, 255);
  static Color registerTextFieldBg = Color.fromARGB(255, 255, 255, 255);
  static Color totalSumBlue1TableBg = Color.fromARGB(255, 0, 49, 110);
  static Color onTotalSumBlue1TableBg = Color.fromARGB(255, 255, 255, 255);
  static Color addIconBg = Color.fromARGB(250, 150, 150, 150);
  static Color shadowColor = Colors.grey.withOpacity(0.5);
  static Color cDesBG = Color.fromARGB(255, 255, 255, 255);
  static Color cDesSplitLine = Color.fromARGB(255, 0, 0, 0);
  static Color cDesTitle = Color.fromARGB(255, 0, 0, 0);
  static Color cDesValue = Color.fromARGB(255, 150, 150, 150);
  static Color cDesApply = Color.fromARGB(255, 0, 0, 0);
  static Color cDeswakyUpIcon = Color.fromARGB(255, 0, 0, 0);

  static Color addIcon = Color.fromARGB(0, 0, 0, 0);

  static Color snackBarBG = Color.fromARGB(200, 100, 100, 100);
  static Color onSnackBarText = Color.fromARGB(255, 255, 255, 255);
  static Color onSnackBarButton = Color.fromARGB(0, 100, 100, 100);
  static Color onSnackBarButtonText = Color.fromARGB(255, 100, 220
      , 255);




  static ImageFilter fragmentBGFilter =
      ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0);
  static double spreadRadius = 0;
  static double blurRadius = 0;


  static void changeThemeByName(String name) {
    if (name == "dark") {
      setDarkTheme();
    } else if (name == 'red') {
      setRedTheme();
    } else if (name == "orange") {
      setOrangeTheme();
    } else {
      changeDefault();
    }
  }

  static void changeDefault() {
    setOrangeTheme();
  }

  static void setOrangeTheme() {
    themeName = "orange";
    titleBar1 = Color.fromARGB(255, 249, 145, 49);
    titleBar2 = Color.fromARGB(255, 249, 180, 49);
    onTitleBarText = Color.fromARGB(255, 255, 255, 255);
    mainBG = Color.fromARGB(255, 230, 230, 230);
    onMainBGText = Color.fromARGB(255, 100, 100, 100);
    lessonNameBG = Color.fromARGB(255, 255, 255, 255);
    descriptionBG = Color.fromARGB(255, 255, 255, 255);
    warningAndErrorBG = Color.fromARGB(255, 255, 76, 129);
    onItemErrorTextBG = Color.fromARGB(255, 255, 76, 129);
    onWarningAndErrorBG = Color.fromARGB(255, 255, 255, 255);
    onDescriptionBg = Color.fromARGB(255, 100, 100, 100);
    onLessonNameBGText = Color.fromARGB(255, 0, 0, 0);
    startEndTimeItemsBG = Color.fromARGB(255, 255, 255, 255);
    onStartEndTimeItemBG = Color.fromARGB(255, 0, 0, 0);
    onContactItemBg = Color.fromARGB(255, 0, 0, 0);
    contactItemBG = Color.fromARGB(255, 255, 255, 255);
    contactDetailText = Color.fromARGB(255, 150, 150, 150);
    applyButton = Color.fromARGB(255, 82, 222, 151);
    onApplyButton = Color.fromARGB(255, 255, 255, 255);
    blueIcon = Color.fromARGB(255, 0, 49, 110);
    blueBR = Color.fromARGB(255, 0, 49, 110);
    dayDetailHighlight = Color.fromARGB(50, 255, 255, 255);
    dayDetailBG = Color.fromARGB(0, 0, 0, 0);
    lessonHighlight = Color.fromARGB(255, 153, 255, 159);
    cloudyBlue = Color.fromARGB(255, 189, 208, 255);
    searchBoxBg = Color.fromARGB(255, 255, 255, 255);
    grey = Color.fromARGB(150, 150, 150, 150);
    descriptionBlue = Color.fromARGB(255, 98, 98, 98);
    mildGrey = Color.fromARGB(255, 215, 215, 215);
    transWhiteText = Color.fromARGB(200, 255, 255, 255);
    tTransWhiteText = Color.fromARGB(150, 255, 255, 255);
    ttTransWhiteText = Color.fromARGB(100, 255, 255, 255);
    darkText = Color.fromARGB(255, 0, 0, 0);
    brightBlack = Color.fromARGB(100, 0, 50, 50);
    redBright = Color.fromARGB(100, 150, 0, 0);
    importantYellow = Color.fromARGB(255, 255, 190, 70);
    greyTimeLine = Color.fromARGB(255, 149, 156, 168);
    highlightActiveTrack = Color.fromARGB(255, 200, 200, 200);
    fragmentBlurBackGround = Color.fromARGB(120, 0, 0, 0);
    greyTimeDateColor = Color.fromARGB(200, 0, 0, 0);
    settingBg = Color.fromARGB(255, 255, 255, 255);
    onSettingText1 = Color.fromARGB(255, 50, 50, 50);
    onSettingText2 = Color.fromARGB(255, 150, 150, 150);
    blue2CellBG = Color.fromARGB(255, 255, 255, 255);
    registerTextFieldBg = Color.fromARGB(255, 255, 255, 255);
    totalSumBlue1TableBg = Color.fromARGB(255, 255, 255, 255);
    addIconBg = Color.fromARGB(250, 150, 150, 150);
    addIcon = Color.fromARGB(0, 0, 0, 0);
    shadowColor = Colors.grey.withOpacity(0.5);
    onTotalSumBlue1TableBg = Color.fromARGB(255, 0, 0, 0);
     cDesBG = Color.fromARGB(255, 255, 255, 255);
     cDesSplitLine = Color.fromARGB(255, 0, 0, 0);
     cDesTitle = Color.fromARGB(255, 0, 0, 0);
     cDesValue = Color.fromARGB(255, 150, 150, 150);
    cDesApply = Color.fromARGB(255, 0, 0, 0);
    cDeswakyUpIcon = Color.fromARGB(255, 0, 0, 0);
    fragmentBGFilter = ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0);
    spreadRadius = 0;
    blurRadius = 0;
  }

  static void setRedTheme() {
    themeName = "red";
    titleBar1 = Color.fromARGB(255, 226, 61, 85);
    titleBar2 = Color.fromARGB(255, 226, 61, 85);
    onTitleBarText = Color.fromARGB(255, 255, 255, 255);
    grey = Color.fromARGB(150, 150, 150, 150);
    startEndTimeItemsBG = Color.fromARGB(200, 21, 28, 40);
    contactItemBG = Color.fromARGB(200, 21, 28, 40);
    contactDetailText = Color.fromARGB(255, 255, 255, 255);
    mainBG = Color.fromARGB(255, 42, 57, 80);
    warningAndErrorBG = Color.fromARGB(255, 226, 61, 85);
    onItemErrorTextBG = Color.fromARGB(255, 226, 61, 85);
    onWarningAndErrorBG = Color.fromARGB(255, 255, 255, 255);
    onStartEndTimeItemBG = Color.fromARGB(255, 255, 255, 255);
    onContactItemBg = Color.fromARGB(255, 255, 255, 255);
    descriptionBlue = Color.fromARGB(255, 98, 98, 98);
    descriptionBG = Color.fromARGB(255, 255, 255, 255);
    onDescriptionBg = Color.fromARGB(255, 0, 0, 0);
    blueBR = Color.fromARGB(255, 56, 81, 121);
    cloudyBlue = Color.fromARGB(255, 189, 208, 255);
    searchBoxBg = Color.fromARGB(255, 255, 255, 255);
    blueIcon = Color.fromARGB(255, 60, 90, 136);
    mildGrey = Color.fromARGB(255, 215, 215, 215);
    onMainBGText = Color.fromARGB(255, 255, 255, 255);
    transWhiteText = Color.fromARGB(200, 255, 255, 255);
    tTransWhiteText = Color.fromARGB(150, 255, 255, 255);
    ttTransWhiteText = Color.fromARGB(100, 255, 255, 255);
    applyButton = Color.fromARGB(255, 59, 196, 78);
    onApplyButton = Color.fromARGB(255, 255, 255, 255);
    darkText = Color.fromARGB(255, 0, 0, 0);
    brightBlack = Color.fromARGB(100, 0, 50, 50);
    redBright = Color.fromARGB(100, 150, 0, 0);
    importantYellow = Color.fromARGB(255, 255, 204, 0);
    lessonHighlight = Color.fromARGB(255, 153, 255, 159);
    greyTimeLine = Color.fromARGB(255, 149, 156, 168);
    highlightActiveTrack = Color.fromARGB(255, 200, 200, 200);
    dayDetailHighlight = Color.fromARGB(250, 181, 49, 68);
    dayDetailBG = Color.fromARGB(0, 80, 0, 40);
    fragmentBlurBackGround = Color.fromARGB(120, 0, 0, 0);
    greyTimeDateColor = Color.fromARGB(200, 0, 0, 0);
    blue2CellBG = Color.fromARGB(255, 255, 255, 255);
    settingBg = Color.fromARGB(255, 255, 255, 255);
    onSettingText1 = Color.fromARGB(255, 50, 50, 50);
    onSettingText2 = Color.fromARGB(255, 150, 150, 150);
    registerTextFieldBg = Color.fromARGB(255, 255, 255, 255);
    totalSumBlue1TableBg = Color.fromARGB(255, 60, 90, 136);
    addIconBg = Color.fromARGB(0, 150, 150, 150);
    addIcon = Color.fromARGB(255, 255, 255, 255);
    shadowColor = Color.fromARGB(200, 21, 28, 40);
    cDesBG = Color.fromARGB(255, 255, 255, 255);
    cDesSplitLine = Color.fromARGB(255, 0, 0, 0);
    cDesTitle = Color.fromARGB(255, 0, 0, 0);
    cDesValue = Color.fromARGB(255, 150, 150, 150);
    cDesApply = Color.fromARGB(255, 0, 0, 0);
    cDeswakyUpIcon = Color.fromARGB(255, 0, 0, 0);
    onTotalSumBlue1TableBg = Color.fromARGB(255, 255, 255, 255);
    fragmentBGFilter = ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0);
    spreadRadius = 0;
    blurRadius = 0;
  }

  static setDarkTheme() {
    themeName = "dark";
    titleBar1 = Color.fromARGB(255, 38, 38, 40);
    titleBar2 = Color.fromARGB(255, 38, 38, 40);
    onTitleBarText = Color.fromARGB(255, 255, 255, 255);
    mainBG = Color.fromARGB(255, 20, 20, 20);
    onStartEndTimeItemBG = Color.fromARGB(255, 255, 255, 255);
    onContactItemBg = Color.fromARGB(255, 255, 255, 255);
    contactDetailText = Color.fromARGB(255, 255, 255, 255);
    startEndTimeItemsBG = Color.fromARGB(255, 79, 79, 79);
    contactItemBG = Color.fromARGB(200, 79, 79, 79);
    applyButton = Color.fromARGB(255, 78, 78, 78);
    onApplyButton = Color.fromARGB(255, 255, 255, 255);
    warningAndErrorBG = Color.fromARGB(255, 78, 78, 78);
    onItemErrorTextBG = Color.fromARGB(255, 210, 170, 170);
    onWarningAndErrorBG = Color.fromARGB(255, 255, 255, 255);
    descriptionBG = Color.fromARGB(255, 255, 255, 255);
    onDescriptionBg = Color.fromARGB(255, 0, 0, 0);
    blueIcon = Color.fromARGB(255, 0, 49, 110);
    blueBR = Color.fromARGB(255, 0, 49, 110);
    dayDetailHighlight = Color.fromARGB(100, 255, 255, 255);
    dayDetailBG = Color.fromARGB(0, 79, 79, 79);
    searchBoxBg = Color.fromARGB(255, 255, 255, 255);
    lessonHighlight = Color.fromARGB(255, 189, 208, 255);
    cloudyBlue = Color.fromARGB(255, 189, 208, 255);
    grey = Color.fromARGB(150, 150, 150, 150);
    descriptionBlue = Color.fromARGB(255, 98, 98, 98);
    mildGrey = Color.fromARGB(255, 215, 215, 215);
    onMainBGText = Color.fromARGB(255, 255, 255, 255);
    transWhiteText = Color.fromARGB(200, 255, 255, 255);
    tTransWhiteText = Color.fromARGB(150, 255, 255, 255);
    ttTransWhiteText = Color.fromARGB(100, 255, 255, 255);
    darkText = Color.fromARGB(255, 0, 0, 0);
    brightBlack = Color.fromARGB(100, 0, 50, 50);
    redBright = Color.fromARGB(100, 150, 0, 0);
    importantYellow = Color.fromARGB(255, 255, 204, 0);
    greyTimeLine = Color.fromARGB(255, 149, 156, 168);
    highlightActiveTrack = Color.fromARGB(255, 200, 200, 200);
    fragmentBlurBackGround = Color.fromARGB(120, 0, 0, 0);
    greyTimeDateColor = Color.fromARGB(200, 0, 0, 0);
    settingBg = Color.fromARGB(255, 255, 255, 255);
    onSettingText1 = Color.fromARGB(255, 50, 50, 50);
    onSettingText2 = Color.fromARGB(255, 150, 150, 150);
    blue2CellBG = Color.fromARGB(255, 255, 255, 255);
    registerTextFieldBg = Color.fromARGB(255, 255, 255, 255);
    totalSumBlue1TableBg = Color.fromARGB(255, 255, 255, 255);
    addIconBg = Color.fromARGB(250, 150, 150, 150);
    addIcon = Color.fromARGB(0, 0, 0, 0);
    shadowColor = Colors.grey.withOpacity(0.5);
    onTotalSumBlue1TableBg = Color.fromARGB(255, 0, 0, 0);
    cDesBG = Color.fromARGB(255, 255, 255, 255);
    cDesSplitLine = Color.fromARGB(255, 0, 0, 0);
    cDesTitle = Color.fromARGB(255, 0, 0, 0);
    cDesValue = Color.fromARGB(255, 150, 150, 150);
    cDesApply = Color.fromARGB(255, 0, 0, 0);
    cDeswakyUpIcon = Color.fromARGB(255, 0, 0, 0);
    fragmentBGFilter = ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0);
    spreadRadius = 0;
    blurRadius = 0;
  }
}

TextStyle buttonTextStyle =
    TextStyle(fontSize: 22.0, color: Theme.onMainBGText);

charts.TextStyleSpec chartLabelTextStyle =
    new charts.TextStyleSpec(fontSize: 14, color: charts.MaterialPalette.white);

TextStyle getTextStyle(double fontsize, Color c,
    {double height, fontWeight = FontWeight.w500}) {
  return TextStyle(
      fontSize: fontsize,
      height: height,
      fontFamily: 'traffic',
      fontWeight: fontWeight,
      color: c);
}
