import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:mhamrah/Models/ChatMV.dart';
import 'package:mhamrah/Models/UserMV.dart';

import 'HTTPService.dart';

class StudentProfileSRV {
  ConnectionService httpReq = new ConnectionService();
  String subURL = "student_profile/";

  Future<Student> getStudentProfile(
      String consUsername, String auth, String studentUsername) async {
    String requestSubURL;
    HashMap<String, String> header = new HashMap();
    header['consUsername'] = consUsername;
    header['password'] = auth;
    requestSubURL = subURL + 'get_profile';
    HashMap bodyHashMap = new HashMap();
    bodyHashMap['stuUsername'] = studentUsername;
    String body = json.encode(bodyHashMap);
    String jsonString =
        await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    if (json.decode(jsonString)['success']) {
      return Student.fromJson(json.decode(jsonString)['student']);
    }
    return null;
  }

  Future<Map> checkConsultantAcceptStatus(String username, String auth) async {
    String requestSubURL;
    HashMap<String, String> header = new HashMap();
    header['username'] = username;
    header['password'] = auth;
    requestSubURL = subURL + 'check_accept_status';
    HashMap bodyHashMap = new HashMap();
    String body = json.encode(bodyHashMap);
    String jsonString =
        await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    if (json.decode(jsonString)['success']) {
      return json.decode(jsonString);
    }
    return null;
  }

  Future<Map> editStudentProfile(String consUsername, String auth,
      Student student, CustomFile file) async {
    String requestSubURL;
    requestSubURL = subURL + 'edit_student_data';
    HashMap<String, String> data = new HashMap();
    data['username'] = consUsername;
    data['password'] = auth;
    data['student'] = json.encode(student.toJson());
    String jsonString = await httpReq.uploadWithFile(requestSubURL, data, file);
    return (json.decode(jsonString));
  }

  Future<Map> editStudentConsultants(String consUsername, String auth,
      Student student, CustomFile file) async {
    String requestSubURL;
    requestSubURL = subURL + 'edit_student_consultant';
    HashMap<String, String> data = new HashMap();
    data['username'] = consUsername;
    data['password'] = auth;
    data['student'] = json.encode(student.toJson());
    String jsonString = await httpReq.uploadWithFile(requestSubURL, data, file);
    return (json.decode(jsonString));
  }

  Future<Map> editStudentAvatar(String consUsername, String auth,
      Student student, CustomFile file) async {
    String requestSubURL;
    requestSubURL = subURL + 'edit_student_avatar';
    HashMap<String, String> data = new HashMap();
    data['username'] = consUsername;
    data['password'] = auth;
    data['student'] = json.encode(student.toJson());
    String jsonString = await httpReq.uploadWithFile(requestSubURL, data, file);
    return (json.decode(jsonString));
  }

  Future<bool> changeSetting(
      String stuUsername, String auth, String settingKey, value) async {
    String requestSubURL = subURL + 'change_setting';
    HashMap<String, String> header = new HashMap();
    header['password'] = auth;
    header['username'] = stuUsername;
    HashMap bodyHashMap = new HashMap();
    bodyHashMap['settingKey'] = settingKey;
    bodyHashMap['settingValue'] = value;
    String body = json.encode(bodyHashMap);
    String jsonString =
    await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    return json.decode(jsonString)['success'];
  }
}
