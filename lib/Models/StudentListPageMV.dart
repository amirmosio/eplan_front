import 'package:mhamrah/Values/string.dart';

import 'UserMV.dart';

class LeagueContactElement {
  int rank = 0;
  String username = "";
  String fullName = "";
  int durationTime = 0;
  int  testNumber = 0;
  double score =  0.0;
  int presentTime = 0;


  LeagueContactElement();

  factory LeagueContactElement.fromJson(Map<String, dynamic> json) {
    LeagueContactElement s = LeagueContactElement();
    s.rank = json['rank'];
    s.username = json['username'];
    s.fullName = json['fullName'];
    s.durationTime = json['durationTime'];
    s.testNumber = json['testNumber'];
    s.score = (json['score']??0).toDouble();
    s.presentTime = json['presentTime'];
    return s;
  }

  Map<String, dynamic> toJson() => {
    'rank': rank,
    'username': username,
    'fullName': fullName,
    'durationTime': durationTime,
    'testNumber': testNumber,
    'score': score,
    'presentTime': presentTime,
  };
}

class StudentListData {
  List<ContactElement> studentList = [];
  List<ContactElement> subConsList = [];

  StudentListData();

  factory StudentListData.fromJson(dynamic json) {
    StudentListData s = StudentListData();
    s.studentList = [];
    for (int i = 0; i < json['user_list'].length; i++) {
      s.studentList.add(ContactElement.fromJson(json['user_list'][i]));
    }

    s.subConsList = [];
    for (int i = 0; i < (json['subCons_list'] ?? []).length; i++) {
      s.subConsList.add(ContactElement.fromJson(json['subCons_list'][i]));
    }
    return s;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> res = {};
    List<Map<String, dynamic>> studentListMap = [];
    for (int i = 0; i < studentList.length; i++) {
      studentListMap.add(studentList[i].toJson());
    }
    res['user_list'] = studentListMap;

    List<Map<String, dynamic>> subConsListMap = [];
    for (int i = 0; i < this.subConsList.length; i++) {
      subConsListMap.add(this.subConsList[i].toJson());
    }
    res['subCons_list'] = subConsListMap;
    return res;
  }

  void setStudentByUsername(Student student) {
    ContactElement c = ContactElement();

    c.username = student.username;
    c.name = student.first_name + " " + student.last_name;
    c.subConsUsername = student.sub_consultant_username;
    c.bossConsUsername = student.boss_consultant_username;
    c.phone = c.phone;
    c.fatherPhone = student.father_phone;
    c.motherPhone = student.mother_phone;
    c.homeNumber = student.home_number;
    c.studentMajor = student.student_major;
    c.studentEduLevel = student.student_edu_level;
    c.studentSchool = student.school;

    for (int i = 0; i < studentList.length; i++) {
      if (studentList[i].username == usernameLabel) {
        studentList[i] = c;
        break;
      }
    }
  }

  Student getStudentByUsername(String username) {
    Student s = Student();
    ContactElement c;
    for (int i = 0; i < studentList.length; i++) {
      if (studentList[i].username == username) {
        c = studentList[i];
        break;
      }
    }
    if (c != null) {
      s.username = c.username;
      s.first_name = c.name;
      s.last_name = "";
      s.sub_consultant_username = c.subConsUsername;
      s.boss_consultant_username = c.bossConsUsername;
      s.phone = c.phone;
      s.father_phone = c.fatherPhone;
      s.mother_phone = c.motherPhone;
      s.home_number = c.homeNumber;
      s.student_major = c.studentMajor;
      s.student_edu_level = c.studentEduLevel;
      s.school = c.studentSchool;
      return s;
    } else {
      return null;
    }
  }
}


class ContactElement {
  String username = "";
  String name = "";
  String subConsName = "";
  String subConsUsername = "";
  String bossConsUsername = "";
  int unseenMessageCount = 0;
  String phone = "";
  String fatherPhone = "";
  String motherPhone = "";
  String homeNumber = "";
  String studentEduLevel = "";
  String studentMajor = "";
  String studentSchool = "";
  String userType = "";

  String getContactKey() {
    return (username ?? "") +
        (name ?? "") +
        (subConsUsername ?? "") +
        (subConsName ?? "") +
        (bossConsUsername ?? "") +
        (phone ?? "") +
        (fatherPhone ?? "") +
        (motherPhone ?? "") +
        (homeNumber ?? "") +
        (studentEduLevel ?? "") +
        (studentMajor ?? "") +
        (studentSchool ?? "") +
        (userType ?? "");
  }

  ContactElement();

  factory ContactElement.fromJson(Map<String, dynamic> json) {
    ContactElement s = ContactElement();
    s.username = json['username'];
    s.name = json['name'];
    s.subConsName = json['sub_consultant_name'];
    s.subConsUsername = json['sub_consultant_username'];
    s.bossConsUsername = json['boss_consultant_username'];
    s.unseenMessageCount = json['unseen_message_count'];
    s.phone = json['phone'];
    s.fatherPhone = json['father_phone'];
    s.motherPhone = json['mother_phone'];
    s.homeNumber = json['home_number'];
    s.studentEduLevel = json['student_edu_level'];
    s.studentMajor = json['student_major'];
    s.studentSchool = json['school'];
    s.userType = json['user_type'];
    return s;
  }

  Map<String, dynamic> toJson() => {
        'username': username,
        'name': name,
        'sub_consultant_name': subConsName,
        'sub_consultant_username': subConsUsername,
        'boss_consultant_username': bossConsUsername,
        'unseen_message_count': unseenMessageCount,
        'phone': phone,
        'father_phone': fatherPhone,
        'mother_phone': motherPhone,
        'home_number': homeNumber,
        'student_edu_level': studentEduLevel,
        'student_major': studentMajor,
        'school': schoolName,
        'user_type': userType
      };
}
