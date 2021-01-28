import 'dart:math';

import 'package:crypto/crypto.dart';
import 'dart:convert';

class SecurityAndKeyGeneration {
  static String codeAuthString(String auth) {
    var bytes = utf8.encode(auth); // data being hashed

    var digest = sha1.convert(bytes);
    return "$digest";
  }

  static String generateRandomString({int length = 10}) {
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random _rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
    ;
  }
}
