import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:mhamrah/Models/ChatMV.dart';
import 'package:mhamrah/Models/UserMV.dart';

import 'HTTPService.dart';

class ConsultantProfileSRV {
  ConnectionService httpReq = new ConnectionService();

  Future<bool> verifyPayment(
      String merchantId, String authority, String amount) async {
    String zarinPalApi = "https://api.zarinpal.com/pg/v4/payment";
    String requestURL = zarinPalApi + "/verify.json";
    HashMap<String, String> header = new HashMap();

    HashMap bodyHashMap = new HashMap();
    bodyHashMap['authority'] = authority;
    String body = json.encode(bodyHashMap);
    String jsonString =
        await httpReq.postAndGetResponseBody(requestURL, header, body);
    try {
      print(jsonString);
      return false;
    } catch (e) {
      return false;
    }
  }
}
