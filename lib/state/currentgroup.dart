// import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:worldetor/models/group.dart';
import 'package:worldetor/models/notice.dart';
import 'package:worldetor/services/database.dart';

class CurrentGroup extends ChangeNotifier {
  OurGroup _currentgroup = OurGroup();
  OurNotice _currentnotice = OurNotice();
  bool _doneWithCurrentAssignment = false;
  OurGroup get getCurrentGroup => _currentgroup;
  OurNotice get getCurrentNotice => _currentnotice;
  bool get getDoneWithCurrentAssignment => _doneWithCurrentAssignment;
  void updateSteteFromDatabase(String groupId, String userId) async {
    try {
      _currentgroup = await OurDatabase().getGroupInfo(groupId);
      _currentnotice = await OurDatabase()
          .getCurrentNotice(groupId, _currentgroup.currentNoticeid);
      _doneWithCurrentAssignment = await OurDatabase()
          .isUserdoneAssignment(groupId, _currentgroup.currentNoticeid, userId);
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<String> finishedAssignment(String uid, String userName, String review,
      List urlString, List fileName) async {
    String retval = "Error";
    try {
      await OurDatabase().sendAssignment(
          _currentgroup.id,
          _currentgroup.currentNoticeid,
          uid,
          userName,
          review,
          urlString,
          fileName);
      _doneWithCurrentAssignment = true;
      notifyListeners();
    } catch (e) {
      print(e);
    }
    return retval;
  }
}
