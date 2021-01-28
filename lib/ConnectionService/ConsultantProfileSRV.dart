import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:mhamrah/Models/ChatMV.dart';
import 'package:mhamrah/Models/UserMV.dart';

import 'HTTPService.dart';

class ConsultantProfileSRV {
  ConnectionService httpReq = new ConnectionService();
  String subURL = "consultant_profile/";

  Future<List> getStudentChartData(String consUsername, String auth) async {
    String requestSubURL;
    HashMap<String, String> header = new HashMap();
    header['username'] = consUsername;
    header['password'] = auth;
    requestSubURL = subURL + 'student_number_chart_data';
    HashMap bodyHashMap = new HashMap();
    String body = json.encode(bodyHashMap);
    String jsonString =
        await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    if (json.decode(jsonString)['success']) {
      return json.decode(jsonString)['chart_data'];
    }
    return null;
  }

  Future<Map> editConsultant(String consUsername, String auth,
      Consultant consultant, CustomFile file) async {
    String requestSubURL;
    requestSubURL = subURL + 'edit_consultant_data';
    HashMap<String, String> data = new HashMap();
    data['username'] = consUsername;
    data['password'] = auth;
    data['consultant'] = json.encode(consultant.toJson());
    String jsonString = await httpReq.uploadWithFile(requestSubURL, data, file);
    return (json.decode(jsonString));
  }

  Future<Map> editConsultantAvatar(String consUsername, String auth,
      Consultant consultant, CustomFile file) async {
    String requestSubURL;
    requestSubURL = subURL + 'edit_consultant_avatar';
    HashMap<String, String> data = new HashMap();
    data['username'] = consUsername;
    data['password'] = auth;
    data['consultant'] = json.encode(consultant.toJson());
    String jsonString = await httpReq.uploadWithFile(requestSubURL, data, file);
    return (json.decode(jsonString));
  }

  Future<Consultant> getConsultantDetail(String username, String auth,
      String stuUsername, String consUsername) async {
    String requestSubURL = subURL + 'get_consultant_profile';
    HashMap<String, String> header = new HashMap();
    header['username'] = username;
    header['password'] = auth;

    HashMap bodyHashMap = new HashMap();
    bodyHashMap['consUsername'] = consUsername;
    bodyHashMap['stuUsername'] = stuUsername;

    String body = json.encode(bodyHashMap);
    String jsonString =
        await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    if (json.decode(jsonString)['success']) {
      return Consultant.fromJson(json.decode(jsonString)['consultant']);
    }
    return null;
  }

  Future<bool> changeSetting(
      String consUsername, String auth, String settingKey, value) async {
    String requestSubURL = subURL + 'change_setting';
    HashMap<String, String> header = new HashMap();
    header['password'] = auth;
    header['username'] = consUsername;
    HashMap bodyHashMap = new HashMap();
    bodyHashMap['settingKey'] = settingKey;
    bodyHashMap['settingValue'] = value;
    String body = json.encode(bodyHashMap);
    String jsonString =
        await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    return json.decode(jsonString)['success'];
  }

  Future<Map> getPaymentForm(String consUsername, String auth) async {
    //TODO
    String requestSubURL = subURL + 'get_payment_form';
    HashMap<String, String> header = new HashMap();
    header['password'] = auth;
    header['username'] = consUsername;

    HashMap bodyHashMap = new HashMap();
    String body = json.encode(bodyHashMap);
    String jsonString =
        await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    try {
      if (json.decode(jsonString)['success']) {
        return json.decode(jsonString)['paymentData'];
      } else {
        return {};
      }
    } catch (e) {
      return {};
    }
  }

  Future<Map> chargeAccount(String consUsername, String auth,
      String authorityStr, String refId) async {
    //TODO
    String requestSubURL = subURL + 'charge_account';
    HashMap<String, String> header = new HashMap();
    header['password'] = auth;
    header['username'] = consUsername;

    HashMap bodyHashMap = new HashMap();
    bodyHashMap['authority'] = authorityStr;
    bodyHashMap['refID'] = refId;
    String body = json.encode(bodyHashMap);
    String jsonString =
        await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    try {
      if (json.decode(jsonString)['success']) {
        return json.decode(jsonString)['paymentData'];
      } else {
        return {};
      }
    } catch (e) {
      return {};
    }
  }

  Future<Map> updateServerAfterConsPaymentForOneMonth(
      String username, String auth, String authority, String amount) async {
    String requestSubURL;
    HashMap<String, String> header = new HashMap();
    header['username'] = username;
    header['password'] = auth;
    requestSubURL = subURL + 'update_payment_status';
    HashMap bodyHashMap = new HashMap();
    bodyHashMap['authority'] = authority;
    bodyHashMap['amount'] = amount;
    String body = json.encode(bodyHashMap);
    String jsonString =
        await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    try {
      return json.decode(jsonString);
    } catch (e) {
      return {};
    }
  }
}
