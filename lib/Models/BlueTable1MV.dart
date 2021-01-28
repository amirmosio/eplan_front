import 'dart:collection';

import 'package:mhamrah/Values/Models.dart';
import 'package:mhamrah/Values/Utils.dart';
import 'package:mhamrah/Values/string.dart';
import 'package:mhamrah/Values/style.dart';
import 'package:flutter/cupertino.dart';

class AllBlue1Tables {
  String year;
  List<BlueTable1Data> allTables = [];

  factory AllBlue1Tables.fromJson(Map<String, dynamic> jsonData) {
    AllBlue1Tables c = AllBlue1Tables.initialEmpty(jsonData['year'].toString());
    for (int i = 0; i < jsonData['allTables'].length; i++) {
      c.allTables.add(BlueTable1Data.fromJson(jsonData['allTables'][i]));
    }
    return c;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> res = {'year': year};
    List<Map<String, dynamic>> tables = [];
    for (int i = 0; i < allTables.length; i++) {
      tables.add(allTables[i].toJson());
    }
    res['allTables'] = tables;
    return res;
  }

  AllBlue1Tables(this.year, this.allTables);

  AllBlue1Tables.initialEmpty(this.year);

  BlueTable1Data getBlueTable1ByName(String name) {
    for (int index = 0; index < allTables.length; index++) {
      if (allTables[index].name == name) {
        return allTables[index];
      }
    }
    return null;
  }

  String getNewWeekPlanName() {
    if (allTables.length == 0) {
      return "برنامه شماره ۱";
    }
    String lastName = allTables.last.name;
    String tablePersianNumber = lastName.split(" ")[2];
    int englishNumber =
        int.parse(replacePersianWithEnglishNumber(tablePersianNumber));
    englishNumber += 1;

    return "برنامه شماره " +
        replaceEnglishWithPersianNumber(englishNumber.toString());
  }

  List<String> getPlanListName() {
    List<String> res = [];
    for (int index = 0; index < allTables.length; index++) {
      res.add(allTables[index].name);
    }
    return res;
  }

  void updateSingleTable(BlueTable1Data b1Table) {
    BlueTable1Data c = getBlueTable1ByName(b1Table.name);
    if (c == null) {
      this.allTables.add(b1Table);
    } else {
      for (int i = 0; i < allTables.length; i++) {
        if (allTables[i].name == b1Table.name) {
          allTables[i] = b1Table;
        }
      }
    }
  }

  BlueTable1Data getLast() {
    return allTables[allTables.length - 1];
  }
}

class BlueTable1Data {
  String name;
  String startDate;
  String lessonIdentifier;
  List<B1DayPlan> daysSchedule = [
    B1DayPlan(0),
    B1DayPlan(1),
    B1DayPlan(2),
    B1DayPlan(3),
    B1DayPlan(4),
    B1DayPlan(5),
    B1DayPlan(6)
  ];

  factory BlueTable1Data.fromJson(Map<String, dynamic> jsonData) {
    BlueTable1Data c = BlueTable1Data.initialEmptyDate(jsonData['name'],
        jsonData['startDate'], (jsonData['lessonIdentifier'] ?? ""));
    for (int i = 0; i < jsonData['daysSchedule'].length; i++) {
      c.daysSchedule[i] = B1DayPlan.fromJson(jsonData['daysSchedule'][i]);
    }
    return c;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> res = {
      'name': name,
      'startDate': startDate,
      'lessonIdentifier': lessonIdentifier
    };
    List<Map<String, dynamic>> days = [];
    for (int i = 0; i < daysSchedule.length; i++) {
      days.add(daysSchedule[i].toJson());
    }
    res['daysSchedule'] = days;
    return res;
  }

  BlueTable1Data.initialData(
      this.name, this.daysSchedule, this.startDate, this.lessonIdentifier);

  BlueTable1Data.initialEmptyDate(
      this.name, this.startDate, this.lessonIdentifier);

  Map<String, int> getTotalLessonsTime() {
    Map<String, int> res = {};
    for (int day = 0; day < daysSchedule.length; day++) {
      for (int lesson = 0;
          lesson < daysSchedule[day].dayLessonPlans.length;
          lesson++) {
        B1LessonPlanPerDay b1lessonPlanPerDay =
            daysSchedule[day].dayLessonPlans[lesson];
        String lessonName = b1lessonPlanPerDay.lessonName;
        int extra = 0;
        try {
          extra = getTimeMinute(b1lessonPlanPerDay.durationTime);
        } catch (Exception) {}
        if (res.containsKey(lessonName)) {
          res[lessonName] = res[lessonName] + extra;
        } else {
          res[lessonName] = extra;
        }
      }
    }
    return res;
  }

