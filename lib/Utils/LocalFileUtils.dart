import 'dart:convert';

import 'package:mhamrah/ConnectionService/HTTPService.dart';
import 'package:mhamrah/Models/BlueTable1MV.dart';
import 'package:mhamrah/Models/BlueTable2MV.dart';
import 'package:mhamrah/Models/ChatMV.dart';
import 'package:mhamrah/Models/ConsultantTableMV.dart';
import 'package:mhamrah/Models/StudentListPageMV.dart';
import 'package:mhamrah/Pages/ChatRoom/ChatMessage.dart';
import 'package:mhamrah/Pages/User/FirstPage.dart';
import 'package:flutter/animation.dart';

import 'package:mhamrah/Models/UserMV.dart';

import 'LocalStorage/localstorage.dart';

//import 'package:zarinpal/zarinpal.dart';

class LSM {
  static LocalStorage storage = new LocalStorage('app_data_mhamrah');

  /// users

  static List<String> getUsernameAuthSync() {
    storage.ready;
    String consultant = storage.getItem('consultant');
    if (consultant != null) {
      Consultant c = Consultant.fromJson(json.decode(consultant));
      return [
        c.username,
        c.authentication_string
      ]; //TODO this should become 0 later
    }

    String student = storage.getItem('student');
    if (student != null) {
      Student s = Student.fromJson(json.decode(student));
      return [s.username, s.authentication_string];
    }

    return ["", ""];
  }

  static Future<Student> getStudent() async {
    await storage.ready;
    String student = storage.getItem('student');
    if (student == null) {
      return null;
    }
    Student s = Student.fromJson(json.decode(student));
    return s;
  }

  static Student getStudentSync() {
    storage.ready;
    String student = storage.getItem('student');
    if (student == null) {
      return null;
    }
    Student s = Student.fromJson(json.decode(student));
    return s;
  }

  static void updateStudentInfo(Student student) async {
    await storage.ready;
    String jsonString;
    if (student == null) {
      jsonString = null;
    } else {
      jsonString = json.encode(student.toJson());
    }
    storage.setItem('student', jsonString);
    storage.setItem('consultant', null);
    FirstPage.studentAccount = student;
    FirstPage.userType = 1;
  }

  static Future<Consultant> getConsultant() async {
    await storage.ready;
    String consultant = storage.getItem('consultant');
    if (consultant == null) {
      return null;
    }
    Consultant c = Consultant.fromJson(json.decode(consultant));
    return c;
  }

  static Consultant getConsultantSync() {
    storage.ready;
    String consultant = storage.getItem('consultant');
    if (consultant == null) {
      return null;
    }
    Consultant c = Consultant.fromJson(json.decode(consultant));
    return c;
  }

  static void updateConsultantInfo(Consultant consultant) async {
    await storage.ready;
    String jsonString;
    if (consultant == null) {
      jsonString = null;
    } else {
      jsonString = json.encode(consultant.toJson());
    }
    await storage.setItem('consultant', jsonString);
    await storage.setItem('student', null);
    FirstPage.consultantAccount = consultant;
    FirstPage.userType = 0;
  }

  static Future<int> getUserMode() async {
    try {
      await storage.ready;
      String consultant = await storage.getItem('consultant');
      if (consultant != null) {
        return 0;
      }

      String student = storage.getItem('student');
      if (student != null) {
        return 1;
      }
    } catch (e) {
      return -1;
    }

    return -1;
  }

  static int getUserModeSync() {
    storage.ready;
    String consultant = storage.getItem('consultant');
    if (consultant != null) {
      return 0;
    }

    String student = storage.getItem('student');
    if (student != null) {
      return 1;
    }

    return -1;
  }

  /// settinig
  static Future<ConsultantSetting> getConsultantSetting() async {
    await storage.ready;
    String setting = storage.getItem('consultantSetting');
    if (setting == null) {
      return ConsultantSetting();
    }
    ConsultantSetting c = ConsultantSetting.fromJson(json.decode(setting));
    return c;
  }

  static ConsultantSetting getConsultantSettingSync() {
    storage.ready;
    String setting = storage.getItem('consultantSetting');
    if (setting == null) {
      return ConsultantSetting();
    }
    ConsultantSetting c = ConsultantSetting.fromJson(json.decode(setting));
    return c;
  }

