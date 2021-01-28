import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mhamrah/ConnectionService/HTTPService.dart';
import 'package:mhamrah/ConnectionService/LeagueSRV.dart';
import 'package:mhamrah/ConnectionService/StudentListSRV.dart';
import 'package:mhamrah/ConnectionService/UserSRV.dart';
import 'package:mhamrah/Models/StudentListPageMV.dart';
import 'package:mhamrah/Models/UserMV.dart';
import 'package:mhamrah/Utils/AutoTextUtils.dart';
import 'package:mhamrah/Utils/LocalFileUtils.dart';
import 'package:mhamrah/Values/Utils.dart';
import 'package:mhamrah/Values/string.dart';
import 'package:mhamrah/Values/style.dart' as prefix0;
import 'package:mhamrah/Values/style.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class LeagueList {
  int _consultantType; // zero is boss consultant and one is sub consultant
  BuildContext context;
  TickerProviderStateMixin widget;
  TextEditingController _searchTextController = TextEditingController();
  StateSetter alertStateSetter;

  int selectedIndex;
  List<LeagueContactElement> _dailyStudents = [];
  List<LeagueContactElement> _totallyStudents = [];
  bool _listLoading = false;
  bool firstFetchDone = false;
  TabController tabController;
  bool logoutLoading = false;
  bool searchMode = false;
  int userType;
  double height = 100;
  double width = 100;
  String stuUsername = "";
  AutoScrollController _dailyScrollController;
  AutoScrollController _totalScrollController;
  final scrollDirection = Axis.vertical;
  bool hasChangedTab = false;

  LeagueList(this.context, this.widget) {
    tabController = TabController(
      length: 2, //TODO
      initialIndex: 1,
      vsync: widget,
    );
    tabController.addListener(() {
      try {
        alertStateSetter(() {
          hasChangedTab = true;
        });
      } catch (e) {}
    });
    userType = LSM.getUserModeSync();
    height = MediaQuery.of(context).size.height * (90 / 100);
    width = MediaQuery.of(context).size.width * (90 / 100);
    stuUsername = (LSM.getStudentSync() ?? Student()).username;
    _dailyScrollController = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: scrollDirection);
    _totalScrollController = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: scrollDirection);
  }

  void showLeagueListDialog() {
    if (alertStateSetter != null) {
      fetchStudentTotalLeagueData();
    }

    Widget w = BackdropFilter(
      filter: prefix0.Theme.fragmentBGFilter,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(25),
          ),
        ),
        backgroundColor: prefix0.Theme.settingBg,
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter dialogStateSetter) {
            this.alertStateSetter = dialogStateSetter;
            if (!firstFetchDone) {
              fetchStudentTotalLeagueData();
            }
            return Container(
              height: height,
              width: width,
              child: DefaultTabController(
                length: 2,
                initialIndex: 1,
                child: Column(
                  children: [
                    getTitlePart(),
                    Container(
                      height: 40,
                      child: TabBar(
                        controller: tabController,
                        tabs: [
                          Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: AutoSizeText(
                              "لیگ کلی",
                              style: prefix0.getTextStyle(
                                  18, prefix0.Theme.onMainBGText),
                              maxLines: 1,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            alignment: Alignment.center,
                            child: AutoSizeText(
                              'روزانه',
                              style: prefix0.getTextStyle(
                                  18, prefix0.Theme.onMainBGText),
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: height - 100 - 40,
                      child: TabBarView(
                        controller: tabController,
                        children: [
                          Column(
                            children: [
                              getSplitLine(),
                              getStudentLeagueTotalList(),
                            ],
                          ),
                          Column(
                            children: [
                              getSplitLine(),
                              getStudentLeagueDailyList(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
    showDialog(context: context, child: w, barrierDismissible: true);
  }

  Widget getTitlePart() {
    String title = "جامعه آماری " +
        (!hasChangedTab
            ? _dailyStudents.length.toString()
            : (tabController.previousIndex == 0
                ? _dailyStudents.length.toString()
                : _totallyStudents.length.toString()));
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                searchMode
                    ? SizedBox()
                    : (userType == 1
                        ? GestureDetector(
                            child: logoutLoading
                                ? getButtonLoadingProgress(r: 20, stroke: 1)
                                : Padding(
                                    padding:
                                        EdgeInsets.only(left: 10, right: 10),
                                    child: Icon(Icons.logout),
                                  ),
                            onTap: logOutUserFromLeague,
                          )
                        : SizedBox()),
                searchMode
                    ? SizedBox()
                    : GestureDetector(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: Icon(Icons.info_outline),
                        ),
                        onTap: () {
                          showLeagueInfo();
                        },
                      ),
              ],
            ),
            AnimatedSize(
              duration: Duration(milliseconds: 400),
              vsync: this.widget,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    child: Padding(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: Icon(searchMode ? Icons.close : Icons.search),
                    ),
                    onTap: () {
                      alertStateSetter(() {
                        searchMode = !searchMode;
                        _searchTextController.text = "";
                      });
                    },
                  ),
                  Container(
                    child: searchMode
                        ? getSearchTextField()
                        : Container(
                            height: 30,
                            alignment: Alignment.center,
                            child: AutoSizeText(
                              title,
                              textDirection: TextDirection.rtl,
                            ),
                          ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void logOutUserFromLeague() {
    this.alertStateSetter(() {
      logoutLoading = true;
    });
    LeagueSRV leagueSRV = LeagueSRV();
    if (userType == 1) {
      LSM.getStudent().then((student) {
        leagueSRV
            .changeStudentLoginLogout(
                student.username, student.authentication_string, false)
            .then((success) {
          this.alertStateSetter(() {
            logoutLoading = false;
          });
          if (success) {
            student.league_flag = false;
            LSM.updateStudentInfo(student);
            try {
              Navigator.of(context, rootNavigator: true).pop('dialog');
            } catch (e) {}
            try {
              Navigator.maybePop(context);
            } catch (e) {}
          }
        });
      });
    }
  }

  Widget getSearchTextField() {
    return Padding(
      padding: EdgeInsets.only(left: 5, right: 5),
      child: Container(
          height: 35,
          width: width * (50 / 100),
          child: TextField(
            controller: _searchTextController,
            maxLines: 1,
            style: prefix0.getTextStyle(18, prefix0.Theme.onSettingText1),
            textAlign: TextAlign.center,
            onChanged: (c) {
              if (!hasChangedTab) {
                highLightWithSearchTextInDailyLeague(c);
              } else {
                if (tabController.previousIndex == 0) {
                  highLightWithSearchTextInDailyLeague(c);
                } else {
                  highLightWithSearchTextInTotalLeague(c);
                }
              }
            },
          )),
    );
  }

  void highLightWithSearchTextInDailyLeague(String text) async {
    int index = -1;
    text = removeExtraSpaceAndExtraChars(text).replaceAll(" ", "");
    for (int i = 0; i < _dailyStudents.length; i++) {
      String searchText = removeExtraSpaceAndExtraChars(
          _dailyStudents[i].username +
              " ------- " +
              _dailyStudents[i].fullName.trim().replaceAll(" ", ""));

      if ((searchText).contains(text)) {
        index = i;
        break;
      }
    }
    if (index != -1) {
      await _dailyScrollController.scrollToIndex(index,
          preferPosition: AutoScrollPosition.begin);
      await _dailyScrollController.highlight(index);
    }
  }

  void highLightWithSearchTextInTotalLeague(String text) async {
    int index = -1;
    text = removeExtraSpaceAndExtraChars(text).replaceAll(" ", "");
    for (int i = 0; i < _totallyStudents.length; i++) {
      String searchText = removeExtraSpaceAndExtraChars(
          _totallyStudents[i].username +
              " ------- " +
              _totallyStudents[i].fullName.trim().replaceAll(" ", ""));
      if ((searchText).contains(text)) {
        index = i;
        break;
      }
    }
    if (index != -1) {
      await _totalScrollController.scrollToIndex(index,
          preferPosition: AutoScrollPosition.begin);
      await _totalScrollController.highlight(index);
    }
  }

  void showLeagueInfo() {
    Widget w = BackdropFilter(
      filter: prefix0.Theme.fragmentBGFilter,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(25),
          ),
        ),
        backgroundColor: Color.fromARGB(0, 0, 0, 0),
        content: Container(
          width: width,
          color: Color.fromARGB(0, 0, 0, 0),
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: prefix0.Theme.settingBg,
                borderRadius: BorderRadius.all(Radius.circular(15))),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  getAutoSizedDirectionText(leagueInfoTitle,
                      style: getTextStyle(19, prefix0.Theme.onSettingText1)),
                  SizedBox(
                    height: 10,
                  ),
                  getAutoSizedDirectionText(
                    leagueGuidance,
                    style: getTextStyle(15, prefix0.Theme.onSettingText2,
                        height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    showDialog(context: context, child: w, barrierDismissible: true);
  }

  Widget getSplitLine() {
    return Container(
      height: 1,
      width: double.infinity,
      color: prefix0.Theme.onSettingText2,
    );
  }

  List<Widget> getDailyContacts() {
    List<Widget> res = [];
    for (int i = 0; i < _dailyStudents.length; i++) {
      var element = _dailyStudents[i];
      res.add(_wrapDailyScrollTag(
          index: i, child: StudentItem(element, this.stuUsername)));
    }
    return res;
  }

  List<Widget> getTotalContacts() {
    List<Widget> res = [];
    for (int i = 0; i < _totallyStudents.length; i++) {
      var element = _totallyStudents[i];
      res.add(_wrapTotallyScrollTag(
          index: i, child: StudentItem(element, this.stuUsername)));
    }
    return res;
  }

  Widget getStudentLeagueDailyList() {
    List<Widget> contacts = getDailyContacts();
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(),
        child: Container(
          alignment: Alignment.topCenter,
          child: _listLoading
              ? getPageLoadingProgress()
              : ListView(
                  scrollDirection: scrollDirection,
                  controller: _dailyScrollController,
                  shrinkWrap: true,
                  children: contacts.length == 0
                      ? <Widget>[]
                      : contacts +
                          [
                            SizedBox(
                              height: 250,
                            )
                          ],
                ),
        ),
      ),
    );
  }

  Widget getStudentLeagueTotalList() {
    List<Widget> contacts = getTotalContacts();
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(),
        child: Container(
          alignment: Alignment.topCenter,
          child: _listLoading
              ? getPageLoadingProgress()
              : ListView(
                  scrollDirection: scrollDirection,
                  controller: _totalScrollController,
                  shrinkWrap: true,
                  children: contacts.length == 0
                      ? <Widget>[]
                      : contacts +
                          [
                            SizedBox(
                              height: 250,
                            )
                          ],
                ),
        ),
      ),
    );
  }

  Widget _wrapDailyScrollTag({int index, Widget child}) => AutoScrollTag(
        key: ValueKey(index),
        controller: _dailyScrollController,
        index: index,
        child: child,
        highlightColor: prefix0.Theme.warningAndErrorBG.withOpacity(0.3),
      );

  Widget _wrapTotallyScrollTag({int index, Widget child}) => AutoScrollTag(
        key: ValueKey(index),
        controller: _totalScrollController,
        index: index,
        child: child,
        highlightColor: prefix0.Theme.warningAndErrorBG.withOpacity(0.3),
      );

  void fetchStudentTotalLeagueData() {
    UserSRV userSRV = UserSRV();
    int userType = LSM.getUserModeSync();

    firstFetchDone = true;

    alertStateSetter(() {
      _listLoading = true;
    });
    LeagueSRV leagueSRV = LeagueSRV();
    if (userType == 0) {
      LSM.getConsultant().then((consultant) {
        leagueSRV
            .getStudentLeagueList(
                consultant.username, consultant.authentication_string)
            .then((jsonDecode) {
          List<LeagueContactElement> dailyLeagueContacts = [];
          List<LeagueContactElement> totalLeagueContacts = [];

          (jsonDecode['dailyLeagueList'] as List).forEach((element) {
            dailyLeagueContacts.add(LeagueContactElement.fromJson(element));
          });
          (jsonDecode['totalLeagueList'] as List).forEach((element) {
            totalLeagueContacts.add(LeagueContactElement.fromJson(element));
          });
          alertStateSetter(() {
            _totallyStudents = totalLeagueContacts;
            _dailyStudents = dailyLeagueContacts;
            _listLoading = false;
          });
        });
      });
    } else if (userType == 1) {
      LSM.getStudent().then((student) {
        leagueSRV
            .getStudentLeagueList(
                student.username, student.authentication_string)
            .then((jsonDecode) {
          List<LeagueContactElement> dailyLeagueContacts = [];
          List<LeagueContactElement> totalLeagueContacts = [];

          (jsonDecode['dailyLeagueList'] as List).forEach((element) {
            dailyLeagueContacts.add(LeagueContactElement.fromJson(element));
          });
          (jsonDecode['totalLeagueList'] as List).forEach((element) {
            totalLeagueContacts.add(LeagueContactElement.fromJson(element));
          });
          alertStateSetter(() {
            _totallyStudents = totalLeagueContacts;
            _dailyStudents = dailyLeagueContacts;
            _listLoading = false;
          });
          highLightWithSearchTextInDailyLeague(student.username);
        });
      });
    }
  }
}

class StudentItem extends StatefulWidget {
  final LeagueContactElement consultantContactElement;
  final String currentUsername;

  StudentItem(
    this.consultantContactElement,
    this.currentUsername, {
    Key key,
  }) : super(key: key);

  @override
  _StudentContactElement createState() =>
      _StudentContactElement(consultantContactElement, currentUsername);
}

class _StudentContactElement extends State<StudentItem> {
  ConnectionService httpRequestService = ConnectionService();
  StudentListSRV studentListSRV = StudentListSRV();
  LeagueContactElement consultantContactElement;
  String currentUsername = "";
  double xSize;
  double ySize;
  String imageURL = "";

  final columns = 7;
  final rows = 13;
  bool deleteToggle = false;
  bool descriptionToggle = false;

  bool _deletedFlag = true;

  _StudentContactElement(this.consultantContactElement, this.currentUsername);

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Widget build(BuildContext context) {
    String username = consultantContactElement.username;
    imageURL = httpRequestService.getConsultantImageURL(username);
    xSize = MediaQuery.of(context).size.width;
    ySize = MediaQuery.of(context).size.height;
    return GestureDetector(
      child: new Padding(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: new Container(
          decoration: new BoxDecoration(
              border: Border.all(width: 0.2),
              borderRadius: BorderRadius.all(Radius.circular(35)),
              color: prefix0.Theme.blueBR),
          child: getStudentContact(),
        ),
      ),
      onTap: () {
        setState(() {
          descriptionToggle = !descriptionToggle;
        });
      },
    );
  }

  Widget getStudentContact() {
    return Container(
      decoration: new BoxDecoration(
          color: !deleteToggle
              ? prefix0.Theme.startEndTimeItemsBG
              : prefix0.Theme.blueBR,
          borderRadius:
              BorderRadius.all(Radius.circular(descriptionToggle ? 15 : 30))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          new Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              getContactRank(),
              new Expanded(
                child: Container(),
              ),
              getContactDetail(),
              getContactAvatar()
            ],
          ),
          descriptionToggle ? getContactDescription() : SizedBox(),
        ],
      ),
    );
  }

  Widget getContactRank() {
    bool self = consultantContactElement.username == currentUsername;
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: new Container(
        width: ySize * (4 / 100),
        height: ySize * (4 / 100),
        alignment: Alignment.center,
        decoration: new BoxDecoration(
          color: self
              ? prefix0.Theme.warningAndErrorBG
              : Color.fromARGB(0, 0, 0, 0),
          shape: BoxShape.circle,
        ),
        child: getAutoSizedDirectionText(
            consultantContactElement.rank.toString(),
            style: prefix0.getTextStyle(
                18,
                self
                    ? prefix0.Theme.onWarningAndErrorBG
                    : prefix0.Theme.onContactItemBg)),
      ),
    );
  }

  Widget getContactAvatar() {
    double r = ySize * (6 / 100);
    r = ySize * (1.8 / 100);
    return new Container(
      width: r,
      height: r,
      decoration: new BoxDecoration(
        shape: BoxShape.circle,
//        image: new DecorationImage(
//          fit: BoxFit.fill,
//          image: new NetworkImage(
//            imageURL,
//          ),
//        ),
      ),
    );
  }

  Widget getContactDetail() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
      child: new Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: new Text(
                consultantContactElement.fullName.trim(),
                textAlign: TextAlign.right,
                style: prefix0.getTextStyle(14, prefix0.Theme.onContactItemBg),
              ),
            ),
          ]),
    );
  }

  Widget getContactDescription() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.fromLTRB(10, 5, 20, 0),
      child: new Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                height: 1,
                color: prefix0.Theme.onSettingText1,
                width: double.infinity,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 5),
              child: new AutoSizeText(
                "دقایق مطالعه: " +
                    consultantContactElement.durationTime.toString(),
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: prefix0.getTextStyle(14, prefix0.Theme.onContactItemBg),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 5),
              child: new AutoSizeText(
                "تعداد تست: " + consultantContactElement.testNumber.toString(),
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: prefix0.getTextStyle(14, prefix0.Theme.onContactItemBg),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: new AutoSizeText(
                    consultantContactElement.presentTime == 0 ||
                            consultantContactElement.presentTime == 24 * 60
                        ? " - "
                        : replacePersianWithEnglishNumber(
                            convertMinuteToTimeString(
                                    consultantContactElement.presentTime)
                                .toString()),
                    textAlign: TextAlign.right,
                    style:
                        prefix0.getTextStyle(14, prefix0.Theme.onContactItemBg),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: new AutoSizeText(
                    "زمان بیداری: ",
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style:
                        prefix0.getTextStyle(14, prefix0.Theme.onContactItemBg),
                  ),
                ),
              ],
            ),
//            Container(
//              padding: EdgeInsets.symmetric(vertical: 5),
//              child: new AutoSizeText(
//                "نمره مشاور: " +
//                    (consultantContactElement.score == 0.0
//                        ? " - "
//                        : consultantContactElement.score.toString()),
//                textAlign: TextAlign.right,
//                textDirection: TextDirection.rtl,
//                style: prefix0.getTextStyle(14, prefix0.Theme.onContactItemBg),
//              ),
//            )
          ]),
    );
  }
}