  Map<String, int> getTotalLessonsTestNumber() {
    Map<String, int> res = {};
    for (int day = 0; day < daysSchedule.length; day++) {
      for (int lesson = 0;
          lesson < daysSchedule[day].dayLessonPlans.length;
          lesson++) {
        B1LessonPlanPerDay b1lessonPlanPerDay =
            daysSchedule[day].dayLessonPlans[lesson];
        String lessonName = b1lessonPlanPerDay.lessonName;
        int extra = 0;
        try {
          extra = int.parse(removeAllSpace(b1lessonPlanPerDay.testNumber));
        } catch (Exception) {}
        if (res.containsKey(lessonName)) {
          res[lessonName] = res[lessonName] + extra;
        } else {
          res[lessonName] = extra;
        }
      }
    }
    return res;
  }

  B1LessonPlanPerDay planNewDayPlan(int dayIndex) {
    List<B1LessonPlanPerDay> dayPlan = daysSchedule[dayIndex].dayLessonPlans;
    int newKeyNumber;
    if (dayPlan.length != 0) {
      String lastDayKey = dayPlan[dayPlan.length - 1].key;
      int lastDayKeyNumber = int.parse(lastDayKey.split("-")[1]);
      newKeyNumber = lastDayKeyNumber + 1;
    } else {
      newKeyNumber = 0;
    }
    B1LessonPlanPerDay l = B1LessonPlanPerDay();
    l.key = dayIndex.toString() + "-" + newKeyNumber.toString();
    daysSchedule[dayIndex].dayLessonPlans.add(l);
    return l;
  }

  int deleteLessonPerDay(int dayIndex, planKey) {
    int selectedIndex = getLessonPerDayIndex(dayIndex, planKey);
    daysSchedule[dayIndex].dayLessonPlans.removeAt(selectedIndex);
    return selectedIndex;
  }

  void updateLessonPerDay(
      int dayIndex, B1LessonPlanPerDay newLessonPlanPerDay) {
    int lessonPerDayIndex =
        getLessonPerDayIndex(dayIndex, newLessonPlanPerDay.key);
    B1LessonPlanPerDay selectedLessonPerDay =
        daysSchedule[dayIndex].dayLessonPlans[lessonPerDayIndex];
    selectedLessonPerDay.durationTime = newLessonPlanPerDay.durationTime;
    selectedLessonPerDay.testNumber = newLessonPlanPerDay.testNumber;
    selectedLessonPerDay.lessonName = newLessonPlanPerDay.lessonName;
  }

  int getLessonPerDayIndex(int dayIndex, String key) {
    List<B1LessonPlanPerDay> dayPlan = daysSchedule[dayIndex].dayLessonPlans;
    int selectedIndex = -1;
    for (int i = 0; i < dayPlan.length; i++) {
      if (key == dayPlan[i].key) {
        selectedIndex = i;
        break;
      }
    }
    return selectedIndex;
  }

  List<String> getDaysDate() {
    List<String> res = [];
    for (int i = 0; i < daysSchedule.length; i++) {
      res.add(daysSchedule[i].dayDate);
    }
    return res;
  }

  List<CircularChartModel> getCircularLessonData(String studentEduAndMajor) {
    Map<String, int> data = getTotalLessonsTime();
    List<CircularChartModel> res = [];
    data.forEach((key, value) {
      if (getLessonType(studentEduAndMajor, key) != 2) {
        Color color = getLessonColorByNameAndMajor(studentEduAndMajor, key);
        Color c =
            getColorFromARGB(color.alpha, color.red, color.green, color.blue);
        CircularChartModel cdata = CircularChartModel(key, value, c);
        res.add(cdata);
      }
    });
    return res;
  }
}

class B1DayPlan {
  int dayNumber;
  String dayDate;
  List<B1LessonPlanPerDay> dayLessonPlans = [];

  B1DayPlan(this.dayNumber) {
    initialAllLessons();
  }

  B1DayPlan.initialData(this.dayNumber, this.dayDate, this.dayLessonPlans);

  B1DayPlan.getEmptyInitial(this.dayNumber, this.dayDate) {
//    initialAllLessons();
  }

  void initialAllLessons() {
    List<B1LessonPlanPerDay> res = [];
//    for (int i = 0; i < mathLessons.length; i++) {
//      B1LessonPlanPerDay lpp = B1LessonPlanPerDay();
//      lpp.key = dayNumber.toString() + "-" + i.toString();
//      lpp.durationTime = "";
//      lpp.lessonName = "mathLessons[i]";
//      lpp.testNumber = "";
//      res.add(lpp);
//    }
    dayLessonPlans = res;
  }

