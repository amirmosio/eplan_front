import 'package:auto_size_text/auto_size_text.dart';
import 'package:mhamrah/ConnectionService/UserSRV.dart';
import 'package:mhamrah/Models/UserMV.dart';
import 'package:mhamrah/Utils/AutoTextUtils.dart';
import 'package:mhamrah/Values/string.dart';
import 'package:mhamrah/Values/style.dart' as prefix0;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mhamrah/ConnectionService/HTTPService.dart';
import 'package:mhamrah/ConnectionService/StudentListSRV.dart';
import 'package:mhamrah/Models/StudentListPageMV.dart';
import 'package:mhamrah/Pages/SlideMainPage.dart';
import 'package:mhamrah/Utils/LocalFileUtils.dart';
import 'package:mhamrah/Values/Utils.dart';

class StudentLeaguePage {
  int _consultantType; // zero is boss consultant and one is sub consultant
  BuildContext context;
  TextEditingController _searchTextController = TextEditingController();
  TextEditingController consUsernameController;
  TextEditingController bossConsUsernameController; // in case of subcons list
  TextEditingController selectedConsultantController = TextEditingController();
  StateSetter alertStateSetter;

  int selectedIndex;
  List<ContactElement> _consultants = [];
  bool _listLoading = false;
  bool firstFetchDone = false;

  StudentLeaguePage(
      this.consUsernameController, this.context, this._consultantType,
      {TextEditingController this.bossConsUsernameController}) {
    selectedConsultantController.text = consUsernameController.text;
  }

