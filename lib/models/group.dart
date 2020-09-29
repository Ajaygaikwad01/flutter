import 'package:cloud_firestore/cloud_firestore.dart';

class OurGroup {
  String id;
  String name;
  String leader;
  String description;
  List<String> members;
  Timestamp groupCreated;
  String currentNoticeid;
  Timestamp currentNoticeDue;

  OurGroup({
    this.id,
    this.name,
    this.leader,
    this.description,
    this.members,
    this.groupCreated,
    this.currentNoticeid,
    this.currentNoticeDue,
  });
}
