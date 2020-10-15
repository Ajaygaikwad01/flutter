import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:worldetor/screens/home/home.dart';
import 'package:worldetor/screens/homevideoroom/homeVideoRoom.dart';

class HomeNavigator extends StatefulWidget {
  @override
  _HomeNavigatorState createState() => _HomeNavigatorState();
}

class _HomeNavigatorState extends State<HomeNavigator> {
  int _page = 0;
  final pages = [HomeScreen(), HomeVideoRoom()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        index: 0,
        animationCurve: Curves.bounceInOut,
        animationDuration: Duration(microseconds: 150),
        height: 50,
        backgroundColor: Colors.white70,
        items: <Widget>[
          Icon(Icons.home, size: 30),
          Icon(Icons.video_call, size: 30),
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
