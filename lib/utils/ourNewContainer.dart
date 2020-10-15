import 'package:flutter/material.dart';

class OurNewcontener extends StatelessWidget {
  final Widget child;

  const OurNewcontener({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // List _colors = [
    //   // Colors.white,
    //   // Colors.blueAccent[200],
    //   Colors.cyanAccent[100],
    // ];
    return Container(
      // padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
          // color: (_colors..shuffle()).first,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
                color: Colors.grey,
                blurRadius: 5.0,
                spreadRadius: 5.0,
                offset: Offset(
                  3,
                  3,
                )),
          ]),
      child: child,
    );
  }
}
