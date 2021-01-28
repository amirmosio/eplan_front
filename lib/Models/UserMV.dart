import 'dart:collection';

import 'package:mhamrah/Models/AccountDataAndSetting.dart';
import 'package:mhamrah/Values/Utils.dart';

class PaymentStatus {
  bool access = true;
  int remainingDays = 365;
  int remainingHours = 23;

  PaymentStatus();

  factory PaymentStatus.fromJson(dynamic json) {
    PaymentStatus paymentStatus = PaymentStatus();
    paymentStatus.access = json['access'] ?? true;
    paymentStatus.remainingDays = json['remainingDays'] ?? 365;
    paymentStatus.remainingHours = json['remainingHours'] ?? 23;
    return paymentStatus;
  }

  Map<String, dynamic> toJson() => {
        'access': access,
        'remainingDays': remainingDays,
        'remainingHours': remainingHours,
      };
}

class Student {
  String username = "";
  String authentication_string = "";
  String first_name = "";
  String last_name = "";
  String phone = "";
  String father_phone = "";
  String mother_phone = "";
  String home_number = "";
  String sub_consultant_username = "";
  String boss_consultant_username = "";
  String student_major = "";
  String student_edu_level = "";
  String school = "";
  String phone_code = "";
  bool sub_consultant_request_accept = false;
  bool boss_consultant_request_accept = false;
  bool student_access = false;
  String parent = "";
  bool league_flag = false;

  Student();

  factory Student.fromJson(dynamic json) {
    Student s = Student();
    s.username = json['username'];
    s.authentication_string = json['authentication_string'];
    s.first_name = json['first_name'];
    s.last_name = json['last_name'];
    s.phone = json['phone'];
    s.father_phone = json['father_phone'];
    s.mother_phone = json['mother_phone'];
    s.home_number = json['home_number'];
    s.sub_consultant_username = json['sub_consultant_username'];
    s.boss_consultant_username = json['boss_consultant_username'];
    s.student_major = json['student_major'];
    s.student_edu_level = json['student_edu_level'];
    s.school = json['school'];
    s.sub_consultant_request_accept =
        json['sub_consultant_request_accept'] ?? false;
    s.boss_consultant_request_accept = json['boss_consultant_request_accept'];
    s.student_access = json['student_access'] ?? false;
    s.parent = json['parent'] ?? "";
    s.league_flag = json['leagueFlag'] ?? false;
    return s;
  }

  Map<String, dynamic> toJson() => {
        'username': username,
        'authentication_string': authentication_string,
        'first_name': first_name,
        'last_name': last_name,
        'phone': phone,
        'father_phone': father_phone,
        'mother_phone': mother_phone,
        'home_number': home_number,
        'sub_consultant_username': sub_consultant_username,
        'boss_consultant_username': boss_consultant_username,
        'student_major': student_major,
        'student_edu_level': student_edu_level,
        'school': school,
        'sub_consultant_request_accept': sub_consultant_request_accept,
        'boss_consultant_request_accept': boss_consultant_request_accept,
        'phoneCode': phone_code,
        'student_access': student_access,
        'parent': parent,
        'leagueFlag': league_flag
      };

  bool checkValidDataForConsultantRequest() {
    return validateEduLevel() &&
        validateNotAllowedEmptyFatherPhone() &&
        validateNotAllowedEmptyMotherPhone() &&
        validateNotAllowedEmptyPhone() &&
        validateNotEmptyFirstName() &&
        validateNotEmptyLastName() &&
        validateSchoolName() &&
        validHomeNumber();
  }

  bool validateNotEmptyFirstName() {
    String text = this.first_name;
    if (text.trim() == "") {
      return false;
    } else {
      return true;
    }
  }

  bool validateSchoolName() {
    String text = this.school;
    if (text.trim() == "") {
      return false;
    } else {
      return true;
    }
  }

  bool validateNotEmptyLastName() {
    String text = this.last_name;
    if (text.trim() == "") {
      return false;
    } else {
      return true;
    }
  }

  bool validateEduLevel() {
    if ((this.student_edu_level ?? "") + (this.student_major ?? "") != "") {
      return true;
    }
    return false;
  }