  int getTotalDayTimeMinute() {
    int res = 0;
    for (int lIndex = 0; lIndex < dayLessonPlans.length; lIndex++) {
      if (!list_motefareghe.contains(dayLessonPlans[lIndex].lessonName)) {
        res += getTimeMinute(dayLessonPlans[lIndex].durationTime);
      }
    }
    return res;
  }

  List<int> getTotalDayTest() {
    int totalTest = 0;
    int wrong = 0;
    int right = 0;
    int empty = 0;
    for (int lIndex = 0; lIndex < dayLessonPlans.length; lIndex++) {
      try {
        String testNumber = dayLessonPlans[lIndex].testNumber;
        testNumber = replacePersianWithEnglishNumber(testNumber);
        testNumber = testNumber.replaceAll(" ", '');
        totalTest += int.parse(testNumber);
      } catch (Exception) {}
      try {
        String testNumber = dayLessonPlans[lIndex].wrongTestNumber;
        testNumber = replacePersianWithEnglishNumber(testNumber);
        testNumber = testNumber.replaceAll(" ", '');
        wrong += int.parse(testNumber);
      } catch (Exception) {}
      try {
        String testNumber = dayLessonPlans[lIndex].rightTestNumber;
        testNumber = replacePersianWithEnglishNumber(testNumber);
        testNumber = testNumber.replaceAll(" ", '');
        right += int.parse(testNumber);
      } catch (Exception) {}
      try {
        String testNumber = dayLessonPlans[lIndex].emptyTestNumber;
        testNumber = replacePersianWithEnglishNumber(testNumber);
        testNumber = testNumber.replaceAll(" ", '');
        empty += int.parse(testNumber);
      } catch (Exception) {}
    }
    return [totalTest, wrong, right, empty];
  }

  B1DayPlan getHalfCopyOfDayPlan(int dayIndex) {
    B1DayPlan copyDayPlan = B1DayPlan(dayIndex);
    List<B1LessonPlanPerDay> halfCopyDayLessonPlans = [];
    for (int index = 0; index < dayLessonPlans.length; index++) {
      B1LessonPlanPerDay l = B1LessonPlanPerDay();
      l.key = dayIndex.toString() + "-" + index.toString();
      l.durationTime = dayLessonPlans[index].durationTime;
      halfCopyDayLessonPlans.add(l);
    }
    copyDayPlan.dayLessonPlans = halfCopyDayLessonPlans;
    return copyDayPlan;
  }

  factory B1DayPlan.fromJson(dynamic json) {
    B1DayPlan d = B1DayPlan(json['dayNumber']);
    d.dayDate = json['dayDate'];
    d.dayLessonPlans = [];
    for (int i = 0; i < json['dayLessonPlans'].length; i++) {
      d.dayLessonPlans
          .add(B1LessonPlanPerDay.fromJson(json['dayLessonPlans'][i]));
    }
    return d;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> res = {'dayNumber': dayNumber, 'dayDate': dayDate};
    List<Map<String, dynamic>> dayLessons = [];
    for (int i = 0; i < dayLessonPlans.length; i++) {
      dayLessons.add(dayLessonPlans[i].toJson());
    }
    res['dayLessonPlans'] = dayLessons;
    return res;
  }
}

class B1LessonPlanPerDay {
  String key = "";
  String durationTime = "";
  String testNumber = "";
  String wrongTestNumber = "";
  String rightTestNumber = "";
  String emptyTestNumber = "";
  String lessonName = "";

  B1LessonPlanPerDay();

  B1LessonPlanPerDay.initialData(
      this.key,
      this.durationTime,
      this.testNumber,
      this.wrongTestNumber,
      this.rightTestNumber,
      this.emptyTestNumber,
      this.lessonName);

  factory B1LessonPlanPerDay.fromJson(dynamic json) {
    B1LessonPlanPerDay l = B1LessonPlanPerDay();
    l.key = json['key'];
    l.testNumber = json['testNumber'];
    l.wrongTestNumber = json['wrongTestNumber'] ?? "";
    l.rightTestNumber = json['rightTestNumber'] ?? "";
    l.emptyTestNumber = json['emptyTestNumber'] ?? "";
    l.durationTime = json['durationTime'];
    l.lessonName = json['lessonName'];
    return l;
  }

  Map<String, dynamic> toJson() => {
        'key': key,
        'lessonName': lessonName,
        'testNumber': testNumber,
        'durationTime': durationTime,
        'wrongTestNumber': wrongTestNumber,
        'rightTestNumber': rightTestNumber,
        'emptyTestNumber': emptyTestNumber,
      };
}
