import 'package:flutter/cupertino.dart';
import 'package:worldetor/models/group.dart';
import 'package:worldetor/models/notice.dart';
import 'package:worldetor/services/database.dart';

class CurrentGroup extends ChangeNotifier {
  OurGroup _currentgroup = OurGroup();
  OurNotice _currentnotice = OurNotice();
  // OurUser _groupmember = OurUser();
  bool _doneWithCurrentAssignment = false;
  // bool _adminAttendanceMrked = false;
  OurGroup get getCurrentGroup => _currentgroup;
  OurNotice get getCurrentNotice => _currentnotice;
  // OurUser get getgroupmember => _groupmember;
  bool get getDoneWithCurrentAssignment => _doneWithCurrentAssignment;
  // bool get getAdminAttendanceMarked => _adminAttendanceMrked;
  void updateSteteFromDatabase(String groupId, String userId) async {
    try {
      _currentgroup = await OurDatabase().getGroupInfo(groupId);
      _currentnotice = await OurDatabase()
          .getCurrentNotice(groupId, _currentgroup.currentNoticeid);
      // _groupmember = await OurDatabase().

      _doneWithCurrentAssignment = await OurDatabase()
          .isUserdoneAssignment(groupId, _currentgroup.currentNoticeid, userId);
      notifyListeners();

      // _adminAttendanceMrked = await OurDatabase()
      //     .isAttendanceMarked(groupId, _currentgroup.currentNoticeid, userId);
      // notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<String> adminMarkedAttendance(String groupId, String indexval,
      String uniqueId, String noticeid, String noticeName) async {
    String retval = "Error";
    try {
      await OurDatabase().markAdminAttandance(
          groupId, indexval, uniqueId, noticeid, noticeName);
      // _adminAttendanceMrked = true;
      // notifyListeners();
    } catch (e) {
      print(e);
    }
    return retval;
  }

  Future<String> adminMarkedAssignment(
    int point,
    String groupId,
    String indexuserId,
    String noticeId,
    String noticeName,
  ) async {
    String retval = "Error";
    try {
      await OurDatabase().markAdminAssignment(
          point, groupId, indexuserId, noticeId, noticeName);
      // _adminAttendanceMrked = true;
      // notifyListeners();
    } catch (e) {
      print(e);
    }
    return retval;
  }

  Future<String> finishedAssignment(String uid, String userName,
      String useruniqueid, String review, List urlString, List fileName) async {
    String retval = "Error";
    try {
      await OurDatabase().sendAssignment(
          _currentgroup.id,
          _currentgroup.currentNoticeid,
          uid,
          userName,
          useruniqueid,
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
