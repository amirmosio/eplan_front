import 'dart:async';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mhamrah/ConnectionService/DateTime.dart';
import 'package:mhamrah/Models/BlueTable2MV.dart';
import 'package:mhamrah/Utils/AutoTextUtils.dart';
import 'package:mhamrah/Values/string.dart';
import 'package:mhamrah/Values/style.dart';
import 'package:mhamrah/Values/style.dart' as prefix0;
import 'package:shamsi_date/shamsi_date.dart';
import 'package:url_launcher/url_launcher.dart';

Future navigateToSubPage(context, Widget w) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => w));
}

void showLoadingDialog(context) {
  AlertDialog d = new AlertDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(25),
      ),
    ),
    backgroundColor: Color.fromARGB(180, 100, 100, 100),
    content: new Container(
      alignment: Alignment.center,
      height: MediaQuery.of(context).size.width / 2,
      width: MediaQuery.of(context).size.width / 2,
      child: new Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[new CircularProgressIndicator()],
      ),
      decoration: new BoxDecoration(
        shape: BoxShape.circle,
      ),
    ),
  );
  showDialog(context: context, child: d, barrierDismissible: false);
}

void closeLoadingDialog(context) {
  Navigator.of(context, rootNavigator: true).pop();
}

int getTimeMinute(String time) {
  time = removeAllSpace(time);
  time = replacePersianWithEnglishNumber(time);
  try {
    if (time.contains(":")) {
      int hour = int.parse(time.split(":")[0]);
      int minute = int.parse(time.split(":")[1]);
      return (60 * hour) + minute;
    } else {
      int minute = int.parse(time);
      return minute;
    }
  } catch (Exception) {
    return 0;
  }
}

String removeAllSpace(String text) {
  return text.replaceAll(" ", "");
}

bool checkEmptyAllowTestNumber(String number) {
  String english = replacePersianWithEnglishNumber(number);
  try {
    if (english == "") {
      return true;
    } else {
      int.parse(english);
      return true;
    }
  } catch (Exception) {
    return false;
  }
}

bool checkEmptyAllowTime(String time) {
  if (time == "") {
    return true;
  }
  String value2 = replacePersianWithEnglishNumber(time);
  RegExp regex =
      RegExp(r"^[0-9]?[0-9][ ]?:[ ]?[0-9][0-9]$", caseSensitive: true);
  if (!regex.hasMatch(value2)) {
    return false;
  } else {
    if (int.parse(value2.split(":")[1]) > 60) {
      return false;
    }
    return true;
  }
}

String convertMinuteToTimeString(int lessonsMinute) {
  int hour = ((lessonsMinute / 60).floor());
  int minute = lessonsMinute % 60;
  String hourString = hour < 10 ? "0" + hour.toString() : hour.toString();
  String minuteString =
      minute < 10 ? "0" + minute.toString() : minute.toString();
  return hourString + " : " + minuteString;
}

String replacePersianWithEnglishNumber(String text) {
  for (int i = 0; i < persianNumber.length; i++) {
    text = text.replaceAll(persianNumber[i], i.toString());
  }
  return text;
}

String replaceEnglishWithPersianNumber(String text) {
  for (int i = 0; i < persianNumber.length; i++) {
    text = text.replaceAll(i.toString(), persianNumber[i]);
  }
  return text;
}

int getEnglishNumber(String char) {
  for (int i = 0; i < persianNumber.length; i++) {
    if (persianNumber[i] == char) {
      return i;
    }
  }
  return 0;
}