  static void setConsultantSetting(ConsultantSetting setting) async {
    await storage.ready;
    String jsonString;
    if (setting == null) {
      jsonString = null;
    } else {
      jsonString = json.encode(setting.toJson());
    }
    storage.setItem('consultantSetting', jsonString);
  }

  static Future<StudentSetting> getStudentSetting() async {
    await storage.ready;
    String setting = storage.getItem('studentSetting');
    if (setting == null) {
      return StudentSetting();
    }
    StudentSetting c = StudentSetting.fromJson(json.decode(setting));
    return c;
  }

  static StudentSetting getStudentSettingSync() {
    storage.ready;
    String setting = storage.getItem('studentSetting');
    if (setting == null) {
      return StudentSetting();
    }
    StudentSetting c = StudentSetting.fromJson(json.decode(setting));
    return c;
  }

  static void setStudentSetting(StudentSetting setting) async {
    await storage.ready;
    String jsonString;
    if (setting == null) {
      jsonString = null;
    } else {
      jsonString = json.encode(setting.toJson());
    }
    storage.setItem('studentSetting', jsonString);
  }

  /// tables
  static Future<ConsultantAllTables> getConsultantAllTables(
      String username) async {
    await storage.ready;
    String allConsultant = storage.getItem('consultantAllTables:' + username);
    if (allConsultant == null) {
      return null;
    }
    ConsultantAllTables c =
        ConsultantAllTables.fromJson(json.decode(allConsultant));
    return c;
  }

  static ConsultantAllTables getConsultantAllTablesSync(String username) {
    storage.ready;
    String allConsultant = storage.getItem('consultantAllTables:' + username);
    if (allConsultant == null) {
      return null;
    }
    ConsultantAllTables c =
        ConsultantAllTables.fromJson(json.decode(allConsultant));
    return c;
  }

  static void setConsultantAllTables(
      String username, ConsultantAllTables consultantAllTables) async {
    await storage.ready;
    String jsonString;
    if (consultantAllTables == null) {
      jsonString = null;
    } else {
      jsonString = json.encode(consultantAllTables.toJson());
    }
    storage.setItem('consultantAllTables:' + username, jsonString);
  }

  static Future<AllBlue1Tables> getBlue1AllTables(String username) async {
    await storage.ready;
    String allBlue1 = storage.getItem('blue1AllTables:' + username);
    if (allBlue1 == null) {
      return null;
    }
    AllBlue1Tables c = AllBlue1Tables.fromJson(json.decode(allBlue1));
    return c;
  }

  static void setBlue1AllTables(
      String username, AllBlue1Tables allBlue1Tables) async {
    await storage.ready;
    String jsonString;
    if (allBlue1Tables == null) {
      jsonString = null;
    } else {
      jsonString = json.encode(allBlue1Tables.toJson());
    }
    storage.setItem('blue1AllTables:' + username, jsonString);
  }

  static Future<AllBlue2Tables> getBlue2AllTables(String username) async {
    await storage.ready;
    String allBlue2Tables = storage.getItem('blue2AllTables:' + username);
    if (allBlue2Tables == null) {
      return null;
    }
    AllBlue2Tables c = AllBlue2Tables.fromJson(json.decode(allBlue2Tables));
    return c;
  }

  static void setBlue2AllTables(
      String username, AllBlue2Tables allBlue2Tables) async {
    await storage.ready;
    String jsonString;
    if (allBlue2Tables == null) {
      jsonString = null;
    } else {
      jsonString = json.encode(allBlue2Tables.toJson());
    }
    storage.setItem('blue2AllTables:' + username, jsonString);
  }

  /// student list
  static Future<StudentListData> getAcceptedStudentListData() async {
    await storage.ready;
    String studentListData = storage.getItem('acceptedStudentListData');
    if (studentListData == null) {
      return null;
    }
    StudentListData c = StudentListData.fromJson(json.decode(studentListData));
    return c;
  }

