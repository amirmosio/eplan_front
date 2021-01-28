import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart' as chewie;
import 'package:chewie_audio/chewie_audio.dart' as chewie_audio;
import 'package:mhamrah/ConnectionService/ChannelSRV.dart';
import 'package:mhamrah/ConnectionService/ChatSRV.dart';
import 'package:mhamrah/ConnectionService/HTTPService.dart';
import 'package:mhamrah/Models/ChatMV.dart';
import 'package:mhamrah/Models/SocketNotifingModel.dart';
import 'package:mhamrah/Pages/ChatRoom/ConsultantChannel/ConsChannelChatScreen.dart';
import 'package:mhamrah/Utils/AutoTextUtils.dart';
import 'package:mhamrah/Utils/LocalFileUtils.dart';
import 'package:mhamrah/Utils/SnackAnFlushBarUtils.dart';
import 'package:mhamrah/Utils/StorageAndFileUtils.dart';
import 'package:mhamrah/Values/Utils.dart';
import 'package:mhamrah/Values/string.dart';
import 'package:mhamrah/Values/style.dart' as prefix0;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';

import 'ChatScreen.dart';

//import 'package:photo_view/photo_view.dart';

class ChatMessage extends StatefulWidget {
  final int pos;
  final ChatMessageData chatMessageData;
  final String messageKey;
  int status;
  int chatOrChannel; // 0
  List<String> users = []; //
  var screenState; // = chat and 1=channel

  ChatMessage(this.screenState, this.users, this.pos, this.chatMessageData,
      this.messageKey, int this.status, this.chatOrChannel);

  @override
  ChatMessageState createState() => new ChatMessageState(screenState, users,
      pos, chatMessageData, messageKey, status, chatOrChannel);
}

class ChatMessageState extends State<ChatMessage> {
  ConnectionService connectionService = ConnectionService();
  int userType;
  final ChatMessageData chatMessageData;
  final String messageKey;
  int status;
  int chatOrChannel;
  int pos = 0;
  double xSize;
  int messageType = 0; //0 for text and 1 for image 2 for voice 3 for doc
  bool messageOptionToggle = false;
  bool deleteMessageLoading = false;
  bool editTextMessageLoading = false;
  List<String> usernames;
  var screenState;

  /// save
  bool saveDownloadLoading = false;

  /// image
  CachedNetworkImage cachedImage;
  ImageProvider imageProvider;

  /// voice
  VideoPlayerController _audioPlayerController;
  chewie_audio.ChewieAudioController _chewieAudioController;
  AudioPlayer audioPlayer;
  AudioPlayerState audioStatus = AudioPlayerState.STOPPED;
  Duration _duration = Duration();
  Duration _position = Duration();
  StreamSubscription _durationSubscription;
  StreamSubscription _positionSubscription;
  StreamSubscription _playerCompleteSubscription;
  StreamSubscription _playerErrorSubscription;
  StreamSubscription _playerStateSubscription;
  bool voiceDownloaded = false;

  /// 0=stopped and 1=paused and 2=playing

  /// video
  VideoPlayerController _videoPlayerController;
  chewie.ChewieController _chewieController;