Color getLessonColor(String str) {
  int R;
  int G;
  int B;
  if (str == "ریاضی" ||
      str == "دیفرانسیل" ||
      str == "دیف" ||
      str == "Math" ||
      str == "MATH" ||
      str == "جبرواحتمال" ||
      str == "جبر" ||
      str == "احتمال" ||
      str == "آمار" ||
      str == "امار" ||
      str == "هندسه" ||
      str == "هندسه1" ||
      str == "هندسه 1" ||
      str == "هندسه 2" ||
      str == "هندسه2" ||
      str == "هندسه 3" ||
      str == "هندسه3" ||
      str == "هندسه یک" ||
      str == "هندسه دو" ||
      str == "هندسه سه" ||
      str == "هندسه تحلیلی" ||
      str == "گسسته" ||
      str == "ریاضی گسسته" ||
      str == "ریاضیات گسسته" ||
      str == "حسابان" ||
      str == "پایه" ||
      str == "ریاضی پایه" ||
      str == "ریاضیات پایه" ||
      str == "ریاضی دهم" ||
      str == "ریاضیات دهم" ||
      str == "ریاضی 10ا" ||
      str == "ریاضی10" ||
      str == "ریاضی یازدهم" ||
      str == "ریاضی ده" ||
      str == "ریاضیات یازدهم" ||
      str == "ریاضی 11" ||
      str == "ریاضی11" ||
      str == "ریاضی دوازدهم" ||
      str == "ریاضی دوازده" ||
      str == "ریاضی 12" ||
      str == "ریاضی12" ||
      str == "ریاضیات دوازدهم" ||
      str == "ریاضی ده" ||
      str == "ریاضی یازده") {
    R = 0;
    G = 0;
    B = 0;
  } else if (str == "فیزیک" ||
      str == "فیزیک1" ||
      str == "فیزیک 1" ||
      str == "فیزیک 10" ||
      str == "فیزیک10" ||
      str == "فیزیک دهم" ||
      str == "فیزیک ده" ||
      str == "فیزیک2" ||
      str == "فیزیک 2" ||
      str == "فیزیک 11" ||
      str == "فیزیک11" ||
      str == "فیزیک یازدهم" ||
      str == "فیزیک یازده" ||
      str == "فیزیک 3" ||
      str == "فیزیک3" ||
      str == "فیزیک12" ||
      str == "فیزیک 12" ||
      str == "فیزیک دوازدهم" ||
      str == "فیزیک دوازده") {
    R = 20;
    G = 20;
    B = 20;
  } else if (str == "شیمی" ||
      str == "شیمی1" ||
      str == "شیمی 1" ||
      str == "شیمی 10" ||
      str == "شیمی10" ||
      str == "شیمی دهم" ||
      str == "شیمی ده" ||
      str == "شیمی2" ||
      str == "شیمی 2" ||
      str == "شیمی 11" ||
      str == "شیمی11" ||
      str == "شیمی یازدهم" ||
      str == "شیمی یازده" ||
      str == "شیمی 3" ||
      str == "شیمی3" ||
      str == "شیمی12" ||
      str == "شیمی 12" ||
      str == "شیمی دوازدهم" ||
      str == "شیمی دوازده") {
    R = 60;
    G = 60;
    B = 60;
  } else if (str == "عربی" ||
      str == "عربی1" ||
      str == "عربی 1" ||
      str == "عربی 10" ||
      str == "عربی10" ||
      str == "عربی دهم" ||
      str == "عربی ده" ||
      str == "عربی2" ||
      str == "عربی 2" ||
      str == "عربی 11" ||
      str == "عربی11" ||
      str == "عربی یازدهم" ||
      str == "عربی یازده" ||
      str == "ترجمه" ||
      str == "ترجمه و مفاهیم" ||
      str == "مفهوم" ||
      str == "لغت" ||
      str == "مفهوم لغت" ||
      str == "عربی درک مطلب" ||
      str == "درک مطلب عربی" ||
      str == "تحلیل" ||
      str == "تحلیل صرفی" ||
      str == "حرکت گذاری" ||
      str == "زبان عربی") {
    R = 40;
    G = 40;
    B = 40;
  } else if (str == "معارف" ||
      str == "معارف1" ||
      str == "معارف 1" ||
      str == "معارف 10" ||
      str == "معارف10" ||
      str == "معارف دهم" ||
      str == "معارف ده" ||
      str == "معارف2" ||
      str == "معارف 2" ||
      str == "معارف 11" ||
      str == "معارف11" ||
      str == "معارف یازدهم" ||
      str == "معارف یازده" ||
      str == "معارف 3" ||
      str == "معارف3" ||
      str == "معارف12" ||
      str == "معارف 12" ||
      str == "معارف دوازدهم" ||
      str == "معارف دوازده" ||
      str == "دینی" ||
      str == "دینی1" ||
      str == "دینی 1" ||
      str == "دینی 10" ||
      str == "دینی10" ||
      str == "دینی دهم" ||
      str == "دینی ده" ||
      str == "دینی2" ||
      str == "دینی 2" ||
      str == "دینی 11" ||
      str == "دینی11" ||
      str == "دینی یازدهم" ||
      str == "دینی یازده" ||
      str == "دینی 3" ||
      str == "دینی3" ||
      str == "دینی12" ||
      str == "دینی 12" ||
      str == "دینی دوازدهم") {
    R = 80;
    G = 80;
    B = 80;
  } else if (str == "فارسی") {
    R = 100;
    G = 100;
    B = 100;
  } else if (str == "زبان انگلیسی") {
    R = 120;
    G = 120;
    B = 120;
  } else if (str == "عمومی") {
    R = 55;
    G = 232;
    B = 120;
  } else if (str == "تخصصی") {
    R = 32;
    G = 161;
    B = 234;
  } else {
    R = 180;
    G = 180;
    B = 180;
  }
  return Color.fromARGB(255, R, G, B);
}

