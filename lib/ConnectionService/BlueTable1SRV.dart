import 'dart:collection';
import 'dart:convert';
import 'dart:convert';

import 'package:mhamrah/Models/BlueTable1MV.dart';
import 'package:mhamrah/Models/ConsultantTableMV.dart';
import 'package:mhamrah/Values/Utils.dart';

import 'HTTPService.dart';

class BlueTable1SRV {
  ConnectionService httpReq = new ConnectionService();
  String subURL = "blue_1_table/";

  Future<AllBlue1Tables> getAllTables(
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
    String jsonString =
        await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    if (json.decode(jsonString)['success']) {
      return AllBlue1Tables.fromJson(
          json.decode(jsonString)['consultant_all_tables']);
    }
    return null;
  }

  Future<AllBlue1Tables> getTableByName(String consUsername, String stuUsername,
      String auth, String tableName) async {
    consUsername = getChildUsernameFromParentUsername(consUsername);
    stuUsername = getChildUsernameFromParentUsername(stuUsername);
    String requestSubURL;
    HashMap<String, String> header = new HashMap();
    header['consUsername'] = consUsername;
    header['stuUsername'] = stuUsername;
    header['password'] = auth;
    requestSubURL = subURL + 'get_table_by_name';
    HashMap<String, String> bodyHashMap = new HashMap();
    bodyHashMap['tableName'] = tableName;
    String body = json.encode(bodyHashMap);
    String jsonString =
        await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    if (json.decode(jsonString)['success']) {
      return AllBlue1Tables.fromJson(
          json.decode(jsonString)['consultant_all_tables']);
    }
    return null;
  }

  Future<bool> updateWholeTable(
      String stuUsername, String auth, BlueTable1Data blue1Table) async {
    stuUsername = getChildUsernameFromParentUsername(stuUsername);
    String requestSubURL;
    requestSubURL = subURL + 'edit_whole_table';
    HashMap<String, String> header = new HashMap();
    header['stuUsername'] = stuUsername;
    header['password'] = auth;
    HashMap bodyHashMap = new HashMap();
    bodyHashMap['table'] = json.encode(blue1Table);
    String body = json.encode(bodyHashMap);
    String jsonString =
        await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    return json.decode(jsonString)['success'];
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
    String jsonString =
        await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    return json.decode(jsonString)['success'];
  }
}
