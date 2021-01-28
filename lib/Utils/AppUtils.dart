import 'dart:io';

import 'package:mhamrah/ConnectionService/AppService.dart';
import 'package:mhamrah/Pages/User/FirstPage.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info/package_info.dart';

import 'SnackAnFlushBarUtils.dart';

List<String> socialApps = [
  'iGap.Plus',
  'net.iGap',
  'mobi.mmdt.ottplus',
  'mobi.mmdt.ott',
  'ir.nasim',
  'ir.eitaa.messenger',
  'eitaa.file.mas',
  'com.gapafzar.messenger',
  'com.application.Bluechat',
  'com.app.bechat',
  'com.tencent.mm',
  'ir.Roomak.MRD',
  'com.whatsapp',
  'com.whatsapp.w4b',
  'com.imo.android.imoim',
  'com.bistalk.bisphoneplus',
  'com.bistalk.bisphoneplus',
  'com.google.android.gm',
  'io.raychat.raychat',
  'mini.video.chat',
  'com.pinterest',
  'com.instagram.android',
  'com.nazdika.app',
  'ir.android.baham',
  'com.appgozar.instaclip',
  'net.farvardin.cloobsocialnetwork',
  'com.skype.raider',
  'link.zamin.balonet',
  'jp.naver.line.android',
  'com.beint.pinngle',
  'com.google.android.talk',
  'co.jinngchat.android',
  'org.qtproject.example.navamessenger',
  'org.telegram.messenger',
  'org.thunderdog.challegram',
  'org.vidogram.messenger',
  'com.sungeram.app',
  'org.telegram.plus',
  'com.powerasdev.wetel',
  'org.modogramorg.com',
  'org.teleturbo.messenger',
  'org.tmessenger.bichat',
  'com.gemplus.salah.new.app',
  'com.hotgeram.tg.x23',
  'com.filtershekanha.teledr',
  'org.messenger.newtel',
  'com.samagram.tele.bist.messenger',
  'com.tel.tizigram.cut',
  'arat.aman.vpngram',
  'dev.goldenmobogram.messenger',
  'rainbow.app.pxlist',
  'com.manigram.manifitergram',
  'com.prougram.app',
  'com.messenger.grin',
  'com.chatplus.msngr',
  'com.elgramert.org',
  'com.city.pluse',
  'pro.talagram.messenger',
  'com.mobo.filtertel',
  'com.avaplus.pmessageapp.pxd.clmode',
  'org.modogramorg.com',
  'org.freegram.messenger',
  'com.web_view_mohammed.ad.webview_app',
  'org.nicemobo.gram',
  'org.tplus',
  'com.mobogeramm.tg.x23',
  'com.video.playerppv',
  'com.weeboapps.',
  'com.social.messenger.allinoneapp',
  'com.social.media.network.smart',
  'com.amar.socialmedianetworks',
  'com.andromo.dev932247.app1067143',
  'com.all.newsocial.networkapp',
  'com.apkkajal.all_social_network',
  'com.aparat',
  'com.twitter.android',
  'com.zhiliaoapp.musically',
  'com.ss.android.ugc.trill',
  'com.google.android.youtube',
  'com.facebook.katana',
  'com.facebook.orca',
  'com.facebook.mlite',
  'com.facebook.lite',
  'com.sgiggle.production',
  'com.snapchat.android'
];

List<String> systemApps = [
  'com.google.android.gm',
  "com.google.android.contacts",
  'com.android.vending',
  'com.miui.securitycenter',
  'com.android.phone',
  'com.android.settings',
  'com.android.systemui',
  'com.google.android.apps.messaging',
  'com.google.android.packageinstaller',
  'com.google.android.dialer',
  'android',
  'com.google.android.apps.docs',
  'com.miui.home',
  'com.android.deskclock'
];

void checkNewApplicationVersion() async {
  AppSRV appSRV = AppSRV();
  Device device;
  if (Platform.isAndroid) {
    device = Device.Android;
  } else if (Platform.isIOS) {
    device = Device.Ios;
  } else if (kIsWeb) {
    device = Device.Web;
  }

  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  String appName = packageInfo.appName;
  String packageName = packageInfo.packageName;
  String version = packageInfo.version;
  String buildNumber = packageInfo.buildNumber;

  if (!kIsWeb) {
    appSRV.getNewApplicationLink(device, version, buildNumber).then((link) {
      if (link != "") {
        showNewAppVersion(link);
      }
    });
  }
}

//void sendAppUsageData() async {
//  List<Map> sevenPrevDayPhoneUsage = [];
//
//  if (!kIsWeb) {
//    try {
//      AppUsage appUsage = new AppUsage();
//      // Define a time interval
//      DateTime now = new DateTime.now();
//      DateTime today = DateTime(now.year, now.month, now.day, 0, 0, 0);
//
//      Map<String, double> todayUsage = await appUsage.fetchUsage(today, now);
//      todayUsage.removeWhere(
//          (key, val) => (val.round() == 0) || systemApps.contains(key));
//      sevenPrevDayPhoneUsage.add(todayUsage);
//
//      for (int i = 1; i < 7; i++) {
//        DateTime endTime = today.subtract(Duration(days: i - 1));
//        DateTime startTime = endTime.subtract(Duration(days: 1));
//
//        // Fetch the usage stats
//        Map<String, double> usage =
//            await appUsage.fetchUsage(startTime, endTime);
//        usage.removeWhere(
//            (key, val) => (val.round() == 0) || systemApps.contains(key));
//        sevenPrevDayPhoneUsage.add(usage);
//      }
//    } on Exception catch (exception) {
////    print(exception);
//    }
//  }
//  if (sevenPrevDayPhoneUsage.length != 0) {
//    AppSRV appSRV = AppSRV();
//    appSRV
//        .update7PrevDayPhoneUsage(
//            FirstPage.studentAccount.username,
//            FirstPage.studentAccount.authentication_string,
//            sevenPrevDayPhoneUsage)
//        .then((value) {
//      if (!value) {}
//    });
//  }
//}
