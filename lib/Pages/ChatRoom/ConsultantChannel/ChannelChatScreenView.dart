import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:mhamrah/ConnectionService/ChannelSRV.dart';
import 'package:mhamrah/ConnectionService/ChatSRV.dart';
import 'package:mhamrah/ConnectionService/HTTPService.dart';
import 'package:mhamrah/ConnectionService/test.dart';
import 'package:mhamrah/Models/ChatMV.dart';
import 'package:mhamrah/Models/SocketNotifingModel.dart';
import 'package:mhamrah/Pages/ChatRoom/ChatRoomTitlePart.dart';
import 'package:mhamrah/Pages/StudentMainPage.dart';
import 'package:mhamrah/Utils/LocalFileUtils.dart';
import 'package:mhamrah/Utils/SocketUtils.dart';
import 'package:mhamrah/Values/Utils.dart';
import 'package:mhamrah/Values/string.dart';
import 'package:mhamrah/Values/style.dart' as prefix0;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:auto_direction/auto_direction.dart';

import '../ChatMessage.dart';
import 'ChannelChatRoomTitlePart.dart';

class ChannelChatScreenView extends StatefulWidget {
  final StudentMainPageState studentMainPageState;
  final String mainConsUsername;

  ChannelChatScreenView(this.studentMainPageState, this.mainConsUsername,
      {Key key});

  @override
  State createState() =>
      new ChannelChatScreenViewState(studentMainPageState, mainConsUsername);
}

class ChannelChatScreenViewState extends State<ChannelChatScreenView> {
  ConnectionService httpRequestService = new ConnectionService();
  ChannelSRV channelSRV = new ChannelSRV();
  int userType = 1;
  StudentMainPageState studentMainPageState;
  String mainConsUsername;
  String chatText;
  final TextEditingController _chatController = new TextEditingController();
  List<ChatMessageData> messagesData = [];
  List<String> messageKeys = [];
  bool firstMessageForStream = true;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();

  bool loadingPage = false;
  Timer socketTimer;

  ChannelChatScreenViewState(this.studentMainPageState, this.mainConsUsername);

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    int type = LSM.getUserModeSync();
    setState(() {
      userType = type;
    });

    /// socket connection checker
    socketConnectionChecker(
            [mainConsUsername], this, () {}, fetchInitialMessageList)
        .then((value) {
      socketTimer = value;
    });

    /// fetching data