  static StudentListData getAcceptedStudentListDataSync() {
    storage.ready;
    String studentListData = storage.getItem('acceptedStudentListData');
    if (studentListData == null) {
      return null;
    }
    StudentListData c = StudentListData.fromJson(json.decode(studentListData));
    return c;
  }

  static void setAcceptedStudentListData(
      StudentListData studentListData) async {
    await storage.ready;
    String jsonString;
    if (studentListData == null) {
      jsonString = null;
    } else {
      jsonString = json.encode(studentListData.toJson());
    }
    storage.setItem('acceptedStudentListData', jsonString);
  }

  static Future<StudentListData> getPendingStudentListData() async {
    await storage.ready;
    String studentListData = storage.getItem('pendingStudentListData');
    if (studentListData == null) {
      return null;
    }
    StudentListData c = StudentListData.fromJson(json.decode(studentListData));
    return c;
  }

  static StudentListData getPendingStudentListDataSync() {
    storage.ready;
    String studentListData = storage.getItem('pendingStudentListData');
    if (studentListData == null) {
      return null;
    }
    StudentListData c = StudentListData.fromJson(json.decode(studentListData));
    return c;
  }

  static void setPendingStudentListData(StudentListData studentListData) async {
    await storage.ready;
    String jsonString;
    if (studentListData == null) {
      jsonString = null;
    } else {
      jsonString = json.encode(studentListData.toJson());
    }
    storage.setItem('pendingStudentListData', jsonString);
  }

  /// message
  static void setMessageList(
      List<String> accessUsers, ChatMessageDataList messages) async {
    await storage.ready;
    String jsonString;
    if (messages == null) {
      jsonString = null;
    } else {
      jsonString = json.encode(messages.toJson());
      storage.setItem(
          ConnectionService.getUsersGroupCode(accessUsers), jsonString);
    }
  }

  static Future<ChatMessageDataList> getMessageList(
      List<String> accessUsers) async {
    await storage.ready;
    String messageDataList =
        storage.getItem(ConnectionService.getUsersGroupCode(accessUsers));
    if (messageDataList == null || messageDataList == 'null') {
      return null;
    }
    ChatMessageDataList c =
        ChatMessageDataList.fromJson(json.decode(messageDataList), status: 1);
    return c;
  }

  static ChatMessageDataList getMessageListSync(List<String> accessUsers) {
    storage.ready;
    String messageDataList =
        storage.getItem(ConnectionService.getUsersGroupCode(accessUsers));
    if (messageDataList == null || messageDataList == 'null') {
      return null;
    }
    ChatMessageDataList c =
        ChatMessageDataList.fromJson(json.decode(messageDataList), status: 1);
    return c;
  }

  /// theme
  static Future<String> getTheme() async {
    await storage.ready;
    String theme = storage.getItem('theme');
    if (theme == null) {
      return "";
    }
    return theme;
  }

  static void setTheme(String theme) async {
    await storage.ready;
    storage.setItem('theme', theme);
  }

  static String getThemeSync() {
    storage.ready;
    String theme = storage.getItem('theme');
    if (theme == null) {
      return "";
    }
    return theme;
  }

  static void clearWholeStorageExceptTheme() async {
    String theme = await LSM.getTheme();
    await storage.ready;
    await storage.clear();
    await setTheme(theme);
  }
}

class FBT {
  static LocalStorage storage = new LocalStorage('firebase_token');

  static String getFirebaseTokenSync() {
    storage.ready;
    String token = storage.getItem('token') ?? "";
    return token;
  }

  static void setFirebaseToken(String token) async {
    await storage.ready;
    storage.setItem('token', token);
  }

//  static Future<PaymentRequest> getLastPaymentRequest() async {
//    await storage.ready;
//    String paymentString = storage.getItem('lastPayment') ?? "";
//    if (paymentString == "" || paymentString == null) {
//      return null;
//    }
//    PaymentRequest pay = PaymentRequest.fromJson(json.decode(paymentString));
//    return pay;
//  }
//
//  static void setLastPaymentRequest(PaymentRequest payment) async {
//    await storage.ready;
//    if (payment == null) {
//      storage.setItem('lastPayment', "");
//    } else {
//      storage.setItem('lastPayment', json.encode(payment.toMap()));
//    }
//  }
}