List<String> list_motefareghe = ["کلاس", "تلف شده", "خواب"];

int getLessonType(String lessonIdenrifier, String lessonName) {
  lessonIdenrifier = lessonIdenrifier.trim();
  List<String> list_motefareghe = ["کلاس", "تلف شده", "خواب"];
  List<String> list_omomi = [];
  List<String> list_takhasosi = [];
  if (lessonIdenrifier == "کنکوری ریاضی") {
    list_omomi = ["ادبیات فارسی", "زبان عربی", "دین و زندگی", "زبان انگلیسی"];
    list_takhasosi = [
      "حسابان",
      "هندسه",
      "آمار",
      "گسسته",
      "فیزیک",
      "شیمی",
    ];
  } else if (lessonIdenrifier == "یازدهم ریاضی") {
    list_omomi = ["ادبیات فارسی", "زبان عربی", "دین و زندگی", "زبان انگلیسی"];
    list_takhasosi = [
      "حسابان",
      "هندسه",
      "آمار",
      "فیزیک",
      "شیمی",
    ];
  } else if (lessonIdenrifier == "دهم ریاضی") {
    list_omomi = ["ادبیات فارسی", "زبان عربی", "دین و زندگی", "زبان انگلیسی"];
    list_takhasosi = [
      "ریاضی",
      "هندسه",
      "فیزیک",
      "شیمی",
    ];
  } else if (lessonIdenrifier == "کنکوری تجربی") {
    list_omomi = ["ادبیات فارسی", "زبان عربی", "دین و زندگی", "زبان انگلیسی"];
    list_takhasosi = ["زمین شناسی", "ریاضیات", "زیست شناسی", "فیزیک", "شیمی"];
  } else if (lessonIdenrifier == "یازدهم تجربی") {
    list_omomi = ["ادبیات فارسی", "زبان عربی", "دین و زندگی", "زبان انگلیسی"];
    list_takhasosi = ["زمین شناسی", "ریاضیات", "زیست شناسی", "فیزیک", "شیمی"];
  } else if (lessonIdenrifier == "دهم تجربی") {
    list_omomi = ["ادبیات فارسی", "زبان عربی", "دین و زندگی", "زبان انگلیسی"];
    list_takhasosi = ["ریاضیات", "زیست شناسی", "فیزیک", "شیمی"];
  } else if (lessonIdenrifier == "کنکوری انسانی") {
    list_omomi = ["ادبیات فارسی", "زبان عربی", "دین و زندگی", "زبان انگلیسی"];
    list_takhasosi = [
      "ریاضی و آمار",
      "اقتصاد",
      "علوم و فنون ادبی",
      "عربی تخصصی",
      "تاریخ",
      "جغرافیا",
      "جامعه شناسی",
      "فلسفه",
      "منطق",
      "روانشناسی",
      "زبان و ادبیات فارسی"
    ];
  } else if (lessonIdenrifier == "یازدهم انسانی") {
    list_omomi = ["ادبیات فارسی", "زبان عربی", "دین و زندگی", "زبان انگلیسی"];
    list_takhasosi = [
      "ریاضی و آمار",
      "علوم و فنون ادبی",
      "عربی تخصصی",
      "تاریخ",
      "جغرافیا",
      "جامعه شناسی",
      "فلسفه",
      "روانشناسی"
    ];
  } else if (lessonIdenrifier == "دهم انسانی") {
    list_omomi = ["ادبیات فارسی", "زبان عربی", "دین و زندگی", "زبان انگلیسی"];
    list_takhasosi = [
      "ریاضی و آمار",
      "اقتصاد",
      "علوم و فنون ادبی",
      "عربی تخصصی",
      "تاریخ",
      "جغرافیا",
      "جامعه شناسی",
      "منطق"
    ];
  } else if (lessonIdenrifier == "ششم") {
    list_omomi = ["ادبیات فارسی", "قرآن و پیام آسمانی", "مطالعات اجتماعی"];
    list_takhasosi = ["علوم تجربی", "ریاضیات"];
  } else if (lessonIdenrifier == "هفتم") {
    list_omomi = [
      "ادبیات فارسی",
      "قرآن و پیام آسمانی",
      "زبان انگلیسی",
      "مطالعات اجتماعی",
      "زبان عربی"
    ];
    list_takhasosi = ["علوم تجربی", "ریاضیات"];
  } else if (lessonIdenrifier == "هشتم") {
    list_omomi = [
      "ادبیات فارسی",
      "قرآن و پیام آسمانی",
      "زبان انگلیسی",
      "مطالعات اجتماعی",
      "زبان عربی"
    ];
    list_takhasosi = ["علوم تجربی", "ریاضیات"];
  } else if (lessonIdenrifier == "نهم") {
    list_omomi = [
      "ادبیات فارسی",
      "قرآن و پیام آسمانی",
      "زبان انگلیسی",
      "مطالعات اجتماعی",
      "زبان عربی"
    ];
    list_takhasosi = ["علوم تجربی", "ریاضیات"];
  }
  if (list_takhasosi.contains(lessonName)) {
    return 1;
  } else if (list_omomi.contains(lessonName)) {
    return 0;
  } else {
    return 2;
  }
}

