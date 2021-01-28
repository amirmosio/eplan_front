import 'dart:convert';
import 'dart:io';

import 'dart:typed_data';

class CustomFile {
  Uint8List fileBytes;
  String fileNameOrPath;
}

class ChatMessageDataList {
  List<ChatMessageData> chatMessageDataList = [];

  Map<String, dynamic> toJson() {
    Map<String, dynamic> res = {};
    List<Map> list = [];
    for (int i = 0; i < chatMessageDataList.length; i++) {
      list.add(chatMessageDataList[i].toJson());
    }
    res['chatMessageDataList'] = list;
    return res;
  }

  ChatMessageDataList();

  factory ChatMessageDataList.fromJson(Map<String, dynamic> json,
      {int status = -1}) {
    ChatMessageDataList c = ChatMessageDataList();
    c.chatMessageDataList = <ChatMessageData>[];
    for (int i = 0; i < json['chatMessageDataList'].length; i++) {
      c.chatMessageDataList.add(ChatMessageData.fromJson(
          json['chatMessageDataList'][i],
          status: status));
    }
    return c;
  }
}

class ChatMessageData {
  String ownerUsername;
  String clientRandomKey;
  Map<String, bool> usersWithAccess = {};
  String messageNetKey;
  String text;

  bool hasImageFile;
  String imageNetKey;
  CustomFile imageFile;
  String imageFileExt;

  bool hasVoiceFile;
  String voiceNetKey;
  File voiceFile;
  String voiceFileExt;

  bool hasDocFile;
  String docNetKey;
  CustomFile docFile;
  String docFileExt;

  String time;
  String date;
  int status;

  ChatMessageData();

  ChatMessageData getCopy() {
    ChatMessageData chatMessageData = ChatMessageData();
    chatMessageData.ownerUsername = this.ownerUsername;
    chatMessageData.clientRandomKey = this.clientRandomKey;
    chatMessageData.usersWithAccess = this.usersWithAccess;
    chatMessageData.messageNetKey = this.messageNetKey;
    chatMessageData.text = this.text;

    chatMessageData.hasImageFile = this.hasImageFile;
    chatMessageData.imageNetKey = this.imageNetKey;
    chatMessageData.imageFile = this.imageFile;
    chatMessageData.imageFileExt = this.imageFileExt;

    chatMessageData.hasVoiceFile = this.hasVoiceFile;
    chatMessageData.voiceNetKey = this.voiceNetKey;
    chatMessageData.voiceFile = this.voiceFile;
    chatMessageData.voiceFileExt = this.voiceFileExt;

    chatMessageData.hasDocFile = this.hasDocFile;
    chatMessageData.docNetKey = this.docNetKey;
    chatMessageData.docFile = this.docFile;
    chatMessageData.docFileExt = this.docFileExt;

    chatMessageData.time = this.time;
    chatMessageData.date = this.date;
    chatMessageData.status = this.status;

    return chatMessageData;
  }

  String getMessageKey() {
    return ((ownerUsername ?? "") +
        (clientRandomKey ?? "") +
        (time ?? "") +
        (date ?? ""));
  }

  Map<String, dynamic> toJson() => {
        'clientRandomKey': clientRandomKey,
        'ownerUsername': ownerUsername,
        'text': text,
        'messageKey': messageNetKey,
        'hasImageFile': hasImageFile,
        'imageURL': imageNetKey,
        'imageFile': (imageFile != null && imageFile.fileBytes != null)
            ? base64.encode(imageFile.fileBytes)
            : null,
        'imageFileExt': (imageFile != null && imageFile.fileNameOrPath != null)
            ? imageFile.fileNameOrPath.split(".").last
            : imageFileExt,
        'hasVoiceFile': hasVoiceFile,
        'voiceURL': voiceNetKey,
        'voiceFile': (voiceFile != null)
            ? base64.encode(voiceFile.readAsBytesSync())
            : null,
        'voiceFileExt':
            voiceFile != null ? voiceFile.path.split(".").last : voiceFileExt,
        'hasDocFile': hasDocFile,
        'docURL': docNetKey,
        'docFile': (docFile != null && docFile.fileBytes != null)
            ? base64.encode(docFile.fileBytes)
            : null,
        'docFileExt': (docFile != null && docFile.fileNameOrPath != null)
            ? docFile.fileNameOrPath.split(".").last
            : docFileExt,
        'usersWithAccess': usersWithAccess,
        'time': time,
        'date': date
      };

