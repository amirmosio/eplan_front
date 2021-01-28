import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:mhamrah/Models/ChatMV.dart';
import 'package:mhamrah/Models/SocketNotifingModel.dart';
import 'package:mhamrah/Models/UserMV.dart';

import 'HTTPService.dart';

class ChannelSRV {
  ConnectionService httpReq = new ConnectionService();
  String subURL = "channel/";

  Future<Map> submitMessageToChannelFile(
      String username, String auth, ChatMessageData message,CustomFile file) async {



    String requestSubURL;
    requestSubURL = subURL + 'submit_channel_message';

    HashMap<String, String> data = new HashMap();
    data['username'] = username;
    data['password'] = auth;
    data['message'] = json.encode(message.toJson());
    String jsonString = await httpReq.uploadWithFile(requestSubURL, data, file);
    return (json.decode(jsonString));
  }

  Future<bool> submitChannelMessageFromSocket(
      String ownerUsername, String auth, ChatMessageData message) async {
    SocketNotifyingData s = SocketNotifyingData();
    s.requestType = "submit_channel_message";
    SubmitChannelMessageSR requestData = SubmitChannelMessageSR();
    requestData.consUserName = ownerUsername;
    requestData.chatMessageData = message;
    s.requestData = requestData;
    ConnectionService.sendDataToSocket(
        message.usersWithAccess.keys.toList(), s);
  }

  Future<List<ChatMessageData>> getRecentChannelChat(
      String stuUsername, String consUsername, String auth) async {
    String requestSubURL;
    HashMap<String, String> header = new HashMap();
    header['consUsername'] = consUsername;
    header['stuUsername'] = stuUsername;
    header['password'] = auth;
    requestSubURL = subURL + 'get_recent_channel_messages';
    HashMap bodyHashMap = new HashMap();
    String body = json.encode(bodyHashMap);
    String jsonString =
        await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    if (json.decode(jsonString)['success']) {
      List<ChatMessageData> res = [];
      for (int i = 0; i < json.decode(jsonString)['chatMessages'].length; i++) {
        res.add(ChatMessageData.fromJson(
            json.decode(jsonString)['chatMessages'][i],status: 1));
      }
      return res;
    } else {
      return [];
    }
  }


}