Color getLessonColorByNameAndMajor(String lessonIdenrifier, String lessonName) {
  lessonIdenrifier = lessonIdenrifier.trim();
  List<String> list_omomi = [];
  List<String> list_takhasosi = [];
  List<String> color_omomi = [];
  List<String> color_takhasosi = [];
  if (lessonIdenrifier == "کنکوری ریاضی") {
    list_omomi = ["ادبیات فارسی", "زبان عربی", "دین و زندگی", "زبان انگلیسی"];
    list_takhasosi = [
      "حسابان",
      "هندسه",
      "آمار",
      "گسسته",
      "فیزیک",
      "شیمی",
    ];
    color_omomi = ["(255,242,0)", "(237,28,36)", "(0,255,255)", "(247,156,55)"];
    color_takhasosi = [
      "(211,44,177)",
      "(222,55,188)",
      "(233,66,199)",
      "(244,77,200)",
      "(0,255,0)",
      "(239,228,176)"
    ];
  } else if (lessonIdenrifier == "یازدهم ریاضی") {
    list_omomi = ["ادبیات فارسی", "زبان عربی", "دین و زندگی", "زبان انگلیسی"];
    list_takhasosi = [
      "حسابان",
      "هندسه",
      "آمار",
      "فیزیک",
      "شیمی",
    ];
    color_omomi = ["(255,242,0)", "(237,28,36)", "(0,255,255)", "(247,156,55)"];
    color_takhasosi = [
      "(211,44,177)",
      "(222,55,188)",
      "(233,66,199)",
      "(0,255,0)",
      "(239,228,176)"
    ];
  } else if (lessonIdenrifier == "دهم ریاضی") {
    list_omomi = ["ادبیات فارسی", "زبان عربی", "دین و زندگی", "زبان انگلیسی"];
    list_takhasosi = [
      "ریتضی",
      "هندسه",
      "فیزیک",
      "شیمی",
    ];
    color_omomi = ["(255,242,0)", "(237,28,36)", "(0,255,255)", "(247,156,55)"];
    color_takhasosi = [
      "(211,44,177)",
      "(222,55,188)",
      "(0,255,0)",
      "(239,228,176)"
    ];
  } else if (lessonIdenrifier == "کنکوری تجربی") {
    list_omomi = ["ادبیات فارسی", "زبان عربی", "دین و زندگی", "زبان انگلیسی"];
    list_takhasosi = ["زمین شناسی", "ریاضیات", "زیست شناسی", "فیزیک", "شیمی"];
    color_omomi = ["(255,242,0)", "(237,28,36)", "(0,255,255)", "(247,156,55)"];
    color_takhasosi = [
      "(255,159,190)",
      "(211,44,177)",
      "(255,43,112)",
      "(0,255,0)",
      "(239,228,176)"
    ];
  } else if (lessonIdenrifier == "یازدهم تجربی") {
    list_omomi = ["ادبیات فارسی", "زبان عربی", "دین و زندگی", "زبان انگلیسی"];
    list_takhasosi = ["زمین شناسی", "ریاضیات", "زیست شناسی", "فیزیک", "شیمی"];
    color_omomi = ["(255,242,0)", "(237,28,36)", "(0,255,255)", "(247,156,55)"];
    color_takhasosi = [
      "(255,159,190)",
      "(211,44,177)",
      "(255,43,112)",
      "(0,255,0)",
      "(239,228,176)"
    ];
  } else if (lessonIdenrifier == "دهم تجربی") {
    list_omomi = ["ادبیات فارسی", "زبان عربی", "دین و زندگی", "زبان انگلیسی"];
    list_takhasosi = ["ریاضیات", "زیست شناسی", "فیزیک", "شیمی"];
    color_omomi = ["(255,242,0)", "(237,28,36)", "(0,255,255)", "(247,156,55)"];
    color_takhasosi = [
      "(211,44,177)",
      "(255,43,112)",
      "(0,255,0)",
      "(239,228,176)"
    ];
  } else if (lessonIdenrifier == "کنکوری انسانی") {
    list_omomi = ["ادبیات فارسی", "زبان عربی", "دین و زندگی", "زبان انگلیسی"];
    list_takhasosi = [
      "ریاضی و آمار",
      "اقتصاد",
      "علوم و فنون ادبی",
      "عربی تخصصی",
      "تاریخ",
      "جغرافیا",
      "جامعه شناسی",
      "فلسفه",
      "منطق",
      "روانشناسی",
      "زبان و ادبیات فارسی"
    ];
    color_omomi = ["(255,242,0)", "(237,28,36)", "(0,255,255)", "(247,156,55)"];
    color_takhasosi = [
      "(255,159,190)",
      "(211,44,177)",
      "(211,211,211)",
      "(216,189,63)",
      "(0,255,0)",
      "(255,43,112)",
      "(239,228,176)",
      "(56,211,220)",
      "(185,122,87)",
      "(159,255,157)",
      "(209,240,130)",
    ];
  } else if (lessonIdenrifier == "یازدهم انسانی") {
    list_omomi = ["ادبیات فارسی", "زبان عربی", "دین و زندگی", "زبان انگلیسی"];
    list_takhasosi = [
      "ریاضی و آمار",
      "علوم و فنون ادبی",
      "عربی تخصصی",
      "تاریخ",
      "جغرافیا",
      "جامعه شناسی",
      "فلسفه",
      "روانشناسی"
    ];
    color_omomi = ["(255,242,0)", "(237,28,36)", "(0,255,255)", "(247,156,55)"];
    color_takhasosi = [
      "(255,159,190)",
      "(211,44,177)",
      "(211,211,211)",
      "(216,189,63)",
      "(0,255,0)",
      "(255,43,112)",
      "(239,228,176)",
      "(185,122,87)"
    ];
  } else if (lessonIdenrifier == "دهم انسانی") {
    list_omomi = ["ادبیات فارسی", "زبان عربی", "دین و زندگی", "زبان انگلیسی"];
    list_takhasosi = [
      "ریاضی و آمار",
      "اقتصاد",
      "علوم و فنون ادبی",
      "عربی تخصصی",
      "تاریخ",
      "جغرافیا",
      "جامعه شناسی",
      "منطق"
    ];
    color_omomi = ["(255,242,0)", "(237,28,36)", "(0,255,255)", "(247,156,55)"];
    color_takhasosi = [
      "(255,159,190)",
      "(211,44,177)",
      "(211,211,211)",
      "(216,189,63)",
      "(0,255,0)",
      "(255,43,112)",
      "(239,228,176)",
      "(185,122,87)"
    ];
  } else if (lessonIdenrifier == "ششم") {
    list_omomi = ["ادبیات فارسی", "قرآن و پیام آسمانی", "مطالعات اجتماعی"];
    list_takhasosi = ["علوم تجربی", "ریاضیات"];
    color_omomi = ["(255,242,0)", "(237,28,36)", "(0,255,255)"];
    color_takhasosi = ["(247,156,55)", "(0,255,0)"];
  } else if (lessonIdenrifier == "هفتم") {
    list_omomi = [
      "ادبیات فارسی",
      "قرآن و پیام آسمانی",
      "زبان انگلیسی",
      "مطالعات اجتماعی",
      "زبان عربی"
    ];
    color_omomi = [
      "(255,242,0)",
      "(237,28,36)",
      "(0,255,255)",
      "(247,156,55)",
      "(0,255,0)"
    ];
    list_takhasosi = ["علوم تجربی", "ریاضیات"];
    color_takhasosi = ["(247,80,55)", "(0,255,0)"];
  } else if (lessonIdenrifier == "هشتم") {
    list_omomi = [
      "ادبیات فارسی",
      "قرآن و پیام آسمانی",
      "زبان انگلیسی",
      "مطالعات اجتماعی",
      "زبان عربی"
    ];
    list_takhasosi = ["علوم تجربی", "ریاضیات"];
    color_omomi = [
      "(255,242,0)",
      "(237,28,36)",
      "(0,255,255)",
      "(247,156,55)",
      "(0,255,0)"
    ];
    color_takhasosi = ["(0,255,0)", "(239,228,176)"];
  } else if (lessonIdenrifier == "نهم") {
    list_omomi = [
      "ادبیات فارسی",
      "قرآن و پیام آسمانی",
      "زبان انگلیسی",
      "مطالعات اجتماعی",
      "زبان عربی"
    ];
    list_takhasosi = ["علوم تجربی", "ریاضیات"];
    color_omomi = [
      "(255,242,0)",
      "(237,28,36)",
      "(0,255,255)",
      "(247,156,55)",
      "(0,255,0)"
    ];
    color_takhasosi = ["(0,255,0)", "(239,228,176)"];
  }
  if (list_takhasosi.contains(lessonName)) {
    int index = list_takhasosi.indexOf(lessonName);
    return getColorFromString(color_takhasosi[index]);
  } else if (list_omomi.contains(lessonName)) {
    int index = list_omomi.indexOf(lessonName);
    return getColorFromString(color_omomi[index]);
  } else {
    return Colors.black;
  }
}

