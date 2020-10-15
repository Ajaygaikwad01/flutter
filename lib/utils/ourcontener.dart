import 'package:flutter/material.dart';

class Ourcontener extends StatelessWidget {
  final Widget child;

  const Ourcontener({Key key, this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.0),
          boxShadow: [
            BoxShadow(
                color: Colors.grey,
                blurRadius: 9.0,
                spreadRadius: 5.0,
                offset: Offset(
                  6.0,
                  3.5,
                )),
          ]),
      child: child,
    );
  }
}