  void showSelectionAlert() {
    if (alertStateSetter != null) {
      fetchConsultant();
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
              fetchConsultant();
            }
            return Container(
              height: MediaQuery.of(context).size.height * (70 / 100),
              width: MediaQuery.of(context).size.width * (90 / 100),
              child: Column(
                children: [
                  getTitle(),
                  getSplitLine(),
                  getSearchTextField(),
                  getConsultantList(),
                  getSelectedUsernameText(),
                  getApplyButton()
                ],
              ),
            );
          },
        ),
      ),
    );
    showDialog(context: context, child: w, barrierDismissible: true);
  }

  Widget getTitle() {
    String title = "لیست";
    if (_consultantType == 0) {
      title += " " + "مشاوران";
    } else if (_consultantType == 1) {
      title += " " + "پشتیبانان" + " " + bossConsUsernameController.text;
    }
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Container(
        child: AutoSizeText(
          title,
          textDirection: TextDirection.rtl,
        ),
      ),
    );
  }

  Widget getSplitLine() {
    return Container(
      height: 1,
      width: double.infinity,
      color: prefix0.Theme.onSettingText2,
    );
  }

  Widget getSearchTextField() {
    return Padding(
      padding: EdgeInsets.only(),
      child: Container(
          child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          GestureDetector(
            child: Padding(
                padding: EdgeInsets.only(right: 10),
                child: Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.all(
                      Radius.circular(15),
                    ),
                  ),
                  child: Icon(
                    Icons.search,
                    size: 30,
                  ),
                )),
            onTap: () {
              alertStateSetter(() {});
            },
          ),
          Expanded(
            child: TextField(
              controller: _searchTextController,
              maxLines: 1,
              style: prefix0.getTextStyle(18, prefix0.Theme.onSettingText1),
              textAlign: TextAlign.center,
              onSubmitted: (c) {
                alertStateSetter(() {});
              },
//              decoration: InputDecoration(
//                border: OutlineInputBorder(
//                  borderRadius: new BorderRadius.all(
//                    Radius.circular(25),
//                  ),
//                ),
//              ),
            ),
          ),
        ],
      )),
    );
  }

  List<Widget> getContacts() {
    List<Widget> res = [];
    _consultants.forEach((element) {
      String searchKey = _searchTextController.text.toLowerCase();
      if (element.username.toLowerCase().contains(searchKey) ||
          element.name.toLowerCase().contains(searchKey)) {
        res.add(GestureDetector(
          key: ValueKey(element.username),
          child: ConsultantItem(element),
          onTap: () {
            alertStateSetter(() {
              selectedConsultantController.text = element.username;
            });
          },
        ));
      }
    });
    return res;
  }

  Widget getConsultantList() {
    List<Widget> contacts = getContacts();
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(),
        child: Container(
          alignment: Alignment.topCenter,
          child: _listLoading
              ? getPageLoadingProgress()
              : ListView(
                  shrinkWrap: true,
                  children: contacts.length == 0
                      ? <Widget>[getUnkownBossConsultant()]
                      : contacts,
                ),
        ),
      ),
    );
  }

  Widget getUnkownBossConsultant() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          border: Border.all(width: 0.2),
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        child: getAutoSizedDirectionText(
          "مشاوری با این نام کاربری " +
              "(" +
              (bossConsUsernameController.text ?? "") +
              ")" +
              " وجود ندارد.",
        ),
      ),
    );
  }

  Widget getSelectedUsernameText() {
    return Padding(
      padding: EdgeInsets.all(5),
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            border: Border.all()),
        child: Column(
          children: [
            Container(
              child: Text(
                (_consultantType == 0 ? "مشاور" : "پشتیان") + " انتخاب شده: ",
                maxLines: 1,
                textDirection: TextDirection.rtl,
                style: prefix0.getTextStyle(18, prefix0.Theme.onSettingText1),
              ),
            ),
            Container(
              child: Text(
                selectedConsultantController.text ?? "",
                maxLines: 1,
                textDirection: TextDirection.ltr,
                style: prefix0.getTextStyle(18, prefix0.Theme.onSettingText1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getApplyButton() {
    return Padding(
      padding: EdgeInsets.only(),
      child: GestureDetector(
        child: Container(
          height: 45,
          alignment: Alignment.center,
          decoration: new BoxDecoration(
              color: prefix0.Theme.applyButton,
              borderRadius: new BorderRadius.all(Radius.circular(15))),
          child: Text(
            applyLabel,
            maxLines: 1,
            style: prefix0.getTextStyle(18, prefix0.Theme.onSettingText1),
          ),
        ),
        onTap: () {
          consUsernameController.text = selectedConsultantController.text;
          Navigator.of(context, rootNavigator: true).pop('dialog');
        },
      ),
    );
  }

  void fetchConsultant() {
    UserSRV userSRV = UserSRV();
    int userType = LSM.getUserModeSync();
    List<ContactElement> getContactElementList(List consultants) {
      List<ContactElement> res = [];
      consultants.forEach((element) {
        res.add(ContactElement.fromJson(element));
      });
      return res;
    }

    firstFetchDone = true;

    alertStateSetter(() {
      _listLoading = true;
    });

    if (userType == 0) {
      LSM.getConsultant().then((consultant) {
        userSRV
            .getConsultantList(
                consultant.username,
                consultant.authentication_string,
                this._consultantType,
                bossConsUsernameController == null
                    ? ""
                    : bossConsUsernameController.text)
            .then((consultants) {
          alertStateSetter(() {
            _consultants = getContactElementList(consultants);
            _listLoading = false;
          });
        });
      });
    } else if (userType == 1) {
      LSM.getStudent().then((student) {
        userSRV
            .getConsultantList(
                student.username,
                student.authentication_string,
                this._consultantType,
                bossConsUsernameController == null
                    ? ""
                    : bossConsUsernameController.text)
            .then((consultants) {
          alertStateSetter(() {
            _consultants = getContactElementList(consultants);
            _listLoading = false;
          });
        });
      });
    }
  }
}

class ConsultantItem extends StatefulWidget {
  final ContactElement consultantContactElement;

  ConsultantItem(
    this.consultantContactElement, {
    Key key,
  }) : super(key: key);

  @override
  _ConsultantContactElement createState() =>
      _ConsultantContactElement(consultantContactElement);
}

class _ConsultantContactElement extends State<ConsultantItem> {
  ConnectionService httpRequestService = ConnectionService();
  StudentListSRV studentListSRV = StudentListSRV();
  ContactElement consultantContactElement;
  double xSize;
  double ySize;
  String imageURL = "";

  final columns = 7;
  final rows = 13;
  bool deleteToggle = false;
  bool descriptionToggle = false;

  bool _deletedFlag = true;

  _ConsultantContactElement(this.consultantContactElement);

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
    return Visibility(
      key: ValueKey(consultantContactElement.username),
      child: new Padding(
        padding: EdgeInsets.only(top: 10),
        child: new Container(
          decoration: new BoxDecoration(
              border: Border.all(width: 0.2),
              borderRadius: BorderRadius.all(Radius.circular(35)),
              color: prefix0.Theme.blueBR),
          child: getStudentContact(),
        ),
      ),
      visible: _deletedFlag,
    );
  }

  Widget getStudentContact() {
    return Container(
      height: ySize * (6 / 100),
      decoration: new BoxDecoration(
          color: !deleteToggle
              ? prefix0.Theme.startEndTimeItemsBG
              : prefix0.Theme.blueBR,
          borderRadius: BorderRadius.all(Radius.circular(35))),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          new Expanded(
            child: Container(),
          ),
          getContactDetail(),
          getContactAvatar()
        ],
      ),
    );
  }

  Widget getContactAvatar() {
    return new Container(
      width: ySize * (6 / 100),
      height: ySize * (6 / 100),
      decoration: new BoxDecoration(
          shape: BoxShape.circle,
          image: new DecorationImage(
              fit: BoxFit.fill,
              image: new NetworkImage(
                imageURL,
              ))),
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
                consultantContactElement.name.trim(),
                textAlign: TextAlign.right,
                style: prefix0.getTextStyle(18, prefix0.Theme.onContactItemBg),
              ),
            ),
            Container(
              child: new Text(
                consultantContactElement.username.trim(),
                textAlign: TextAlign.right,
                style: prefix0.getTextStyle(15, prefix0.Theme.onContactItemBg),
              ),
            )
          ]),
    );
  }
}