Color getColorFromString(String colorString) {
  colorString = colorString.substring(1, colorString.length - 1);
  List<String> colors = colorString.split(",");
  Color c = Color.fromARGB(
      255, int.parse(colors[0]), int.parse(colors[1]), int.parse(colors[2]));
  return c;
}

charts.Color getChartColor(Color color) {
  return charts.Color(
      r: color.red, g: color.green, b: color.blue, a: color.alpha);
}

String improveStringJsonFromSocket(String text) {
  text = text.replaceAll("\\\\u", '\\u');
  text = text.replaceAll("\\\"", "\"");
  text = text.replaceAll("\"", "\"");
  text = text.replaceAll('\\"', "'");
  text = text.substring(1, text.length - 1);
  return text;
}

String improveMessageStringText(String text) {
  text = text.replaceAll("\\\\n", '\n');
  text = text.replaceAll("\\n", '\n');
  text = text.replaceAll("\\\"", "\"");
  text = text.replaceAll("\"", "\"");
  text = text.replaceAll('\\"', "'");
  text = text.substring(1, text.length - 1);
  return text;
}

String getCurrentTimeString() {
  DateTime date = new DateTime.now();
  return (date.hour.toString().length == 1
          ? "0" + date.hour.toString()
          : date.hour.toString()) +
      ":" +
      (date.minute.toString().length == 1
          ? "0" + date.minute.toString()
          : date.minute.toString()) +
      ":" +
      date.second.toString();
}

