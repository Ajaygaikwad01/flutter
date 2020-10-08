import 'package:cloud_firestore/cloud_firestore.dart';

class OurUser {
  String uid;
  String email;
  String fullName;
  String uniqueId;
  int point;
  int attend;
  Timestamp accountCreated;
  String groupid;
  List<String> listGroup;
  OurUser({
    this.uid,
    this.email,
    this.fullName,
    this.uniqueId,
    this.point,
    this.attend,
    this.accountCreated,
    this.groupid,
    this.listGroup,
  });
}
