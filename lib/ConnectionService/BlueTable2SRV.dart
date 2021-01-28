import 'dart:collection';
import 'dart:convert';

import 'package:mhamrah/Models/BlueTable2MV.dart';

import 'HTTPService.dart';

class BlueTable2SRV {
  ConnectionService httpReq = new ConnectionService();
  String subURL = "blue_2_table/";

  Future<AllBlue2Tables> getAllTables(
      String consUsername, String stuUsername, String auth) async {
    String requestSubURL;
    HashMap<String, String> header = new HashMap();
    header['consUsername'] = consUsername;
    header['stuUsername'] = stuUsername;
    header['password'] = auth;
    requestSubURL = subURL + 'all_tables';
    String body = "{}";
    String jsonString =
        await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    if (json.decode(jsonString)['success']) {
      return AllBlue2Tables.fromJson(json.decode(jsonString)['all_tables']);
    }
    return null;
  }

  Future<bool> updateWholeTable(
      String stuUsername, String auth, BlueTable2Data blue2Table) async {
    String requestSubURL;
    requestSubURL = subURL + 'edit_whole_table';
    HashMap<String, String> header = new HashMap();
    header['stuUsername'] = stuUsername;
    header['password'] = auth;
    HashMap bodyHashMap = new HashMap();
    bodyHashMap['table'] = json.encode(blue2Table);
    String body = json.encode(bodyHashMap);
    String jsonString =
        await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    return json.decode(jsonString)['success'];
  }

  Future<bool> addNewTable(String consUsername, String auth, String stuUsername,
      String tableName, String date) async {
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
    String jsonString =
        await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    return json.decode(jsonString)['success'];
  }

  Future<bool> editLesson(String stuUsername, String auth, String tableName,
      B2LessonPerDay b2lessonPerDay) async {
    String requestSubURL;
    requestSubURL = subURL + 'edit_lesson';
    HashMap<String, String> header = new HashMap();
    header['stuUsername'] = stuUsername;
    header['password'] = auth;
    HashMap bodyHashMap = new HashMap();
    bodyHashMap['tableName'] = tableName;
    bodyHashMap['lesson_data'] = b2lessonPerDay.toJson();
    String body = json.encode(bodyHashMap);
    String jsonString =
        await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    return json.decode(jsonString)['success'];
  }

  Future<bool> addLesson(String stuUsername, String auth, String tableName,
      B2LessonPerDay b2lessonPerDay) async {
    String requestSubURL;
    requestSubURL = subURL + 'add_lesson';
    HashMap<String, String> header = new HashMap();
    header['stuUsername'] = stuUsername;
    header['password'] = auth;
    HashMap bodyHashMap = new HashMap();
    bodyHashMap['tableName'] = tableName;
    bodyHashMap['lesson_data'] = b2lessonPerDay.toJson();
    String body = json.encode(bodyHashMap);
    String jsonString =
        await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    return json.decode(jsonString)['success'];
  }

  Future<bool> changeBlue2Table(String stuUsername, String auth, String tableName,
      int selectedDay, String cellValue, int rowIndex, int columnIndex) async {
    String requestSubURL;
    requestSubURL = subURL + 'set_cell_value';
    HashMap<String, String> header = new HashMap();
    header['stuUsername'] = stuUsername;
    header['password'] = auth;
    HashMap bodyHashMap = new HashMap();
    bodyHashMap['tableName'] = tableName;
    bodyHashMap['selectedDay'] = selectedDay;
    bodyHashMap['cellValue'] = cellValue;
    bodyHashMap['rowIndex'] = rowIndex;
    bodyHashMap['columnIndex'] = columnIndex;

    String body = json.encode(bodyHashMap);
    String jsonString =
        await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    return json.decode(jsonString)['success'];
  }
}
