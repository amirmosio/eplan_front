import 'package:mhamrah/Values/Utils.dart';
import 'package:mhamrah/Values/string.dart';
import 'package:flutter/cupertino.dart';

class AllBlue2Tables {
  String year;
  List<BlueTable2Data> allTables = [];

  factory AllBlue2Tables.fromJson(Map<String, dynamic> jsonData) {
    AllBlue2Tables c = AllBlue2Tables.initialEmpty(jsonData['year'].toString());
    for (int i = 0; i < jsonData['allTables'].length; i++) {
      c.allTables.add(BlueTable2Data.fromJson(jsonData['allTables'][i]));
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

  AllBlue2Tables(this.year, this.allTables);

  AllBlue2Tables.initialEmpty(this.year);

  BlueTable2Data getBlueTable2ByName(String name) {
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

  void updateSingleTable(BlueTable2Data b2Table) {
    BlueTable2Data c = getBlueTable2ByName(b2Table.name);
    if (c == null) {
      this.allTables.add(b2Table);
    } else {
      for (int i = 0; i < allTables.length; i++) {
        if (allTables[i].name == b2Table.name) {
          allTables[i] = b2Table;
        }
      }
    }
  }

  BlueTable2Data getLast() {
    return allTables[allTables.length - 1];
  }
}

class BlueTable2Data {
  String name;
  String startDate;
  List<B2DayPlan> daysSchedule = [
    B2DayPlan(0),
    B2DayPlan(1),
    B2DayPlan(2),
    B2DayPlan(3),
    B2DayPlan(4),
    B2DayPlan(5),
    B2DayPlan(6)
  ];

  factory BlueTable2Data.fromJson(Map<String, dynamic> jsonData) {
    BlueTable2Data c = BlueTable2Data.initialEmptyDate(
        jsonData['name'], jsonData['startDate']);
    for (int i = 0; i < jsonData['daysSchedule'].length; i++) {
      c.daysSchedule[i] = B2DayPlan.fromJson(jsonData['daysSchedule'][i]);
    }
    return c;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> res = {'name': name, 'startDate': startDate};
    List<Map<String, dynamic>> days = [];
    for (int i = 0; i < daysSchedule.length; i++) {
      days.add(daysSchedule[i].toJson());
    }
    res['daysSchedule'] = days;
    return res;
  }

  BlueTable2Data.initialData(this.name, this.daysSchedule, this.startDate);

  BlueTable2Data.initialEmptyDate(this.name, this.startDate);

  B2LessonPerDay getNewPlanLesson(int dayIndex) {
    List<B2LessonPerDay> dayPlan = daysSchedule[dayIndex].dayLessons;
    int newKeyNumber;
    if (dayPlan.length != 0) {
      String lastDayKey = dayPlan[dayPlan.length - 1].key;
      int lastDayKeyNumber = int.parse(lastDayKey.split("-")[1]);
      newKeyNumber = lastDayKeyNumber + 1;
    } else {
      newKeyNumber = 0;
    }
    B2LessonPerDay l = B2LessonPerDay();
    l.key = dayIndex.toString() + "-" + newKeyNumber.toString();
    daysSchedule[dayIndex].dayLessons.add(l);
    return l;
  }

  String getNewKey(dayIndex) {
    List<B2LessonPerDay> dayPlan = daysSchedule[dayIndex].dayLessons;
    int newKeyNumber;
    if (dayPlan.length != 0) {
      String lastDayKey = dayPlan[dayPlan.length - 1].key;
      int lastDayKeyNumber = int.parse(lastDayKey.split("-")[1]);
      newKeyNumber = lastDayKeyNumber + 1;
    } else {
      newKeyNumber = 0;
    }
    return dayIndex.toString() + "-" + newKeyNumber.toString();
  }

  int deleteLessonPerDay(int dayIndex, planKey) {
    int selectedIndex = getLessonPerDayIndex(dayIndex, planKey);
    daysSchedule[dayIndex].dayLessons.removeAt(selectedIndex);
    return selectedIndex;
  }

//  void updateLessonPerDay(
//      int dayIndex, planKey, B2LessonPerDay newLessonPlanPerDay) {
//    int lessonPerDayIndex = getLessonPerDayIndex(dayIndex, planKey);
//    B2LessonPerDay selectedLessonPerDay =
//        daysSchedule[dayIndex].dayLessons[lessonPerDayIndex];
//    selectedLessonPerDay.durationTime = newLessonPlanPerDay.durationTime;
//    selectedLessonPerDay.lessonName = newLessonPlanPerDay.lessonName;
//  }

  int getLessonPerDayIndex(int dayIndex, String key) {
    List<B2LessonPerDay> dayPlan = daysSchedule[dayIndex].dayLessons;
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
}

class B2DayPlan {
  int dayNumber;
  String dayDate;
  List<List<String>> dayPlan = []; //put the day lesson keys in there
  List<B2LessonPerDay> dayLessons = [];

  B2DayPlan(this.dayNumber);

  B2DayPlan.initialData(this.dayNumber, this.dayDate, this.dayLessons);

  B2DayPlan.getEmptyInitial(this.dayNumber, this.dayDate, this.dayLessons) {
    setEmptyDayPlan();
  }

  void setEmptyDayPlan() {
    List<List<String>> res = [];
    for (int hour = 0; hour < 24; hour++) {
      List<String> emptyHour = [];
      for (int tenMin = 0; tenMin < 4; tenMin++) {
        emptyHour.add(null);
      }
      res.add(emptyHour);
    }
    dayPlan = res;
  }

  Map<String, double> getDedicatedTimeForAllLessons() {
    Map<String, double> result = {};
    for (int hour = 0; hour < dayPlan.length; hour++) {
      for (int hourPart = 0; hourPart < dayPlan[hourPart].length; hourPart++) {
        if (dayPlan[hour][hourPart] != null) {
          result[dayPlan[hour][hourPart]] =
              (result[dayPlan[hour][hourPart]] ?? 0) + 15;
        }
      }
    }
    return result;
  }

  B2LessonPerDay getB2LessonPerDayByKey(String key) {
    for (int i = 0; i < dayLessons.length; i++) {
      if (dayLessons[i].key == key) {
        return dayLessons[i];
      }
    }
    return null;
  }

  factory B2DayPlan.fromJson(dynamic json) {
    B2DayPlan d = B2DayPlan(json['dayNumber']);
    d.dayDate = json['dayDate'];
    List<List<String>> daysLesson = [];
    for (int hour = 0; hour < json['dayPlan'].length; hour++) {
      List<String> emptyHour = [];
      for (int tenMin = 0; tenMin < json['dayPlan'][hour].length; tenMin++) {
        emptyHour.add(json['dayPlan'][hour][tenMin]);
      }
      daysLesson.add(emptyHour);
    }
    d.dayPlan = daysLesson;
    d.dayLessons = [];
    for (int i = 0; i < json['dayLessons'].length; i++) {
      d.dayLessons.add(B2LessonPerDay.fromJson(json['dayLessons'][i]));
    }
    return d;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> res = {
      'dayNumber': dayNumber,
      'dayDate': dayDate,
      'dayPlan': dayPlan
    };
    List<Map<String, dynamic>> resDayLessons = [];
    for (int i = 0; i < dayLessons.length; i++) {
      resDayLessons.add(dayLessons[i].toJson());
    }
    res['dayLessons'] = dayLessons;
    return res;
  }
}

class B2LessonPerDay {
  String key = "";
  String predictedDurationTime = "";
  String finalDurationTime = "";
  String predictedTestNumber = "";
  String finalTestNumber = "";
  String lessonName = "";
  List<int> lessonColor = [255, 150, 150, 150];

  B2LessonPerDay();

  B2LessonPerDay.initialData(data) {
    key = data[0];
    predictedDurationTime = data[1];
    predictedTestNumber = data[2];
    lessonName = data[3];
    lessonColor = data[4];
  }

  int getPredictedMinute() {
    return getTimeMinute(predictedDurationTime);
  }

  factory B2LessonPerDay.fromJson(dynamic json) {
    B2LessonPerDay l = B2LessonPerDay();
    l.key = json['key'];
    l.predictedDurationTime = json['predictedDurationTime'];
    l.finalDurationTime = json['finalDurationTime'];
    l.predictedTestNumber = json['predictedTestNumber'];
    l.finalTestNumber = json['finalTestNumber'];
    l.lessonName = json['lessonName'];
    l.lessonColor = [];
    for (int i = 0; i < json['lessonColor'].length; i++) {
      l.lessonColor.add(json['lessonColor'][i]);
    }
    return l;
  }

  Map<String, dynamic> toJson() => {
        'key': key,
        'predictedDurationTime': predictedDurationTime,
        'finalDurationTime': finalDurationTime,
        'predictedTestNumber': predictedTestNumber,
        'finalTestNumber': finalTestNumber,
        'lessonName': lessonName,
        'lessonColor': lessonColor
      };
}
