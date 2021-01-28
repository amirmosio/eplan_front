import 'dart:collection';
import 'dart:convert';
import 'dart:convert';

import 'package:mhamrah/Models/ConsultantTableMV.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:mhamrah/Models/ChatMV.dart';
import 'package:mhamrah/Models/SocketNotifingModel.dart';
import 'package:mhamrah/Models/UserMV.dart';
import 'package:mhamrah/Utils/LocalFileUtils.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'HTTPService.dart';

class DateTimeService {
  ConnectionService httpReq = new ConnectionService();

  Future<Map<String, dynamic>> getDateTime() async {
    HashMap headerHashMap = HashMap();
    headerHashMap.addAll({
      'Content-Type': 'application/json; charset=UTF-8',
    });
    http.Response response;
    try {
      response = await http.get(
        "http://api.codebazan.ir/time-date/?json=fa",
      );
    } catch (e) {
      return null;
    }
    if (response.statusCode != 201) {
      return json.decode(response.body);
    } else {
      throw Exception(
          'Error in post with error code: ' + response.statusCode.toString());
    }
  }
}
