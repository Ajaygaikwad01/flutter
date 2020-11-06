import 'package:cloud_firestore/cloud_firestore.dart';

class OurGroup {
  String id;
  String name;
  String leader;
  String leaderName;
  String description;
  List<String> members;
  List<String> tockens;
  Timestamp groupCreated;
  String currentNoticeid;
  String currentAssignmentsenderid;
  Timestamp currentNoticeDue;

  OurGroup({
    this.id,
    this.name,
    this.leader,
    this.leaderName,
    this.description,
    this.members,
    this.tockens,
    this.groupCreated,
    this.currentNoticeid,
    this.currentAssignmentsenderid,
    this.currentNoticeDue,
  });
}
