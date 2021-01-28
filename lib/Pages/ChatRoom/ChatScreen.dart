import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:mhamrah/ConnectionService/ChatSRV.dart';
import 'package:mhamrah/ConnectionService/HTTPService.dart';
import 'package:mhamrah/Models/ChatMV.dart';
import 'package:mhamrah/Models/SocketNotifingModel.dart';
import 'package:mhamrah/Models/UserMV.dart';
import 'package:mhamrah/Pages/ChatRoom/ChatRoomTitlePart.dart';
import 'package:mhamrah/Pages/ChatRoom/ChatBottomBar.dart';
import 'package:mhamrah/Pages/StudentMainPage.dart';
import 'package:mhamrah/Utils/LocalFileUtils.dart';
import 'package:mhamrah/Utils/SocketUtils.dart';
import 'package:mhamrah/Values/Utils.dart';
import 'package:mhamrah/Values/style.dart' as prefix0;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'ChatMessage.dart';

class ChatScreen extends StatefulWidget {
  final StudentMainPageState studentMainPageState;
  final List<String> usernames;

  ChatScreen(this.studentMainPageState, this.usernames, {Key key});

  @override
  State createState() => new ChatScreenState(studentMainPageState, usernames);
}

class ChatScreenState extends State<ChatScreen> {
  ConnectionService httpRequestService = new ConnectionService();
  ChatSRV chatSRV = new ChatSRV();
  int userType = 0;
  StudentMainPageState studentMainPageState;
  String username = "";
  List<String> usernames;
  List<ChatMessageData> messagesData = [];
  ChatBottomBar chatBottomBar;
  List<String> chatScreenMessagesKey = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  bool loadingPage = false;
  Timer socketTimer;

  bool firstMessageForStream = false;

  ChatScreenState(this.studentMainPageState, this.usernames);

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    chatBottomBar = ChatBottomBar(this, null);

    int type = LSM.getUserModeSync();
    userType = type;

    /// socket connection checker
    socketConnectionChecker(usernames, this, () {}, fetchInitialMessageList)
        .then((value) {
      socketTimer = value;
    });

