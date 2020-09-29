import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class OurTimeLeft {
  List<String> timeleft(DateTime due) {
    List<String> retval = List(1);

    Duration _timeuntilrleft = due.difference(DateTime.now());
    int _dayUntil = _timeuntilrleft.inDays;
    int _hourUntil = _timeuntilrleft.inHours - (_dayUntil * 24);
    int _minUntil =
        _timeuntilrleft.inMinutes - (_dayUntil * 24 * 60) - (_hourUntil * 60);
    int _secUntil = _timeuntilrleft.inSeconds -
        (_dayUntil * 24 * 60 * 60) -
        (_hourUntil * 60 * 60) -
        (_minUntil * 60);

    if (_secUntil >= 0) {
      retval[0] = _dayUntil.toString() +
          ":" +
          _hourUntil.toString() +
          ":" +
          _minUntil.toString() +
          ":" +
          _secUntil.toString();
      // retval[1] = "--:--";
      // } else if (_dayUntil <= 0 &&
      //     _hourUntil <= 0 &&
      //     _minUntil <= 0 &&
      //     _secUntil <= 0) {
      //   retval[0] = "00:00";
      //   // } else {
      //   //   retval[0] = "00:00";
    }
    return retval;
  }
}
