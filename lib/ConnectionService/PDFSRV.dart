import 'dart:collection';
import 'dart:convert';
import 'dart:convert';

import 'package:mhamrah/Models/ConsultantTableMV.dart';
import 'package:url_launcher/url_launcher.dart';

import 'HTTPService.dart';

class PDFSRV {
  ConnectionService httpReq = new ConnectionService();
  String subURL = "pdf/";

  Future<String> generatePDFToken(String username, String stuUsername,
      String auth, String tableName) async {
    String requestSubURL = subURL + 'generate_pdf_token';
    HashMap<String, String> header = new HashMap();
    header['username'] = username;
    header['password'] = auth;
    header['stuUsername'] = stuUsername;
    HashMap bodyHashMap = new HashMap();
    bodyHashMap['tableName'] = tableName;
    String body = json.encode(bodyHashMap);
    String jsonString;
    try {
      jsonString =
          await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    } catch (Exception) {
      return null;
    }
    if (json.decode(jsonString)['success']) {
      return json.decode(jsonString)['token'];
    }
    return null;
  }


}