String getCurrentDateString() {
  Jalali date = Jalali.now();
  return date.year.toString() +
      "/" +
      date.month.toString() +
      "/" +
      date.day.toString();
}

Future<int> checkCurrentDay(
    int dayIndex, String planStartDate, List<String> dayDate) async {
  DateTimeService dateTime = DateTimeService();
  planStartDate = replacePersianWithEnglishNumber(planStartDate);
  int year = int.parse(planStartDate.split("/")[0]);
  int month = int.parse(planStartDate.split("/")[1]);
  int day = int.parse(planStartDate.split("/")[2]);
  int startDayIndex =
      dayDate.indexOf(replaceEnglishWithPersianNumber(day.toString()));
//  Jalali currentDate = Jalali.now();
  String dateString = replacePersianWithEnglishNumber(
          (await dateTime.getDateTime())['result']["date"])
      .replaceAll("\/", ".");
  Jalali currentDate = Jalali(int.parse(dateString.split(".")[0]),
      int.parse(dateString.split(".")[1]), int.parse(dateString.split(".")[2]));
  currentDate = currentDate.addDays(-1 * (dayIndex - startDayIndex));
  if (currentDate.day == day &&
      currentDate.month == month &&
      currentDate.year == year) {
    DateTime date = new DateTime.now();
    if (date.hour >= 3) {
      return 1;
    }
    return 1;
  }
  return -2;
}

