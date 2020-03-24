import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  final String text;
  final String name;
  final bool receiveSent; //true means we received it and vise versa
// constructor to get text from textfield
  ChatMessage(
      {@required this.text, @required this.name, @required this.receiveSent});

  @override
  Widget build(BuildContext context) {
    return new Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        alignment: receiveSent ? Alignment.bottomRight : Alignment.bottomLeft,
        child: new Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            !receiveSent
                ? new Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                    child: new CircleAvatar(
                      child: new Image.network(
                          "http://res.cloudinary.com/kennyy/image/upload/v1531317427/avatar_z1rc6f.png"),
                    ),
                  )
                : new SizedBox(
                    width: 0,
                    height: 0,
                  ),
            new Container(
              padding: EdgeInsets.all(10),
              decoration: new BoxDecoration(
                  color: receiveSent ? Colors.blue : Colors.blueGrey,
                  borderRadius: new BorderRadius.all(Radius.circular(10))),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Text(name, style: Theme.of(context).textTheme.subhead),
                  new Container(
                    margin: const EdgeInsets.only(top: 5.0),
                    child: new Text(text),
                  )
                ],
              ),
            )
          ],
        ));
  }
}
