import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mhamrah/Pages/User/FirstPage.dart';
import 'package:mhamrah/Utils/PaymentUtils.dart';
import 'package:uni_links/uni_links.dart';
import 'package:sentry/sentry.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

//final sentry = SentryClient(dsn: "https://f459dea3ae7e461d83fdc146985721e5@o442268.ingest.sentry.io/5413810");
//
//Future<void> _reportError(dynamic error, dynamic stackTrace) async {
//  // Print the exception to the console.
//  print('Caught error: $error');
//  // Send the Exception and Stacktrace to Sentry in Production mode.
//  sentry.captureException(
//    exception: error,
//    stackTrace: stackTrace,
//  );
//}

void main() async {
  Crashlytics.instance.enableInDevMode = true;

  // Pass all uncaught errors from the framework to Crashlytics.
  FlutterError.onError = Crashlytics.instance.recordFlutterError;

//  Isolate.current.addErrorListener(RawReceivePort((pair) async {
//    final List<dynamic> errorAndStacktrace = pair;
//    await Crashlytics.instance.recordError(
//      errorAndStacktrace.first,
//      errorAndStacktrace.last,
//    );
//  }).sendPort);

  runZonedGuarded<Future<void>>(() async {
    runApp(MyApp());
  }, Crashlytics.instance.recordError);
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

enum UniLinksType { string, uri }

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  StreamSubscription _sub;

  @override
  initState() {
    super.initState();
    checkInitialLinkForPayment();
  }

  @override
  dispose() {
    if (_sub != null) _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FirstPage(),
    );
  }
}
