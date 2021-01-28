import 'dart:async';

import 'package:mhamrah/ConnectionService/HTTPService.dart';
import 'package:mhamrah/Pages/User/FirstPage.dart';
import 'package:flutter/material.dart';

import 'SnackAnFlushBarUtils.dart';

Future<Timer> socketConnectionChecker(List<String> groupCode, State pageWidget,
    Function socketUpdater, Function httpUpdater) async {
  double snackBarContentHeight = 40;
  double snackBarFontSize = 15;
  bool connectNow = false;
  if (ConnectionService.stream != null) {
    socketUpdater();
  }

  int connectionStablePower = 0;
  int connectionCheckerPeriod = 750;
  int connectErrorCount = 0;
  Timer timer = Timer.periodic(Duration(milliseconds: connectionCheckerPeriod),
      (Timer t) {
    print(pageWidget);
    FirstPage.currentPageState = pageWidget;
    if (ConnectionService.channel == null ||
        (ConnectionService.channel.closeCode != null &&
            ConnectionService.channel.closeReason != null)) {
      if (connectErrorCount == 0) {
        try {
          showTryingToConnectSnackBar(snackBarContentHeight, snackBarFontSize);
        } catch (e) {}
      }
      connectErrorCount += 1;
      connectionStablePower = 0;
      ConnectionService.openSocket(groupCode);
      connectNow = true;
    } else if (ConnectionService.channel != null &&
        ConnectionService.channel.closeCode == null &&
        connectNow) {
      connectErrorCount = 0;
      connectionStablePower += 1;
      if (connectionStablePower >= 4) {
        socketUpdater();
        try {
          httpUpdater();
        } catch (e) {}
        connectNow = false;
        removeSnackBars();
        try {
          showConnectedSnackBar(snackBarContentHeight, snackBarFontSize);
        } catch (e) {}
      }
      ConnectionService.sendPendingRequest();
      pageWidget.setState(() {});
    } else {
//      removeSnackBars();
      connectionStablePower += 1;
//      pageWidget.setState(() {});
      ConnectionService.getOpenChannel(groupCode);
    }
  });
  return timer;
}
