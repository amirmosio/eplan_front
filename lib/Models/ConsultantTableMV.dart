import 'dart:collection';

import 'package:mhamrah/Values/Models.dart';
import 'package:mhamrah/Values/Utils.dart';
import 'package:mhamrah/Values/string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'dart:io' as io;

import 'ChatMV.dart';

class ConsultantAllTables {
  String year;
  List<ConsultantTableModel> allTables = [];
  bool studentAccess = false;

  factory ConsultantAllTables.fromJson(Map<String, dynamic> jsonData) {
    ConsultantAllTables c =
        ConsultantAllTables.initialEmpty(jsonData['year'].toString());
    for (int i = 0; i < jsonData['allTables'].length; i++) {
      c.allTables.add(ConsultantTableModel.fromJson(jsonData['allTables'][i]));
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

  ConsultantAllTables(this.year, this.allTables);

  ConsultantAllTables.initialEmpty(this.year);

  ConsultantTableModel getConsultantTableByName(String name) {
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
    } else if (allTables.length == 1 &&
        allTables.last.name == emptyInitialPlanName) {
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

  void updateSingleTable(ConsultantTableModel cTable) {
    ConsultantTableModel c = getConsultantTableByName(cTable.name);
    if (c == null) {
      this.allTables.add(cTable);
    } else {
      for (int i = 0; i < allTables.length; i++) {
        if (allTables[i].name == cTable.name) {
          allTables[i] = cTable;
        }
      }
    }
  }

  ConsultantTableModel getNewTablePlan(String startDate) {
    String newName = getNewWeekPlanName();
    ConsultantTableModel c =
        ConsultantTableModel.emptyInitialData(newName, startDate);
    allTables.add(c);
    return c;
  }

  List<String> getPlanListName() {
    List<String> res = [];
    for (int index = 0; index < allTables.length; index++) {
      res.add(allTables[index].name);
    }
    return res;
  }

  ConsultantTableModel getLast() {
    return allTables[allTables.length - 1];
  }
}

class ConsultantTableModel {
  String name;
  String startDate;
  List<CDayPlan> daysSchedule = [
    CDayPlan(),
    CDayPlan(),
    CDayPlan(),
    CDayPlan(),
    CDayPlan(),
    CDayPlan(),
    CDayPlan()
  ];

  bool canBeVolumeBaseTable() {
    for (int day = 0; day < daysSchedule.length; day++) {
      for (int lesson = 0;
          lesson < daysSchedule[day].dayLessonPlans.length;
          lesson++) {
        CLessonPlanPerDay lessonPlanPerDay =
            daysSchedule[day].dayLessonPlans[lesson];
        if (lessonPlanPerDay.startTime != "") {
          return false;
        }
      }
    }
    return true;
  }

  factory ConsultantTableModel.fromJson(Map<String, dynamic> jsonData) {
    ConsultantTableModel c = ConsultantTableModel.emptyInitialData(
        jsonData['name'], jsonData['startDate']);
    for (int i = 0; i < jsonData['daysSchedule'].length; i++) {
      c.daysSchedule[i] = CDayPlan.fromJson(jsonData['daysSchedule'][i]);
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

  Map<String, dynamic> toCopyJson() {
    Map<String, dynamic> res = {'name': name, 'startDate': startDate};
    List<Map<String, dynamic>> days = [];
    for (int i = 0; i < daysSchedule.length; i++) {
      days.add(daysSchedule[i].toCopyJson());
    }
    res['daysSchedule'] = days;
    return res;
  }

  ConsultantTableModel.initialData(
      this.name, this.daysSchedule, this.startDate);

  ConsultantTableModel.emptyInitialData(this.name, this.startDate);

  CLessonPlanPerDay planNewDayPlan(int dayIndex) {
    List<CLessonPlanPerDay> dayPlan = daysSchedule[dayIndex].dayLessonPlans;
    int newKeyNumber;
    if (dayPlan.length != 0) {
      String lastDayKey = dayPlan[dayPlan.length - 1].key;
      int lastDayKeyNumber = int.parse(lastDayKey.split("-")[1]);
      newKeyNumber = lastDayKeyNumber + 1;
    } else {
      newKeyNumber = 0;
    }
    CLessonPlanPerDay l = CLessonPlanPerDay();
    l.key = dayIndex.toString() + "-" + newKeyNumber.toString();
    daysSchedule[dayIndex].dayLessonPlans.add(l);
    return l;
  }

  String getNewDayPlanKey(int dayIndex) {
    List<CLessonPlanPerDay> dayPlan = daysSchedule[dayIndex].dayLessonPlans;
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
    daysSchedule[dayIndex].dayLessonPlans.removeAt(selectedIndex);
    return selectedIndex;
  }

  void updateLessonPerDay(int dayIndex, CLessonPlanPerDay newLessonPlanPerDay) {
    int lessonPerDayIndex =
        getLessonPerDayIndex(dayIndex, newLessonPlanPerDay.key);
    CLessonPlanPerDay selectedLessonPerDay =
        daysSchedule[dayIndex].dayLessonPlans[lessonPerDayIndex];
    selectedLessonPerDay.startTime = newLessonPlanPerDay.startTime;
    selectedLessonPerDay.endTime = newLessonPlanPerDay.endTime;
    selectedLessonPerDay.lessonName = newLessonPlanPerDay.lessonName;
    selectedLessonPerDay.description = newLessonPlanPerDay.description;
    selectedLessonPerDay.hasVoiceFile = newLessonPlanPerDay.hasVoiceFile;
    selectedLessonPerDay.importance = newLessonPlanPerDay.importance;
  }

  int getLessonPerDayIndex(int dayIndex, String key) {
    List<CLessonPlanPerDay> dayPlan = daysSchedule[dayIndex].dayLessonPlans;
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

  List<int> getDaysCompletePercent() {
    List<int> res = [];
    for (int i = 0; i < daysSchedule.length; i++) {
      res.add(daysSchedule[i].getCompletePercent());
    }
    return res;
  }
}

class CDayPlan {
  int dayNumber;
  String dayDate;
  List<CLessonPlanPerDay> dayLessonPlans = [];
  String dailyWakeUpTime = "";
  String dailyScore = "";

  CDayPlan();

  CDayPlan.initialData(this.dayNumber, this.dayDate, this.dayLessonPlans);

  CDayPlan getHalfCopyOfDayPlan(int dayIndex) {
    CDayPlan copyDayPlan = CDayPlan();
    List<CLessonPlanPerDay> halfCopyDayLessonPlans = [];
    for (int index = 0; index < dayLessonPlans.length; index++) {
      CLessonPlanPerDay l = CLessonPlanPerDay();
      l.key = dayIndex.toString() + "-" + index.toString();
      l.startTime = dayLessonPlans[index].startTime;
      l.endTime = dayLessonPlans[index].endTime;
      halfCopyDayLessonPlans.add(l);
    }
    copyDayPlan.dayNumber = dayNumber;
    copyDayPlan.dayDate = dayDate;
    copyDayPlan.dayLessonPlans = halfCopyDayLessonPlans;
    return copyDayPlan;
  }

  factory CDayPlan.fromJson(dynamic json) {
    CDayPlan d = CDayPlan();
    d.dayNumber = json['dayNumber'];
    d.dayDate = json['dayDate'].toString();
    d.dailyWakeUpTime = json['dailyPresentTime'] ?? "";
    d.dailyScore = json['dailyScore'] ?? "";
    d.dayLessonPlans = [];
    for (int i = 0; i < json['dayLessonPlans'].length; i++) {
      d.dayLessonPlans
          .add(CLessonPlanPerDay.fromJson(json['dayLessonPlans'][i]));
    }
    return d;
  }

  int getCompletePercent() {
    if (dayLessonPlans.length == 0) {
      return 0;
    } else {
      int total = 0;
      int count = 0;
      for (int i = 0; i < dayLessonPlans.length; i++) {
        int time = 0;
        if (dayLessonPlans[i].endTime.trim() == "" &&
            dayLessonPlans[i].startTime.trim() == "") {
          time = 60;
        } else if (dayLessonPlans[i].endTime.trim() == "") {
          time = getTimeMinute(dayLessonPlans[i].startTime);
        } else if (dayLessonPlans[i].startTime.trim() == "") {
          time = getTimeMinute(dayLessonPlans[i].endTime);
        } else {
          time = getTimeMinute(dayLessonPlans[i].endTime) -
              getTimeMinute(dayLessonPlans[i].startTime);
        }
        if (time < 0) {
          time = 24 * 60 + time;
        }
        total += time;
        if (dayLessonPlans[i].isComplete) {
          count += time;
        }
      }
      return total == 0 ? 0 : ((count / total) * 100).round();
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> res = {
      'dayNumber': dayNumber,
      'dayDate': dayDate,
      'dailyScore': dailyScore,
      'dailyPresentTime': dailyWakeUpTime
    };
    List<Map<String, dynamic>> dayLessons = [];
    for (int i = 0; i < dayLessonPlans.length; i++) {
      dayLessons.add(dayLessonPlans[i].toJson());
    }
    res['dayLessonPlans'] = dayLessons;
    return res;
  }

  Map<String, dynamic> toCopyJson() {
    Map<String, dynamic> res = {'dayNumber': dayNumber, 'dayDate': dayDate};
    List<Map<String, dynamic>> dayLessons = [];
    for (int i = 0; i < dayLessonPlans.length; i++) {
      dayLessons.add(dayLessonPlans[i].toCopyJson());
    }
    res['dayLessonPlans'] = dayLessons;
    return res;
  }
}

class CLessonPlanPerDay {
  String key = "-";
  String startTime = "";
  String endTime = "";
  String lessonName = "";
  String description = "";
  CustomFile voiceFile;
  bool hasVoiceFile = false;
  bool isComplete = false;
  bool importance = false;

  CLessonPlanPerDay();

  CLessonPlanPerDay.initialData(
      this.key,
      this.startTime,
      this.endTime,
      this.lessonName,
      this.description,
      this.voiceFile,
      this.hasVoiceFile,
      this.isComplete,
      this.importance);

  factory CLessonPlanPerDay.fromJson(Map<String, dynamic> json) {
    CLessonPlanPerDay l = CLessonPlanPerDay();
    l.key = json['key'];
    l.startTime = json['startTime'];
    l.endTime = json['endTime'];
    l.lessonName = json['lessonName'];
    l.description = json['description'];
    l.hasVoiceFile =
        json.keys.contains("hasVoiceFile") ? json['hasVoiceFile'] : false;
    l.isComplete = json['isCompleted'];
    l.importance = json['importance'];
    return l;
  }

  Map<String, dynamic> toJson() => {
        'key': key,
        'startTime': startTime,
        'endTime': endTime,
        'lessonName': lessonName,
        'description': description,
        'hasVoiceFile': hasVoiceFile,
        'isCompleted': isComplete,
        'importance': importance,
      };

  Map<String, dynamic> toCopyJson() => {
        'key': key,
        'startTime': startTime,
        'endTime': endTime,
        'lessonName': lessonName,
        'description': description,
        'hasVoiceFile': hasVoiceFile,
        'isCompleted': false,
        'importance': importance
      };
}
