import 'dart:collection';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:mhamrah/ConnectionService/ConsultantProfileSRV.dart';
import 'package:mhamrah/Utils/LocalFileUtils.dart';
import 'package:mhamrah/Utils/PaymentUtils.dart';
import 'package:mhamrah/Values/Utils.dart';
import 'package:mhamrah/Values/string.dart';
import 'package:mhamrah/Values/style.dart' as prefix1;
import 'package:mhamrah/Values/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  PaymentPage({Key key}) : super(key: key);

  @override
  PaymentPageState createState() => PaymentPageState();
}

class PaymentPageState extends State<PaymentPage> {
  ConsultantProfileSRV consultantProfileSRV = new ConsultantProfileSRV();
  String studentNumber = "3";
  String description = "";
  String deadLineDate = "";
  String amount = "";
  bool paymentPageLoading = false;
  bool paymentButtonLoading = false;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPaymentForm();
  }

  @override
  Widget build(BuildContext context) {
    double xSize = MediaQuery.of(context).size.width;
    double ySize = MediaQuery.of(context).size.height;
    return Container(
        width: 280,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(25),
            ),
            color: Color.fromARGB(0, 0, 0, 0)),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(25),
              ),
              color: prefix1.Theme.settingBg),
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: paymentPageLoading
                ? [getLoadingBar()]
                : <Widget>[
                    getTitleText(),
                    getTextParts(studentNumberPayment, studentNumber),
                    getTextParts("تاریخ اتمام دوره : ", deadLineDate),
                    getTextParts("توضیحات : ", description),
                    getPaymentMoney(),
//                    this.amount != "" && this.amount != "0"
//                        ? getPayButton()
//                        : SizedBox()
                    getPayButton()
                  ],
          ),
        ));
  }

  Widget getPayButton() {
    return GestureDetector(
      child: Container(
        width: double.maxFinite,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(25),
              bottomLeft: Radius.circular(25),
            ),
            color: prefix1.Theme.warningAndErrorBG),
        child: paymentButtonLoading
            ? getButtonLoadingProgress(r: 22, stroke: 2.5)
            : AutoSizeText(
                "پرداخت",
                style: getTextStyle(18, prefix1.Theme.onWarningAndErrorBG),
              ),
      ),
      onTap: () {
        LSM.getConsultant().then((consultant) {
          setState(() {
            paymentButtonLoading = true;
          });
          launchConsultantPaymentSite(
              int.parse(amount), description, consultant.phone, onPaymentDone);
        });
      },
    );
  }

  void onPaymentDone(String refId) {
    Navigator.of(context, rootNavigator: true).pop('dialog');
    setState(() {
      paymentButtonLoading = false;
    });
  }

  Widget getTitleText() {
    return Padding(
      padding: EdgeInsets.only(top: 10, left: 10, right: 10),
      child: Container(
        height: 50,
        child: AutoSizeText(
          paymentPageTitle,
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: getTextStyle(22, prefix1.Theme.onSettingText1),
        ),
      ),
    );
  }

  Widget getTextParts(String title, String message) {
    return Padding(
      padding: EdgeInsets.only(right: 10, left: 10, top: 30),
      child: Container(
          width: double.maxFinite,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              AutoSizeText(
                title,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: getTextStyle(18, prefix1.Theme.onSettingText1),
              ),
              AutoSizeText(
                message,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: getTextStyle(16, prefix1.Theme.onSettingText1),
              ),
            ],
          )),
    );
  }

  Widget getPaymentMoney() {
    return Padding(
      padding: EdgeInsets.only(right: 10, left: 10, top: 30),
      child: Container(
        height: 60,
        child: AutoSizeText(
          paymentMoney + " " + amount + " تومان",
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: getTextStyle(18, prefix1.Theme.onSettingText1),
        ),
      ),
    );
  }

  Widget getLoadingBar() {
    Widget w = new Padding(
      padding: EdgeInsets.only(top: 10),
      child: new Container(
        height: 150,
        width: 150,
        padding: EdgeInsets.all(20),
        child: CircularProgressIndicator(),
      ),
    );
    return w;
  }

  void fetchPaymentForm() {
    setState(() {
      paymentPageLoading = true;
    });
    LSM.getConsultant().then((consultant) {
      consultantProfileSRV
          .getPaymentForm(consultant.username, consultant.authentication_string)
          .then((paymentForm) {
        //TODO
        setState(() {
          studentNumber = (paymentForm['studentNumber'] ?? "").toString();
          description = (paymentForm['description'] ?? "").toString();
          amount = (paymentForm['amount'] ?? "").toString();
          deadLineDate = (paymentForm['deadLineData'] ?? "").toString();
          paymentPageLoading = false;
        });
      });
    });
  }
}
