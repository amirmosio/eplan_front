import 'dart:collection';
import 'dart:convert';

import 'package:mhamrah/ConnectionService/HTTPService.dart';
import 'package:mhamrah/Models/StudentListPageMV.dart';
import 'package:mhamrah/Models/UserMV.dart';

class StudentListSRV {
  ConnectionService httpReq = new ConnectionService();
  String subURL = "student_list/";

  Future<StudentListData> getAcceptedStudentList(
      String consUsername, String auth, String searchText) async {
    String requestSubURL;
    HashMap<String, String> header = new HashMap();
    header['password'] = auth;
    header['username'] = consUsername;
    requestSubURL = subURL + 'accepted_student';
    HashMap bodyHashMap = new HashMap();
    bodyHashMap['searchText'] = searchText;
    String body = json.encode(bodyHashMap);
    String jsonString =
        await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    if (json.decode(jsonString)['success']) {
      return StudentListData.fromJson(
          json.decode(jsonString)['user_list_data']);
    }
    return null;
  }

  Future<StudentListData> getPendingUserList(
      String consUsername, String auth, String searchText) async {
    String requestSubURL;
    HashMap<String, String> header = new HashMap();
    header['password'] = auth;
    header['username'] = consUsername;
    requestSubURL = subURL + "pending_student";
    HashMap<String, String> bodyHashMap = new HashMap();
    bodyHashMap['searchText'] = searchText;
    String body = json.encode(bodyHashMap);
    String jsonString =
        await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    if (json.decode(jsonString)['success']) {
      return StudentListData.fromJson(
          json.decode(jsonString)['user_list_data']);
    }
    return null;
  }

  Future<bool> acceptStudent(
      String consUsername, String auth, String stuUsername) async {
    String requestSubURL;
    HashMap<String, String> header = new HashMap();
    header['consultantUsername'] = consUsername;
    header['password'] = auth;
    header['studentUsername'] = stuUsername;
    requestSubURL = subURL + "accept_student";

    String body = "{}";
    String jsonString =
        await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    return json.decode(jsonString)['success'];
  }

  Future<bool> rejectStudent(
      String consUsername, String auth, String stuUsername) async {
    String requestSubURL;
    HashMap<String, String> header = new HashMap();
    header['consultantUsername'] = consUsername;
    header['password'] = auth;
    header['studentUsername'] = stuUsername;
    requestSubURL = subURL + "reject_student";

    String body = "{}";
    String jsonString =
        await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    return json.decode(jsonString)['success'];
  }

  Future<bool> acceptSubConsultant(
      String consUsername, String auth, String stuUsername) async {
    String requestSubURL;
    HashMap<String, String> header = new HashMap();
    header['consultantUsername'] = consUsername;
    header['password'] = auth;
    header['subConsultantUsername'] = stuUsername;
    requestSubURL = subURL + "accept_consultant";

    String body = "{}";
    String jsonString =
        await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    return json.decode(jsonString)['success'];
  }

  Future<bool> rejectSubConsultant(
      String consUsername, String auth, String stuUsername) async {
    String requestSubURL;
    HashMap<String, String> header = new HashMap();
    header['consultantUsername'] = consUsername;
    header['password'] = auth;
    header['subConsultantUsername'] = stuUsername;
    requestSubURL = subURL + "reject_consultant";

    String body = "{}";
    String jsonString =
        await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    return json.decode(jsonString)['success'];
  }

  Future<bool> deleteSubConsultant(
      String consUsername, String auth, String stuUsername) async {
    String requestSubURL;
    HashMap<String, String> header = new HashMap();
    header['consultantUsername'] = consUsername;
    header['password'] = auth;
    header['subConsultantUsername'] = stuUsername;
    requestSubURL = subURL + "delete_consultant";

    String body = "{}";
    String jsonString =
    await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    return json.decode(jsonString)['success'];
  }

  Future<bool> deleteFromStudentListAddToPending(
      String consUsername, String auth, String stuUsername) async {
    String requestSubURL;
    HashMap<String, String> header = new HashMap();
    header['consultantUsername'] = consUsername;
    header['password'] = auth;
    header['studentUsername'] = stuUsername;
    requestSubURL = subURL + "delete_student";

    String body = "{}";
    String jsonString =
        await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    return json.decode(jsonString)['success'];
  }
}

class ProfileSRV {
  ConnectionService httpReq = new ConnectionService();
  String subURL = "profile/";

  Future<Consultant> getStudentConsultantProfile(
      String stuUsername, String auth) async {
    String requestSubURL;
    HashMap<String, String> header = new HashMap();
    header['username'] = stuUsername;
    header['authentication_string'] = auth;
    requestSubURL = subURL + "student_consultant_profile";

    String body = "{}";
    String jsonString =
        await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    if (json.decode(jsonString)['success']) {
      return Consultant.fromJson(json.decode(jsonString)['consultant']);
    }
    return null;
  }

  Future<bool> editConsultantProfile(Consultant consultant) async {
    //the user name is the key and it is not changeable
    String requestSubURL;
    HashMap<String, String> header = new HashMap();
    requestSubURL = subURL + "edit_consultant_profile";
    String body = json.encode(consultant);
    String jsonString =
        await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    return json.decode(jsonString)['success'];
  }

  Future<Student> getConsultantStudentProfile(
      String consUsername, String auth, String stuUsername) async {
    String requestSubURL;
    HashMap<String, String> header = new HashMap();
    header['consultant_username'] = consUsername;
    header['authentication_string'] = auth;
    header['student_username'] = consUsername;
    requestSubURL = subURL + "consultant_student_profile";

    String body = "{}";
    String jsonString =
        await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    if (json.decode(jsonString)['success']) {
      return Student.fromJson(json.decode(jsonString)['student']);
    }
    return null;
  }

  Future<bool> editStudentProfile(Student student) async {
    //the user name is the key and it is not changeable
    String requestSubURL;
    HashMap<String, String> header = new HashMap();
    requestSubURL = subURL + "edit_student_profile";
    String body = json.encode(student);
    String jsonString =
        await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    return json.decode(jsonString)['success'];
  }
}