Color getColorFromLesson(B2LessonPerDay b2lessonPerDay) {
  return getColorFromARGB(
      b2lessonPerDay.lessonColor[0],
      b2lessonPerDay.lessonColor[1],
      b2lessonPerDay.lessonColor[2],
      b2lessonPerDay.lessonColor[3]);
}

Color getColorFromARGB(int aa, int rr, int gg, int bb) {
  int add = 90;
  int a = min(255, aa * (100 / 100)).round();
  int r = min(255, (rr + add) * (80 / 100)).round();
  int g = min(255, (gg + add) * (80 / 100)).round();
  int b = min(255, (bb + add) * (80 / 100)).round();
  return Color.fromARGB(a, r, g, b);
}

void showErrorToast() {
  Fluttertoast.showToast(msg: serverError);
}

String matchParentUsername(String username) {
  username = username.trim();
  RegExp mRegex = RegExp(r"^mother:.+$", caseSensitive: false);
  RegExp fRegex = RegExp(r"^father:.+$", caseSensitive: false);
  if (mRegex.hasMatch(username)) {
    return "mother";
  } else if (fRegex.hasMatch(username)) {
    return "father";
  }
  return "";
}

String getChildUsernameFromParentUsername(String parentUsername) {
  parentUsername = parentUsername.trim();
  RegExp mRegex = RegExp(r"^mother:.+$", caseSensitive: false);
  RegExp fRegex = RegExp(r"^father:.+$", caseSensitive: false);
  if (mRegex.hasMatch(parentUsername)) {
    return parentUsername.substring(7);
  } else if (fRegex.hasMatch(parentUsername)) {
    return parentUsername.substring(7);
  }
  return parentUsername;
}

