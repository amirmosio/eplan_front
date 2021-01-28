import 'dart:ui';

import 'package:mhamrah/Models/UserMV.dart' as prefix0;

class AccountData {
  prefix0.Student student;
  prefix0.StudentSetting studentSetting;
  prefix0.Consultant consultant;
  prefix0.ConsultantSetting consultantSetting;

  AccountData();

  factory AccountData.fromJson(dynamic json) {
    AccountData accountData = AccountData();
    accountData.student = prefix0.Student.fromJson(json['student']);
    accountData.studentSetting =
        prefix0.StudentSetting.fromJson(json['student']['setting']);
    accountData.consultant = prefix0.Consultant.fromJson(json['consultant']);
    accountData.consultantSetting =
        prefix0.ConsultantSetting.fromJson(json['consultant']['setting']);
    return accountData; //TODO
  }

  Map<String, dynamic> toJson() =>
      {'student': student, 'consultant': consultant};
}
