import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:mhamrah/Models/ChatMV.dart';
import 'package:mhamrah/Models/ContactUs.dart';
import 'package:mhamrah/Models/UserMV.dart';

import 'HTTPService.dart';

enum Device { Android, Ios, Web }

class AppSRV {
  ConnectionService httpReq = new ConnectionService();
  String subURL = "app/";

  Future<ContactUs> getContactUsInfo() async {
    String requestSubURL;
    requestSubURL = subURL + 'get_contact_us';
    HashMap<String, String> header = new HashMap();
    HashMap bodyHashMap = new HashMap();
    String body = json.encode(bodyHashMap);
    String jsonString =
        await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    if (json.decode(jsonString)['success']) {
      return ContactUs.fromJson(json.decode(jsonString)['contactUs']);
    }
    return null;
  }

  Future<String> getNewApplicationLink(Device device, String currentVersionName,
      String currentVersionCode) async {
    String requestSubURL;
    HashMap<String, String> header = new HashMap();
    requestSubURL = subURL + 'get_update_link';
    HashMap bodyHashMap = new HashMap();
    bodyHashMap['device'] = device.toString();
    bodyHashMap['currentVersionName'] = currentVersionName;
    bodyHashMap['currentVersionCode'] = currentVersionCode;
    String body = json.encode(bodyHashMap);
    String jsonString =
        await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    if (json.decode(jsonString)['success']) {
      return json.decode(jsonString)['link'][device.toString()] ?? "";
    }
    return "";
  }

  Future<bool> update7PrevDayPhoneUsage(
      String stuUsername, String auth, List<Map> dayPhoneUsage) async {
    String requestSubURL;
    HashMap<String, String> header = new HashMap();
    header['username'] = stuUsername;
    header['password'] = auth;
    requestSubURL = subURL + 'update_phone_usage';
    HashMap bodyHashMap = new HashMap();
    bodyHashMap['phoneUsage'] = dayPhoneUsage;
    String body = json.encode(bodyHashMap);
    String jsonString =
        await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    try {
      return json.decode(jsonString)['success'];
    } catch (e) {
      return false;
    }
  }

  Future<Map> get7PrevDayPhoneUsage(
      String username, String auth, String stuUsername) async {
    String requestSubURL;
    HashMap<String, String> header = new HashMap();
    header['username'] = username;
    header['password'] = auth;
    requestSubURL = subURL + 'get_phone_usage';
    HashMap bodyHashMap = new HashMap();
    bodyHashMap['stuUsername'] = stuUsername;
    String body = json.encode(bodyHashMap);
    String jsonString =
        await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    try {
      Map responseMap = json.decode(jsonString);
      if (responseMap['success']) {
        return responseMap['usage'];
      }
    } catch (e) {}
    return {};
  }
}
