import 'dart:collection';
import 'dart:convert';

import 'package:mhamrah/Models/ConsultantTableMV.dart';
import 'package:mhamrah/Values/Utils.dart';

import 'HTTPService.dart';

class ConsultantTableSRV {
  ConnectionService httpReq = new ConnectionService();
  String subURL = "consultant_table/";

  Future<ConsultantAllTables> getAllTables(
      String consUsername, String stuUsername, String auth) async {
    consUsername = getChildUsernameFromParentUsername(consUsername);
    stuUsername = getChildUsernameFromParentUsername(stuUsername);
    String requestSubURL;
    HashMap<String, String> header = new HashMap();
    header['consUsername'] = consUsername;
    header['stuUsername'] = stuUsername;
    header['password'] = auth;
    requestSubURL = subURL + 'all_tables';
    String body = "{}";
    String jsonString;
    try {
      jsonString =
          await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    } catch (Exception) {
      return null;
    }
    Map<String, dynamic> jsonDecode = json.decode(jsonString);
    if (jsonDecode['success']) {
      ConsultantAllTables c =
          ConsultantAllTables.fromJson(jsonDecode['consultant_all_tables']);
      c.studentAccess = jsonDecode['studentAccess'];
      return c;
    }
    return null;
  }

  Future<Map<String, dynamic>> addLessonField(
      String username,
      String stuUsername,
      String auth,
      CLessonPlanPerDay c,
      String tableName) async {
    username = getChildUsernameFromParentUsername(username);
    stuUsername = getChildUsernameFromParentUsername(stuUsername);
    String requestSubURL;
    requestSubURL = subURL + 'add_lesson_field';
    HashMap<String, String> data = new HashMap();
    data['username'] = username;
    data['password'] = auth;
    data['stuUsername'] = stuUsername;
    data['lessonPlanPerDay'] = json.encode(c.toJson());
    data['tableName'] = tableName;
    String jsonString;
    try {
      jsonString =
          await httpReq.uploadWithFile(requestSubURL, data, c.voiceFile);
    } catch (Exception) {
      return {'success': false};
    }
    return json.decode(jsonString);
  }

  Future<Map<String, dynamic>> deleteLessonField(
      String username,
      String stuUsername,
      String auth,
      String lessonKey,
      String tableName) async {
    username = getChildUsernameFromParentUsername(username);
    stuUsername = getChildUsernameFromParentUsername(stuUsername);
    String requestSubURL;
    requestSubURL = subURL + 'delete_lesson_field';
    HashMap<String, String> header = new HashMap();
    header['username'] = username;
    header['password'] = auth;
    HashMap bodyHashMap = new HashMap();
    bodyHashMap['stuUsername'] = stuUsername;
    bodyHashMap['lessonKey'] = lessonKey;
    bodyHashMap['tableName'] = tableName;
    String body = json.encode(bodyHashMap);
    String jsonString;
    try {
      jsonString =
          await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    } catch (Exception) {
      return {'success': false};
    }
    return json.decode(jsonString);
  }

  Future<Map<String, dynamic>> update_lesson_field(
      String username,
      String stuUsername,
      String auth,
      CLessonPlanPerDay c,
      String tableName) async {
    username = getChildUsernameFromParentUsername(username);
    stuUsername = getChildUsernameFromParentUsername(stuUsername);
    String requestSubURL;
    requestSubURL = subURL + 'edit_lesson_field';
    HashMap<String, String> data = new HashMap();
    data['username'] = username;
    data['password'] = auth;
    data['stuUsername'] = stuUsername;
    data['lessonPlanPerDay'] = json.encode(c.toJson());
    data['tableName'] = tableName;
    String jsonString;
    try {
      jsonString =
          await httpReq.uploadWithFile(requestSubURL, data, c.voiceFile);
    } catch (Exception) {
      return {'success': false};
    }
    return json.decode(jsonString);
  }

  Future<bool> change_complete_mark(String stuUsername, String auth,
      bool completeStatus, String tableName, String lessonKey) async {
    stuUsername = getChildUsernameFromParentUsername(stuUsername);
    String requestSubURL;
    requestSubURL = subURL + 'change_complete_status';
    HashMap<String, String> header = new HashMap();
    header['stuUsername'] = stuUsername;
    header['password'] = auth;
    HashMap bodyHashMap = new HashMap();
    bodyHashMap['completeStatus'] = completeStatus;
    bodyHashMap['lessonKey'] = lessonKey;
    bodyHashMap['tableName'] = tableName;
    String body = json.encode(bodyHashMap);
    String jsonString;
    try {
      jsonString =
          await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    } catch (Exception) {
      return false;
    }
    return json.decode(jsonString)['success'];
  }