    /// set username for contact title bar
    if (type == 1) {
      Student student = LSM.getStudentSync();
      if (student != null) {
        username = student.parent == ""
            ? student.username
            : student.parent + ":" + student.username;
      } else {
        LSM.getStudent().then((student) {
          setState(() {
            username = student.parent == ""
                ? student.username
                : student.parent + ":" + student.username;
          });
        });
      }

      ChatMessageDataList chatMessageDataList =
          LSM.getMessageListSync(usernames);
      if (chatMessageDataList != null) {
        setState(() {
          messagesData = chatMessageDataList.chatMessageDataList;
        });
        fetchInitialMessageList(withLoading: false);
      } else {
        fetchInitialMessageList(withLoading: true);
      }
    } else if (userType == 0) {
      Consultant consultant = LSM.getConsultantSync();
      if (consultant != null) {
        username = consultant.username;
      } else {
        LSM.getConsultant().then((consultant) {
          setState(() {
            username = consultant.username;
          });
        });
      }

      ChatMessageDataList chatMessageDataList =
          LSM.getMessageListSync(usernames);
      if (chatMessageDataList != null) {
        setState(() {
          messagesData = chatMessageDataList.chatMessageDataList;
        });
        fetchInitialMessageList(withLoading: false);
      } else {
        fetchInitialMessageList(withLoading: true);
      }
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
      if (s.requestType == "submit_message") {
        int pos = 0;
        if (username ==
            (s.requestData as SubmitMessageSR).chatMessageData.ownerUsername) {
          pos = 1;
        } else {
          pos = -1;
        }
        ChatMessageData messageData =
            (s.requestData as SubmitMessageSR).chatMessageData;
        messageData.status = 1;
        if (!chatBottomBar.messageKeys.contains(messageData.getMessageKey()) &&
            !chatScreenMessagesKey.contains(messageData.getMessageKey())) {
//          addAnItemToLast(messageData);
        } else {
          int index = -1;
          for (int i = 0; i < messagesData.length; i++) {
            if (messagesData[i].getMessageKey() ==
                messageData.getMessageKey()) {
              index = i;
              break;
            }
          }
          if (index != -1 && messagesData[index].status != messageData.status) {
            updateItemWithIndex(messageData, index);
          }
        }

        /// send loading state
        if (pos == 1) {
          chatBottomBar.messageKeys.remove(messageData.getMessageKey());
        }
      } else if (s.requestType == "delete_chat_message") {
        String messageKey = (s.requestData as DeleteChatMessageSR).messageKey;
        removeItemByServerKey(messageKey);
      } else if (s.requestType == "edit_chat_text_message") {
        String messageKey = (s.requestData as EditChatTextMessageSR).messageKey;
        String newText = (s.requestData as EditChatTextMessageSR).newText;
        updateItemTextByServerKey(messageKey, newText);
      }
    } catch (e) {}
    LSM.setMessageList(usernames, getMessageListData());
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          ChatRoomTitlePart(usernames, studentMainPageState),
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
                            return _buildMessageItem(context, index, animation);
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
              : SizedBox(),
          chatBottomBar
        ],
      ),
      color: prefix0.Theme.mainBG,
    );
  }

  Widget _buildMessageItem(
      BuildContext context, int index, Animation animation) {
    int pos = 0;
    if (messagesData.length == 0) {
      return Container();
    } else if (username == messagesData[index].ownerUsername) {
      pos = 1;
    } else {
      pos = -1;
    }
    return SizeTransition(
        key: ValueKey(messagesData[index]),
        sizeFactor: animation,
        axis: Axis.vertical,
        child: ChatMessage(
            this,
            this.usernames,
            pos,
            messagesData[index],
            messagesData[index].getMessageKey(),
            messagesData[index].status,
            0));
  }

  void updateItemWithIndex(ChatMessageData ce, int index) {
    try {
//      setState(() {
      messagesData[index] = ce;
//      });
    } catch (e) {}
  }

  void addAnItemToLast(ChatMessageData ce) {
    _addAnItem(0, ce);
  }

  void _addAnItem(index, ChatMessageData ce) {
    try {
      chatBottomBar.messageKeys.add(ce.getMessageKey());
      chatScreenMessagesKey.add(ce.getMessageKey());
      messagesData.insert(index, ce);
      _listKey.currentState
          .insertItem(index, duration: Duration(milliseconds: 100));
    } catch (e) {}
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
      LSM.setMessageList(usernames, cmdl);
    }
  }

  void removeItemByOfflineKey(String messageKey) {
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
      LSM.setMessageList(usernames, cmdl);
    }
  }

  void _removeItemByIndex(index) {
    try {
      _listKey.currentState.removeItem(
        index,
        (BuildContext context, Animation<double> animation) =>
            _buildMessageItem(context, index, animation),
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

  List<ChatMessage> getChatMessageFromMessageData(
      List<ChatMessageData> messageList, int userType) {
    if (userType == 0) {
      List<ChatMessage> res = [];
      for (int i = 0; i < messageList.length; i++) {
        int pos = 0;
        if (username == messageList[i].ownerUsername) {
          pos = 1;
        } else {
          pos = -1;
        }
        res.add(ChatMessage(this, this.usernames, pos, messageList[i],
            (i + 1).toString() + "-" + 0.toString(), 1, 0));
      }
      return res;
    } else if (userType == 1) {
      List<ChatMessage> res = [];
      for (int i = 0; i < messageList.length; i++) {
        int pos = 0;
        if (username == messageList[i].ownerUsername) {
          pos = 1;
        } else {
          pos = -1;
        }
        res.add(ChatMessage(this, this.usernames, pos, messageList[i],
            (i + 1).toString() + "-" + 0.toString(), 1, 0));
      }
      return res;
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
        chatSRV
            .getRecentMessages(consultant.username,
                consultant.authentication_string, usernames)
            .then((messageList) {
          setState(() {
            loadingPage = false;
          });
          ChatMessageDataList chatMessageDataList = ChatMessageDataList();
          chatMessageDataList.chatMessageDataList = messageList;
          LSM.setMessageList(usernames, chatMessageDataList);
          updateAnimatedList(messageList);
        });
      });
    } else if (userType == 1) {
      LSM.getStudent().then((student) async {
        chatSRV
            .getRecentMessages(
                student.username, student.authentication_string, usernames)
            .then((messageList) {
          setState(() {
            loadingPage = false;
          });
          ChatMessageDataList chatMessageDataList = ChatMessageDataList();
          chatMessageDataList.chatMessageDataList = messageList;
          LSM.setMessageList(usernames, chatMessageDataList);
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
