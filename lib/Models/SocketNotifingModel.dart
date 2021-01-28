import 'package:mhamrah/Models/ChatMV.dart';
import 'package:mhamrah/Models/ConsultantTableMV.dart';
import 'package:mhamrah/Pages/ConsultantTable/ConsultantTable.dart';

import 'BlueTable1MV.dart';
import 'BlueTable2MV.dart';

class ValidationModel {
  String student_username = "";
  String consultant_username = "";
  String password = "";
  int user_type = -1;

  ValidationModel.student(this.student_username, this.password) {
    this.user_type = 1;
  }

  ValidationModel.consultant(this.consultant_username, this.password) {
    this.user_type = 0;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> dict = {
      'stuUsername': student_username,
      'consUsername': consultant_username,
      'password': password,
      'userType': user_type
    };
    return dict;
  }
}

class SocketNotifyingData {
  String requestType = "-1";
  RequestData requestData;

  SocketNotifyingData();

  Map<String, dynamic> toJson() {
    Map<String, dynamic> dict = {"requestType": requestType};
    if (requestData != null) {
      dict["requestData"] = requestData.toJson();
    } else {
      dict["requestData"] = "";
    }
    return dict;
  }

  factory SocketNotifyingData.fromJson(Map<String, dynamic> json) {
    SocketNotifyingData s = SocketNotifyingData();
    s.requestType = json['requestType'];
    if (s.requestType == "submit_message") {
      s.requestData = SubmitMessageSR.fromJson(json['requestData']);
    } else if (s.requestType == "delete_chat_message") {
      s.requestData = DeleteChatMessageSR.fromJson(json['requestData']);
    } else if (s.requestType == "edit_chat_text_message") {
      s.requestData = EditChatTextMessageSR.fromJson(json['requestData']);
    } else if (s.requestType == "submit_channel_message") {
      s.requestData = SubmitChannelMessageSR.fromJson(json['requestData']);
    } else if (s.requestType == "delete_channel_message") {
      s.requestData = DeleteChannelMessageSR.fromJson(json['requestData']);
    } else if (s.requestType == "edit_channel_text_message") {
      s.requestData = EditChannelTextMessageSR.fromJson(json['requestData']);
    } else if (s.requestType == "notify_consultant_table") {
      s.requestData = ConsultantTableSR.fromJson(json['requestData']);
    } else if (s.requestType == "notify_blue1_table") {
      s.requestData = Blue1TableSR.fromJson(json['requestData']);
    } else if (s.requestType == "notify_blue2_table") {
      s.requestData = Blue2TableSR.fromJson(json['requestData']);
    } else if (s.requestType == "notify_blue2_color_table") {
      s.requestData = Blue2TableColorSR.fromJson(json['requestData']);
    } else if (s.requestType == "share_consultant_table") {
      s.requestData = null;
    }

    return s;
  }
}

abstract class RequestData {
  Map<String, dynamic> toJson();

  RequestData();

  RequestData.fromJson(Map<String, dynamic> json);
}

class ChangeGroupCode extends RequestData {
  String groupCode;

  ChangeGroupCode();

  @override
  Map<String, dynamic> toJson() => {
        "groupCode": groupCode,
      };

  @override
  factory ChangeGroupCode.fromJson(Map<String, dynamic> json) {
    ChangeGroupCode s = ChangeGroupCode();
    s.groupCode = json['groupCode'];
    return s;
  }
}

class SubmitMessageSR extends RequestData {
  ChatMessageData chatMessageData;
  String username;

  SubmitMessageSR();

  @override
  Map<String, dynamic> toJson() => {
        "message": chatMessageData.toJson(),
        "username": username,
      };

  @override
  factory SubmitMessageSR.fromJson(Map<String, dynamic> json) {
    SubmitMessageSR s = SubmitMessageSR();
    s.chatMessageData = ChatMessageData.fromJson(json['message']);
    s.username = json['username'];
    return s;
  }
}

class DeleteChatMessageSR extends RequestData {
  String messageKey;
  String username;

  DeleteChatMessageSR();

  @override
  Map<String, dynamic> toJson() => {
        "messageKey": messageKey,
        "username": username,
      };

  @override
  factory DeleteChatMessageSR.fromJson(Map<String, dynamic> json) {
    DeleteChatMessageSR s = DeleteChatMessageSR();
    s.messageKey = json['messageKey'];
    s.username = json['username'];
    return s;
  }
}

class EditChatTextMessageSR extends RequestData {
  String messageKey;
  String newText;
  String username;

  EditChatTextMessageSR();