  ChatMessageState(this.screenState, this.usernames, this.pos,
      this.chatMessageData, this.messageKey, this.status, this.chatOrChannel);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userType = LSM.getUserModeSync();
    if ((chatMessageData.imageNetKey != null &&
            chatMessageData.imageNetKey != "") ||
        chatMessageData.imageFile != null) {
      messageType = 1;
    } else if ((chatMessageData.docNetKey != null &&
            chatMessageData.docNetKey != "") ||
        chatMessageData.docFile != null) {
      messageType = 3;
    } else if (chatMessageData.text != null && chatMessageData.text != "") {
      messageType = 0;

      /// video
      if (checkURLRegex(chatMessageData.text)) {
        try {
          _videoPlayerController =
              VideoPlayerController.network(chatMessageData.text);
          _chewieController = chewie.ChewieController(
            videoPlayerController: _videoPlayerController,
            aspectRatio: 1,
            autoPlay: false,
            looping: false,
            showControls: true,
            deviceOrientationsAfterFullScreen: [
              DeviceOrientation.landscapeRight,
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
            ],
            materialProgressColors: chewie.ChewieProgressColors(
              playedColor: Colors.red,
              handleColor: Colors.blue,
              backgroundColor: Colors.grey,
              bufferedColor: Colors.lightGreen,
            ),
            placeholder: Container(
              color: Colors.grey,
            ),
            autoInitialize: true,
            allowMuting: false,
            showControlsOnInitialize: false,
            allowedScreenSleep: false,
          );
        } catch (e) {}
      }
    } else if ((chatMessageData.voiceNetKey != null &&
            chatMessageData.voiceNetKey != "") ||
        chatMessageData.voiceFile != null) {
      messageType = 2;

      if (chatMessageData.voiceFile == null) {
        /// voice
        String voiceURL;
        if (chatOrChannel == 0) {
          voiceURL = connectionService
              .getChatMessageVoiceURL(chatMessageData.voiceNetKey);
        } else {
          voiceURL = connectionService
              .getChannelMessageVoiceURL(chatMessageData.voiceNetKey);
        }
        try {
          audioPlayer = AudioPlayer();
          audioPlayer.setUrl(voiceURL);
          _durationSubscription =
              audioPlayer.onDurationChanged.listen((Duration d) {
            setState(() {
              _duration = d;
            });
          });

          _positionSubscription =
              audioPlayer.onAudioPositionChanged.listen((Duration d) {
            setState(() {
              _position = d;
              voiceDownloaded = true;
            });
          });
          _playerCompleteSubscription =
              audioPlayer.onSeekComplete.listen((t) {});

          _playerStateSubscription =
              audioPlayer.onPlayerStateChanged.listen((AudioPlayerState s) {
            if (s == AudioPlayerState.COMPLETED) {
              setState(() {
                s = AudioPlayerState.STOPPED;
                _position = Duration(milliseconds: 0);
              });
            }
            setState(() {
              audioStatus = s;
            });
          });
        } catch (e) {}
      }
    }

