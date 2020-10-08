import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:worldetor/models/group.dart';
import 'package:worldetor/models/notice.dart';
import 'package:worldetor/models/user.dart';

class OurDatabase {
  final Firestore _firestore = Firestore.instance;

  Future<String> createUser(OurUser user) async {
    String retval = "Error";
    try {
      await _firestore.collection("users").document(user.uid).setData({
        'fullName': user.fullName,
        'email': user.email,
        'uniqueId': user.uniqueId,
        'accountCreated': Timestamp.now(),
      });
      retval = "Success";
    } catch (e) {
      print(e);
    }
    return retval;
  }

  Future<String> createGroup(String groupName, String description,
      String userUid, String fullName, String email, String uniqueId) async {
    String retval = "Error";
    List<String> members = List();

    List<String> groupIdList = List();

    try {
      members.add(userUid);
      DocumentReference _docref = await _firestore.collection("groups").add({
        'name': groupName,
        'leader': userUid,
        'members': members,
        'Description': description,
        'groupcreated': Timestamp.now(),
      });
      groupIdList.add(_docref.documentID);

      await _firestore
          .collection("users")
          .document(userUid)
          .updateData({'groupId': _docref.documentID});

      await _firestore
          .collection("users")
          .document(userUid)
          .updateData({'listgroup': FieldValue.arrayUnion(groupIdList)});
      groupmemberinfo(_docref.documentID, userUid, fullName, email, uniqueId);
      retval = "Success";
    } catch (e) {
      print(e);
    }
    return retval;
  }

  Future<String> joinGroup(String groupId, String userUid, String fullName,
      String email, String uniqueId) async {
    String retval = "Error";
    List<String> members = List();

    List<String> groupIdList = List();
    try {
      members.add(userUid);

      groupIdList.add(groupId);

      await _firestore
          .collection("groups")
          .document(groupId)
          .updateData({'members': FieldValue.arrayUnion(members)});

      await _firestore.collection("users").document(userUid).updateData({
        'groupId': groupId,
      });

      await _firestore
          .collection("users")
          .document(userUid)
          .updateData({'listgroup': FieldValue.arrayUnion(groupIdList)});
      groupmemberinfo(groupId, userUid, fullName, email, uniqueId);
      retval = "Success";
    } catch (e) {
      print(e);
    }
    return retval;
  }

  Future<String> openGroup(
    String groupId,
    String userUid,
  ) async {
    String retval = "Error";
    List<String> members = List();

    try {
      members.add(userUid);
      await _firestore
          .collection("groups")
          .document(groupId)
          .updateData({'members': FieldValue.arrayUnion(members)});

      await _firestore.collection("users").document(userUid).updateData({
        'groupId': groupId,
      });
      // groupmemberinfo(groupId, userUid, fullName, email);
      retval = "Success";
    } catch (e) {
      print(e);
    }
    return retval;
  }

  Future<OurUser> getUserInfo(String userId) async {
    OurUser retval = OurUser();
    try {
      DocumentSnapshot _docSnapshot =
          await _firestore.collection("users").document(userId).get();
      retval.uid = userId;
      retval.fullName = _docSnapshot.data["fullName"];
      retval.email = _docSnapshot.data["email"];
      retval.uniqueId = _docSnapshot.data["uniqueId"];
      retval.accountCreated = _docSnapshot.data["accountCreated"];
      retval.groupid = _docSnapshot.data["groupId"];
      retval.listGroup = List<String>.from(_docSnapshot.data["listgroup"]);
    } catch (e) {
      print(e);
    }
    return retval;
  }

  Future<OurGroup> getGroupInfo(String groupId) async {
    OurGroup retval = OurGroup();
    try {
      DocumentSnapshot _docSnapshot =
          await _firestore.collection("groups").document(groupId).get();
      retval.id = groupId;
      retval.name = _docSnapshot.data["name"];
      retval.leader = _docSnapshot.data["leader"];
      retval.description = _docSnapshot.data["Description"];
      retval.members = List<String>.from(_docSnapshot.data["members"]);
      retval.groupCreated = _docSnapshot.data["groupCreated"];
      retval.currentAssignmentsenderid =
          _docSnapshot.data["currentAssignmentSenderid"];
      retval.currentNoticeid = _docSnapshot.data["currentNoticeid"];
      retval.currentNoticeid = _docSnapshot.data["currentNoticeid"];
    } catch (e) {
      print(e);
    }
    return retval;
  }

  Future<String> removeNotice(String groupId, String noticeId) async {
    String retval = "Error";

    try {
      await _firestore
          .collection("groups")
          .document(groupId)
          .collection("notice")
          .document(noticeId)
          .delete();

      retval = "Success";
    } catch (e) {
      print(e);
    }
    return retval;
  }

