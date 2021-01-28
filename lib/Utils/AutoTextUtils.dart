import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:mhamrah/Values/Utils.dart';

TextDirection getTextDirectionByText(String text) {
  text = (text ?? "");
  if (text == "") {
    return TextDirection.ltr;
  } else {
    String firstChar = text.substring(0, 1);
    if (checkPersianCharsAndSpaceOnly(firstChar)) {
      return TextDirection.rtl;
    } else {
      return TextDirection.ltr;
    }
  }
}

Widget getAutoSizedDirectionText(String data,
    {TextStyle style,
    double minFontSize,
    double maxFontSize,
    TextAlign textAlign,
    double width}) {
  List<Widget> texts = [];
  List<String> textLines = data.split("\n");
  textLines.forEach((line) {
    texts.add(AutoSizeText(
      line,
      textDirection: getTextDirectionByText(line),
      style: style,
      wrapWords: true,
      softWrap: true,
      overflow: TextOverflow.visible,
      maxLines: 10,
    ));
  });
  return Container(
    width: width,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: texts,
    ),
  );
}