  @override
  Map<String, dynamic> toJson() => {
        "messageKey": messageKey,
        "newText": newText,
        "username": username,
      };

  @override
  factory EditChatTextMessageSR.fromJson(Map<String, dynamic> json) {
    EditChatTextMessageSR s = EditChatTextMessageSR();
    s.messageKey = json['messageKey'];
    s.username = json['username'];
    s.newText = json["newText"];
    return s;
  }
}

class SubmitChannelMessageSR extends RequestData {
  ChatMessageData chatMessageData;
  String consUserName;

  SubmitChannelMessageSR();

  @override
  Map<String, dynamic> toJson() => {
        "message": chatMessageData.toJson(),
        "consUsername": consUserName,
      };

  @override
  factory SubmitChannelMessageSR.fromJson(Map<String, dynamic> json) {
    SubmitChannelMessageSR s = SubmitChannelMessageSR();
    s.chatMessageData = ChatMessageData.fromJson(json['message']);
    s.consUserName = json['consUsername'];
    return s;
  }
}

class DeleteChannelMessageSR extends RequestData {
  String messageKey;
  String username;

  DeleteChannelMessageSR();

  @override
  Map<String, dynamic> toJson() => {
        "messageKey": messageKey,
        "username": username,
      };

  @override
  factory DeleteChannelMessageSR.fromJson(Map<String, dynamic> json) {
    DeleteChannelMessageSR s = DeleteChannelMessageSR();
    s.messageKey = json['messageKey'];
    s.username = json['username'];
    return s;
  }
}

class EditChannelTextMessageSR extends RequestData {
  String messageKey;
  String newText;
  String username;

  EditChannelTextMessageSR();

  @override
  Map<String, dynamic> toJson() => {
        "messageKey": messageKey,
        "newText": newText,
        "username": username,
      };

  @override
  factory EditChannelTextMessageSR.fromJson(Map<String, dynamic> json) {
    EditChannelTextMessageSR s = EditChannelTextMessageSR();
    s.messageKey = json['messageKey'];
    s.username = json['username'];
    s.newText = json["newText"];
    return s;
  }
}

class ConsultantTableSR extends RequestData {
  ConsultantTableModel consultantTableModel;

  ConsultantTableSR();

  @override
  Map<String, dynamic> toJson() =>
      {'consultantTable': consultantTableModel.toJson()};

  @override
  factory ConsultantTableSR.fromJson(Map<String, dynamic> json) {
    ConsultantTableSR s = ConsultantTableSR();
    s.consultantTableModel =
        ConsultantTableModel.fromJson(json['consultantTable']);
    return s;
  }
}

class Blue1TableSR extends RequestData {
  BlueTable1Data blueTable1Data;

  Blue1TableSR();

  @override
  Map<String, dynamic> toJson() => {'blueTable1Data': blueTable1Data.toJson()};

  @override
  factory Blue1TableSR.fromJson(Map<String, dynamic> json) {
    Blue1TableSR s = Blue1TableSR();
    s.blueTable1Data = BlueTable1Data.fromJson(json['blueTable1Data']);
    return s;
  }
}

class Blue2TableSR extends RequestData {
  String studentUsername;
  BlueTable2Data blueTable2Data;

  Blue2TableSR();

  @override
  Map<String, dynamic> toJson() => {
        'blueTable1Data': blueTable2Data.toJson(),
        'studentUsername': studentUsername
      };

  @override
  factory Blue2TableSR.fromJson(Map<String, dynamic> json) {
    Blue2TableSR s = Blue2TableSR();
    s.blueTable2Data = BlueTable2Data.fromJson(json['blueTable1Data']);
    s.studentUsername = json['studentUsername'];
    return s;
  }
}

class Blue2TableColorSR extends RequestData {
  String studentUsername;
  String tableName;
  int selectedDay;
  int partIndex;
  int hourIndex;
  String value;

  Blue2TableColorSR();

  @override
  Map<String, dynamic> toJson() => {
        'studentUsername': studentUsername,
        'tableName': tableName,
        'selectedDay': selectedDay,
        'partIndex': partIndex,
        'hourIndex': hourIndex,
        'value': value,
      };

  @override
  factory Blue2TableColorSR.fromJson(Map<String, dynamic> json) {
    Blue2TableColorSR s = Blue2TableColorSR();
    s.studentUsername = json['studentUsername'];
    s.tableName = json['tableName'];
    s.selectedDay = json['selectedDay'];
    s.value = json['value'];
    s.hourIndex = json['hourIndex'];
    s.partIndex = json['partIndex'];
    return s;
  }
}
