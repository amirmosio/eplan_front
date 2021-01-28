import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import 'SnackAnFlushBarUtils.dart';

class StorageFolders {
  static String appStorageFolderName = "mhamrah";

  static String chatRoomFiles = "ChatRoomFiles";
  static String channelFiles = "ChannelFiles";
  static String pdfChartAndTablesFiles = "TablePDFs";
}

Future<File> downloadFile(String fileURL) async {
  File file = await DefaultCacheManager().getSingleFile(fileURL);
  return file;
}

Future<File> downloadAndSaveFileToStorage(
    String fileURL, String folder, String fileNameWithoutExt,
    {bool popDialogOnDone = true, BuildContext context}) async {
  showFlutterToastWithFlushBar("در حال دانلود فایل", secsForDurations: 8);
  File file = await downloadFile(fileURL);
  saveFileToStorage(file, fileURL, folder, fileNameWithoutExt,
      popDialogOnDone: popDialogOnDone, context: context);
  return file;
}

void saveFileToStorage(
    File file, String fileURL, String folder, String fileNameWithoutExt,
    {bool popDialogOnDone = true, BuildContext context}) async {
  Directory path = await getExternalStorageDirectory();
  String mhamrahPath = path.parent.parent.parent.parent.path +
      "/" +
      StorageFolders.appStorageFolderName +
      "/";
  Directory c =
      await new Directory(mhamrahPath + folder + "/").create(recursive: true);
  await file.copy(mhamrahPath +
      folder +
      "/" +
      fileNameWithoutExt +
      "." +
      file.path.split(".").last);
  showFlutterToastWithFlushBar(
    "فایل در آدرس زیر ذخیره شد:" +
        "\n" +
        StorageFolders.appStorageFolderName +
        "/" +
        folder,
  );
  if (popDialogOnDone) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}

Future<OpenResult> saveAndOpenFile(
    String fileURL, String folder, String fileNameWithoutExt,
    {bool popDialogOnDone = true, BuildContext context}) async {
  int createSecs = 20;
  int guide1Secs = 10;
  int guide2Secs = 10;

  Future.delayed(Duration(milliseconds: 50)).then((_) {
    showFlutterToastWithFlushBar("ساخت و دانلود فایل",
        secsForDurations: createSecs, loading: true, snackContentHeight: 25);
  });
  Future.delayed(Duration(seconds: createSecs)).then((_) {
    showFlutterToastWithFlushBar(
        "بعد از اتمام دانلود، تمام فایل ها در پوشه " +
            StorageFolders.appStorageFolderName +
            " ذخیره می شوند.",
        secsForDurations: guide1Secs,
        loading: false);
  });
  Future.delayed(Duration(seconds: guide1Secs + createSecs)).then((_) {
    showFlutterToastWithFlushBar(
        "نام فایل درخواستی " + fileNameWithoutExt + " است.",
        secsForDurations: guide2Secs,
        loading: false);
  });
  File file = await downloadFile(fileURL);
  saveFileToStorage(file, fileURL, folder, fileNameWithoutExt,
      context: context, popDialogOnDone: popDialogOnDone);
  return openFile(file);
}

Future<OpenResult> openFileWithFileURL(String fileURL) async {
  showFlutterToastWithFlushBar(
      "در حال دانلود و باز کردن فایل" +
          "\n" +
          "بعد از دانلود به شما اطلاع داده می شود.",
      secsForDurations: 15);
  File file = await downloadFile(fileURL);
  return await openFile(file);
}

Future<OpenResult> openFile(File file) async {
  final filePath = file.path;
  final result = await OpenFile.open(filePath);
  return result;
}
