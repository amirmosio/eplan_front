import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:mhamrah/Models/ChatMV.dart';
import 'package:mhamrah/Models/SocketNotifingModel.dart';
import 'package:mhamrah/Models/UserMV.dart';
import 'package:mhamrah/Utils/LocalFileUtils.dart';
import 'package:http/http.dart' as http;
// import 'package:web_socket_channel/html.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class PendingSocketRequest {
  List<String> groupCode;
  SocketNotifyingData data;

  PendingSocketRequest(this.groupCode, this.data);
}

class ConnectionService {
  static final Ip = "mhamrah.ir";

//  static final Ip = "127.0.0.1";

//  static final Ip = "185.208.172.203";
  static final Port = "9000";

  static final String mainServerURL = "https://" + Ip + "/api/";

//  static final String mainServerURL = "http://" + Ip + ":" + Port + "/api/";
//  static final String mainSocketURl = "ws://" + Ip + ":" + Port + "/ws/eplan?";

  static final String mainSocketURl = "wss://" + Ip + "/ws/eplan?";

  static Future<bool> checkInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
    return false;
  }

  static WebSocketChannel channel;
  static WebSocket socket;
  static Stream stream;
  static String currentStreamGroupCode;
  static List<PendingSocketRequest> socketQueue = [];

  ConnectionService() {}

  static Future<WebSocketChannel> openSocket(List<String> groupCode) async {
    try {
      if (channel != null && channel.closeReason == null) {
        return sendChangeChannelToSocket(groupCode);
      }
//      channel.sink.close(status.goingAway);
    } catch (Exception) {}
    currentStreamGroupCode = getUsersGroupCode(groupCode);
    String query = getOpenSocketQueryString(groupCode);
    print("opening: " + mainSocketURl + query);
    try {
      if (!kIsWeb) {
        WebSocket.connect(mainSocketURl + query)
            .timeout(Duration(seconds: 10))
            .then((socket) {
          ConnectionService.socket = socket;
          socket.pingInterval = Duration(seconds: 5);
          channel = IOWebSocketChannel(socket);
          stream = channel.stream.asBroadcastStream();
          stream.listen((message) {
            // handling of the incoming messages
          }, onError: (error, StackTrace stackTrace) {
            print(error.toString());
            channel = null;
            channel = null;
          }, onDone: () {
            channel = null;
          });
        });
      } else {
       // channel = HtmlWebSocketChannel.connect(mainSocketURl + query);
//        stream = channel.stream.asBroadcastStream();
//        stream.listen((message) {
//          // handling of the incoming messages
//        }, onError: (error, StackTrace stackTrace) {
//          print(error.toString());
//          channel = null;
//          channel = null;
//        }, onDone: () {
//          channel = null;
//          print("Done Socket");
//        });
      }
    } catch (e) {
      print('error caught: $e');
      channel = null;
    }

    return channel;
  }

  static String getUsersGroupCode(List<String> groupCode) {
    groupCode.sort();
    String groupStringCode = "";
    for (int i = 0; i < groupCode.length; i++) {
      groupStringCode += groupCode[i];
    }
    return groupStringCode;
  }

  static String getOpenSocketQueryString(List<String> groupCode) {
    String groupStringCode = getUsersGroupCode(groupCode);
    int userType = LSM.getUserModeSync();
    String query = "";
    if (userType == 0) {
      Consultant c = LSM.getConsultantSync();
      query += 'userType=' +
          userType.toString() +
          "&" +
          'consUsername=' +
          c.username +
          "&" +
          "password=" +
          c.authentication_string +
          "&" +
          "groupCode=" +
          groupStringCode;
    } else if (userType == 1) {
      Student s = LSM.getStudentSync();
      query += 'userType=' +
          userType.toString() +
          "&" +
          'stuUsername=' +
          s.username +
          '&' +
          'password=' +
          s.authentication_string +
          '&' +
          'groupCode=' +
          groupStringCode;
    }

    return query;
  }

  static WebSocketChannel sendChangeChannelToSocket(List<String> newGroupCode) {
    String requestedGroupCode = getUsersGroupCode(newGroupCode);
    SocketNotifyingData data = SocketNotifyingData();
    data.requestType = "change_group_code";
    ChangeGroupCode cgc = ChangeGroupCode();
    cgc.groupCode = requestedGroupCode;
    data.requestData = cgc;
    try {
      channel.sink.add(json.encode(data.toJson()));
    } catch (Exception) {
      socketQueue.add(new PendingSocketRequest(newGroupCode, null));
    }
    currentStreamGroupCode = requestedGroupCode;
    return channel;
    print(mainSocketURl + "change group code");
  }

  static Future<WebSocketChannel> getOpenChannel(List<String> groupCode) async {
    String requestedGroupCode = getUsersGroupCode(groupCode);
    if (currentStreamGroupCode == requestedGroupCode &&
        channel != null &&
        channel.closeCode == null) {
      return channel;
    }

    return await openSocket(groupCode);
  }

  static void sendPendingRequest() async {
    while (socketQueue.length != 0) {
      PendingSocketRequest p = socketQueue[0];
      socketQueue.removeAt(0);
      if (getUsersGroupCode(p.groupCode) != currentStreamGroupCode) {
        sendChangeChannelToSocket(p.groupCode);
      }
      if (p.data != null) {
        sendDataToSocket(p.groupCode, p.data);
      }
    }
  }

  static Future<int> sendDataToSocket(
      List<String> groupCode, SocketNotifyingData data) async {
    int res = -1;
    WebSocketChannel channel = await getOpenChannel(groupCode);
    try {
      if (channel.closeReason != null) {
        throw Exception();
      }
      channel.sink.add(json.encode(data.toJson()));
      res = 1;
    } catch (Exception) {
      print("****** failed in sending" + Exception.toString());
      PendingSocketRequest p = PendingSocketRequest(groupCode, data);
      socketQueue.add(p);
      print(socketQueue.length);
    }
    return res;
  }

  static closeChannel() {
    try {
      channel.sink.close();
    } catch (Exception) {}
  }

  Future<String> postAndGetResponseBody(
    String subURL,
    HashMap<String, String> headerHashMap,
    String jsonBody,
  ) async {
    print(mainServerURL + subURL);
    headerHashMap.addAll({
      'Content-Type': 'application/json; charset=UTF-8',
    });
    Map<String, dynamic> body = jsonDecode(jsonBody);
    body['Content-Type'] = 'application/json; charset=UTF-8';
    http.Response response = await http.post(
      mainServerURL + subURL,
      headers: headerHashMap,
      body: jsonEncode(body),
    );
    if (response.statusCode != 201) {
      return response.body;
    } else {
      throw Exception(
          'Error in post with error code: ' + response.statusCode.toString());
    }
  }

  Future<String> uploadWithFile(
      String subURL, HashMap<String, String> data, CustomFile file) async {
    http.MultipartRequest request = http.MultipartRequest(
      "POST",
      Uri.parse(mainServerURL + subURL),
    );
    request.fields.addAll(data);

    /// this image name has changed and we send file here but it is hard tp change
    if (file != null) {
      request.files.add(http.MultipartFile.fromString(
          'image', base64.encode(file.fileBytes)));
    }

    http.StreamedResponse response = await request.send();
    if (response.statusCode != 201) {
      return response.stream.bytesToString();
    } else {
      throw Exception(
          'Error in post with error code: ' + response.statusCode.toString());
    }
  }

  String getConsultantImageURL(String username) {
    if (username == null) {
      return "";
    }
    String url = mainServerURL + "user/get_cons_avatar_image";
    url = url + "?" + 'username=' + username;
    return url;
  }

  String getGroupImageURL() {
    String url = mainServerURL + "user/get_group_avatar";
    return url;
  }

  String getStudentImageURL(String username) {
    if (username == null) {
      return "";
    }
    String url = mainServerURL + "user/get_stu_avatar_image";
    url = url + "?" + 'username=' + username;
    return url;
  }

  String getConsultantPdfURL(
      String username, String stuUsername, String tableName, String token) {
    String url = mainServerURL + "pdf/get_table_pdf";
    url = url + "?" + 'stuUsername=' + stuUsername;
    url = url + "&" + "username=" + username;
    url = url + "&" + "token=" + token;
    url = url + "&" + "tableName=" + tableName;
    return url;
  }

  String getChatMessageImageURL(String imageKey) {
    List<String> userAuth = LSM.getUsernameAuthSync();
    if (imageKey == null || imageKey == "") {
      return "";
    }
    String url = mainServerURL + "chat/get_chat_image";
    url = url + "?" + 'key=' + imageKey;
    url = url + "&" + "username=" + userAuth[0];
    url = url + "&" + "password=" + userAuth[1];
    return url;
  }

  String getChatMessageDocURL(String imageKey) {
    List<String> userAuth = LSM.getUsernameAuthSync();

    if (imageKey == null || imageKey == "") {
      return "";
    }
    String url = mainServerURL + "chat/get_chat_doc";
    url = url + "?" + 'key=' + imageKey;
    url = url + "&" + "username=" + userAuth[0];
    url = url + "&" + "password=" + userAuth[1];
    return url;
  }

  String getChannelMessageDocURL(String imageKey) {
    List<String> userAuth = LSM.getUsernameAuthSync();

    if (imageKey == null || imageKey == "") {
      return "";
    }
    String url = mainServerURL + "channel/get_channel_doc";
    url = url + "?" + 'key=' + imageKey;
    url = url + "&" + "username=" + userAuth[0];
    url = url + "&" + "password=" + userAuth[1];
    return url;
  }

  String getChannelMessageImageURL(String imageKey) {
    List<String> userAuth = LSM.getUsernameAuthSync();

    if (imageKey == null || imageKey == "") {
      return "";
    }
    String url = mainServerURL + "channel/get_channel_image";
    url = url + "?" + 'key=' + imageKey;
    url = url + "&" + "username=" + userAuth[0];
    url = url + "&" + "password=" + userAuth[1];
    return url;
  }

  String getChatMessageVoiceURL(String voiceKey) {
    List<String> userAuth = LSM.getUsernameAuthSync();

    if (voiceKey == null || voiceKey == "") {
      return "";
    }
    String url = mainServerURL + "chat/get_chat_voice";
    url = url + "?" + 'key=' + voiceKey;
    url = url + "&" + "username=" + userAuth[0];
    url = url + "&" + "password=" + userAuth[1];
    return url;
  }

  String getChannelMessageVoiceURL(String voiceKey) {
    List<String> userAuth = LSM.getUsernameAuthSync();

    if (voiceKey == null || voiceKey == "") {
      return "";
    }
    String url = mainServerURL + "channel/get_channel_voice";
    url = url + "?" + 'key=' + voiceKey;
    url = url + "&" + "username=" + userAuth[0];
    url = url + "&" + "password=" + userAuth[1];
    return url;
  }

  String getLessonDescriptionVoiceURL(
      String stuUsername, String tableName, String lessonKey) {
    List<String> userAuth = LSM.getUsernameAuthSync();

    if (stuUsername == null || stuUsername == "") {
      return "";
    }
    if (tableName == null || tableName == "") {
      return "";
    }
    if (lessonKey == null || lessonKey == "") {
      return "";
    }
    String url = mainServerURL + "consultant_table/get_description_voice";
    url = url + "?" + 'stuUsername=' + stuUsername;
    url = url + "&" + "username=" + userAuth[0];
    url = url + "&" + "password=" + userAuth[1];
    url = url + "&" + 'lessonKey=' + lessonKey;
    url = url + "&" + 'tableName=' + tableName;

    return url;
  }
}
