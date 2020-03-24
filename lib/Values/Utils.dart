import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future navigateToSubPage(context, Widget w) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => w));
}