  Future<String> openNotice(String groupId, String noticeId) async {
    String retval = "Error";
    // List<String> members = List();

    try {
      await _firestore.collection("groups").document(groupId).updateData({
        "currentNoticeid": noticeId,
        // "currentNoticeDue": notice.datecompleted,
      });

      retval = "Success";
    } catch (e) {
      print(e);
    }
    return retval;
  }

  Future<String> addnotice(String groupId, OurNotice notice) async {
    String retval = "Error";
    try {
      DocumentReference _docref = await _firestore
          .collection("groups")
          .document(groupId)
          .collection("notice")
          .add({
        // 'noticeid': _docref.documentID,
        'name': notice.name,
        'point': notice.point,
        'datecompleted': notice.datecompleted,
        'subject': notice.subject,
        'description': notice.description,
        'noticetype': notice.noticetype,
        'datesend': Timestamp.now(),
        //  'accountCreated': Timestamp.now(),
      });

      await _firestore.collection("groups").document(groupId).updateData({
        "currentNoticeid": _docref.documentID,
        "currentNoticeDue": notice.datecompleted,
      });
      retval = "Success";
    } catch (e) {
      print(e);
    }
    return retval;
  }

  Future<OurNotice> getCurrentNotice(String groupId, String noticeId) async {
    OurNotice retval = OurNotice();
    try {
      DocumentSnapshot _docSnapshot = await _firestore
          .collection("groups")
          .document(groupId)
          .collection("notice")
          .document(noticeId)
          .get();
      retval.id = noticeId;
      retval.name = _docSnapshot.data["name"];
      retval.point = _docSnapshot.data["point"];
      retval.datecompleted = _docSnapshot.data["datecompleted"];
      retval.datesend = _docSnapshot.data["datesend"];
      retval.noticetype = _docSnapshot.data["noticetype"];
      retval.description = _docSnapshot.data["description"];
      retval.subject = _docSnapshot.data["subject"];

      retval.attendynames =
          List<String>.from(_docSnapshot.data["attendynames"]);
    } catch (e) {
      print(e);
    }
    return retval;
  }

  Future<String> groupmemberinfo(String groupId, String userId, String fullName,
      String email, String uniqueId) async {
    String retval = "Error";
    try {
      await _firestore
          .collection("groups")
          .document(groupId)
          .collection("groupTotalAttendance")
          .document(uniqueId)
          .setData({
        //  'id': _docref.documentID,
        "Name": fullName,
      });

      await _firestore
          .collection("groups")
          .document(groupId)
          .collection("group_member")
          .document(userId)
          .setData({
        //  'id': _docref.documentID,
        'name': fullName,
        'uniqueId': uniqueId,
        'point': 0,
        'email': email,
        'attend': 0,
      });

      retval = "Success";
    } catch (e) {
      print(e);
    }
    return retval;
  }

  Future<String> sendAssignment(String groupId, String noticeId, String uid,
      String userName, String review, List urlString, List fileNmae) async {
    String retval = "Error";
    try {
      await _firestore
          .collection("groups")
          .document(groupId)
          .collection("notice")
          .document(noticeId)
          .collection("assignment")
          .document(uid)
          .setData({
        "review": review,
        "userName": userName,
        "fileUrl": FieldValue.arrayUnion(urlString),
        "fileName": FieldValue.arrayUnion(fileNmae),
      });
    } catch (e) {
      print(e);
    }
    return retval;
  }

  Future<bool> isUserdoneAssignment(
    String groupId,
    String noticeId,
    String uid,
  ) async {
    bool retval = false;
    try {
      DocumentSnapshot _docsnapshot = await _firestore
          .collection("groups")
          .document(groupId)
          .collection("notice")
          .document(noticeId)
          .collection("assignment")
          .document(uid)
          .get();
      if (_docsnapshot.exists) {
        retval = true;
      }
    } catch (e) {
      print(e);
    }
    return retval;
  }

  Future<String> getattandance(
      String groupId, String noticeId, String sendername, String userid) async {
    String retval = "Error";
    try {
      List<String> names = List();
      List<String> uid = List();
      names.add(sendername);
      uid.add(userid);
      await _firestore
          .collection("groups")
          .document(groupId)
          .collection("notice")
          .document(noticeId)
          .updateData({
        'attendynames': FieldValue.arrayUnion(names),
        'attendyid': FieldValue.arrayUnion(uid),
      });
      retval = "Success";
    } catch (e) {
      print(e);
    }
    return retval;
  }

  Future<String> groupTotalAttendance(
      String groupId, String uniqueID, String date) async {
    String retval = "Error";
    try {
      await _firestore
          .collection("groups")
          .document(groupId)
          .collection("groupTotalAttendance")
          .document(uniqueID)
          .updateData({
        //  'id': _docref.documentID,
        date: "present",
      });

      retval = "Success";
    } catch (e) {
      print(e);
    }
    return retval;
  }
}
