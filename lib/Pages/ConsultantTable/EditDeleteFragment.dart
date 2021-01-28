import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:mhamrah/Values/style.dart' as prefix0;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'ConsultantTable.dart';

class EditDeleteFragment extends StatefulWidget {
  final ConsultantTableState consultantTableState;

  EditDeleteFragment(this.consultantTableState, {Key key}) : super(key: key);

  @override
  EditDeleteFragmentState createState() =>
      EditDeleteFragmentState(consultantTableState);
}

class EditDeleteFragmentState extends State<EditDeleteFragment> {
  final ConsultantTableState consultantTableState;
  bool deleteLoading = false;

  EditDeleteFragmentState(this.consultantTableState);

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: () {
        consultantTableState.closeDeleteEditFrag();
      },
      child: new Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: prefix0.Theme.fragmentBlurBackGround,
        alignment: Alignment.center,
        child: BackdropFilter(
          filter: prefix0.Theme.fragmentBGFilter,
          child: GestureDetector(
            onTap: () {},
            child: new Container(
//              width: MediaQuery.of(context).size.width * (50 / 100),
              height: 50,
              decoration: new BoxDecoration(
                  borderRadius: new BorderRadius.all(Radius.circular(15)),
                  color: Colors.white),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  deleteLoading
                      ? new Container(
                          padding: EdgeInsets.only(
                              right: 25, left: 25, top: 5, bottom: 5),
                          child: getLoadingProgress(),
                          alignment: Alignment.center,
                          height: 60,
                        )
                        : new GestureDetector(
                          child: new Container(
                            padding: EdgeInsets.only(
                                right: 25, left: 25, top: 5, bottom: 5),
                            child: AutoSizeText(
                              "حذف",
                              style: prefix0.getTextStyle(
                                  20, prefix0.Theme.titleBar1),
                            ),
                            alignment: Alignment.center,
                            height: 60,
                          ),
                          onTap: () {
                            setState(() {
                              deleteLoading = true;
                            });
                            consultantTableState.deleteLesson();
                          },
                        ),
                  new Padding(
                    padding:
                        EdgeInsets.only(top: 10, bottom: 10, left: 0, right: 0),
                    child: new Container(
                      width: 2,
                      height: 50,
                      color: Colors.black,
                    ),
                  ),
                  new GestureDetector(
                    child: new Container(
                      child: AutoSizeText(
                        "ویرایش",
                        style:
                            prefix0.getTextStyle(20, prefix0.Theme.darkText),
                      ),
                      padding: EdgeInsets.only(
                          right: 25, left: 25, top: 5, bottom: 5),
                      alignment: Alignment.center,
                      height: 60,
                    ),
                    onTap: consultantTableState.showEditLessonFragment,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getLoadingProgress() {
    double r = 35;
    return Container(
      child: CircleAvatar(
        child: CircularProgressIndicator(),
        backgroundColor: Color.fromARGB(0, 0, 0, 0),
        radius: r,
      ),
      width: r,
      height: r,
    );
  }
}
