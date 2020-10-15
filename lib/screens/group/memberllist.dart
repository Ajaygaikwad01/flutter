import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:share/share.dart';
import 'package:worldetor/screens/home/drawer.dart';
import 'package:worldetor/state/currentgroup.dart';
import 'package:worldetor/state/currentuser.dart';

class OurGroupMember extends StatefulWidget {
  @override
  _OurGroupMemberState createState() => _OurGroupMemberState();
}

class _OurGroupMemberState extends State<OurGroupMember> {
  _share(BuildContext context) {
    CurrentGroup _currentgroup =
        Provider.of<CurrentGroup>(context, listen: false);
    var groupname = _currentgroup.getCurrentGroup.name;
    String text = _currentgroup.getCurrentGroup.id;
    String subject = "Group joining invitation from $groupname";
    final RenderBox box = context.findRenderObject();
    Share.share(text,
        subject: subject,
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }

  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();

    CurrentUser _currentuser = Provider.of<CurrentUser>(context, listen: false);
    CurrentGroup _currentgroup =
        Provider.of<CurrentGroup>(context, listen: false);
    _currentgroup.updateSteteFromDatabase(
        _currentuser.getCurrentUser.groupid, _currentuser.getCurrentUser.uid);
  }

  void _deletedialog(userId, groupId) {
    Alert(
      context: context,
      type: AlertType.info,
      title: "Remove",
      desc: "Are you sure? ",
      buttons: [
        DialogButton(
          child: Text(
            "Cancel",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          color: Color.fromRGBO(0, 179, 134, 1.0),
        ),
        DialogButton(
          child: Text(
            "Remove",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            _removemember(userId, groupId);
            Navigator.pop(context);
          },
          gradient: LinearGradient(colors: [
            Color.fromRGBO(116, 116, 191, 1.0),
            Color.fromRGBO(52, 138, 199, 1.0)
          ]),
        )
      ],
    ).show();
  }

  void _removemember(userId, groupId) async {
    await Firestore.instance.collection("users").document(userId).updateData({
      "listgroup": FieldValue.arrayRemove([groupId]),
    });
    await Firestore.instance.collection("groups").document(groupId).updateData({
      "members": FieldValue.arrayRemove([userId]),
    });
    await Firestore.instance
        .collection("groups")
        .document(groupId)
        .collection("group_member")
        .document(userId)
        .delete();
    Scaffold.of(context).showSnackBar(new SnackBar(
        content: new Text("member Removed"), duration: Duration(seconds: 1)));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentGroup>(
        builder: (BuildContext context, value, Widget child) {
      return Scaffold(
        appBar: AppBar(
            title: Text(" Members ", style: TextStyle(color: Colors.white)),
            iconTheme: IconThemeData(color: Colors.white),
            actions: <Widget>[
              Row(
                children: [
                  IconButton(
                      icon: Icon(Icons.share),
                      tooltip: "invite",
                      onPressed: () {
                        _share(context);
                      }),
                  Text("Invite  ",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white)),
                ],
              ),
            ]),
        drawer: OurDrawer(),
        body: StreamBuilder(
            stream: Firestore.instance
                .collection("groups")
                .document(value.getCurrentGroup.id)
                .collection("group_member")
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.data == null) {
                return Container(
                  child: Center(
                    child: Text("Loading...."),
                  ),
                );
              } else {
                if (snapshot.data.documents == null) {
                  return Container(
                    child: Center(
                      child: Text("Loading...."),
                    ),
                  );
                } else {
                  return ListView.builder(
                      itemCount: snapshot.data.documents.length ?? 0,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 2, horizontal: 10),
                          child: Slidable(
                            actionPane: SlidableDrawerActionPane(),
                            actionExtentRatio: 0.30,
                            secondaryActions: <Widget>[
                              IconSlideAction(
                                caption: 'Remove',
                                color: Colors.redAccent,
                                icon: Icons.remove_done,
                                onTap: () {
                                  _deletedialog(
                                      snapshot.data.documents
                                          .elementAt(index)
                                          .documentID,
                                      value.getCurrentGroup.id);
                                },
                              )
                            ],
                            child: Material(
                              child: Ink(
                                color: Colors.white,
                                child: Container(
                                  child: ListTile(
                                    onTap: () {},
                                    leading: // CircleAvatar(
                                        //   backgroundImage: AssetImage(
                                        //       "lib/assets/google_logo.png"),
                                        // ),
                                        Icon(Icons.account_circle),
                                    title: Row(
                                      children: [
                                        Text(
                                            snapshot.data.documents
                                                    .elementAt(index)["name"] ??
                                                "Loading...",
                                            style: TextStyle(fontSize: 15)),
                                        Spacer(),
                                        Text(
                                          "Attend: ${snapshot.data.documents.elementAt(index)["attend"]}" ??
                                              "0",
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold),
                                        )
                                      ],
                                    ),
                                    subtitle: Row(
                                      children: [
                                        Text(
                                            snapshot.data.documents.elementAt(
                                                    index)["email"] ??
                                                "Loading...",
                                            style: TextStyle(fontSize: 12)),
                                        Spacer(),
                                        Text(
                                          "Points: ${snapshot.data.documents.elementAt(index)["point"]}" ??
                                              "0",
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      });
                }
              }
            }),
      );
    });
  }
}
