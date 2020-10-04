import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:worldetor/screens/group/Inside%20notice/noticepage.dart';
import 'package:worldetor/screens/group/chatpage.dart';
import 'package:worldetor/screens/group/memberllist.dart';

class GroupNavigator extends StatefulWidget {
  @override
  _GroupNavigatorState createState() => _GroupNavigatorState();
}

class _GroupNavigatorState extends State<GroupNavigator> {
  int _page = 0;
  final pages = [
    // OurAlartPage(),
    OurNoticePage(),
    OurChatPaage(),
    OurGroupMember(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        index: 0,
        animationCurve: Curves.bounceInOut,
        animationDuration: Duration(microseconds: 150),
        height: 50,
        backgroundColor: Color.fromARGB(255, 213, 235, 220),
        items: <Widget>[
          // Icon(Icons.info, size: 30),
          Icon(Icons.notification_important, size: 30),
          Icon(Icons.chat, size: 30),
          Icon(Icons.people, size: 30),
        ],
        onTap: (index) {
          setState(() {
            _page = index;
          });
        },
      ),
      body: pages[_page],
    );
  }
}