Widget getSwitchSettingField(String settingName, String activeDesc,
    String deactiveDesc, Function f, bool initialValue, bool loading) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          new Padding(
            padding: EdgeInsets.only(top: 0, right: 3, left: 3),
            child: Container(
                width: 60,
                alignment: Alignment.center,
                child: Stack(
                  alignment: Alignment.center,
                  fit: StackFit.loose,
                  children: [
                    Switch(
                      value: initialValue,
                      activeTrackColor: prefix0.Theme.highlightActiveTrack,
                      activeColor: prefix0.Theme.warningAndErrorBG,
                      inactiveTrackColor: prefix0.Theme.mildGrey,
                      onChanged: f,
                    ),
                    loading ? getSwitchLoadingProgress() : SizedBox(),
                  ],
                )),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 0, right: 10),
            child: AutoSizeText(
              settingName,
              textAlign: TextAlign.start,
              textDirection: TextDirection.rtl,
              style: getTextStyle(17, prefix0.Theme.onSettingText1),
            ),
          ),
        ],
      ),
      new Padding(
        padding: EdgeInsets.only(top: 0, right: 10, bottom: 5),
        child: AutoSizeText(
          initialValue ? activeDesc : deactiveDesc,
          textAlign: TextAlign.start,
          textDirection: TextDirection.rtl,
          maxLines: 2,
          style: getTextStyle(12, prefix0.Theme.onSettingText2),
        ),
      ),
      Padding(
        child: Container(
          height: 0.2,
          color: prefix0.Theme.darkText,
        ),
        padding: EdgeInsets.only(left: 10, right: 10),
      )
    ],
  );
}

Widget getPageLoadingProgress() {
  double r = 400;
  double stroke = 3;
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        child: CircleAvatar(
          backgroundColor: Color.fromARGB(0, 0, 0, 0),
          child: CircularProgressIndicator(
            strokeWidth: stroke,
          ),
          radius: r,
        ),
        width: r,
        height: r,
      ),
      getAutoSizedDirectionText("ممکن است مقداری طول بکشد!")
    ],
  );
}

Widget getSwitchLoadingProgress() {
  double r = 15;
  return SizedBox(
    child: CircleAvatar(
      backgroundColor: Color.fromARGB(0, 0, 0, 0),
      child: CircularProgressIndicator(
        strokeWidth: 2,
      ),
      radius: r,
    ),
    width: r,
    height: r,
  );
}

Widget getButtonLoadingProgress({double r = 30, double stroke = 3}) {
  return SizedBox(
    height: r,
    width: r,
    child: CircleAvatar(
      radius: r,
      backgroundColor: Color.fromARGB(0, 0, 0, 0),
      child: CircularProgressIndicator(
        strokeWidth: stroke,
      ),
    ),
  );
}

String getStringCutForNotification(String text) {
  String resultText = "";
  text = text ?? "";
  List<String> lines = text.split("\n");
  for (int i = 0; i < min(lines.length, 3); i++) {
    resultText += lines[i] + "\n";
  }
  resultText = resultText.substring(0, min(resultText.length, 40));
  if (resultText.length < text.length) {
    resultText += "...";
  }
  return resultText;
}

bool stringListEquality(List<dynamic> l1, List<String> l2) {
  for (int i = 0; i < l1.length; i++) {
    String element = l1[i].toString();
    if (!l2.contains(element)) {
      return false;
    }
  }
  if (l1.length != l2.length) {
    return false;
  }
  return true;
}

Future<void> lunchBrowser(url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

bool checkPersianCharsAndSpaceOnly(String text) {
  text = text
      .replaceAll(String.fromCharCodes([8206]), "")
      .replaceAll(String.fromCharCodes([8207]), "")
      .replaceAll(" ", "");
  RegExp regex = RegExp(
      r"^[\u0622\u0627\u0628\u067E\u062A-\u062C\u0686\u062D-\u0632\u0698\u0633-\u063A\u0641\u0642\u06A9\u06AF\u0644-\u0648\u06CC]+$",
      caseSensitive: true);
  if (regex.hasMatch(text)) {
    return true;
  }
  return false;
}

bool checkURLRegex(String text) {
  text = text ?? "";
  RegExp regExp = new RegExp(
    "^(https?|ftp|file)://[-a-zA-Z0-9+&@#/%?=~_|!:,.;]*[-a-zA-Z0-9+&@#/%=~_|]",
    caseSensitive: false,
    multiLine: false,
  );
  return regExp.hasMatch(text);
}

String removeExtraSpaceAndExtraChars(String searchText) {
  searchText = searchText.replaceAll(String.fromCharCode(8207), "");
  searchText = searchText.replaceAll(String.fromCharCode(8206), "");
  int oldLength = searchText.length;
  searchText = searchText.replaceAll("  ", " ");
  while (searchText.length != oldLength) {
    oldLength = searchText.length;
    searchText = searchText.replaceAll("  ", " ");
  }
  return searchText;
}