  factory ChatMessageData.fromJson(Map<String, dynamic> json, {int status}) {
    ChatMessageData c = ChatMessageData();
    c.ownerUsername = json['ownerUsername'];
    c.clientRandomKey = json['clientRandomKey'];
    c.text = json['text'];
    try {
      c.messageNetKey = json['messageKey'].toString() ?? "";
    } catch (e) {}
    c.status = status;
    Map<String, bool> res = {};
    List<String> usernames = json['usersWithAccess'].keys.toList();
    for (int i = 0; i < usernames.length; i++) {
      res[usernames[i]] = json['usersWithAccess'][usernames[i]];
    }
    c.usersWithAccess = res;

    /// image
    if (json['imageFile'] != null && json['imageFile'] != "") {
//      File imageFile = File("temp.jpg");
//      imageFile.writeAsBytesSync(json['imageFile']);
//      c.imageFile = CustomFile();
//      c.imageFile.fileBytes = imageFile.readAsBytesSync();
//      c.imageFileExt =
//          imageFile.path.split(".")[imageFile.path.split(".").length - 1];
    }
    c.hasDocFile = json['hasImageFile'];
    c.imageNetKey = json['imageURL'];
    c.imageFileExt = json['imageFileExt'];

    /// voice
    if (json['voiceFile'] != null && json['voiceFile'] != "") {
//      File voiceFile = File("temp.wav");
//      voiceFile.writeAsBytesSync(json['voiceFile']);
//      c.voiceFile = voiceFile;
//      c.voiceFileExt =
//          voiceFile.path.split(".")[voiceFile.path.split(".").length - 1];
    }
    c.hasVoiceFile = json['hasVoiceFile'];
    c.voiceNetKey = json['voiceURL'];
    c.voiceFileExt = json['voiceFileExt'];

    /// doc
    if (json['docFile'] != null && json['docFile'] != "") {
//      File docFile = File("temp.doc");
//      docFile.writeAsBytesSync(json['docFile']);
//      c.docFile = CustomFile();
//      c.docFile.fileBytes = docFile.readAsBytesSync();
//      c.docFileExt =
//          docFile.path.split(".")[docFile.path.split(".").length - 1];
    }
    c.hasDocFile = json['hasDocFile'];
    c.docNetKey = json['docURL'];
    c.docFileExt = json['docFileExt'];

    /// time date id
    c.time = json['time'];
    c.date = json['date'];
    //TODO
    return c;
  }

  ChatMessageData.messageLoad(
      String ownerUsername,
      String text,
      CustomFile imageFile,
      File voiceFile,
      Map<String, bool> usersWithAccess,
      String time,
      String date) {
    if (text != null && text != "") {
      textMessageLoad(ownerUsername, text, usersWithAccess, time, date);
    } else if (imageFile != null) {
      imageMessageLoad(ownerUsername, imageFile, usersWithAccess, time, date);
    } else if (voiceFile != null) {
      voiceMessageLoad(ownerUsername, voiceFile, usersWithAccess, time, date);
    }
  }

  ChatMessageData.messageSubmit(
      String ownerUsername,
      String text,
      CustomFile imageFile,
      File voiceFile,
      CustomFile docFile,
      List<String> userNamesList,
      String time,
      String date) {
    if (text != null && text != "") {
      textMessageSubmit(ownerUsername, text, userNamesList, time, date);
    } else if (imageFile != null) {
      imageMessageSubmit(ownerUsername, imageFile, userNamesList, time, date);
    } else if (voiceFile != null) {
      voiceMessageSubmit(ownerUsername, voiceFile, userNamesList, time, date);
    } else if (docFile != null) {
      docMessageSubmit(ownerUsername, docFile, userNamesList, time, date);
    }
  }

  void textMessageLoad(String ownerUsername, String text,
      Map<String, bool> usersWithAccess, String time, String date) {
    this.ownerUsername = ownerUsername;
    this.text = text;
    this.usersWithAccess = usersWithAccess;
    this.time = time;
    this.date = date;
  }

  void textMessageSubmit(String ownerUsername, String text,
      List<String> userNamesList, String time, String date) {
    Map<String, bool> usersWithAccess = {};
    for (int i = 0; i < userNamesList.length; i++) {
      usersWithAccess[userNamesList[i]] = false;
    }
    this.ownerUsername = ownerUsername;
    this.text = text;
    this.usersWithAccess = usersWithAccess;
    this.time = time;
    this.date = date;
  }

  void imageMessageLoad(String ownerUsername, CustomFile imageFile,
      Map<String, bool> usersWithAccess, String time, String date) {
    this.ownerUsername = ownerUsername;
    this.imageFile = imageFile;
    this.usersWithAccess = usersWithAccess;
    this.time = time;
    this.date = date;
  }

  void imageMessageSubmit(String ownerUsername, CustomFile imageFile,
      List<String> userNamesList, String time, String date) {
    Map<String, bool> usersWithAccess = {};
    for (int i = 0; i < userNamesList.length; i++) {
      usersWithAccess[userNamesList[i]] = false;
    }
    this.ownerUsername = ownerUsername;
    this.imageFile = imageFile;
    this.usersWithAccess = usersWithAccess;
    this.time = time;
    this.date = date;
  }

  void voiceMessageLoad(String ownerUsername, File voiceFile,
      Map<String, bool> usersWithAccess, String time, String date) {
    this.ownerUsername = ownerUsername;
    this.voiceFile = voiceFile;
    this.usersWithAccess = usersWithAccess;
    this.time = time;
    this.date = date;
  }

  void voiceMessageSubmit(String ownerUsername, File voiceFile,
      List<String> userNamesList, String time, String date) {
    Map<String, bool> usersWithAccess = {};
    for (int i = 0; i < userNamesList.length; i++) {
      usersWithAccess[userNamesList[i]] = false;
    }
    this.ownerUsername = ownerUsername;
    this.voiceFile = voiceFile;
    this.usersWithAccess = usersWithAccess;
    this.time = time;
    this.date = date;
  }

  void docMessageSubmit(String ownerUsername, CustomFile docFile,
      List<String> userNamesList, String time, String date) {
    Map<String, bool> usersWithAccess = {};
    for (int i = 0; i < userNamesList.length; i++) {
      usersWithAccess[userNamesList[i]] = false;
    }
    this.ownerUsername = ownerUsername;
    this.docFile = docFile;
    this.usersWithAccess = usersWithAccess;
    this.time = time;
    this.date = date;
  }
}
