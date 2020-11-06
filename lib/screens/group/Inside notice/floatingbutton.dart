import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import 'package:worldetor/screens/group/Inside%20notice/addAttendance.dart';
import 'package:worldetor/screens/group/Inside%20notice/addasignment.dart';
import 'package:worldetor/screens/group/Inside%20notice/live_pages/addlive.dart';
import 'package:worldetor/screens/group/Inside%20notice/addnotice.dart';
import 'package:worldetor/state/currentgroup.dart';

class OurFloatButton extends StatefulWidget {
  @override
  _OurFloatButtonState createState() => _OurFloatButtonState();
}

class _OurFloatButtonState extends State<OurFloatButton> {
  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      animatedIcon: AnimatedIcons.add_event,
      animatedIconTheme: IconThemeData(size: 22),
      visible: true,
      closeManually: false,
      curve: Curves.bounceIn,
      overlayColor: Colors.black,
      overlayOpacity: 0.5,
      backgroundColor: Colors.blue,
      foregroundColor: Colors.black,
      elevation: 8.0,
      shape: CircleBorder(),
      children: [
        SpeedDialChild(
          child: Icon(Icons.assignment),
          backgroundColor: Colors.white70,
          foregroundColor: Colors.black,
          label: "Assignment",
          labelStyle: TextStyle(fontSize: 16),
          onTap: () {
            Widget retval;
            retval = ChangeNotifierProvider(
              create: (context) => CurrentGroup(),
              child: OurAddAssignment(),
            );
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => retval),
            );
            // Navigator.of(context).push(
            //   MaterialPageRoute(builder: (context) => retval),
            // );
          },
        ),
        SpeedDialChild(
          child: Icon(Icons.check_circle),
          backgroundColor: Colors.white70,
          foregroundColor: Colors.black,
          label: "Attendance",
          labelStyle: TextStyle(fontSize: 16),
          onTap: () {
            Widget retval;
            retval = ChangeNotifierProvider(
              create: (context) => CurrentGroup(),
              child: OurAddAttendance(),
            );
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => retval),
            );
            // Navigator.of(context).push(
            //   MaterialPageRoute(
            //     builder: (context) => OurAddAttendance(),
            //   ),
            // );
          },
        ),
        SpeedDialChild(
          child: Icon(Icons.add_alert),
          backgroundColor: Colors.white70,
          foregroundColor: Colors.black,
          label: "Notice",
          labelStyle: TextStyle(fontSize: 16),
          onTap: () {
            Widget retval;
            retval = ChangeNotifierProvider(
              create: (context) => CurrentGroup(),
              child: OurAddNotice(),
            );
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => retval),
            );
            // Navigator.of(context).push(
            //   MaterialPageRoute(
            //     builder: (context) => OurAddNotice(),
            //   ),
            // );
          },
        ),
        SpeedDialChild(
          child: Icon(Icons.video_call),
          backgroundColor: Colors.white70,
          foregroundColor: Colors.black,
          label: "Live",
          labelStyle: TextStyle(fontSize: 16),
          onTap: () {
            Widget retval;
            retval = ChangeNotifierProvider(
              create: (context) => CurrentGroup(),
              child: OurLiveNotice(),
            );
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => retval),
            );
            // Navigator.of(context).push(
            //   MaterialPageRoute(
            //     builder: (context) => OurLiveNotice(),
            //   ),
            // );
          },
        )
      ],
    );
  }
}
