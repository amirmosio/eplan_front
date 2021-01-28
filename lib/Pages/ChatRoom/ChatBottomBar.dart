import 'dart:async';
import 'dart:io';

import 'package:auto_direction/auto_direction.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:mhamrah/ConnectionService/ChannelSRV.dart';
import 'package:mhamrah/ConnectionService/ChatSRV.dart';
import 'package:mhamrah/ConnectionService/HTTPService.dart';
import 'package:mhamrah/Models/ChatMV.dart';
import 'package:mhamrah/Models/SocketNotifingModel.dart';
import 'package:mhamrah/Pages/ChatRoom/ChatScreen.dart';
import 'package:mhamrah/Utils/AutoTextUtils.dart';
import 'package:mhamrah/Utils/LocalFileUtils.dart';
import 'package:mhamrah/Utils/SecurityUtils.dart';
import 'package:mhamrah/Values/Utils.dart';
import 'package:mhamrah/Values/string.dart';
import 'package:mhamrah/Values/style.dart' as prefix0;
import 'package:file_picker/file_picker.dart' as picMob;
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' as io;
import 'package:file/file.dart';

import 'package:path_provider/path_provider.dart';
import 'package:file/local.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'ConsultantChannel/ConsChannelChatScreen.dart';

//import 'package:photo_view/photo_view.dart';

class ChatBottomBar extends StatefulWidget {
  ChatScreenState chatScreenState;
  bool loading = false;
  List<String> messageKeys = [];
  LocalFileSystem localFileSystem;
  final ConsultantChannelChatScreenState consultantChannelChatScreenState;

  ChatBottomBar(this.chatScreenState, this.consultantChannelChatScreenState,
      {this.localFileSystem}) {
    if (localFileSystem == null) {
      localFileSystem = LocalFileSystem();
    }
    chatBottomBarState =
        ChatBottomBarState(chatScreenState, consultantChannelChatScreenState);
  }

  ChatBottomBarState chatBottomBarState;

  @override
  ChatBottomBarState createState() {
    return chatBottomBarState;
  }
}

