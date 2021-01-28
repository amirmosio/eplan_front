import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:mhamrah/ConnectionService/ChannelSRV.dart';
import 'package:mhamrah/ConnectionService/HTTPService.dart';
import 'package:mhamrah/Models/ChatMV.dart';
import 'package:mhamrah/Models/SocketNotifingModel.dart';
import 'package:mhamrah/Models/UserMV.dart';
import 'package:mhamrah/Pages/StudentMainPage.dart';
import 'package:mhamrah/Utils/LocalFileUtils.dart';
import 'package:mhamrah/Utils/SocketUtils.dart';
import 'package:mhamrah/Values/Utils.dart';
import 'package:mhamrah/Values/style.dart' as prefix0;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../ChatBottomBar.dart';
import '../ChatMessage.dart';
import 'ChannelChatRoomTitlePart.dart';

class ConsultantChannelChatScreen extends StatefulWidget {
  ConsultantChannelChatScreen({Key key});

  @override
  State createState() => new ConsultantChannelChatScreenState();
}

class ConsultantChannelChatScreenState
    extends State<ConsultantChannelChatScreen> {
  ConnectionService httpRequestService = new ConnectionService();
  ChannelSRV channelSRV = new ChannelSRV();
  StudentMainPageState studentMainPageState;
  String mainConsUsername = "";
  String chatText;
  WebSocketChannel channel;
  final TextEditingController _chatController = new TextEditingController();
  List<ChatMessageData> messagesData = [];
  List<String> channelScreenMessageKeys = [];
  bool firstMessageForStream = false;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();

  bool loadingPage = false;
  Timer socketTimer;
  ChatBottomBar chatBottomBar;

  ConsultantChannelChatScreenState();

  @override
  void initState() {
    super.initState();
    chatBottomBar = ChatBottomBar(null, this);
    Consultant consultant = LSM.getConsultantSync();
    if (consultant != null) {
      mainConsUsername = consultant.username;
      ChatMessageDataList chatList = LSM.getMessageListSync([mainConsUsername]);
      if (chatList != null) {
        setState(() {
          messagesData = chatList.chatMessageDataList;
        });
        fetchInitialMessage(withLoading: false);
      } else {
        fetchInitialMessage(withLoading: true);
      }

      /// socket connection checker
      socketConnectionChecker(
              [mainConsUsername], this, () {}, fetchInitialMessage)
          .then((value) {
        setState(() {
          socketTimer = value;
        });
      });
    } else {
      LSM.getConsultant().then((consultant) {
        setState(() {
          mainConsUsername = consultant.username;
        });
        ChatMessageDataList chatList =
            LSM.getMessageListSync([mainConsUsername]);
        if (chatList != null) {
          setState(() {
            messagesData = chatList.chatMessageDataList;
          });
          fetchInitialMessage(withLoading: false);
        } else {
          fetchInitialMessage(withLoading: true);
        }

        /// socket connection checker
        socketConnectionChecker(
                [mainConsUsername], this, () {}, fetchInitialMessage)
            .then((value) {
          setState(() {
            socketTimer = value;
          });
        });
      });
    }
  }

  void _handleReceiveMessage(String text) {
    firstMessageForStream = true;
    try {
      String ntext = improveStringJsonFromSocket(text);
      SocketNotifyingData s = SocketNotifyingData.fromJson(json.decode(ntext));
      if (s.requestType == "submit_channel_message") {
        ChatMessageData messageData =
            (s.requestData as SubmitChannelMessageSR).chatMessageData;
        messageData.status = 1;
        if (!chatBottomBar.messageKeys.contains(messageData.getMessageKey()) &&
            !channelScreenMessageKeys.contains(messageData.getMessageKey())) {
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
          updateItemWithIndex(messageData, index);
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

  ChatMessageDataList getMessageListData() {
    ChatMessageDataList c = ChatMessageDataList();
    c.chatMessageDataList = [];
    for (int i = 0; i < messagesData.length; i++) {
      c.chatMessageDataList.add(messagesData[i]);
    }
    return c;
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          ? getButtonLoadingProgress()
                          : new Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children:
                                  getChatMessageFromMessageData(messagesData)
                                      .reversed
                                      .toList(),
                            ),
                    ),
                  ),
                )
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
                        loadingPage ? getButtonLoadingProgress() : SizedBox(),
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
    _addAnItem(0, ce);
  }

  void _addAnItem(index, ChatMessageData ce) {
    try {
      chatBottomBar.messageKeys.add(ce.getMessageKey());
      channelScreenMessageKeys.add(ce.getMessageKey());
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

  void updateItemWithIndex(ChatMessageData ce, int index) {
    try {
      messagesData[index] = ce;
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
      setState(() {
        messagesData.removeAt(index);
      });
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
      List<ChatMessageData> messageList) {
    List<ChatMessage> res = [];
    for (int i = 0; i < messageList.length; i++) {
      res.add(ChatMessage(this, [mainConsUsername], 0, messageList[i],
          (i + 1).toString(), 1, 1));
    }
    return res;
  }

  void fetchInitialMessage({bool withLoading = false}) {
    setState(() {
      if (withLoading) {
        loadingPage = true;
      }
    });
    LSM.getConsultant().then((consultant) {
      channelSRV
          .getRecentChannelChat(
              "", consultant.username, consultant.authentication_string)
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

  @override
  void dispose() {
    if (socketTimer != null) {
      socketTimer.cancel();
    }
//    ConnectionService.closeChannel();
    super.dispose();
  }
}