    ChatMessageDataList chatMassageDataList =
        LSM.getMessageListSync([mainConsUsername]);
    if (chatMassageDataList != null) {
      setState(() {
        messagesData = chatMassageDataList.chatMessageDataList;
      });
      fetchInitialMessageList(withLoading: false);
    } else {
      fetchInitialMessageList(withLoading: true);
    }
  }

  List<ChatMessage> getChatMessageFromMessageData(
      List<ChatMessageData> messageList, int userType) {
    if (userType == 0) {
      List<ChatMessage> res = [];
      for (int i = 0; i < messageList.length; i++) {
        res.add(ChatMessage(this, [mainConsUsername], 0, messageList[i],
            (i + 1).toString() + "-" + 0.toString(), 1, 1));
      }
      return res;
    } else if (userType == 1) {
      List<ChatMessage> res = [];
      for (int i = 0; i < messageList.length; i++) {
        res.add(ChatMessage(this, [mainConsUsername], 0, messageList[i],
            (i + 1).toString() + "-" + 0.toString(), 1, 1));
      }
      return res;
    }
  }

  ChatMessageDataList getMessageListData() {
    ChatMessageDataList c = ChatMessageDataList();
    c.chatMessageDataList = [];
    for (int i = 0; i < messagesData.length; i++) {
      c.chatMessageDataList.add(messagesData[i]);
    }
    return c;
  }

  void _handleReceiveMessage(String text) {
    firstMessageForStream = true;
    try {
      String ntext = improveStringJsonFromSocket(text);
      SocketNotifyingData s = SocketNotifyingData.fromJson(json.decode(ntext));
      if (s.requestType == "submit_channel_message") {
        ChatMessageData messageData =
            (s.requestData as SubmitChannelMessageSR).chatMessageData;
        if (!messageKeys.contains(messageData.getMessageKey())) {
          messageKeys.add(messageData.getMessageKey());
          addAnItemToLast(messageData);
        }
      } else if (s.requestType == "delete_channel_message") {
        String messageKey =
            (s.requestData as DeleteChannelMessageSR).messageKey;
        removeItemByServerKey(messageKey);
      } else if (s.requestType == "edit_channel_text_message") {
        String messageKey =
            (s.requestData as EditChannelTextMessageSR).messageKey;
        String newText = (s.requestData as EditChannelTextMessageSR).newText;
        updateItemTextByServerKey(messageKey, newText);
      }
    } catch (e) {}
    LSM.setMessageList([mainConsUsername], getMessageListData());
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          ChannelChatTitle(),
          !firstMessageForStream && ConnectionService.stream == null
              ? new Expanded(
                  child: Container(
                  alignment: Alignment.center,
                  child: SingleChildScrollView(
                    reverse: true,
                    scrollDirection: Axis.vertical,
                    child: loadingPage
                        ? getPageLoadingProgress()
                        : new Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: getChatMessageFromMessageData(
                                    messagesData, userType)
                                .reversed
                                .toList(),
                          ),
                  ),
                ))
              : SizedBox(),
          ConnectionService.stream != null
              ? StreamBuilder(
                  stream: ConnectionService.stream,
                  builder: (context, snapshot) {
                    firstMessageForStream = true;
                    if (snapshot.hasData) {
                      _handleReceiveMessage(snapshot.data);
                    }
                    return new Expanded(
                        child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedList(
                          key: _listKey,
                          reverse: true,
                          initialItemCount: messagesData.length,
                          itemBuilder: (context, index, animation) {
                            return _buildStudentItem(context, index, animation);
                          },
                        ),
                        loadingPage ? getPageLoadingProgress() : SizedBox(),
                      ],
                    ));
                  },
                )
              : SizedBox(),
          firstMessageForStream && ConnectionService.stream == null
              ? Expanded(child: getPageLoadingProgress())
              : SizedBox()
        ],
      ),
      color: prefix0.Theme.mainBG,
    );
  }

  Widget _buildStudentItem(
      BuildContext context, int index, Animation animation) {
    int pos = 0;
    return SizeTransition(
        key: ValueKey(messagesData[index]),
        sizeFactor: animation,
        axis: Axis.vertical,
        child: ChatMessage(
            this,
            [mainConsUsername],
            pos,
            messagesData[index],
            messagesData[index].getMessageKey(),
            messagesData[index].status,
            1));
  }

  void addAnItemToLast(ChatMessageData ce) {
    _addAnItem(messagesData.length, ce);
  }

  void _addAnItem(index, ChatMessageData ce) {
    try {
      messagesData.insert(index, ce);
      _listKey.currentState
          .insertItem(index, duration: Duration(milliseconds: 100));
    } catch (e) {}
  }

  void updateItemWithClientRandomKey(
      String clientKey, ChatMessageData message) {
    int index = -1;
    for (int i = 0; i < this.messagesData.length; i++) {
      if (messagesData[i].clientRandomKey == clientKey) {
        index = i;
        break;
      }
    }
    if (index != -1) {
      try {
        messagesData[index] = message;
      } catch (e) {}
    }
  }

  void updateItemTextByServerKey(String serverKey, String text) {
    int index = -1;
    for (int i = 0; i < this.messagesData.length; i++) {
      if (messagesData[i].messageNetKey == serverKey) {
        index = i;
        break;
      }
    }
    if (index != -1) {
      try {
        messagesData[index].text = text;
      } catch (e) {}
    }
  }

  void removeItemByServerKey(String serverKey) {
    int index = -1;
    for (int i = 0; i < this.messagesData.length; i++) {
      if (messagesData[i].messageNetKey == serverKey) {
        index = i;
        break;
      }
    }
    if (index != -1) {
      _removeItemByIndex(index);
      ChatMessageDataList cmdl = ChatMessageDataList();
      cmdl.chatMessageDataList = messagesData;
      LSM.setMessageList([mainConsUsername], cmdl);
    }
  }

  void removeItemByKey(String messageKey) {
    int index = -1;
    for (int i = 0; i < this.messagesData.length; i++) {
      if (messagesData[i].getMessageKey() == messageKey) {
        index = i;
        break;
      }
    }
    if (index != -1) {
      _removeItemByIndex(index);
      ChatMessageDataList cmdl = ChatMessageDataList();
      cmdl.chatMessageDataList = messagesData;
      LSM.setMessageList([mainConsUsername], cmdl);
    }
  }

  void _removeItemByIndex(index) {
    try {
      _listKey.currentState.removeItem(
        index,
        (BuildContext context, Animation<double> animation) =>
            _buildStudentItem(context, index, animation),
        duration: const Duration(milliseconds: 100),
      );
      messagesData.removeAt(index);
    } catch (e) {}
  }

  void updateAnimatedList(List<ChatMessageData> fetchedData) {
    Map oldDataAndHasToStayFlag = {};
    for (int i = 0; i < messagesData.length; i++) {
      oldDataAndHasToStayFlag[messagesData[i].getMessageKey()] = false;
    }
    for (int i = 0; i < fetchedData.length; i++) {
      if (!oldDataAndHasToStayFlag.keys
          .contains(fetchedData[i].getMessageKey())) {
        _addAnItem(messagesData.length, fetchedData[i]);
      } else {
        updateItemWithClientRandomKey(
            fetchedData[i].clientRandomKey, fetchedData[i]);
      }
      oldDataAndHasToStayFlag[fetchedData[i].getMessageKey()] = true;
    }
    for (int i = 0; i < oldDataAndHasToStayFlag.keys.length; i++) {
      String username = oldDataAndHasToStayFlag.keys.toList()[i];
      if (!oldDataAndHasToStayFlag[username]) {
        _removeItemByIndex(i);
      }
    }
  }

  void fetchInitialMessageList({bool withLoading = false}) {
    setState(() {
      if (withLoading) {
        loadingPage = true;
      }
    });
    if (userType == 0) {
      LSM.getConsultant().then((consultant) {
        channelSRV
            .getRecentChannelChat(consultant.username, mainConsUsername,
                consultant.authentication_string)
            .then((messageList) {
          setState(() {
            loadingPage = false;
          });
          ChatMessageDataList chatMessageDataList = ChatMessageDataList();
          chatMessageDataList.chatMessageDataList = messageList;
          LSM.setMessageList([mainConsUsername], chatMessageDataList);
          updateAnimatedList(messageList);
        });
      });
    } else if (userType == 1) {
      LSM.getStudent().then((student) async {
        channelSRV
            .getRecentChannelChat(student.username, mainConsUsername,
                student.authentication_string)
            .then((messageList) {
          setState(() {
            loadingPage = false;
          });
          ChatMessageDataList chatMessageDataList = ChatMessageDataList();
          chatMessageDataList.chatMessageDataList = messageList;
          LSM.setMessageList([mainConsUsername], chatMessageDataList);
          updateAnimatedList(messageList);
        });
      });
    }
  }

  @override
  void dispose() {
    if (socketTimer != null) {
      socketTimer.cancel();
    }
    super.dispose();
  }
}
