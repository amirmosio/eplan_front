import 'dart:collection';
import 'dart:convert';

import 'package:mhamrah/Models/ConsultantTableMV.dart';
import 'package:mhamrah/Models/StudentListPageMV.dart';
import 'package:mhamrah/Values/Utils.dart';

import 'HTTPService.dart';

class LeagueSRV {
  ConnectionService httpReq = new ConnectionService();
  String subURL = "league/";

  Future<bool> changeStudentLoginLogout(
      String stuUsername, String auth, bool value) async {
    String requestSubURL;
    HashMap<String, String> header = new HashMap();
    header['username'] = stuUsername;
    header['password'] = auth;
    requestSubURL = subURL + 'student_login_logout';
    HashMap bodyHashMap = new HashMap();
    bodyHashMap['leagueFlag'] = value;
    String body = json.encode(bodyHashMap);
    String jsonString;
    try {
      jsonString =
          await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    } catch (Exception) {
      return false;
    }
    try {
      Map<String, dynamic> jsonDecode = json.decode(jsonString);
      return jsonDecode['success'];
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getStudentLeagueList(
      String username, String auth) async {
    String requestSubURL;
    HashMap<String, String> header = new HashMap();
    header['username'] = username;
    header['password'] = auth;
    requestSubURL = subURL + 'get_league_list';
    HashMap bodyHashMap = new HashMap();
    String body = json.encode(bodyHashMap);
    String jsonString;
    try {
      jsonString =
          await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    } catch (Exception) {
      return null;
    }
    try {
      Map<String, dynamic> jsonDecode = json.decode(jsonString);
      return jsonDecode;
    } catch (e) {
      return null;
    }
  }
}