class ChatBottomBarState extends State<ChatBottomBar>
    with TickerProviderStateMixin {
  ChatSRV chatSRV = ChatSRV();
  ChannelSRV channelSRV = ChannelSRV();
  ChatScreenState chatScreenState;

  ConsultantChannelChatScreenState consultantChannelChatScreenState;

  final TextEditingController chatController = new TextEditingController();
  String chatText;
  int userType = 0;
  ChatMessageData messageForEdit;

  /// voice recorder
  FlutterAudioRecorder _recorder;
  Recording _current;
  RecordingStatus _recorderStatus = RecordingStatus.Stopped;
  io.File voiceFile;
  Timer recorderTimer;

  //// image picker
  /// 0=deactivate and 1=waiting for send or cancel tap
  int filePicketStatus = 0;
  CustomFile attachedFile;

  ChatBottomBarState(
      this.chatScreenState, this.consultantChannelChatScreenState);

  List<String> getUsernames() {
    if (chatScreenState != null) {
      return chatScreenState.usernames;
    } else if (consultantChannelChatScreenState != null) {
      return <String>[consultantChannelChatScreenState.mainConsUsername];
    }
    return <String>[];
  }

  List<ChatMessageData> getMessages() {
    if (chatScreenState != null) {
      return chatScreenState.messagesData;
    } else if (consultantChannelChatScreenState != null) {
      return consultantChannelChatScreenState.messagesData;
    }
    return <ChatMessageData>[];
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _init();
    LSM.getUserMode().then((type) {
      setState(() {
        userType = type;
      });
    });
  }

  void handelAllSubmits(
      String text, CustomFile imageOrDocFile, io.File voiceFile) {
    if (chatScreenState != null) {
      if (imageOrDocFile != null) {
        String fileEXT = imageOrDocFile.fileNameOrPath.split(".").last;
        if (imageFormats.contains(fileEXT)) {
          handleChatRoomSubmit(text, imageOrDocFile, voiceFile, null);
        } else {
          handleChatRoomSubmit(text, null, voiceFile, imageOrDocFile);
        }
      } else {
        /// text
        handleChatRoomSubmit(text, null, voiceFile, null);
      }
    } else if (consultantChannelChatScreenState != null) {
      if (imageOrDocFile != null) {
        String fileEXT = imageOrDocFile.fileNameOrPath.split(".").last;
        if (imageFormats.contains(fileEXT)) {
          handleChannelSubmit(text, imageOrDocFile, voiceFile, null);
        } else {
          handleChannelSubmit(text, null, voiceFile, imageOrDocFile);
        }
      } else {
        handleChannelSubmit(text, null, voiceFile, null);
      }
    }
  }

  void handleChannelSubmit(String text, CustomFile imageFile, io.File voiceFile,
      CustomFile docFile) async {
    ChatMessageData message;
    String currentTimeString = getCurrentTimeString();
    String currentDateString = getCurrentDateString();
    if (text != "") {
      LSM.getConsultant().then((consultant) {
        message = ChatMessageData.messageSubmit(
            consultant.username,
            text,
            imageFile,
            voiceFile,
            docFile,
            [consultantChannelChatScreenState.mainConsUsername],
            currentTimeString,
            currentDateString);
        message.clientRandomKey =
            SecurityAndKeyGeneration.generateRandomString();
        widget.messageKeys.add(message.getMessageKey());
//        sendChannelMessage(message);
        message.status = -1;
        consultantChannelChatScreenState.addAnItemToLast(message);
      });
    }
  }

  void handleChatRoomSubmit(String text, CustomFile imageFile,
      io.File voiceFile, CustomFile docFile) async {
    ChatMessageData message;
    String currentTimeString = getCurrentTimeString();
    String currentDateString = getCurrentDateString();

    if (userType == 1) {
      LSM.getStudent().then((student) {
        message = ChatMessageData.messageSubmit(
            student.parent == ""
                ? student.username
                : student.parent + ":" + student.username,
            text,
            imageFile,
            voiceFile,
            docFile,
            getUsernames(),
            currentTimeString,
            currentDateString);
        message.clientRandomKey =
            SecurityAndKeyGeneration.generateRandomString();
        widget.messageKeys.add(message.getMessageKey());
//        sendChatRoomMessage(message);
        message.status = -1;
        chatScreenState.addAnItemToLast(message);
      });
    } else if (userType == 0) {
      LSM.getConsultant().then((consultant) {
        message = ChatMessageData.messageSubmit(
            consultant.username,
            text,
            imageFile,
            voiceFile,
            docFile,
            getUsernames(),
            currentTimeString,
            currentDateString);
        message.clientRandomKey =
            SecurityAndKeyGeneration.generateRandomString();

        widget.messageKeys.add(message.getMessageKey());
//        sendChatRoomMessage(message);
        message.status = -1;
        chatScreenState.addAnItemToLast(message);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new AnimatedContainer(
        decoration: BoxDecoration(
            color: prefix0.Theme.mildGrey,
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(this.messageForEdit == null ? 0 : 25),
                topLeft:
                    Radius.circular(this.messageForEdit == null ? 0 : 25))),
        duration: Duration(milliseconds: 200),
        child: Column(
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 200),
              height: this.messageForEdit != null ? 70 : 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        child: Container(
                          padding: EdgeInsets.all(10),
                          child: getAutoSizedDirectionText("ویرایش متن"),
                        ),
                        onTap: () {
                          setState(() {
                            this.messageForEdit = null;
                          });
                        },
                      ),
                      GestureDetector(
                        child: Container(
                          padding: EdgeInsets.all(10),
                          child: Icon(Icons.close),
                        ),
                        onTap: () {
                          setState(() {
                            this.messageForEdit = null;
                          });
                        },
                      )
                    ],
                  ),
                  Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        (messageForEdit ?? ChatMessageData()).text ?? "",
                        style: prefix0.getTextStyle(
                          15,
                          Colors.black,
                        ),
                        softWrap: true,
                        overflow: TextOverflow.fade,
                        maxLines: 1,
                      ))
                ],
              ),
            ),
            new AnimatedSize(
              duration: Duration(milliseconds: 80),
              vsync: this,
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  _recorderStatus == RecordingStatus.Paused ||
                          filePicketStatus == 1
                      ? new Container(
                          padding: EdgeInsets.all(2),
                          child: new IconButton(
                            icon: new Icon(
                              Icons.delete_outline,
                              color: prefix0.Theme.titleBar1,
                            ),
                            onPressed: () {
                              cancelVoiceOrImage();
                            },
                          ),
                        )
                      : (_recorderStatus == RecordingStatus.Stopped
                          ? new Container(
                              padding: EdgeInsets.all(2),
                              child: new IconButton(
                                icon: new Icon(
                                  kIsWeb ? Icons.image : Icons.attach_file,
                                  color: prefix0.Theme.blueIcon,
                                ),
                                onPressed: () {
                                  chatController.text = "";
                                  attachFile();
                                },
                              ),
                            )
                          : SizedBox(
                              width: 10,
                            )),

                  //// textfeild
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: new Container(
                        decoration: new BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                            color: filePicketStatus == 1
                                ? prefix0.Theme.ttTransWhiteText
                                : Color.fromARGB(150, 200, 200, 200)),
                        padding: EdgeInsets.fromLTRB(5, 5, 5, 9),
                        alignment: Alignment.topRight,
                        child: AutoDirection(
                          text: chatText == null || chatText == ""
                              ? "g"
                              : chatText,
                          child: TextField(
                            style: TextStyle(fontSize: 18, height: 1.5),
                            enabled: filePicketStatus == 0,
//                    textAlign: TextAlign.end,
//                    textDirection: TextDirection.ltr,
                            maxLines: 4,
                            minLines: 1,
                            onChanged: (value) {
                              setState(() {
                                chatText = value;
                              });
                            },
                            decoration: new InputDecoration.collapsed(
                              hintText: filePicketStatus == 1
                                  ? " File Or Image"
                                  : (_recorderStatus != RecordingStatus.Stopped
                                      ? " Voice"
                                      : " Type here"),
                            ),
                            controller: chatController,
                          ),
                        ),
                      ),
                    ),
                  ),

                  _recorderStatus != RecordingStatus.Recording ||
                          filePicketStatus == 1
                      ? new Container(
                          padding: EdgeInsets.all(2),
                          child: new IconButton(
                            icon: new Icon(
                              Icons.send,
                              color: prefix0.Theme.blueIcon,
                            ),
                            onPressed: () {
                              /// sending text or image
                              if (messageForEdit != null) {
                                editTextMessage();
                              } else {
                                sendTextOrImageOrVoice();
                              }
                            },
                          ),
                        )
                      : SizedBox(),

                  filePicketStatus == 1
                      ? SizedBox()
                      : _recorderStatus == RecordingStatus.Stopped
                          ? Container(
                              padding: EdgeInsets.all(2),
                              child: kIsWeb
                                  ? SizedBox()
                                  : new IconButton(
                                      icon: new Icon(
                                        Icons.keyboard_voice,
                                        color: prefix0.Theme.blueIcon,
                                      ),
                                      onPressed: () {
                                        chatController.text = "";
                                        if (!kIsWeb) {
                                          /// start recording
                                          print("#########");
                                          print(filePicketStatus);
                                          print(_recorderStatus);
                                          startRecording();
                                        }
                                      },
                                    ),
                            )
                          : _recorderStatus == RecordingStatus.Recording
                              ? Container(
                                  padding: EdgeInsets.all(2),
                                  child: new IconButton(
                                    icon: new Icon(
                                      Icons.stop,
                                      color: prefix0.Theme.redBright,
                                    ),
                                    onPressed: () {
                                      chatController.text = "";

                                      /// pause recording;
                                      pauseRecording();
                                    },
                                  ),
                                )
                              : SizedBox(),
                ],
              ),
            ),
          ],
        ));
  }

  Widget getLoadingProgress() {
    return Container(
      padding: EdgeInsets.all(5),
      child: CircularProgressIndicator(
        valueColor: new AlwaysStoppedAnimation<Color>(prefix0.Theme.blueIcon),
      ),
      width: 50,
      height: 50,
    );
  }

  void sendTextOrImageOrVoice() {
    bool flag = false;
    if (filePicketStatus == 1) {
      handelAllSubmits(null, attachedFile, null);
      flag = true;
    } else if (_recorderStatus == RecordingStatus.Paused) {
      setState(() {
        _recorderStatus = RecordingStatus.Stopped;
      });
      _stop().then((voiceFile) {
        handelAllSubmits(null, null, voiceFile);
      });
      flag = true;
    } else if (chatController.text != "") {
      handelAllSubmits(chatController.text, null, null);
      chatController.clear();
      flag = true;
    }
    if (flag) {
      setState(() {
        filePicketStatus = 0;
        _recorderStatus = RecordingStatus.Stopped;
      });
    }
  }

  void editTextMessage() {
    SocketNotifyingData s = SocketNotifyingData();

    if (chatScreenState != null) {
      s.requestType = "edit_chat_text_message";
      EditChatTextMessageSR dcm = EditChatTextMessageSR();
      dcm.messageKey = this.messageForEdit.messageNetKey;
      dcm.username = LSM.getUsernameAuthSync()[0];
      dcm.newText = chatController.text;
      s.requestData = dcm;
      ConnectionService.sendDataToSocket(chatScreenState.usernames, s)
          .then((value) {
        setState(() {
          chatController.text = "";
          this.messageForEdit = null;
        });
      });
    } else {
      s.requestType = "edit_channel_text_message";
      EditChannelTextMessageSR dcm = EditChannelTextMessageSR();
      dcm.messageKey = this.messageForEdit.messageNetKey;
      dcm.username = LSM.getUsernameAuthSync()[0];
      dcm.newText = chatController.text;
      s.requestData = dcm;
      ConnectionService.sendDataToSocket(
              [consultantChannelChatScreenState.mainConsUsername], s)
          .then((value) {
        setState(() {
          chatController.text = "";
          this.messageForEdit = null;
        });
      });
    }
  }

  void cancelVoiceOrImage() {
    setState(() {
      voiceFile = null;
      attachedFile = null;
      filePicketStatus = 0;
      _recorderStatus = RecordingStatus.Stopped;
    });
  }

  /// Image

  Future picFileFromFiles() async {
    final file = await picMob.FilePicker.getFile(
      type: picMob.FileType.custom,
//      allowedExtensions: [
//            'pdf',
//            'doc',
//          ] +
//          imageFormats,
    );

    if (file != null) {
      attachedFile = CustomFile();
      attachedFile.fileNameOrPath = file.path;
      attachedFile.fileBytes = file.readAsBytesSync();
      setState(() {
        filePicketStatus = 1;
        _recorderStatus = RecordingStatus.Stopped;
      });
    }
  }

  Future attachFile() async {
    final cameraImageSource = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(25),
          ),
        ),
        backgroundColor: prefix0.Theme.settingBg,
        content: Container(
          height: 80,
          width: 150,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              AutoSizeText(
                "منبع را انتخاب کنید.",
                textDirection: TextDirection.rtl,
                style: prefix0.getTextStyle(15, prefix0.Theme.darkText),
              ),
              Row(
                mainAxisAlignment: kIsWeb
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  kIsWeb
                      ? SizedBox()
                      : MaterialButton(
                          child: AutoSizeText(
                            "دوربین",
                            style: prefix0.getTextStyle(
                                15, prefix0.Theme.darkText),
                          ),
                          onPressed: () =>
                              Navigator.pop(context, ImageSource.camera)),
                  MaterialButton(
                    child: AutoSizeText(
                      "فایل",
                      style: prefix0.getTextStyle(15, prefix0.Theme.darkText),
                    ),
                    onPressed: () {
                      chatController.text = "";
                      if (kIsWeb) {
                        /// web
//                        ImagePickerWeb.getImageInfo.then((mediaData) {
//                          Navigator.maybePop(context);
//
//                          if (mediaData != null) {
//                            attachedFile = CustomFile();
//                            attachedFile.fileBytes = mediaData.data;
//                            attachedFile.fileNameOrPath = mediaData.fileName;
//                            setState(() {
//                              filePicketStatus = 1;
//                              _recorderStatus = RecordingStatus.Stopped;
//                            });
//                          }
//                        });
                      } else {
                        picFileFromFiles();
                        Navigator.pop(context, null);
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
    if (cameraImageSource != null) {
      io.File file = await ImagePicker.pickImage(source: cameraImageSource);
      if (file != null) {
        attachedFile = CustomFile();
        attachedFile.fileNameOrPath = file.path;
        attachedFile.fileBytes = file.readAsBytesSync();
        setState(() {
          filePicketStatus = 1;
          _recorderStatus = RecordingStatus.Stopped;
        });
      }
    } else {}
  }

  /// Voice
  void startRecording() {
    setState(() {
      filePicketStatus = 0;
      _recorderStatus = RecordingStatus.Recording;
    });
    _start();

    /// todo
  }

  void pauseRecording() async {
    setState(() {
      filePicketStatus = 0;
      _recorderStatus = RecordingStatus.Paused;
    });

    await _recorder.pause();
    setState(() {});
  }

  _init() async {
    try {
      if (await FlutterAudioRecorder.hasPermissions) {
        String customPath = '/flutter_audio_recorder_';
        io.Directory appDocDirectory;
//        io.Directory appDocDirectory = await getApplicationDocumentsDirectory();
        if (io.Platform.isIOS) {
          appDocDirectory = await getApplicationDocumentsDirectory();
        } else {
          appDocDirectory = await getExternalStorageDirectory();
        }

        // can add extension like ".mp4" ".wav" ".m4a" ".aac"
        customPath = appDocDirectory.path +
            customPath +
            DateTime.now().millisecondsSinceEpoch.toString();

        // .wav <---> AudioFormat.WAV
        // .mp4 .m4a .aac <---> AudioFormat.AAC
        // AudioFormat is optional, if given value, will overwrite path extension when there is conflicts.
        _recorder =
            FlutterAudioRecorder(customPath, audioFormat: AudioFormat.WAV);

        await _recorder.initialized;
        // after initialization
        var current = await _recorder.current(channel: 0);
        // should be "Initialized", if all working fine
        setState(() {
          _current = current;
          _recorderStatus = current.status;
          _recorderStatus = RecordingStatus.Stopped;
        });
      } else {
        Scaffold.of(context).showSnackBar(
            new SnackBar(content: new Text("You must accept permissions")));
      }
    } catch (e) {
    }
  }

  _start() async {
    try {
      await _recorder.start();
//      var recording = await _recorder.current(channel: 0);
//      setState(() {
//        _current = recording;
//      });

      const tick = const Duration(milliseconds: 50);
      recorderTimer = new Timer.periodic(tick, (Timer t) {
        if (_recorderStatus == RecordingStatus.Stopped ||
            _recorderStatus == RecordingStatus.Paused) {
          t.cancel();
        }

//        var current = _recorder.current(channel: 0).then((current) {
//          setState(() {
//            _current = current;
//            _recorderStatus = _current.status;
//          });
//        });
      });
    } catch (e) {}
  }

  Future<File> _stop() async {
    var result = await _recorder.stop();
    print("Stop recording: ${result.path}");
    print("Stop recording: ${result.duration}");
    File file = widget.localFileSystem.file(result.path);
    return file;
  }

  @override
  void dispose() {
    try {
      recorderTimer.cancel();
    } catch (Exception) {}
    super.dispose();
  }
}
