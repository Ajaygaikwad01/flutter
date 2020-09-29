import 'package:cloud_firestore/cloud_firestore.dart';

class OurNotice {
  String id;
  String name;
  int point;
  Timestamp datecompleted;
  Timestamp datesend;
  String noticetype;
  String subject;
  String description;
  List<String> attendynames;
  OurNotice({
    this.id,
    this.name,
    this.point,
    this.datecompleted,
    this.datesend,
    this.noticetype,
    this.subject,
    this.description,
    this.attendynames,
  });
}
