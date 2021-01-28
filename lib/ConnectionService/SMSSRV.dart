import 'dart:collection';
import 'dart:convert';

import 'HTTPService.dart';

class SMSSRV {
  ConnectionService httpReq = new ConnectionService();
  String subURL = "sms/";

  Future<Map<String, dynamic>> sendRegisterCode(
      String username, String newPossiblyPhone) async {
    String requestSubURL;
    requestSubURL = subURL + 'send_phone_code';
    HashMap<String, String> header = new HashMap();
    HashMap<String, String> bodyHashMap = new HashMap();
    bodyHashMap['username'] = username;
    bodyHashMap['phone'] = newPossiblyPhone;
    String body = jsonEncode(bodyHashMap);
    String jsonString =
        await httpReq.postAndGetResponseBody(requestSubURL, header, body);
    return json.decode(jsonString);
  }
}
