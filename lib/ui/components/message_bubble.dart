import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

const borderRadius = 8.0;

class MessageBubble extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final bool isMe;

  MessageBubble({
    this.text = '',
    this.backgroundColor = Colors.transparent,
    this.isMe = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: <Widget>[
        Material(
          borderRadius: isMe ?
            BorderRadius.only(
              topLeft: Radius.circular(borderRadius),
              topRight: Radius.circular(borderRadius),
              bottomLeft: Radius.circular(borderRadius),
              bottomRight: Radius.circular(0.0),
            ) :
            BorderRadius.only(
              topLeft: Radius.circular(0),
              topRight: Radius.circular(borderRadius),
              bottomLeft: Radius.circular(borderRadius),
              bottomRight: Radius.circular(borderRadius),
            ),
          elevation: 0.0,
          color: isMe ? Theme.of(context).primaryColorDark : Theme.of(context).primaryColor,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              text,
              style: Theme.of(context).textTheme.button,
            ),
          ),
        ),
      ],
    );
  }
}