    if (status == -1) {
      sendMessage();
    }
  }

  @override
  Widget build(BuildContext context) {
    xSize = MediaQuery.of(context).size.width;
    return Material(
      color: Color.fromARGB(0, 0, 0, 0),
      child: InkWell(
        onTap: () {
          setState(() {
            messageOptionToggle = false;
          });
        },
        onLongPress: () {
          setState(() {
            messageOptionToggle = !messageOptionToggle;
          });
        },
        child: new Container(
          key: ValueKey(messageKey + status.toString()),
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          child: new Stack(
            fit: StackFit.passthrough,
            alignment: pos == 1
                ? Alignment.centerRight
                : (pos == -1 ? Alignment.centerLeft : Alignment.center),
            children: <Widget>[
              new Padding(
                padding: EdgeInsets.only(right: 10, left: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: (pos == 1)
                        ? prefix0.Theme.lessonNameBG
                        : prefix0.Theme.cloudyBlue,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(5),
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            getOwnerUserNameText(),
                            getMessageBody(context),
                            getMessageStatus()
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: pos == 0
                    ? MainAxisAlignment.center
                    : (pos == 1
                        ? MainAxisAlignment.center
                        : MainAxisAlignment.center),
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  getMessageSaveDelete(true, true, false),
                  getMessageSaveDelete(false, false, true)
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getMessageSaveDelete(
      bool saveAndDownloadFlag, bool editTextFlag, bool deleteFlag) {
    return AnimatedOpacity(
        duration: Duration(milliseconds: 400),
        opacity: messageOptionToggle ? 1.0 : 0.0,
        child: Visibility(
          visible: messageOptionToggle,
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    color: Color.fromARGB(100, 255, 255, 255),
                    boxShadow: [
                      BoxShadow(
                        color: prefix0.Theme.shadowColor,
                        spreadRadius: prefix0.Theme.spreadRadius,
                        blurRadius: prefix0.Theme.blurRadius,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(children: [
                        saveAndDownloadFlag
                            ? getSaveAndDownloadIcon()
                            : SizedBox(),
                        editTextFlag ? getEditTextMessageIcon() : SizedBox(),
                      ]),
                      deleteFlag ? getDeleteIcon() : SizedBox()
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }

  Widget getSaveAndDownloadIcon() {
    return messageType != 2
        ? GestureDetector(
            child: Container(
              padding: EdgeInsets.all(10),
              child: Icon(
                messageType == 0 ? Icons.content_copy : Icons.save_alt,
                color: Colors.black,
              ),
            ),
            onTap: () {
              if (status == 1) {
                setState(() {
                  messageOptionToggle = false;
                });
                if (messageType == 0) {
                  Clipboard.setData(
                      new ClipboardData(text: chatMessageData.text));
                  showFlutterToastWithFlushBar(copySuccessFull);
                } else if (messageType == 1) {
                  showSaveToFiles(imageProvider, null);
                } else if (messageType == 3) {
                  showSaveToFiles(null, chatMessageData.docNetKey);
                }
              }
            },
          )
        : SizedBox();
  }

  Widget getDeleteIcon() {
    return LSM.getUsernameAuthSync()[0] == chatMessageData.ownerUsername
        ? (GestureDetector(
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  child: deleteMessageLoading
                      ? getButtonLoadingProgress(stroke: 2)
                      : Icon(
                          Icons.delete_outline,
                          color: Colors.black,
                        ),
                )
              ],
            ),
            onTap: () {
              showDeleteAlertDialog();
            },
          ))
        : SizedBox();
  }

  Widget getEditTextMessageIcon() {
    return LSM.getUsernameAuthSync()[0] == chatMessageData.ownerUsername &&
            messageType == 0
        ? (GestureDetector(
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  child: editTextMessageLoading
                      ? getButtonLoadingProgress(stroke: 2)
                      : Icon(
                          Icons.edit,
                          color: Colors.black,
                        ),
                )
              ],
            ),
            onTap: () {
              if (status == 1 && !editTextMessageLoading) {
                setState(() {
                  messageOptionToggle = false;
                });
                try {
                  ChatScreenState chatScreenState =
                      (screenState as ChatScreenState);
                  chatScreenState.chatBottomBar.chatBottomBarState
                      .messageForEdit = chatMessageData;
                  chatScreenState
                      .chatBottomBar
                      .chatBottomBarState
                      .chatController
                      .text = improveMessageStringText(chatMessageData.text);
                  chatScreenState.chatBottomBar.chatBottomBarState
                      .setState(() {});
                } catch (e) {}
                try {
                  ConsultantChannelChatScreenState chatScreenState =
                      (screenState as ConsultantChannelChatScreenState);
                  chatScreenState.chatBottomBar.chatBottomBarState
                      .messageForEdit = chatMessageData;
                  chatScreenState
                      .chatBottomBar
                      .chatBottomBarState
                      .chatController
                      .text = improveMessageStringText(chatMessageData.text);
                  chatScreenState.chatBottomBar.chatBottomBarState
                      .setState(() {});
                } catch (e) {}
              }
            },
          ))
        : SizedBox();
  }

  Widget getOwnerUserNameText() {
    return new Padding(
      padding: EdgeInsets.only(right: 0),
      child: new AutoSizeText(
        chatMessageData.ownerUsername,
        style: prefix0.getTextStyle(10, prefix0.Theme.darkText),
      ),
    );
  }

  Widget getMessageBody(context) {
    Widget w;

    if (messageType == 0) {
      if (!checkURLRegex(chatMessageData.text) ||
          _videoPlayerController == null) {
        w = getTextWidget(chatMessageData.text);
      } else {
        w = getVideoWidget();
      }
    } else if (messageType == 1 || chatMessageData.imageFile != null) {
      w = getImageWidget(chatMessageData.imageNetKey, context);
    } else if (messageType == 2 || chatMessageData.voiceFile != null) {
      w = false ? SizedBox() : getVoiceWidget();
    } else if (messageType == 3 || chatMessageData.docFile != null) {
      w = getFileWidget();
    } else {
      w = Container();
    }

    return w;
  }

  Widget getFileWidget() {
    double voiceIconSize = 40 + xSize * (1.5 / 100);
    Icon icon;
    if (chatMessageData.docFileExt != null &&
        chatMessageData.docFileExt.toLowerCase() == "pdf") {
      icon = Icon(
        Icons.picture_as_pdf,
        color: Colors.red,
        size: voiceIconSize,
      );
    } else {
      icon = Icon(
        Icons.insert_drive_file,
        color: Colors.blue,
        size: voiceIconSize,
      );
    }
    return GestureDetector(
      child: Container(
          width: voiceIconSize,
          height: voiceIconSize,
          decoration: new BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(5),
            ),
          ),
          alignment: Alignment.center,
          child: icon),
      onTap: () {
        if (status == 1) {
          if (!kIsWeb) {
            String docURL;
            if (chatOrChannel == 0) {
              docURL = connectionService
                  .getChatMessageDocURL(chatMessageData.docNetKey);
            } else if (chatOrChannel == 1) {
              docURL = connectionService
                  .getChannelMessageDocURL(chatMessageData.docNetKey);
            }
            openFileWithFileURL(docURL);
          } else {
            showSaveToFiles(null, chatMessageData.docNetKey);
          }
        }
      },
    );
  }

  Widget getVideoWidget() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 250,
              width: 250,
              child: chewie.Chewie(
                controller: _chewieController,
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.all(0),
          child: Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
                border: Border.all(width: 0.3)),
            margin: const EdgeInsets.only(top: 5.0),
            constraints: BoxConstraints(maxWidth: 200 + xSize * (12 / 100)),
            child: getAutoSizedDirectionText(
              chatMessageData.text,
              style: prefix0.getTextStyle(14, prefix0.Theme.darkText),
            ),
          ),
        )
      ],
    );
  }

  Widget getMessageStatus() {
    String dateTime = chatMessageData.time.split(":")[0] +
        " : " +
        chatMessageData.time.split(":")[1];
    dateTime += " - " + chatMessageData.date;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 2, right: 2, top: 4, bottom: 2),
                child: AutoSizeText(
                  dateTime,
                  style:
                      prefix0.getTextStyle(9, prefix0.Theme.greyTimeDateColor),
                ),
              ),
            ]),
        Icon(
          status != 1 ? Icons.access_time : Icons.done,
          size: 13,
        ),
      ],
    );
  }

  Widget getImageWidget(String imageKey, context) {
    String imageURL;
    if (chatOrChannel == 0) {
      imageURL = connectionService.getChatMessageImageURL(imageKey);
    } else if (chatOrChannel == 1) {
      imageURL = connectionService.getChannelMessageImageURL(imageKey);
    }
    if (kIsWeb) {
      imageProvider = NetworkImage(imageURL);
    }

    return GestureDetector(
        child: Container(
          constraints: BoxConstraints(
              maxWidth: 200 + xSize * (12 / 100),
              maxHeight: 300,
              minHeight: 150),
//        height: MediaQuery.of(context).size.width * (45 / 100),
          decoration: new BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          child: status == 1 && imageURL != ""
              ? (cachedImage == null
                  ? getDownloadImageIcon(imageKey, imageURL)
                  : kIsWeb
                      ? Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.fill,
                                  alignment: Alignment.center)),
                        )
                      : cachedImage)
              : Container(),
        ),
        onTap: () {
          if (status == 1) {
            showPhotoViewDialog(imageURL);
          }
        });
  }

  void showDeleteAlertDialog() {
    Widget d = BackdropFilter(
      filter: prefix0.Theme.fragmentBGFilter,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(25),
          ),
        ),
        backgroundColor: prefix0.Theme.settingBg,
        content: Container(
          height: 100,
          width: 100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              AutoSizeText(
                "پیام حذف می شود.آیا مطمینید؟",
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: prefix0.getTextStyle(15, prefix0.Theme.onSettingText1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  MaterialButton(
                    color: prefix0.Theme.warningAndErrorBG,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: saveDownloadLoading
                        ? getButtonLoadingProgress()
                        : AutoSizeText(
                            "حذف",
                            style: prefix0.getTextStyle(
                                15, prefix0.Theme.onWarningAndErrorBG),
                          ),
                    onPressed: () {
                      if (status == 1 && !deleteMessageLoading) {
                        setState(() {
                          deleteMessageLoading = true;
                        });
                        deleteMessage();
                      }
                      Navigator.of(context, rootNavigator: true).pop('dialog');
                    },
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
    showDialog(context: context, child: d, barrierDismissible: true);
  }

  void showPhotoViewDialog(String imageURL) {
    Widget w = Container(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          child: Icon(
            Icons.close,
            size: 40,
            color: prefix0.Theme.greyTimeLine,
          ),
          onTap: () {
            if (status == 1) {
              Navigator.of(context, rootNavigator: true).pop('dialog');
            }
          },
        ),
        Expanded(
          child: Container(
            height: xSize,
            child: PhotoView(
              backgroundDecoration: BoxDecoration(
                color: Color.fromARGB(0, 0, 0, 0),
              ),
              enableRotation: true,
              initialScale: 0.25,
              imageProvider: NetworkImage(imageURL),
            ),
          ),
        ),
      ],
    ));
    Widget d = BackdropFilter(
      filter: prefix0.Theme.fragmentBGFilter,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(25),
          ),
        ),
        backgroundColor: Color.fromARGB(0, 0, 0, 0),
        content: Container(width: xSize, child: w),
      ),
    );
    showDialog(context: context, child: d, barrierDismissible: false);
  }

  Widget getDownloadImageIcon(String imageKey, String imageURL) {
    return GestureDetector(
      child: status == 1
          ? Icon(Icons.cloud_download, size: 30)
          : getButtonLoadingProgress(
              stroke: 2,
            ),
      onTap: () {
        if (status == 1) {
          setState(() {
            cachedImage = CachedNetworkImage(
              errorWidget: (context, url, error) {
                return Text("خظا در دانلود فایل");
              },
              imageBuilder: (context, imageProvider) {
                this.imageProvider = imageProvider;
                return Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
              placeholder: (context, string) {
                return Icon(Icons.image);
              },
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  SizedBox(
                width: 50,
                height: 50,
                child: CircleAvatar(
                  backgroundColor: Color.fromARGB(0, 0, 0, 0),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    value: downloadProgress.progress,
                  ),
                  radius: 30,
                ),
              ),
              fadeInDuration: Duration(milliseconds: 500),
              imageUrl: kIsWeb ? "" : imageURL,
            );
          });
        }
      },
    );
  }

  void showSaveToFiles(ImageProvider imageProvider, String fileURLToken) {
    if (!kIsWeb) {
      Widget d = BackdropFilter(
        filter: prefix0.Theme.fragmentBGFilter,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(25),
            ),
          ),
          backgroundColor: prefix0.Theme.settingBg,
          content: Container(
            height: 100,
            width: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                AutoSizeText(
                  "فایل در پوشه mhamrah ذخیره می شود.",
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: prefix0.getTextStyle(15, prefix0.Theme.onSettingText1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    MaterialButton(
                      color: prefix0.Theme.applyButton,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: saveDownloadLoading
                          ? getButtonLoadingProgress()
                          : AutoSizeText(
                              "ذخیره",
                              style: prefix0.getTextStyle(
                                  15, prefix0.Theme.onApplyButton),
                            ),
                      onPressed: () {
                        if (imageProvider != null) {
                          String imageURL;
                          String folder;
                          if (chatOrChannel == 0) {
                            imageURL = connectionService.getChatMessageImageURL(
                                chatMessageData.imageNetKey);
                            folder = StorageFolders.chatRoomFiles;
                          } else if (chatOrChannel == 1) {
                            imageURL =
                                connectionService.getChannelMessageImageURL(
                                    chatMessageData.imageNetKey);
                            folder = StorageFolders.channelFiles;
                          }

                          String fileName = chatMessageData.time +
                              "_" +
                              chatMessageData.date +
                              " - " +
                              chatMessageData.ownerUsername;

                          downloadAndSaveFileToStorage(
                              imageURL, folder, fileName);
                        } else if (fileURLToken != null && fileURLToken != "") {
                          String docURL;
                          String folder;
                          if (chatOrChannel == 0) {
                            docURL = connectionService.getChatMessageDocURL(
                                chatMessageData.docNetKey);
                            folder = StorageFolders.chatRoomFiles;
                          } else if (chatOrChannel == 1) {
                            docURL = connectionService.getChannelMessageDocURL(
                                chatMessageData.docNetKey);
                            folder = StorageFolders.channelFiles;
                          }
                          String fileName = chatMessageData.time +
                              "_" +
                              chatMessageData.date +
                              " - " +
                              chatMessageData.ownerUsername;
                          fileName = fileName
                              .replaceAll(":", "_")
                              .replaceAll("/", "_");
                          downloadAndSaveFileToStorage(
                              docURL, folder, fileName);
                        }
                      },
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      );
      showDialog(context: context, child: d, barrierDismissible: true);
    }
  }

  Widget getTextWidget(String text) {
    String impText = text.replaceAll("\\n", "\n");
    return new Container(
      margin: const EdgeInsets.only(top: 5.0),
      constraints: BoxConstraints(maxWidth: 200 + xSize * (12 / 100)),
      child: Stack(
        children: [
          getAutoSizedDirectionText(
            impText,
            style: prefix0.getTextStyle(14, prefix0.Theme.darkText),
          ),
        ],
      ),
    );
  }

  Widget getVoiceWidget() {
    return Padding(
      padding: EdgeInsets.all(5),
      child: Row(
        children: <Widget>[getVoicePauseIcon(), getSoundSlider()],
      ),
    );
  }

  Widget getVoicePauseIcon() {
    double voiceIconSize = 40 + xSize * (1.5 / 100);
    return Container(
      width: voiceIconSize,
      height: voiceIconSize,
      decoration: new BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(5),
        ),
      ),
      alignment: Alignment.center,
      child: (audioStatus == AudioPlayerState.PAUSED ||
              audioStatus == AudioPlayerState.STOPPED)
          ? GestureDetector(
              child: status != 1
                  ? getButtonLoadingProgress(stroke: 1)
                  : Icon(
                      Icons.play_arrow,
                      color: prefix0.Theme.blueBR,
                      size: voiceIconSize,
                    ),
              onTap: () {
                if (status == 1) {
//                audioStream.start();
//                audioPlayer.stop();
                  setState(() {
                    voiceDownloaded = true;
                  });
                  audioPlayer.resume().then((status) {
                    setState(() {
                      voiceDownloaded = false;
                      audioStatus = AudioPlayerState.PLAYING;
                    });
                  });
                }
              },
            )
          : (!voiceDownloaded
              ? getButtonLoadingProgress()
              : GestureDetector(
                  child: Icon(
                    Icons.pause,
                    color: prefix0.Theme.titleBar1,
                    size: voiceIconSize,
                  ),
                  onTap: () {
                    if (status == 1) {
//                audioStream.pause();
                      audioPlayer.pause();
                      audioPlayer.release();
                      setState(() {
                        audioStatus = AudioPlayerState.PAUSED;
                      });
                    }
                  },
                )),
    );
  }

  Widget getSoundSlider() {
    return Padding(
      padding: EdgeInsets.all(5),
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          activeTrackColor: prefix0.Theme.greyTimeLine,
          inactiveTrackColor: prefix0.Theme.greyTimeLine,
          trackShape: RoundedRectSliderTrackShape(),
          trackHeight: 5.0,
          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.0),
          thumbColor: prefix0.Theme.mainBG,
          overlayColor: prefix0.Theme.mainBG,
          overlayShape: RoundSliderOverlayShape(overlayRadius: 8.0),
          tickMarkShape: RoundSliderTickMarkShape(),
          activeTickMarkColor: prefix0.Theme.mainBG,
          inactiveTickMarkColor: prefix0.Theme.mainBG,
          valueIndicatorShape: PaddleSliderValueIndicatorShape(),
          valueIndicatorColor: prefix0.Theme.mainBG,
          valueIndicatorTextStyle:
              TextStyle(color: prefix0.Theme.onMainBGText, fontSize: 10),
        ),
        child: Slider(
          value: _position.inSeconds.toDouble(),
          min: 0.0,
          max: _duration.inSeconds.toDouble(),
          divisions: max(_duration.inSeconds, 1),
          label: (_position.inSeconds).toInt().toString(),
          activeColor: prefix0.Theme.mainBG,
          inactiveColor: prefix0.Theme.mainBG,
          onChanged: (double value) {
            setState(() {
              value = value;
              audioPlayer.seek(Duration(seconds: value.toInt()));
              audioPlayer.resume().then((status) {
                setState(() {
                  voiceDownloaded = false;
                  audioStatus = AudioPlayerState.PLAYING;
                });
              });
            });
          },
        ),
      ),
    );
  }

  void deleteMessage() {
    SocketNotifyingData s = SocketNotifyingData();
    if (this.usernames.length == 1 &&
        this.usernames[0] == LSM.getUsernameAuthSync()[0]) {
      s.requestType = "delete_channel_message";
      DeleteChannelMessageSR dcm = DeleteChannelMessageSR();
      dcm.messageKey = chatMessageData.messageNetKey;
      dcm.username = chatMessageData.ownerUsername;
      s.requestData = dcm;
      ConnectionService.sendDataToSocket(this.usernames, s);
    } else {
      s.requestType = "delete_chat_message";
      DeleteChatMessageSR dcm = DeleteChatMessageSR();
      dcm.messageKey = chatMessageData.messageNetKey;
      dcm.username = chatMessageData.ownerUsername;
      s.requestData = dcm;
      ConnectionService.sendDataToSocket(this.usernames, s);
    }
  }

  /// uploading message
  void sendMessage() {
    if (chatMessageData.imageFile != null ||
        chatMessageData.voiceFile != null ||
        chatMessageData.docFile != null) {
      uploadMessageFileThenSendWithSocket();
    } else {
      justSendWithSocketTextMessage();
    }
  }

  void uploadMessageFileThenSendWithSocket() {
    CustomFile file = getChatMessageDataCustomFile();
    ChatMessageData clearedChatMessageData =
        getClearedChatMessageDataFromFiles(chatMessageData);

    if (chatOrChannel == 0) {
      /// chat
      ChatSRV chatSRV = ChatSRV();
      if (userType == 0) {
        LSM.getConsultant().then((consultant) {
          chatSRV
              .submitMessageFile(
                  consultant.username,
                  consultant.authentication_string,
                  clearedChatMessageData,
                  file)
              .then((result) {
            if (result['success']) {
              clearedChatMessageData.messageNetKey =
                  result['serverKey'].toString();

              chatSRV
                  .submitMessageFromSocket(consultant.username,
                      consultant.authentication_string, clearedChatMessageData)
                  .then((status) {});
            }
          });
        });
      } else if (userType == 1) {
        LSM.getStudent().then((student) {
          chatSRV
              .submitMessageFile(student.username,
                  student.authentication_string, clearedChatMessageData, file)
              .then((result) {
            if (result['success']) {
              clearedChatMessageData.messageNetKey =
                  result['serverKey'].toString();

              chatSRV
                  .submitMessageFromSocket(
                      student.parent == ""
                          ? student.username
                          : student.parent + ":" + student.username,
                      student.authentication_string,
                      clearedChatMessageData)
                  .then((status) {});
            }
          });
        });
      }
    } else {
      /// channel
      ChannelSRV channelSRV = ChannelSRV();
      LSM.getConsultant().then((consultant) {
        channelSRV
            .submitMessageToChannelFile(consultant.username,
                consultant.authentication_string, clearedChatMessageData, file)
            .then((result) {
          if (result['success']) {
            clearedChatMessageData.messageNetKey =
                result['serverKey'].toString();
            channelSRV.submitChannelMessageFromSocket(consultant.username,
                consultant.authentication_string, clearedChatMessageData);
          }
        });
      });
    }
  }

  void justSendWithSocketTextMessage() {
    if (chatOrChannel == 0) {
      /// chat
      ChatSRV chatSRV = ChatSRV();
      if (userType == 0) {
        LSM.getConsultant().then((consultant) {
          chatSRV
              .submitMessageFromSocket(consultant.username,
                  consultant.authentication_string, chatMessageData)
              .then((status) {});
        });
      } else if (userType == 1) {
        LSM.getStudent().then((student) {
          chatSRV
              .submitMessageFromSocket(
                  student.parent == ""
                      ? student.username
                      : student.parent + ":" + student.username,
                  student.authentication_string,
                  chatMessageData)
              .then((status) {});
        });
      }
    } else {
      /// channel
      ChannelSRV channelSRV = ChannelSRV();
      LSM.getConsultant().then((consultant) {
        channelSRV.submitChannelMessageFromSocket(consultant.username,
            consultant.authentication_string, chatMessageData);
      });
    }
  }

  CustomFile getChatMessageDataCustomFile() {
    CustomFile file = CustomFile();
    if (chatMessageData.imageFile != null) {
      file.fileNameOrPath = chatMessageData.imageFile.fileNameOrPath;
      file.fileBytes = chatMessageData.imageFile.fileBytes;
    } else if (chatMessageData.voiceFile != null) {
      file.fileNameOrPath = chatMessageData.voiceFile.path;
      file.fileBytes = chatMessageData.voiceFile.readAsBytesSync();
    } else if (chatMessageData.docFile != null) {
      file.fileNameOrPath = chatMessageData.docFile.fileNameOrPath;
      file.fileBytes = chatMessageData.docFile.fileBytes;
    }
    return file;
  }

  ChatMessageData getClearedChatMessageDataFromFiles(
      ChatMessageData chatMessageData) {
    ChatMessageData clearedChatMessageData = chatMessageData.getCopy();
    if (clearedChatMessageData.imageFile != null) {
      clearedChatMessageData.imageFileExt =
          clearedChatMessageData.imageFile.fileNameOrPath.split(".").last;
      clearedChatMessageData.hasImageFile = true;
      clearedChatMessageData.imageFile.fileBytes = null;
    } else if (clearedChatMessageData.voiceFile != null) {
      clearedChatMessageData.voiceFileExt =
          clearedChatMessageData.voiceFile.path.split(".").last;
      clearedChatMessageData.hasVoiceFile = true;
      clearedChatMessageData.voiceFile = null;
    } else if (clearedChatMessageData.docFile != null) {
      clearedChatMessageData.docFileExt =
          clearedChatMessageData.docFile.fileNameOrPath.split(".").last;
      clearedChatMessageData.hasDocFile = true;
      clearedChatMessageData.docFile.fileBytes = null;
    }
    return clearedChatMessageData;
  }

  @override
  void dispose() {
    if (audioPlayer != null) {
      try {
        _durationSubscription?.cancel();
      } catch (e) {}
      try {
        _playerCompleteSubscription?.cancel();
      } catch (e) {}
      try {
        _playerStateSubscription?.cancel();
      } catch (e) {}
      try {
        _playerErrorSubscription?.cancel();
      } catch (e) {}
      try {
        audioPlayer.release();
      } catch (e) {}
      try {
        audioPlayer.dispose();
      } catch (e) {}
    }

    try {
      _videoPlayerController.dispose();
      _chewieController.dispose();
    } catch (e) {}
    try {
      _audioPlayerController.dispose();
      _chewieAudioController.dispose();
    } catch (e) {}

    super.dispose();
  }
}
