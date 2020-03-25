import 'package:eplanfront/Values/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FadeInButton extends StatefulWidget {
  final text;
  final func;
  final List margin;
  final _controller;

  FadeInButton(this.text, this.func, this.margin, this._controller);

  @override
  _FadeInButtonState createState() =>
      _FadeInButtonState(text, func, margin, _controller);
}

class _FadeInButtonState extends State<FadeInButton>
    with SingleTickerProviderStateMixin {
  final text;
  final func;
  final List margin;
  final AnimationController _controller;
  Animation _animation;
  CurvedAnimation _curve;

  _FadeInButtonState(this.text, this.func, this.margin, this._controller);

  @override
  void initState() {
    _curve = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _animation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(_curve);

    _animation.addStatusListener((status) {
      if (status == AnimationStatus.completed)
        _controller.reverse();
      else if (status == AnimationStatus.dismissed) _controller.forward();
    });

    super.initState();
  }

  AnimationController getButtonController() {
    return _controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
        opacity: _animation,
        child: new Container(
          decoration: new BoxDecoration(
              borderRadius: new BorderRadius.all(Radius.circular(20))),
          child: new Padding(
            padding: EdgeInsets.fromLTRB(20.0, margin[0], 20.0, margin[1]),
            child: SizedBox(
              width: double.infinity,
              height: 45,
              child: new RaisedButton(
                color: Colors.white,
                onPressed: func,
                child: getButtonText(text),
              ),
            ),
          ),
        )
    );
  }

  Text getButtonText(String text) {
    return Text(text, textDirection: TextDirection.ltr, style: buttonTextStyle);
  }
}