  Future<bool> update_all_table(String username, String auth,
      String stuUsername, ConsultantTableModel c) async {
    username = getChildUsernameFromParentUsername(username);
    stuUsername = getChildUsernameFromParentUsername(stuUsername);
    String requestSubURL;
    requestSubURL = subURL + 'edit_whole_table';
    HashMap<String, String> header = new HashMap();
    header['username'] = username;
    header['password'] = auth;
    HashMap bodyHashMap = new HashMap();
    bodyHashMap['stuUsername'] = stuUsername;
    bodyHashMap['table'] = json.encode(c);
    String body = json.encode(bodyHashMap);
    String jsonString;
    try {
      jsonString =
          await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    } catch (Exception) {
      return false;
    }
    return json.decode(jsonString)['success'];
  }

  Future<Map<String, dynamic>> update_present_time(
      String username,
      String auth,
      String stuUsername,
      String tableName,
      int dayIndex,
      String presentValue) async {
    username = getChildUsernameFromParentUsername(username);
    stuUsername = getChildUsernameFromParentUsername(stuUsername);
    String requestSubURL;
    requestSubURL = subURL + 'edit_present_time';
    HashMap<String, String> header = new HashMap();
    header['username'] = username;
    header['password'] = auth;
    HashMap bodyHashMap = new HashMap();
    bodyHashMap['stuUsername'] = stuUsername;
    bodyHashMap['tableName'] = tableName;
    bodyHashMap['presentValue'] = presentValue;
    bodyHashMap['dayIndex'] = dayIndex;
    String body = json.encode(bodyHashMap);
    String jsonString;
    try {
      jsonString =
          await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    } catch (Exception) {
      return {"success": false};
    }
    return json.decode(jsonString);
  }

  Future<bool> addNewTable(String consUsername, String auth, String stuUsername,
      String tableName, String date) async {
    consUsername = getChildUsernameFromParentUsername(consUsername);
    stuUsername = getChildUsernameFromParentUsername(stuUsername);
    String requestSubURL;
    requestSubURL = subURL + 'add_new_table';
    HashMap<String, String> header = new HashMap();
    header['consUsername'] = consUsername;
    header['password'] = auth;
    HashMap bodyHashMap = new HashMap();
    bodyHashMap['stuUsername'] = stuUsername;
    bodyHashMap['tableName'] = tableName;
    bodyHashMap['date'] = date;
    String body = json.encode(bodyHashMap);
    String jsonString;
    try {
      jsonString =
          await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    } catch (Exception) {
      return false;
    }
    return json.decode(jsonString)['success'];
  }

  Future<bool> editTableStartDate(String consUsername, String auth,
      String stuUsername, String tableName, String date) async {
    consUsername = getChildUsernameFromParentUsername(consUsername);
    stuUsername = getChildUsernameFromParentUsername(stuUsername);
    String requestSubURL;
    requestSubURL = subURL + 'edit_tables_startDate';
    HashMap<String, String> header = new HashMap();
    header['consUsername'] = consUsername;
    header['password'] = auth;
    HashMap bodyHashMap = new HashMap();
    bodyHashMap['stuUsername'] = stuUsername;
    bodyHashMap['tableName'] = tableName;
    bodyHashMap['date'] = date;
    String body = json.encode(bodyHashMap);
    String jsonString;
    try {
      jsonString =
          await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    } catch (Exception) {
      return false;
    }
    return json.decode(jsonString)['success'];
  }

  Future<bool> shareConsultantTableWithStudentList(
      String consUsername,
      String auth,
      List<String> studentUsernames,
      ConsultantTableModel table) async {
    consUsername = getChildUsernameFromParentUsername(consUsername);
    String requestSubURL;
    requestSubURL = subURL + 'share_table';
    HashMap<String, String> header = new HashMap();
    header['consUsername'] = consUsername;
    header['password'] = auth;
    HashMap bodyHashMap = new HashMap();
    bodyHashMap['stuUsernames'] = studentUsernames;
    bodyHashMap['table'] = table.toCopyJson();
    String body = json.encode(bodyHashMap);
    String jsonString;
    try {
      jsonString =
          await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    } catch (Exception) {
      return false;
    }
    return json.decode(jsonString)['success'];
  }
}
