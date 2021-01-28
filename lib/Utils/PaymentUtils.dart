import 'dart:convert';

import 'package:flushbar/flushbar.dart';
import 'package:flutter/foundation.dart';
import 'package:mhamrah/ConnectionService/ConsultantProfileSRV.dart';
import 'package:mhamrah/Models/UserMV.dart';
import 'package:mhamrah/Utils/SnackAnFlushBarUtils.dart';
import 'package:mhamrah/Values/Utils.dart';
import 'package:mhamrah/Values/string.dart';
import 'package:uni_links/uni_links.dart';
//import 'package:zarinpal/zarinpal.dart';

import 'LocalFileUtils.dart';

void checkPaymentAndShowNotification(PaymentStatus paymentStatus) async {
  if (paymentStatus.access == false) {
    String title = "تمدید دوره";
    String message = "دسترسی شما به دانش اموز ها قطع شده است." +
        "\n" +
        "لطفا در صفحه پروفایل خود به برای تمدید دوره اقدام کنید.";
    showNotificationFlushBar(title, message,
        flushbarPosition: FlushbarPosition.BOTTOM,
        flushbarDismissDirection: FlushbarDismissDirection.VERTICAL,
        ignoreOverflow: true,
        preventVibrate: true);
  } else if (paymentStatus.remainingDays < 8) {
    if (paymentStatus.remainingDays == 0) {
      String title = "تمدید دوره";
      String message = "تا پایان این دوره تنها" +
          " " +
          paymentStatus.remainingHours.toString() +
          " " +
          "ساعت باقی مانده است." +
          "\n" +
          "لطفا در صفحه پروفایل خود به برای تمدید دوره اقدام کنید.";
      showNotificationFlushBar(title, message,
          flushbarPosition: FlushbarPosition.BOTTOM,
          flushbarDismissDirection: FlushbarDismissDirection.VERTICAL,
          ignoreOverflow: true,
          preventVibrate: true);
    } else if (paymentStatus.remainingDays % 2 == 1) {
      String title = "تمدید دوره";
      String message = "تا پایان این دوره تنها" +
          " " +
          paymentStatus.remainingDays.toString() +
          " " +
          "روز باقی مانده است." +
          "\n" +
          "لطفا در صفحه پروفایل خود به برای تمدید دوره اقدام کنید.";
      showNotificationFlushBar(title, message,
          flushbarPosition: FlushbarPosition.BOTTOM,
          flushbarDismissDirection: FlushbarDismissDirection.VERTICAL,
          ignoreOverflow: true,
          preventVibrate: true);
    }
  }
}

void checkInitialLinkForPayment() async {
  // Platform messages may fail, so we use a try/catch PlatformException.
//  if (kIsWeb) {
//    try {
//      String initialLink = window.location.href;
//      if (initialLink != null) {
//        FBT.getLastPaymentRequest().then((paymentRequest) {
//          if (paymentRequest != null) {
//            checkPaymentAndUpdateServer(initialLink, paymentRequest);
//          }
//        });
//      }
//    } on Exception {}
//  } else {
//    try {
//      String initialLink = await getInitialLink();
//      if (initialLink != null) {
//        FBT.getLastPaymentRequest().then((paymentRequest) {
//          if (paymentRequest != null) {
//            checkPaymentAndUpdateServer(initialLink, paymentRequest);
//          }
//        });
//      }
//    } on Exception {}
//  }
}

void launchConsultantPaymentSite(
    int amount, String description, String phoneNumber, Function onDone) {
//  String siteCode = "bd117721-bd40-4c94-89fd-cd329ad0791d";
//  String callBackURL = "https://www.mhamrah.ir";
//   Initialize payment request
//  PaymentRequest _paymentRequest = PaymentRequest()
//    ..setIsSandBox(false)
//    ..setMerchantID(siteCode)
//    ..setAmount(amount)
//    ..setCallbackURL(callBackURL)
//    ..setDescription(description)
//    ..setMobile(phoneNumber);
//
//  FBT.setLastPaymentRequest(_paymentRequest);
//
//  // For scheme you can use uni_links dart Package
//  // Call Start payment
//
//  getLinksStream().listen((String link) {
//    checkPaymentAndUpdateServer(link, _paymentRequest);
//  });
//
//  ZarinPal().startPayment(_paymentRequest,
//      (int status, String paymentGatewayUri) {
//    onDone("test");
//    if (status == 100) {
//      lunchBrowser(paymentGatewayUri);
//    } else {
//      showFlutterToastWithFlushBar(paymentError, secsForDurations: 15);
//    } // launch URL in browser
//  });
}

//void checkPaymentAndUpdateServer(String link, PaymentRequest paymentRequest) {
//  Uri initialUri = Uri.parse(link);
//  Map<String, dynamic> pairs = initialUri.queryParametersAll;
//  if (pairs.containsKey("Authority") &&
//      pairs.containsKey("Status") &&
//      pairs['Status'][0] == "OK") {
//    String status = pairs['Status'][0];
//    String authority = pairs['Authority'][0];
//    paymentRequest.authority = authority;
//    LSM.getConsultant().then((consultant) {
//      showFlutterToastWithFlushBar(checkingPaymentTitle,
//          secsForDurations: 15, loading: true);
//      ConsultantProfileSRV()
//          .updateServerAfterConsPaymentForOneMonth(
//              consultant.username,
//              consultant.authentication_string,
//              authority,
//              paymentRequest.amount.toString())
//          .then((result) {
//        if (result['success'] ?? false) {
//          showFlutterToastWithFlushBar(
//              successPayment +
//                  "\n" +
//                  "شماره مرجع: " +
//                  (result['refId'] ?? " - ").toString(),
//              secsForDurations: 15);
//          PaymentStatus status = consultant.paymentStatus;
//          status.access = true;
//          status.remainingDays = 30;
//          status.remainingHours = 24;
//          consultant.paymentStatus = status;
//          LSM.updateConsultantInfo(consultant);
//          FBT.setLastPaymentRequest(null);
//        } else {
//          if (result['error'] == "Payment Submitted with 101 status code.") {
//            FBT.setLastPaymentRequest(null);
//          } else {
//            showFlutterToastWithFlushBar(paymentError, secsForDurations: 15);
//          }
//        }
//      });
//    });
//  }
//}
