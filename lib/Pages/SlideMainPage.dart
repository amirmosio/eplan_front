import 'package:mhamrah/ConnectionService/HTTPService.dart';
import 'package:mhamrah/Pages/ConsultantMainPage.dart';
import 'package:mhamrah/Pages/StudentMainPage.dart';
import 'package:flutter/material.dart';
import 'dart:math' as Math;

import 'package:transformer_page_view/transformer_page_view.dart';

import 'package:flutter/cupertino.dart';

// 1111111 !!!!!!

class SlideMainPage extends StatefulWidget {
  String defaultStudentUsername;

  SlideMainPage({Key key, this.title, this.defaultStudentUsername})
      : super(key: key);

  final String title;

  @override
  SlideMainPageState createState() =>
      new SlideMainPageState(defaultStudentMainPage: defaultStudentUsername);
}

class SlideMainPageState extends State<SlideMainPage> {
  Widget studentMainPage;
  Widget consultantMainPage;
  String defaultStudentMainPage;
  TransformerPageController _pageController;
  static ScrollPhysics ph = new NeverScrollableScrollPhysics();
  static int index = 0;
  bool first = true;
  IndexController indexController = IndexController();

  SlideMainPageState({this.defaultStudentMainPage});

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    studentMainPage = Container(
        child: StudentMainPage(
            defaultStudentMainPage == null ? "" : defaultStudentMainPage));
    consultantMainPage = ConsultantMainPage(this, 3);
    _pageController = TransformerPageController(
        initialPage: defaultStudentMainPage == null ? 0 : 1,
        keepPage: false,
        viewportFraction: 1.0,
        itemCount: 2);
//    if (defaultStudentMainPage != null) {
//      changePage(defaultStudentMainPage);
//    }
//    indexController.addListener(() {
////      if(indexController.index == 0){
////        ph = NeverScrollableScrollPhysics();
////      }else{
////        ph = null;
////
//      }
//    });
    ph = NeverScrollableScrollPhysics();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [consultantMainPage, studentMainPage];
    indexController.index = index;
    indexController.notifyListeners();
    return Container(
      color: Colors.black,
      child: new TransformerPageView(
          loop: false,
          transformer: ZoomOutPageTransformer(this),
          scrollDirection: Axis.vertical,
          curve: Curves.fastOutSlowIn,
          viewportFraction: 2,
          physics: ph,
          controller: indexController,
          onPageChanged: (v) {
            if (v == 0) {
              ph = null;

              setState(() {
                index = v;
              });
            }
            resetStudentPanel();
          },
          index: index,
          pageController: _pageController,
          itemBuilder: (BuildContext context, int index) {
            return list[index];
          },
          itemCount: 2),
    );
  }

  void resetStudentPanel() {
    Future.delayed(Duration(milliseconds: 800)).then((_) {
      StudentMainPage s =
          ((studentMainPage as Container).child as StudentMainPage);
      s.chatRoom = null;
      s.chatContactList = null;
      s.studentProfile = null;
      s.studentTable2 = null;
      s.studentTable1 = null;
      if (StudentMainPage.state.hideBlue2Table()) {
        StudentMainPage.state.changePage(3);
      } else {
        StudentMainPage.state.changePage(4);
      }
      s = null;
    });
  }

  void changePage(String studentUsername) {
    if (_pageController.page != 1) {
      index = 1;
      first = false;
      setState(() {
        if (studentMainPage != null ||
            (studentMainPage as Container).key != ValueKey(studentUsername)) {
          studentMainPage = Container(
            key: ValueKey(studentUsername),
            child: StudentMainPage(studentUsername),
          );
        }
        ph = null;
//      try {
//        ((studentMainPage as Container).child as StudentMainPage)
//            .state
//            .changePage((StudentMainPageState.pageQueue.length != 0 &&
//                    (StudentMainPageState.pageQueue.last != null ||
//                        StudentMainPageState.pageQueue.last != -1))
//                ? StudentMainPageState.pageQueue.last
//                : 0);
//      } catch (e) {}
      });

      _pageController.animateToPage(
        1,
        duration: Duration(seconds: 1),
        curve: Curves.easeInOutQuad,
      );
    }
  }
}

class ZoomOutPageTransformer extends PageTransformer {
  static const double MIN_SCALE = 0.80;
  static const double MIN_ALPHA = 0.7;
  static double oldPosition;
  SlideMainPageState s;

  ZoomOutPageTransformer(this.s);

  void lockThePhysics() async {
    Future.delayed(Duration(milliseconds: 100), () {
      s.setState(() {
        SlideMainPageState.ph = NeverScrollableScrollPhysics();
      });
    });
  }

  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position;
    double pageWidth = info.width;
    double pageHeight = info.height;
    if (oldPosition == 1.0 && position == 0.0) {
      s.resetStudentPanel();
//      lockThePhysics();
    }
    oldPosition = position;

    if (position < -1) {
      // [-Infinity,-1)
      // This page is way off-screen to the left.
      //view.setAlpha(0);
    } else if (position <= 1) {
      // [-1,1]
      // Modify the default slide transition to
      // shrink the page as well
      double scaleFactor = Math.max(MIN_SCALE, 1 - position.abs());
      double vertMargin = pageHeight * (1 - scaleFactor) / 2;
      double horzMargin = pageWidth * (1 - scaleFactor) / 2;
      double dx;
      if (position < 0) {
        dx = (horzMargin - vertMargin / 2);
      } else {
        dx = (-horzMargin + vertMargin / 2);
      }
      // Scale the page down (between MIN_SCALE and 1)
//      double opacity = MIN_ALPHA +
//          (scaleFactor - MIN_SCALE) / (1 - MIN_SCALE) * (1 - MIN_ALPHA);

      return new Transform.translate(
        offset: new Offset(dx, 0.0),
        child: new Transform.scale(
          scale: scaleFactor,
          child: child,
        ),
      );
    } else {
      // (1,+Infinity]
      // This page is way off-screen to the right.
      // view.setAlpha(0);
    }

    return child;
  }
}
