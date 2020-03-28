import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'chatmessage.dart';

class ChatScreen extends StatefulWidget {
  final String username;
  final WebSocketChannel channel;

  ChatScreen({Key key, @required this.username, @required this.channel});

  @override
  State createState() => new ChatScreenState(username, channel);
}

class ChatScreenState extends State<ChatScreen> {
  String name;
  WebSocketChannel channel;
  final TextEditingController _chatController = new TextEditingController();
  final List<ChatMessage> _messages = <ChatMessage>[
    new ChatMessage(
        text: "Oh!Just working around...", name: "Mostafa", receiveSent: false),
    new ChatMessage(
        text: "What are you doing?", name: "You", receiveSent: true),
    new ChatMessage(text: "Hi", name: "Mostafa", receiveSent: false),
    new ChatMessage(text: "Hello", name: "You", receiveSent: true),
  ];

  ChatScreenState(this.name, this.channel);

  void _handleSubmit(String text) {
    _chatController.clear();
    ChatMessage message =
        new ChatMessage(text: text, name: "You", receiveSent: true);
    setState(() {
      _messages.insert(0, message);
    });
    widget.channel.sink.add(text);
    print("sent" + text);
  }

  void _handleReceive(String text) async {
    ChatMessage message =
        new ChatMessage(text: text, name: name, receiveSent: false);
    setState(() {
      _messages.insert(0, message);
    });
  }

  Widget _chatEnvironment() {
    return IconTheme(
      data: new IconThemeData(color: Colors.blue),
      child: new Container(
          color: Color.fromARGB(50, 20, 50, 150),
          child: new Container(
            child: new Row(
              children: <Widget>[
                new Flexible(
                    child: new Container(
                        padding: EdgeInsets.fromLTRB(15, 10, 10, 10),
                        child: new TextField(
                          decoration: new InputDecoration.collapsed(
                              hintText: "Starts typing ..."),
                          controller: _chatController,
                          onSubmitted: _handleSubmit,
                        ))),
                new Container(
                  padding: EdgeInsets.all(5),
                  child: new IconButton(
                    icon: new Icon(Icons.send),
                    onPressed: () => _handleSubmit(_chatController.text),
                  ),
                )
              ],
            ),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        new Flexible(
          child: ListView.builder(
            padding: new EdgeInsets.all(8.0),
            reverse: true,
            itemBuilder: (_, int index) => _messages[index],
            itemCount: _messages.length,
          ),
        ),
//        StreamBuilder(
//          stream: widget.channel.stream,
//          builder: (context, snapshot) {
//            print(snapshot.hasData);
//            if (snapshot.hasData) {
//              _handleReceive('${snapshot.data}');
//            }
//            return new SizedBox(width: 0, height: 0);
//          },
//        ),
        new Container(
          decoration: new BoxDecoration(
            color: Theme.of(context).cardColor,
          ),
          child: _chatEnvironment(),
        )
      ],
    );
  }

  @override
  void dispose() {
    widget.channel.sink.close();
    super.dispose();
  }
}