  bool validateNotAllowedEmptyPhone() {
    String phone = this.phone;
    if (phone.trim() == "") {
      return false;
    } else {
      String engPhone = replacePersianWithEnglishNumber(phone);
      RegExp regex = RegExp(r"^[0][9][0-9]{9}$");
      if (!regex.hasMatch(engPhone)) {
        return false;
      }
    }
    return true;
  }

  bool validateNotAllowedEmptyFatherPhone() {
    String phone = this.father_phone;
    if (phone.trim() == "") {
      return false;
    } else {
      String engPhone = replacePersianWithEnglishNumber(phone);
      RegExp regex = RegExp(r"^[0][9][0-9]{9}$");
      if (!regex.hasMatch(engPhone)) {
        return false;
      }
    }
    return true;
  }

  bool validateNotAllowedEmptyMotherPhone() {
    String phone = this.mother_phone;
    if (phone.trim() == "") {
      return false;
    } else {
      String engPhone = replacePersianWithEnglishNumber(phone);
      RegExp regex = RegExp(r"^[0][9][0-9]{9}$");
      if (!regex.hasMatch(engPhone)) {
        return false;
      }
    }
    return true;
  }

  bool validHomeNumber() {
    String homeNumber = this.home_number;
    if (homeNumber.trim() == "") {
      return false;
    } else {
      String engPhone = replacePersianWithEnglishNumber(homeNumber);
      RegExp regex = RegExp(r"^[0][0-9]{10}$");
      if (!regex.hasMatch(engPhone)) {
        return false;
      }
    }
    return true;
  }
}

class Consultant {
  String username = "";
  String authentication_string = "";
  String first_name = "";
  String last_name = "";
  String phone = "";
  String boss_consultant_username = "";
  String description = "";
  bool sub_cons_access = true;
  bool student_access = true;
  String phone_code = "";
  PaymentStatus paymentStatus = PaymentStatus();

  Consultant();

  factory Consultant.fromJson(dynamic json) {
    Consultant c = Consultant();
    c.username = json['username'];
    c.authentication_string = json['authentication_string'];
    c.first_name = json['first_name'];
    c.last_name = json['last_name'];
    c.phone = json['phone'];
    c.boss_consultant_username = json['boss_consultant_username'];
    c.description = json['description'];
    c.sub_cons_access = json['sub_cons_access'] ?? true;
    c.student_access = json['student_access'] ?? true;
    c.paymentStatus = PaymentStatus.fromJson(json['paymentStatus'] ?? {});
    return c;
  }

  Map<String, dynamic> toJson() => {
        'username': username,
        'authentication_string': authentication_string,
        'first_name': first_name,
        'last_name': last_name,
        'phone': phone,
        'boss_consultant_username': boss_consultant_username,
        'description': description,
        'sub_cons_access': sub_cons_access,
        'student_access': student_access,
        'phoneCode': phone_code,
        'paymentStatus': paymentStatus.toJson()
      };
}

class ConsultantSetting {
  bool subConsAccess = true;
  bool studentAccess = true;
  bool variableTime = true;
  bool hideBlue2Table = true;
  bool timeVolumeConsultantTableMode = true;
  String theme = "";

  ConsultantSetting();

  factory ConsultantSetting.fromJson(dynamic json) {
    ConsultantSetting c = ConsultantSetting();
    try {
      c.subConsAccess = json['subConsAccess'];
      c.studentAccess = json['studentAccess'];
      c.variableTime = json['variableTime'];
      c.hideBlue2Table = json['hideBlue2Table'];
      c.timeVolumeConsultantTableMode = json['timeVolumeConsultantTableMode'];
      c.theme = json['theme'];
    } catch (e) {}

    return c;
  }

  Map<String, dynamic> toJson() => {
        'subConsAccess': subConsAccess,
        'studentAccess': studentAccess,
        'variableTime': variableTime,
        'timeVolumeConsultantTableMode': timeVolumeConsultantTableMode,
        'hideBlue2Table': hideBlue2Table,
        'theme': theme
      };
}

class StudentSetting {
  bool hideBlue2Table = true;
  String theme = "";

  StudentSetting();

  factory StudentSetting.fromJson(dynamic json) {
    StudentSetting c = StudentSetting();
    try {
      c.hideBlue2Table = json['hideBlue2Table'];
      c.theme = json['theme'];
    } catch (e) {}

    return c;
  }

  Map<String, dynamic> toJson() =>
      {'hideBlue2Table': hideBlue2Table, 'theme': theme};
}
