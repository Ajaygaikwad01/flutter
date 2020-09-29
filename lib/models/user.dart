import 'package:cloud_firestore/cloud_firestore.dart';

class OurUser {
  String uid;
  String email;
  String fullName;
  Timestamp accountCreated;
  String groupid;
  List<String> listGroup;
  OurUser({
    this.uid,
    this.email,
    this.fullName,
    this.accountCreated,
    this.groupid,
    this.listGroup,
  });
}
