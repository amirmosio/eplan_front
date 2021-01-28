import 'dart:collection';
import 'dart:convert';

import 'package:mhamrah/ConnectionService/HTTPService.dart';
import 'package:mhamrah/Models/AccountDataAndSetting.dart';
import 'package:mhamrah/Models/StudentListPageMV.dart';
import 'package:mhamrah/Models/UserMV.dart';
import 'package:mhamrah/Values/Utils.dart';
import 'package:http/http.dart';

class UserSRV {
  ConnectionService httpReq = new ConnectionService();
  String subURL = "user/";

  Future<AccountData> validateUser(String username, String auth) async {
    String requestSubURL;
    HashMap<String, String> header = new HashMap();
    header['password'] = auth;
    header['username'] = replacePersianWithEnglishNumber(username);
    requestSubURL = subURL + 'login';
    String body = "{}";
    String jsonString =
        await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    if (json.decode(jsonString)['success']) {
      if (json.decode(jsonString)['account_data'] == "pending") {
        AccountData accountData = AccountData();
        Student student = Student();
        student.username = "pending";
        accountData.student = student;
        return accountData;
      }
      AccountData accountData =
          AccountData.fromJson(json.decode(jsonString)['account_data']);
      if (accountData.consultant.username == null &&
          accountData.student.username == null) {
        return AccountData();
      } else if (accountData.student.username == null) {
        accountData.consultant.authentication_string = auth;
      } else if (accountData.consultant.username == null) {
        accountData.student.authentication_string = auth;
      }
      return accountData;
    }
    return null;
  }

  Future<Student> parentLogin(
      String childUsername, String parentPhone, String phoneCode) async {
    String requestSubURL;
    HashMap<String, String> header = new HashMap();
    header['parentPhone'] = parentPhone;
    header['username'] = replacePersianWithEnglishNumber(childUsername);
    header['phoneCode'] = phoneCode;
    requestSubURL = subURL + 'login_parent';
    String body = "{}";
    String jsonString =
        await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    if (json.decode(jsonString)['success']) {
      Student student = Student.fromJson(json.decode(jsonString)['student']);
      return student;
    }
    return null;
  }

  Future<Map> registerStudent(Student student) async {
    String requestSubURL;
    requestSubURL = subURL + 'register_student';
    HashMap<String, String> header = new HashMap();
    String body = jsonEncode(student);
    String jsonString =
        await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    return json.decode(jsonString);
  }

  Future<Map> changeUserPassword(
      String username, String newPassword, String code) async {
    String requestSubURL = subURL + 'change_password';
    HashMap<String, String> header = new HashMap();
    header['username'] = username;
    header['password'] = newPassword;
    header['phoneCode'] = code;
    String body = jsonEncode({});
    String jsonString = "{'success':false}";
    try {
      jsonString =
          await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    } catch (Exception) {
      return {'success': false, 'error': 'intnet error'};
    }

    return json.decode(jsonString);
  }

  Future<Map> registerConsultant(Consultant consultant) async {
    String requestSubURL;
    requestSubURL = subURL + 'register_consultant';
    HashMap<String, String> header = new HashMap();
    String body = jsonEncode(consultant);
    String jsonString =
        await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    return json.decode(jsonString);
  }

  Future<bool> uploadStudentProfile(Consultant consultant) async {
    //TODO
    String requestSubURL;
    requestSubURL = subURL + 'register_consultant';
    HashMap<String, String> header = new HashMap();
    header['student_username'] = consultant.username;
    header['password'] = consultant.authentication_string;
    String body = "";
    String jsonString =
        await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    return json.decode(jsonString);
  }

  Future<bool> uploadConsultantProfile(Consultant consultant) async {
    //TODO
    String requestSubURL;
    requestSubURL = subURL + 'register_consultant';
    HashMap<String, String> header = new HashMap();
    header['student_username'] = consultant.username;
    header['password'] = consultant.authentication_string;
    String body = "{}";
    String jsonString =
        await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    return json.decode(jsonString);
  }

  Future<bool> check_valid_new_student_username(String username) async {
    String requestSubURL;
    requestSubURL = subURL + 'valid_new_student_username';
    HashMap<String, String> header = new HashMap();
    String body = jsonEncode({'username': username});
    String jsonString =
        await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    return json.decode(jsonString)['valid'];
  }

  Future<bool> check_valid_new_consultant_username(String username) async {
    String requestSubURL;
    requestSubURL = subURL + 'valid_new_consultant_username';
    HashMap<String, String> header = new HashMap();
    String body = jsonEncode({'username': username});
    String jsonString =
        await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    return json.decode(jsonString)['valid'];
  }

  Future<String> get_student_name(String username) async {
    String requestSubURL;
    requestSubURL = subURL + 'get_name_with_student_username';
    HashMap<String, String> header = new HashMap();
    String body = jsonEncode({'username': username});
    String jsonString =
        await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    return json.decode(jsonString);
  }

  Future<Map> get_consultant_name(String username) async {
    String requestSubURL;
    requestSubURL = subURL + 'get_name_with_consultant_username';
    HashMap<String, String> header = new HashMap();
    String body = jsonEncode({'username': username});
    String jsonString =
        await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    return json.decode(jsonString);
  }

  Future<bool> check_valid_new_phone(String phone) async {
    String requestSubURL;
    requestSubURL = subURL + 'check_valid_new_student_phone';
    HashMap<String, String> header = new HashMap();
    String body = jsonEncode({'phone': phone});
    String jsonString =
        await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    try {
      return json.decode(jsonString)['valid'];
    } catch (e) {
      return false;
    }
  }

  Future<bool> setFirebaseTokenForUser(
      String username, String auth, String firebaseToken) async {
    String requestSubURL;
    HashMap<String, String> header = new HashMap();
    header['username'] = username;
    header['password'] = auth;
    header['token'] = firebaseToken;
    requestSubURL = subURL + 'set_firebase_token';
    String body = "{}";
    String jsonString =
        await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    try {
      return json.decode(jsonString)['success'];
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeFirebaseTokenForUser(
      String username, String auth, String firebaseToken) async {
    String requestSubURL;
    HashMap<String, String> header = new HashMap();
    header['username'] = username;
    header['password'] = auth;
    header['token'] = firebaseToken;
    requestSubURL = subURL + 'remove_firebase_token';
    String body = "{}";
    String jsonString =
        await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    try {
      return json.decode(jsonString)['success'];
    } catch (e) {
      return false;
    }
  }

  Future<List> getConsultantList(String username, String auth,
      int consultantType, String bossConsIfGettingSubConsList) async {
    String requestSubURL;
    HashMap<String, String> header = new HashMap();
    header['username'] = username;
    header['password'] = auth;
    requestSubURL = subURL + "get_consultant_list";
    HashMap<String, String> bodyHashMap = new HashMap();
    bodyHashMap['consultantType'] = consultantType.toString();
    bodyHashMap['bossConsultant'] = bossConsIfGettingSubConsList;
    String body = json.encode(bodyHashMap);
    String jsonString =
        await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    if (json.decode(jsonString)['success']) {
      return json.decode(jsonString)['consultants']['user_list'];
    }
    return [];
  }
}
